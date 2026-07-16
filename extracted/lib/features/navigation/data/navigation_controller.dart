import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/services/location_service.dart';
import '../domain/entities/nav_state.dart';
import '../domain/entities/route_info.dart';

/// نقطه‌ی شروعِ پیش‌فرض (مرکز شهرِ نمونه) وقتی هنوز GPS دریافت نشده است.
const LatLng _defaultStart = LatLng(35.7562, 51.4110);

/// کنترلرِ زنده‌ی ناوبری.
///
/// جریان کار:
///  ۱. در حالتِ بی‌کار (idle) نقشه روی موقعیتِ فعلی متمرکز است و نوار بالا پنهان.
///  ۲. با لمسِ طولانیِ نقطه روی نقشه، مسیرِ واقعی از سرویسِ آنلاینِ مسیریابی
///     (OSRM) گرفته شده و با [startRoute] ناوبری آغاز می‌شود (نوار بالا ظاهر می‌شود).
///  ۳. خودرو روی خطِ مسیر حرکت می‌کند و سرعت‌سنج **واقعاً داینامیک** است:
///     در پیچ‌ها کند و در مسیرِ مستقیم تندتر می‌شود (پروفایلِ شتاب/ترمز).
///  ۴. اگر GPS واقعی در دسترس باشد و ناوبری فعال نباشد، موقعیت از GPS به‌روز می‌شود.
class NavigationController extends StateNotifier<NavigationState> {
  NavigationController()
      : super(const NavigationState(
          isNavigating: false,
          position: _defaultStart,
          headingDeg: 0,
          currentSpeedKmh: 0,
        ));

  final LocationService _location = LocationService();
  StreamSubscription<SmoothedPosition>? _locSub;
  Timer? _followTimer;

  RouteInfo? _route;
  List<double> _cum = const []; // فاصله‌ی تجمعی روی خطِ مسیر (متر)
  List<double> _maneuverAlong = const []; // فاصله‌ی هر مانور از ابتدای مسیر
  double _traveled = 0; // متر پیموده‌شده
  double _speed = 0; // km/h جاری (برای شتاب/ترمزِ نرم)

  final Distance _dist = const Distance();

  /// راه‌اندازیِ سرویسِ موقعیت با درخواست مجوز. اگه context داریم دیالوگ GPS نشون میده.
  Future<void> start({BuildContext? context}) async {
    _locSub = _location.stream.listen(_onGpsSample);
    try {
      if (context != null && context.mounted) {
        await _location.requestAndStart(context);
      } else {
        await _location.start();
      }
    } catch (_) {
      // بدونِ مجوز/شبیه‌ساز: در حالتِ بی‌کار می‌مانیم.
    }
  }

  void _onGpsSample(SmoothedPosition s) {
    // در حین ناوبری، حرکت توسطِ موتورِ پیمایشِ مسیر انجام می‌شود.
    if (state.isNavigating) return;
    state = state.copyWith(
      position: s.position,
      headingDeg: s.headingDeg,
      currentSpeedKmh: (s.speedMps * 3.6).clamp(0, 400).toDouble(),
    );
  }

  /// آغازِ ناوبری با یک [RouteInfo] **واقعی** که از قبل توسط سرویسِ مسیریابیِ
  /// آنلاین (OSRM) روی نقشه‌ی زنده محاسبه شده است. اگر مسیر معتبر نباشد
  /// false برمی‌گرداند.
  bool startRoute(RouteInfo route) {
    if (route.polyline.length < 2) return false;

    _route = route;
    _buildMetrics(route);
    _traveled = 0;
    _speed = 0;

    final firstManeuver =
        route.steps.isNotEmpty ? route.steps.first : null;
    state = state.copyWith(
      isNavigating: true,
      destination: route.polyline.last,
      routePolyline: route.polyline,
      position: route.polyline.first,
      headingDeg: _bearing(route.polyline[0], route.polyline[1]),
      currentSpeedKmh: 0,
      speedLimitKmh: 60,
      nextManeuver: firstManeuver,
      distanceToManeuverMeters:
          _maneuverAlong.isNotEmpty ? _maneuverAlong.first : 0,
      remainingDistanceMeters: route.distanceMeters,
      remainingTime: route.duration,
      eta: DateTime.now().add(route.duration),
    );

    _startFollow();
    return true;
  }

  /// توقفِ ناوبری و بازگشت به حالتِ بی‌کار (نوار بالا پنهان می‌شود).
  void stopNavigation() {
    _followTimer?.cancel();
    _followTimer = null;
    _route = null;
    state = state.copyWith(
      isNavigating: false,
      clearDestination: true,
      routePolyline: const [],
      currentSpeedKmh: 0,
    );
  }

  // ---- ساختِ سنجه‌های مسیر (فاصله‌ی تجمعی و موقعیتِ مانورها) ----
  void _buildMetrics(RouteInfo route) {
    final poly = route.polyline;
    final cum = List<double>.filled(poly.length, 0);
    for (var i = 1; i < poly.length; i++) {
      cum[i] = cum[i - 1] +
          _dist.as(LengthUnit.Meter, poly[i - 1], poly[i]);
    }
    _cum = cum;

    // فاصله‌ی هر مانور از ابتدای مسیر = فاصله‌ی نزدیک‌ترین رأسِ خطِ مسیر.
    final along = <double>[];
    for (final step in route.steps) {
      var best = double.infinity;
      var bestIdx = 0;
      for (var i = 0; i < poly.length; i++) {
        final d = _dist.as(LengthUnit.Meter, poly[i], step.point);
        if (d < best) {
          best = d;
          bestIdx = i;
        }
      }
      along.add(cum[bestIdx]);
    }
    _maneuverAlong = along;
  }

  // ---- موتورِ پیمایشِ مسیر (سرعت‌سنجِ داینامیک) ----
  void _startFollow() {
    _followTimer?.cancel();
    const tick = Duration(milliseconds: 120);
    const dt = 0.12; // ثانیه
    _followTimer = Timer.periodic(tick, (_) {
      final route = _route;
      if (route == null || _cum.isEmpty) return;
      final total = _cum.last;

      // مانورِ بعدی و فاصله تا آن.
      double dtn = double.infinity;
      ManeuverStep? nextManeuver = state.nextManeuver;
      for (var i = 0; i < _maneuverAlong.length; i++) {
        final ahead = _maneuverAlong[i] - _traveled;
        if (ahead >= -5) {
          dtn = ahead < 0 ? 0 : ahead;
          nextManeuver = route.steps[i];
          break;
        }
      }

      // پروفایلِ سرعتِ هدف: کند در پیچ، تند در مسیرِ مستقیم + نوسانِ طبیعی.
      double target;
      final arrived = _traveled >= total - 0.5;
      if (arrived) {
        target = 0;
      } else if (dtn < 35) {
        target = 20;
      } else if (dtn < 90) {
        target = 34;
      } else {
        target = 60 + math.sin(DateTime.now().millisecondsSinceEpoch / 1500) * 4;
      }

      // شتاب/ترمزِ نرم به‌سمتِ سرعتِ هدف.
      _speed += (target - _speed) * 0.18;
      if (arrived && _speed < 0.4) _speed = 0.0;

      _traveled += (_speed / 3.6) * dt;
      if (_traveled > total) _traveled = total;

      final pos = _pointAt(_traveled);
      final hd = _headingAt(_traveled);
      final remaining = math.max(0.0, total - _traveled);
      final remTime = _speed > 3
          ? Duration(seconds: (remaining / (_speed / 3.6)).round())
          : state.remainingTime;

      state = state.copyWith(
        position: pos,
        headingDeg: hd,
        currentSpeedKmh: _speed,
        speedLimitKmh: 60,
        nextManeuver: arrived
            ? route.steps.isNotEmpty ? route.steps.last : nextManeuver
            : nextManeuver,
        distanceToManeuverMeters: dtn.isFinite ? dtn : 0,
        remainingDistanceMeters: remaining,
        remainingTime: remTime,
        eta: DateTime.now().add(remTime),
      );

      // رسیدن به مقصد: توقفِ حرکت (نوار بالا تا بستنِ کاربر باقی می‌ماند).
      if (arrived && _speed < 1.2) {
        _speed = 0;
        _followTimer?.cancel();
        _followTimer = null;
      }
    });
  }

  /// موقعیت روی خطِ مسیر در فاصله‌ی [s] متر از ابتدا.
  LatLng _pointAt(double s) {
    final poly = _route!.polyline;
    if (s <= 0) return poly.first;
    if (s >= _cum.last) return poly.last;
    var i = 0;
    while (i < _cum.length - 1 && _cum[i + 1] < s) {
      i++;
    }
    final segLen = _cum[i + 1] - _cum[i];
    final t = segLen <= 0 ? 0.0 : (s - _cum[i]) / segLen;
    final a = poly[i], b = poly[i + 1];
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );
  }

  double _headingAt(double s) {
    final poly = _route!.polyline;
    var i = 0;
    while (i < _cum.length - 1 && _cum[i + 1] < s) {
      i++;
    }
    if (i >= poly.length - 1) return state.headingDeg;
    return _bearing(poly[i], poly[i + 1]);
  }

  double _bearing(LatLng a, LatLng b) {
    final lat1 = a.latitudeInRad, lat2 = b.latitudeInRad;
    final dLon = (b.longitude - a.longitude) * math.pi / 180;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  @override
  void dispose() {
    _locSub?.cancel();
    _followTimer?.cancel();
    _location.dispose();
    super.dispose();
  }
}

/// Provider سراسری وضعیت ناوبری زنده.
/// context برای دیالوگ GPS در navigation_screen پاس داده می‌شه.
final navigationControllerProvider =
    StateNotifierProvider<NavigationController, NavigationState>(
        (ref) => NavigationController()..start());
