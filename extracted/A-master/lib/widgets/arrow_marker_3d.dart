import 'package:flutter/material.dart';
import 'dart:math' as math;

/// پیکان سه‌بعدی (شبیه نشانگر واقعی ناوبری)
class ArrowMarker3D extends StatelessWidget {
  final double rotation; // درجه چرخش (۰ تا ۳۶۰)

  const ArrowMarker3D({super.key, this.rotation = 0});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation * math.pi / 180,
      child: CustomPaint(
        size: const Size(48, 48),
        painter: _Arrow3DPainter(),
      ),
    );
  }
}

class _Arrow3DPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path();
    final w = size.width;
    final h = size.height;

    // شکل پیکان سه‌بعدی
    path.moveTo(w * 0.5, 0);           // نوک پیکان
    path.lineTo(w * 0.15, h * 0.65);   // گوشه چپ
    path.lineTo(w * 0.35, h * 0.65);   // داخل چپ
    path.lineTo(w * 0.35, h);          // پایین چپ
    path.lineTo(w * 0.65, h);          // پایین راست
    path.lineTo(w * 0.65, h * 0.65);   // داخل راست
    path.lineTo(w * 0.85, h * 0.65);   // گوشه راست
    path.close();

    // سایه
    canvas.save();
    canvas.translate(2, 3);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // پیکان اصلی
    canvas.drawPath(path, paint);

    // خطوط برجسته برای حس سه‌بعدی
    final highlight = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(w * 0.5, h * 0.1),
      Offset(w * 0.5, h * 0.55),
      highlight,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}