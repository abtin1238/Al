import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// نشانگر پیکان روی نقشه — طراحی شده با Canvas به‌صورت نمای بالا با حس سه‌بعدی:
/// سقف، لبه‌های بدنه، شیشه، چراغ‌ها، سایه، و چرخ‌ها.
/// با headingDeg می‌چرخه. در آینده با مدل GLB جایگزین می‌شه.
class CarMarker extends StatelessWidget {
  final double headingDeg;
  final bool headlights;
  const CarMarker({super.key, required this.headingDeg, this.headlights = true});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Transform.rotate(
        angle: headingDeg * math.pi / 180.0,
        child: CustomPaint(
          size: const Size(100, 100),
          painter: _PaykanPainter(headlights: headlights),
        ),
      ),
    );
  }
}

class _PaykanPainter extends CustomPainter {
  final bool headlights;
  _PaykanPainter({required this.headlights});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final w = size.width;
    final h = size.height;

    // ---- سایه‌ی زمین ----
    canvas.drawOval(
      Rect.fromCenter(center: c.translate(0, 2), width: 32, height: 10),
      Paint()
        ..color = Colors.black.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // ---- مخروط نور چراغ جلو ----
    if (headlights) {
      final coneShader = ui.Gradient.radial(
        Offset(c.dx, c.dy - 30),
        46,
        [const Color(0x88FFE97A), Colors.transparent],
        [0, 1],
      );
      final cone = Path()
        ..moveTo(c.dx, c.dy - 22)
        ..lineTo(c.dx - 22, c.dy - h * 0.46)
        ..lineTo(c.dx + 22, c.dy - h * 0.46)
        ..close();
      canvas.drawPath(cone, Paint()..shader = coneShader);
    }

    // ---- بدنه‌ی پیکان (شکل خاص: جلو کمی باریک‌تر از عقب، چهار چرخ برجسته) ----
    // بدنه‌ی اصلی
    final bodyPath = Path()
      ..moveTo(c.dx - 11, c.dy - 22) // جلو چپ
      ..quadraticBezierTo(c.dx - 13, c.dy - 23, c.dx, c.dy - 25) // جلو
      ..quadraticBezierTo(c.dx + 13, c.dy - 23, c.dx + 11, c.dy - 22) // جلو راست
      ..lineTo(c.dx + 14, c.dy - 4) // وسط راست
      ..lineTo(c.dx + 15, c.dy + 14) // عقب راست
      ..quadraticBezierTo(c.dx + 14, c.dy + 22, c.dx, c.dy + 24) // عقب
      ..quadraticBezierTo(c.dx - 14, c.dy + 22, c.dx - 15, c.dy + 14) // عقب چپ
      ..lineTo(c.dx - 14, c.dy - 4) // وسط چپ
      ..close();

    // گرادیان بدنه — رنگ کلاسیک پیکان: سفید مایل به کرم
    final bodyGradient = ui.Gradient.linear(
      Offset(c.dx - 15, c.dy - 25),
      Offset(c.dx + 15, c.dy + 24),
      [const Color(0xFFF5EDD6), const Color(0xFFB8A882), const Color(0xFF8C7B60)],
      [0, 0.55, 1],
    );
    canvas.drawPath(bodyPath, Paint()..shader = bodyGradient);

    // لبه‌ی بدنه
    canvas.drawPath(
      bodyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFF6B5C42),
    );

    // ---- سقف (نمای بالا — کمی کوچکتر از بدنه، رنگ روشن‌تر) ----
    final roofPath = Path()
      ..moveTo(c.dx - 8, c.dy - 14)
      ..lineTo(c.dx - 9, c.dy - 6)
      ..lineTo(c.dx - 9, c.dy + 7)
      ..lineTo(c.dx - 7, c.dy + 14)
      ..quadraticBezierTo(c.dx, c.dy + 16, c.dx + 7, c.dy + 14)
      ..lineTo(c.dx + 9, c.dy + 7)
      ..lineTo(c.dx + 9, c.dy - 6)
      ..lineTo(c.dx + 8, c.dy - 14)
      ..quadraticBezierTo(c.dx, c.dy - 16, c.dx - 8, c.dy - 14)
      ..close();
    final roofGradient = ui.Gradient.linear(
      Offset(c.dx - 9, c.dy - 14),
      Offset(c.dx + 9, c.dy + 14),
      [const Color(0xFFF8F0DC), const Color(0xFFE0CEAA)],
      [0, 1],
    );
    canvas.drawPath(roofPath, Paint()..shader = roofGradient);

    // ---- شیشه‌ی جلو ----
    final windshield = Path()
      ..moveTo(c.dx - 7, c.dy - 14)
      ..lineTo(c.dx - 8, c.dy - 21)
      ..quadraticBezierTo(c.dx, c.dy - 23, c.dx + 8, c.dy - 21)
      ..lineTo(c.dx + 7, c.dy - 14)
      ..close();
    canvas.drawPath(
      windshield,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(c.dx, c.dy - 23),
          Offset(c.dx, c.dy - 14),
          [const Color(0xFF8BBCCC), const Color(0xFF4A7A8E)],
        )
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      windshield,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = const Color(0xFF2A4D5A),
    );

    // ---- شیشه‌ی عقب ----
    final rearWindow = Path()
      ..moveTo(c.dx - 7, c.dy + 14)
      ..quadraticBezierTo(c.dx, c.dy + 16, c.dx + 7, c.dy + 14)
      ..lineTo(c.dx + 7, c.dy + 19)
      ..quadraticBezierTo(c.dx, c.dy + 22, c.dx - 7, c.dy + 19)
      ..close();
    canvas.drawPath(
      rearWindow,
      Paint()
        ..color = const Color(0xFF3D6B7A).withOpacity(0.8)
        ..style = PaintingStyle.fill,
    );

    // ---- چرخ‌ها (۴ تا) ----
    _drawWheel(canvas, Offset(c.dx - 15, c.dy - 12)); // جلو چپ
    _drawWheel(canvas, Offset(c.dx + 15, c.dy - 12)); // جلو راست
    _drawWheel(canvas, Offset(c.dx - 15, c.dy + 12)); // عقب چپ
    _drawWheel(canvas, Offset(c.dx + 15, c.dy + 12)); // عقب راست

    // ---- چراغ‌های جلو ----
    _drawHeadlight(canvas, Offset(c.dx - 8, c.dy - 23), headlights);
    _drawHeadlight(canvas, Offset(c.dx + 8, c.dy - 23), headlights);

    // ---- چراغ‌های عقب (قرمز) ----
    _drawTaillight(canvas, Offset(c.dx - 8, c.dy + 23));
    _drawTaillight(canvas, Offset(c.dx + 8, c.dy + 23));

    // ---- هاله‌ی آبی فیروزه‌ای مرکز (GPS dot) ----
    canvas.drawCircle(
      c,
      3.5,
      Paint()
        ..color = AppColors.primary
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(c, 2.5, Paint()..color = Colors.white);
  }

  void _drawWheel(Canvas canvas, Offset pos) {
    // لاستیک (دایره‌ی تیره)
    canvas.drawOval(
      Rect.fromCenter(center: pos, width: 8, height: 11),
      Paint()..color = const Color(0xFF1A1A1A),
    );
    // رینگ (دایره‌ی روشن‌تر)
    canvas.drawOval(
      Rect.fromCenter(center: pos, width: 5, height: 7),
      Paint()..color = const Color(0xFF888888),
    );
    // پیچ مرکزی
    canvas.drawCircle(pos, 1.2, Paint()..color = const Color(0xFFCCCCCC));
  }

  void _drawHeadlight(Canvas canvas, Offset pos, bool on) {
    canvas.drawOval(
      Rect.fromCenter(center: pos, width: 7, height: 4),
      Paint()..color = on ? const Color(0xFFFFEE88) : const Color(0xFF888877),
    );
    if (on) {
      canvas.drawOval(
        Rect.fromCenter(center: pos, width: 7, height: 4),
        Paint()
          ..color = const Color(0x55FFEE88)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  void _drawTaillight(Canvas canvas, Offset pos) {
    canvas.drawOval(
      Rect.fromCenter(center: pos, width: 6, height: 3.5),
      Paint()..color = const Color(0xFFFF2222),
    );
    canvas.drawOval(
      Rect.fromCenter(center: pos, width: 6, height: 3.5),
      Paint()
        ..color = const Color(0x66FF2222)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  @override
  bool shouldRepaint(_PaykanPainter old) => old.headlights != headlights;
}
