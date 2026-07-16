import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../data/offline_map_data.dart';

/// نقشه‌ی سه‌بعدیِ تمام‌صفحه و **کاملاً آفلاین**.
///
/// هیچ تایل شبکه‌ای بارگذاری نمی‌شود؛ کل نقشه (جاده‌ها، ساختمان‌های سه‌بعدی و
/// مسیر) با [CustomPaint] از روی گرافِ محلیِ [OfflineCity] رندر می‌شود. دوربین
/// حالتِ «جهت‌حرکت به بالا» (heading-up) دارد و با شیبِ سه‌بعدی نمایش داده می‌شود.
/// لمسِ هر نقطه روی نقشه به مختصاتِ جغرافیایی تبدیل و به [onTapLatLng] داده می‌شود.
class OfflineMapView extends StatelessWidget {
  final OfflineCity city;
  final LatLng camera;
  final double headingDeg;
  final double pixelsPerMeter;
  final double tilt;
  final List<LatLng> routePolyline;
  final LatLng? destination;
  final Color routeColor;
  final double routeIntensity;
  final bool isDark;
  final Widget? vehicle;
  final ValueChanged<LatLng>? onTapLatLng;

  const OfflineMapView({
    super.key,
    required this.city,
    required this.camera,
    this.headingDeg = 0,
    this.pixelsPerMeter = 3.1,
    this.tilt = 0.45,
    this.routePolyline = const [],
    this.destination,
    this.routeColor = const Color(0xFF00E5D0),
    this.routeIntensity = 0.85,
    this.isDark = true,
    this.vehicle,
    this.onTapLatLng,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final size = Size(c.maxWidth, c.maxHeight);
        final anchorY = size.height * 0.60;
        final proj = _Projector(
          center: camera,
          size: size,
          anchorY: anchorY,
          ppm: pixelsPerMeter,
          heading: headingDeg * math.pi / 180.0,
        );
        final tiltMatrix = Matrix4.identity()
          ..setEntry(3, 2, 0.0011)
          ..rotateX(tilt);

        final bg = isDark
            ? const [Color(0xFF0B1120), Color(0xFF0E1526), Color(0xFF090D18)]
            : const [Color(0xFFDDE6F2), Color(0xFFE9EFF7), Color(0xFFF3F6FB)];

        return ClipRect(
          child: Stack(
            children: [
              // آسمان/زمین (پس‌زمینه‌ی افق سه‌بعدی)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: bg,
                    ),
                  ),
                ),
              ),
              // نقشه‌ی بردار‌ی (با شیب سه‌بعدی) + لمس‌گر
              Positioned.fill(
                child: Transform(
                  alignment: Alignment.center,
                  transform: tiltMatrix,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: onTapLatLng == null
                        ? null
                        : (d) => onTapLatLng!(proj.unproject(d.localPosition)),
                    child: CustomPaint(
                      size: size,
                      painter: _CityPainter(
                        city: city,
                        proj: proj,
                        route: routePolyline,
                        dest: destination,
                        routeColor: routeColor,
                        intensity: routeIntensity,
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),
              ),
              // خودرو به‌صورت بیلبورد (عمودی) در نقطه‌ی لنگر
              if (vehicle != null)
                Positioned(
                  left: size.width / 2 - 45,
                  top: anchorY - 58,
                  width: 90,
                  height: 90,
                  child: IgnorePointer(child: vehicle!),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// پروجکشنِ محلیِ زمین‌مرجع (ENU) با دورانِ «جهت‌حرکت به بالا».
class _Projector {
  final LatLng center;
  final Size size;
  final double anchorY;
  final double ppm;
  final double heading;
  late final double _mLat;
  late final double _mLon;
  late final double _ca;
  late final double _sa;

  _Projector({
    required this.center,
    required this.size,
    required this.anchorY,
    required this.ppm,
    required this.heading,
  }) {
    _mLat = 111320.0;
    _mLon = 111320.0 * math.cos(center.latitude * math.pi / 180.0);
    _ca = math.cos(heading);
    _sa = math.sin(heading);
  }

  Offset project(LatLng p) {
    final de = (p.longitude - center.longitude) * _mLon;
    final dn = (p.latitude - center.latitude) * _mLat;
    final ex = de * _ca - dn * _sa; // راستِ صفحه
    final ny = de * _sa + dn * _ca; // جلو (بالا)
    return Offset(size.width / 2 + ex * ppm, anchorY - ny * ppm);
  }

  LatLng unproject(Offset o) {
    final ex = (o.dx - size.width / 2) / ppm;
    final ny = (anchorY - o.dy) / ppm;
    final de = ex * _ca + ny * _sa;
    final dn = -ex * _sa + ny * _ca;
    return LatLng(
      center.latitude + dn / _mLat,
      center.longitude + de / _mLon,
    );
  }
}

class _CityPainter extends CustomPainter {
  final OfflineCity city;
  final _Projector proj;
  final List<LatLng> route;
  final LatLng? dest;
  final Color routeColor;
  final double intensity;
  final bool isDark;

  _CityPainter({
    required this.city,
    required this.proj,
    required this.route,
    required this.dest,
    required this.routeColor,
    required this.intensity,
    required this.isDark,
  });

  bool _near(Offset p, Size s) =>
      p.dx > -160 && p.dx < s.width + 160 && p.dy > -160 && p.dy < s.height + 160;

  @override
  void paint(Canvas canvas, Size size) {
    // ---- جاده‌ها (سطحِ زمین) ----
    final localCasing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = isDark ? const Color(0xFF05070C) : const Color(0xFFC2CCDA);
    final localFill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = isDark ? const Color(0xFF232B3D) : const Color(0xFFFFFFFF);

    for (final seg in city.roads) {
      final a = proj.project(seg.a);
      final b = proj.project(seg.b);
      if (!_near(a, size) && !_near(b, size)) continue;
      final arterial = seg.roadClass == 0;
      final casingW = arterial ? 15.0 : 9.0;
      final fillW = arterial ? 11.0 : 6.0;
      canvas.drawLine(a, b, localCasing..strokeWidth = casingW);
      canvas.drawLine(
          a,
          b,
          localFill
            ..strokeWidth = fillW
            ..color = arterial
                ? (isDark ? const Color(0xFF2E3750) : const Color(0xFFFFFFFF))
                : (isDark ? const Color(0xFF222A3B) : const Color(0xFFF1F5FA)));
    }

    // ---- ساختمان‌های سه‌بعدی (اکسترودشده رو به بالا) ----
    // مرتب‌سازی بر اساس عمق (دورترها اول) تا نزدیک‌ترها رویشان بیفتند.
    final projected = <_ProjBuilding>[];
    for (final bld in city.buildings) {
      final foot = bld.footprint.map(proj.project).toList();
      if (!foot.any((p) => _near(p, size))) continue;
      final cy = foot.map((p) => p.dy).reduce((a, b) => a + b) / foot.length;
      projected.add(_ProjBuilding(foot, bld.height, cy));
    }
    projected.sort((a, b) => a.centroidY.compareTo(b.centroidY));

    final wall = Paint()..style = PaintingStyle.fill;
    final roof = Paint()..style = PaintingStyle.fill;
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = isDark
          ? Colors.black.withOpacity(0.35)
          : Colors.black.withOpacity(0.08);

    for (final pb in projected) {
      final extrude = 10.0 + pb.height * 22.0;
      final up = Offset(0, -extrude);
      final foot = pb.foot;
      final top = foot.map((p) => p + up).toList();

      wall.color =
          isDark ? const Color(0xFF141B2A) : const Color(0xFFB9C4D4);
      // دیواره‌ها (چهار وجه)
      for (var i = 0; i < 4; i++) {
        final j = (i + 1) % 4;
        final path = Path()
          ..moveTo(foot[i].dx, foot[i].dy)
          ..lineTo(foot[j].dx, foot[j].dy)
          ..lineTo(top[j].dx, top[j].dy)
          ..lineTo(top[i].dx, top[i].dy)
          ..close();
        canvas.drawPath(path, wall);
      }
      // سقف (روشن‌تر)
      roof.color =
          isDark ? const Color(0xFF20293D) : const Color(0xFFDCE4EF);
      final rp = Path()..moveTo(top[0].dx, top[0].dy);
      for (var i = 1; i < 4; i++) {
        rp.lineTo(top[i].dx, top[i].dy);
      }
      rp.close();
      canvas.drawPath(rp, roof);
      canvas.drawPath(rp, edge);
    }

    // ---- مسیر (خطِ درخشان روی همه) ----
    if (route.length >= 2) {
      final pts = route.map(proj.project).toList();
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (var i = 1; i < pts.length; i++) {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
      // هاله
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 18
          ..color = routeColor.withOpacity(0.35 * intensity + 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      // مغزِ مسیر
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 8
          ..color = routeColor.withOpacity((0.85 * intensity).clamp(0.4, 1.0)),
      );
      // خطِ روشنِ مرکزی
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2.4
          ..color = Colors.white.withOpacity(0.75),
      );
    }

    // ---- نشانگرِ مقصد ----
    final d = dest;
    if (d != null) {
      final p = proj.project(d);
      canvas.drawCircle(
          p, 12, Paint()..color = const Color(0xFFEF4444).withOpacity(0.30));
      canvas.drawCircle(p, 7, Paint()..color = const Color(0xFFEF4444));
      canvas.drawCircle(
          p, 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_CityPainter old) =>
      old.proj.center != proj.center ||
      old.proj.heading != proj.heading ||
      old.route != route ||
      old.dest != dest ||
      old.routeColor != routeColor;
}

class _ProjBuilding {
  final List<Offset> foot;
  final double height;
  final double centroidY;
  const _ProjBuilding(this.foot, this.height, this.centroidY);
}
