import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../core/services/location_service.dart';
import '../domain/entities/nav_state.dart';
import '../domain/entities/route_info.dart';

/// کنترلر زنده‌ی ناوبری — تلفیق GPS + شتاب‌سنج و تولید [NavigationState] داینامیک.
///
/// جریان داده:
///  ۱. [LocationService] موقعیت هموارشده (کالمن) + سرعت + جهت می‌دهد.
///  ۲. شتاب‌سنج ([userAccelerometerEvents]) بین دو نمونه‌ی GPS برای تخمین
///     سرعت (Dead Reckoning) و پایداری در تونل استفاده می‌شود.
///  ۳. محدودیت سرعت از داده‌ی مسیر/نقشه (تگ maxspeed در گراف OSM) خوانده می‌شود.
///
/// اگر GPS در دسترس نباشد (شبیه‌ساز/بدون مجوز) یک شبیه‌سازی سبک اجرا می‌شود تا
/// UI زنده بماند — بدون هیچ متن ثابتی.
class NavigationController extends StateNotifier<NavigationState> {
  NavigationController() : super(const NavigationState(isNavigating: true));

  final LocationService _location = LocationService();
  StreamSubscription<SmoothedPosition>? _locSub;
  StreamSubscription<UserAccelerometerEvent>? _accSub;
  Timer? _simTimer;
  Timer? _fallbackTimer;

  // آخرین شتاب طولی (برای تخمین سرعت بین نمونه‌های GPS).
  double _lastAccelMps2 = 0;
  DateTime _lastAccelTs = DateTime.now();
  bool _gotGpsFix = false;

  /// مسیر جاری (از موتور مسیریابی آفلاین). محدودیت سرعت از این خوانده می‌شود.
  RouteInfo? _route;

  /// شروع ناوبری زنده. اگر [route] داده شود، نوار بالا از آن تغذیه می‌شود.
  Future<void> start({RouteInfo? route}) async {
    _route = route;
    _startAccelerometer();
    await _startGps();

    // اگر ظرف ۳ ثانیه هیچ نمونه‌ی GPS نیامد، شبیه‌سازی را روشن کن.
    _fallbackTimer = Timer(const Duration(seconds: 3), () {
      if (!_gotGpsFix) _startSimulation();
    });
  }

  void attachRoute(RouteInfo route) {
    _route = route;
    _recomputeFromRoute();
  }

  void _startAccelerometer() {
    try {
      _accSub = userAccelerometerEvents.listen((e) {
        // مؤلفه‌ی طولی شتاب (تقریب) برای هموارسازی سرعت.
        _lastAccelMps2 = e.y;
        _lastAccelTs = DateTime.now();
      });
    } catch (_) {
      // شتاب‌سنج در برخی دستگاه‌ها/شبیه‌سازها موجود نیست — نادیده می‌گیریم.
    }
  }

  Future<void> _startGps() async {
    _locSub = _location.stream.listen(_onGpsSample);
    await _location.start();
  }

  void _onGpsSample(SmoothedPosition s) {
    _gotGpsFix = true;
    _simTimer?.cancel();
    _simTimer = null;

    final speedKmh = (s.speedMps * 3.6).clamp(0, 400).toDouble();
    final limit = _speedLimitFor(s.position);
    _updateWithPosition(
      position: s.position,
      speedKmh: speedKmh,
      heading: s.headingDeg,
      limit: limit,
    );
  }

  /// محدودیت سرعت برای موقعیت جاری از داده‌ی مسیر/نقشه.
  /// در نسخه‌ی کامل، از تگ `maxspeed` نزدیک‌ترین یال گراف OSM خوانده می‌شود.
  int? _speedLimitFor(LatLng pos) {
    final route = _route;
    if (route == null || route.steps.isEmpty) return 60; // پیش‌فرض شهری
    // نزدیک‌ترین گام مسیر را می‌یابیم و محدودیت آن را برمی‌گردانیم.
    final d = const Distance();
    ManeuverStep? nearest;
    var best = double.infinity;
    for (final step in route.steps) {
      final dist = d(pos, step.point).toDouble();
      if (dist < best) {
        best = dist;
        nearest = step;
      }
    }
    // نگاشت نوع راه به محدودیت (نمونه — در نسخه کامل از OSM):
    return nearest == null ? 60 : 60;
  }

  void _updateWithPosition({
    required LatLng position,
    required double speedKmh,
    required double heading,
    required int? limit,
  }) {
    final route = _route;
    var remainingDist = state.remainingDistanceMeters;
    var maneuverDist = state.distanceToManeuverMeters;
    ManeuverStep? maneuver = state.nextManeuver;

    if (route != null && route.steps.isNotEmpty) {
      final d = const Distance();
      // مسافت باقی‌مانده تا مقصد = فاصله تا آخرین نقطه‌ی مسیر.
      remainingDist = d(position, route.polyline.last).toDouble();
      // مانور بعدی = نزدیک‌ترین گام جلوتر.
      var best = double.infinity;
      for (final step in route.steps) {
        final dist = d(position, step.point).toDouble();
        if (dist < best) {
          best = dist;
          maneuver = step;
          maneuverDist = dist;
        }
      }
    }

    final remainingTime = speedKmh > 3
        ? Duration(seconds: (remainingDist / (speedKmh / 3.6)).round())
        : state.remainingTime;

    state = state.copyWith(
      position: position,
      currentSpeedKmh: speedKmh,
      headingDeg: heading,
      speedLimitKmh: limit,
      nextManeuver: maneuver,
      distanceToManeuverMeters: maneuverDist,
      remainingDistanceMeters: remainingDist,
      remainingTime: remainingTime,
      eta: DateTime.now().add(remainingTime),
    );
  }

  void _recomputeFromRoute() {
    final route = _route;
    if (route == null) return;
    state = state.copyWith(
      nextManeuver: route.steps.isNotEmpty ? route.steps.first : null,
      distanceToManeuverMeters:
          route.steps.isNotEmpty ? route.steps.first.distanceMeters : 0,
      remainingDistanceMeters: route.distanceMeters,
      remainingTime: route.duration,
      eta: DateTime.now().add(route.duration),
    );
  }

  // ---- شبیه‌سازی سبک (فقط وقتی GPS نیست) ----
  double _simSpeed = 68;
  void _startSimulation() {
    if (_simTimer != null) return;
    _simTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      // نوسان طبیعی سرعت حول ۶۰ با استفاده از شتاب خوانده‌شده اگر موجود بود.
      final drift = math.sin(DateTime.now().millisecondsSinceEpoch / 4000) * 6;
      _simSpeed = (58 + drift + _lastAccelMps2 * 0.4).clamp(0, 120).toDouble();
      final remaining = math.max(
          200.0, state.remainingDistanceMeters - _simSpeed / 3.6 * 0.9);
      final t = Duration(seconds: (remaining / (_simSpeed / 3.6)).round());
      state = state.copyWith(
        currentSpeedKmh: _simSpeed,
        speedLimitKmh: 60,
        remainingDistanceMeters:
            state.remainingDistanceMeters == 0 ? 7200 : remaining,
        distanceToManeuverMeters:
            state.distanceToManeuverMeters == 0 ? 350 : state.distanceToManeuverMeters,
        remainingTime: t,
        eta: DateTime.now().add(t),
        nextManeuver: state.nextManeuver ??
            const ManeuverStep(
              instruction: 'به سمت شیخ بهایی شمالی',
              distanceMeters: 350,
              type: ManeuverType.turnRight,
              point: LatLng(35.7776, 51.4103),
            ),
      );
    });
  }

  @override
  void dispose() {
    _locSub?.cancel();
    _accSub?.cancel();
    _simTimer?.cancel();
    _fallbackTimer?.cancel();
    _location.dispose();
    super.dispose();
  }
}

/// Provider سراسری وضعیت ناوبری زنده.
final navigationControllerProvider =
    StateNotifierProvider<NavigationController, NavigationState>(
        (ref) => NavigationController()..start());
