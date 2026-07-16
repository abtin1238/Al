import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../features/routing/data/kalman_filter.dart';

/// موقعیت هموارشده به همراه سرعت و جهت حرکت.
class SmoothedPosition {
  final LatLng position;
  final double speedMps;
  final double headingDeg;
  const SmoothedPosition(this.position, this.speedMps, this.headingDeg);
}

/// نتیجه‌ی درخواست مجوز GPS
enum GpsStartResult { ok, permissionDenied, serviceDisabled }

/// سرویس موقعیت‌یابی:
///  - مجوز GPS رو درخواست می‌کنه
///  - اگه GPS خاموش باشه دیالوگ روشن‌کردن نشون می‌ده
///  - جهت (heading) از flutter_compass (قطب‌نمای واقعی) می‌گیره
///  - موقعیت با کالمن‌فیلتر هموار می‌شه
class LocationService {
  final GpsKalmanFilter _kalman = GpsKalmanFilter();
  StreamSubscription<Position>? _gpsSub;
  StreamSubscription<CompassEvent>? _compassSub;
  final _controller = StreamController<SmoothedPosition>.broadcast();

  double _lastHeading = 0;
  double _lastSpeedMps = 0;
  LatLng? _lastPos;

  Stream<SmoothedPosition> get stream => _controller.stream;

  /// درخواست مجوز و روشن‌کردن GPS + نمایش دیالوگ در صورت نیاز.
  /// context برای نمایش دیالوگ لازمه.
  Future<GpsStartResult> requestAndStart(BuildContext context) async {
    // ۱. بررسی مجوز
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      if (context.mounted) {
        await _showPermissionDialog(context);
      }
      return GpsStartResult.permissionDenied;
    }

    // ۲. بررسی روشن‌بودن سرویس موقعیت
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        final opened = await _showGpsOffDialog(context);
        if (opened == true) {
          // کاربر رفت تنظیمات — صبر کوتاه بعد دوباره چک
          await Future.delayed(const Duration(seconds: 2));
          final nowEnabled = await Geolocator.isLocationServiceEnabled();
          if (!nowEnabled) return GpsStartResult.serviceDisabled;
        } else {
          return GpsStartResult.serviceDisabled;
        }
      } else {
        return GpsStartResult.serviceDisabled;
      }
    }

    await _startStreams();
    return GpsStartResult.ok;
  }

  /// شروع بدون دیالوگ (وقتی context نداریم — مثلاً راه‌اندازی اولیه)
  Future<bool> start() async {
    final permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      return false;
    }
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    await _startStreams();
    return true;
  }

  Future<void> _startStreams() async {
    // قطب‌نمای واقعی از سنسور مغناطیسی
    _compassSub ??= FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        _lastHeading = event.heading!;
        // اگه موقعیت داریم، یک نمونه با heading جدید بفرست
        final pos = _lastPos;
        if (pos != null && !_controller.isClosed) {
          _controller.add(
              SmoothedPosition(pos, _lastSpeedMps, _lastHeading));
        }
      }
    });

    // GPS stream
    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );
    _gpsSub ??= Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) {
      final smoothed = _kalman.process(
        pos.latitude,
        pos.longitude,
        pos.accuracy,
        speedMps: pos.speed,
      );
      _lastPos = smoothed;
      _lastSpeedMps = pos.speed < 0 ? 0 : pos.speed;
      // heading از GPS فقط وقتی سرعت داره معنی داره (>0.5 m/s)
      // وگرنه از قطب‌نمای مغناطیسی استفاده می‌کنیم
      if (pos.speed > 0.5 && pos.headingAccuracy < 45) {
        _lastHeading = pos.heading;
      }
      if (!_controller.isClosed) {
        _controller
            .add(SmoothedPosition(smoothed, _lastSpeedMps, _lastHeading));
      }
    });
  }

  Future<bool?> _showGpsOffDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2235),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.location_off_rounded, color: Color(0xFF00D2AA)),
            SizedBox(width: 10),
            Text('GPS خاموش است',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Vazirmatn')),
          ],
        ),
        content: const Text(
          'برای استفاده از مسیریابی، لطفاً موقعیت‌یابی (GPS) را در تنظیمات دستگاه روشن کنید.',
          style: TextStyle(
              color: Colors.white70, fontSize: 13, fontFamily: 'Vazirmatn'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('بعداً',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D2AA),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx, true);
              if (Platform.isAndroid) {
                await Geolocator.openLocationSettings();
              } else {
                await Geolocator.openAppSettings();
              }
            },
            child: const Text('باز کردن تنظیمات',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermissionDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2235),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.location_disabled_rounded, color: Color(0xFFFF5252)),
            SizedBox(width: 10),
            Text('دسترسی به موقعیت',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Vazirmatn')),
          ],
        ),
        content: const Text(
          'آبتین برای نشان دادن موقعیت شما و مسیریابی به دسترسی موقعیت نیاز دارد.',
          style: TextStyle(
              color: Colors.white70, fontSize: 13, fontFamily: 'Vazirmatn'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('بستن',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D2AA),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await Geolocator.openAppSettings();
            },
            child: const Text('تنظیمات برنامه',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  /// هنگام قطع GPS (تونل)، موقعیت را با Dead Reckoning تخمین بزن.
  void onSignalLost(double headingDeg, double speedMps, int deltaMillis) {
    final estimated = _kalman.deadReckon(headingDeg, speedMps, deltaMillis);
    if (!_controller.isClosed) {
      _controller.add(SmoothedPosition(estimated, speedMps, headingDeg));
    }
  }

  Future<void> dispose() async {
    await _gpsSub?.cancel();
    await _compassSub?.cancel();
    if (!_controller.isClosed) await _controller.close();
  }
}
