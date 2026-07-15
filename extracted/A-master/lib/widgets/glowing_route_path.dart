import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// مسیر نارنجی درخشان با افکت نور (glow) و پیکان‌های جهت حرکت متحرک،
/// دقیقاً مطابق طرح: یک مسیر عمودی با یک پیچ به چپ نزدیک بالای صفحه.
class GlowingRoutePath extends StatefulWidget {
  const GlowingRoutePath({super.key});

  @override
  State<GlowingRoutePath> createState() => _GlowingRoutePathState();
}

class _GlowingRoutePathState extends State<GlowingRoutePath>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _RoutePainter(progress: _controller.value),
          child: Container(),
        );
      },
    );
  }
}

class _RoutePainter extends CustomPainter {
  final double progress;
  _RoutePainter({required this.progress});

  Path _buildPath(Size size) {
    final path = Path();
    final bottom = Offset(size.width * 0.50, size.height * 0.98);
    final mid = Offset(size.width * 0.52, size.height * 0.42);
    final bend = Offset(size.width * 0.46, size.height * 0.22);
    final top = Offset(size.width * 0.40, size.height * 0.03);

    path.moveTo(bottom.dx, bottom.dy);
    path.quadraticBezierTo(
      size.width * 0.53,
      size.height * 0.7,
      mid.dx,
      mid.dy,
    );
    path.quadraticBezierTo(
      size.width * 0.54,
      size.height * 0.30,
      bend.dx,
      bend.dy,
    );
    path.quadraticBezierTo(
      size.width * 0.40,
      size.height * 0.12,
      top.dx,
      top.dy,
    );
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);

    // لایه‌ی درخشش بیرونی (glow)
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 46
      ..color = AppColors.routeGlowOuter.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawPath(path, glowPaint);

    final glowPaint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 30
      ..color = AppColors.routeGlowOuter.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(path, glowPaint2);

    // بدنه‌ی اصلی مسیر با گرادینت عمودی
    final bounds = path.getBounds();
    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 20
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          AppColors.routeGlowCore,
          AppColors.routeGlowOuter,
        ],
      ).createShader(bounds);
    canvas.drawPath(path, corePaint);

    // خط مرکزی روشن‌تر
    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 4
      ..color = Colors.white.withOpacity(0.55);
    canvas.drawPath(path, highlightPaint);

    // پیکان‌های جهت حرکت متحرک روی مسیر
    _drawDirectionArrows(canvas, path);

    // نقطه‌ی درخشان خودرو در انتهای مسیر (پایین)
    final carGlowCenter = Offset(size.width * 0.50, size.height * 0.97);
    final carGlow = Paint()
      ..color = AppColors.routeGlowCore.withOpacity(0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(carGlowCenter, 40, carGlow);
  }

  void _drawDirectionArrows(Canvas canvas, Path path) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final length = metric.length;

    const spacing = 34.0;
    final offsetShift = progress * spacing;
    final arrowPaint = Paint()
      ..color = AppColors.routeArrow.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    for (double d = offsetShift; d < length - 10; d += spacing) {
      final tangent = metric.getTangentForOffset(d);
      if (tangent == null) continue;
      final pos = tangent.position;
      final angle = tangent.angle;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      // پیکان رو به بالا (خلاف جهت مسیر که از بالا به پایین رسم شده)
      canvas.rotate(angle + math.pi / 2 + math.pi);

      final arrowPath = Path()
        ..moveTo(0, -6)
        ..lineTo(-5, 4)
        ..lineTo(0, 1.5)
        ..lineTo(5, 4)
        ..close();
      canvas.drawPath(arrowPath, arrowPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
