import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// نشانگر خودرو روی نقشه با مخروط نورِ چراغ‌جلو (مطابق تصویر مرجع).
///
/// در نسخه‌ی نهایی، این ویجت با مدل سه‌بعدی GLB (`assets/models/car.glb`) از طریق
/// `flutter_3d_controller` جایگزین می‌شود؛ فعلاً یک نمایش برداریِ سبک و بهینه
/// (بدون بار native) ارائه می‌شود که با جهت حرکت می‌چرخد.
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
          size: const Size(90, 90),
          painter: _CarPainter(headlights: headlights),
        ),
      ),
    );
  }
}

class _CarPainter extends CustomPainter {
  final bool headlights;
  _CarPainter({required this.headlights});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);

    // مخروط نور چراغ جلو (رو به بالا = جهت حرکت)
    if (headlights) {
      final cone = Path()
        ..moveTo(c.dx, c.dy - 4)
        ..lineTo(c.dx - 26, size.height * 0.06)
        ..lineTo(c.dx + 26, size.height * 0.06)
        ..close();
      final coneShader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x00FFF3C0), Color(0x55FFE9A8)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(cone, Paint()..shader = coneShader);
    }

    // بدنه‌ی خودرو (نمای بالا)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: 26, height: 44),
      const Radius.circular(9),
    );
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE9EDF3), Color(0xFF9AA6B8)],
        ).createShader(Rect.fromCenter(center: c, width: 26, height: 44)),
    );
    // هاله‌ی فیروزه‌ای برند
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.primary.withOpacity(0.6),
    );
    // شیشه‌ی جلو
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(c.dx, c.dy - 8), width: 18, height: 12),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF2A3446),
    );
    // چراغ‌های عقب (قرمز)
    final tail = Paint()..color = AppColors.danger;
    canvas.drawCircle(Offset(c.dx - 7, c.dy + 20), 2.4, tail);
    canvas.drawCircle(Offset(c.dx + 7, c.dy + 20), 2.4, tail);
  }

  @override
  bool shouldRepaint(_CarPainter old) => old.headlights != headlights;
}
