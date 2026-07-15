import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// نشانگر خودرو با نمای از بالا، شامل چراغ‌های جلو روشن و چراغ‌های عقب قرمز،
/// دقیقاً مطابق طرح که در انتهای مسیر نارنجی قرار می‌گیرد.
class CarMarker extends StatelessWidget {
  final double heading; // زاویه چرخش بر حسب رادیان
  const CarMarker({super.key, this.heading = 0});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: heading,
      child: SizedBox(
        width: 70,
        height: 110,
        child: CustomPaint(painter: _CarPainter()),
      ),
    );
  }
}

class _CarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // نور جلوی خودرو (هدلایت) رو به بالا
    final headlightGlow = Paint()
      ..color = Colors.amber.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset(center.dx, h * 0.15), 26, headlightGlow);

    // بدنه‌ی خودرو (بیضی مستطیل‌گونه)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: w * 0.62, height: h * 0.75),
      const Radius.circular(22),
    );
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey.shade200, Colors.grey.shade500],
      ).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, bodyPaint);

    // شیشه جلو/عقب (تیره‌تر، وسط خودرو)
    final windshield = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, h * 0.42),
        width: w * 0.42,
        height: h * 0.30,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(windshield, Paint()..color = const Color(0xFF1B2330));

    // چراغ‌های جلو (سفید مایل به زرد)
    final headlightPaint = Paint()..color = const Color(0xFFFFF6D6);
    canvas.drawCircle(Offset(center.dx - w * 0.20, h * 0.14), 5, headlightPaint);
    canvas.drawCircle(Offset(center.dx + w * 0.20, h * 0.14), 5, headlightPaint);

    // چراغ‌های عقب (قرمز درخشان)
    final taillightGlow = Paint()
      ..color = AppColors.signRed.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(center.dx - w * 0.22, h * 0.86), 8, taillightGlow);
    canvas.drawCircle(Offset(center.dx + w * 0.22, h * 0.86), 8, taillightGlow);

    final taillightPaint = Paint()..color = AppColors.signRed;
    canvas.drawCircle(Offset(center.dx - w * 0.22, h * 0.86), 4, taillightPaint);
    canvas.drawCircle(Offset(center.dx + w * 0.22, h * 0.86), 4, taillightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
