import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// سرعت‌سنج دایره‌ای آنالوگ با عقربه، مشابه داشبورد خودرو.
/// دامنه نمایش ۰ تا ۲۴۰ کیلومتر بر ساعت با گرادیان آبی (ایمن) به قرمز (خطر).
class SpeedometerGauge extends StatelessWidget {
  final double speed; // km/h
  final String gear; // مثلاً "D"
  final double maxSpeed;

  const SpeedometerGauge({
    super.key,
    required this.speed,
    this.gear = 'D',
    this.maxSpeed = 240,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(210, 210),
            painter: _GaugePainter(speed: speed, maxSpeed: maxSpeed),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(speed.toStringAsFixed(0), style: AppTextStyles.speedValue),
              Text('km/h', style: AppTextStyles.speedUnit),
            ],
          ),
          Positioned(
            bottom: 22,
            child: Text(gear, style: AppTextStyles.gearLabel),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double speed;
  final double maxSpeed;
  _GaugePainter({required this.speed, required this.maxSpeed});

  // قوس از ۱۳۵ درجه تا ۴۵ درجه (طی کردن ۲۷۰ درجه) — مثل بیشتر خودروها
  static const double startAngle = math.pi * 0.75; // 135°
  static const double sweepAngle = math.pi * 1.5; // 270°

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;

    // صفحه پس‌زمینه گیج
    final facePaint = Paint()..color = AppColors.gaugeFace;
    canvas.drawCircle(center, radius + 8, facePaint);

    // مسیر رنگی (آبی -> قرمز)
    final trackRect = Rect.fromCircle(center: center, radius: radius);
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: const [
          AppColors.gaugeTrackBlue,
          AppColors.gaugeTrackBlue,
          AppColors.gaugeTrackRed,
        ],
        stops: const [0.0, 0.55, 1.0],
        transform: GradientRotation(0),
      ).createShader(trackRect);
    canvas.drawArc(trackRect, startAngle, sweepAngle, false, trackPaint);

    // خط‌های درجه‌بندی و اعداد
    const majorStep = 20;
    final maxTicks = (maxSpeed / majorStep).round();
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i <= maxTicks; i++) {
      final value = i * majorStep;
      final angle = startAngle + sweepAngle * (value / maxSpeed);
      final isMajor = i % 2 == 0;

      final outer = Offset(
        center.dx + (radius - 2) * math.cos(angle),
        center.dy + (radius - 2) * math.sin(angle),
      );
      final inner = Offset(
        center.dx + (radius - (isMajor ? 14 : 8)) * math.cos(angle),
        center.dy + (radius - (isMajor ? 14 : 8)) * math.sin(angle),
      );

      final tickPaint = Paint()
        ..color = Colors.white.withOpacity(isMajor ? 0.85 : 0.4)
        ..strokeWidth = isMajor ? 2.2 : 1.2;
      canvas.drawLine(inner, outer, tickPaint);

      if (isMajor) {
        final labelRadius = radius - 30;
        final labelPos = Offset(
          center.dx + labelRadius * math.cos(angle),
          center.dy + labelRadius * math.sin(angle),
        );
        textPainter.text = TextSpan(
          text: '$value',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          labelPos - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }

    // عقربه
    final needleAngle =
        startAngle + sweepAngle * ((speed.clamp(0, maxSpeed)) / maxSpeed);
    final needleEnd = Offset(
      center.dx + (radius - 24) * math.cos(needleAngle),
      center.dy + (radius - 24) * math.sin(needleAngle),
    );
    final needlePaint = Paint()
      ..color = AppColors.gaugeNeedle
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);

    // مرکز عقربه
    canvas.drawCircle(center, 7, Paint()..color = Colors.white);
    canvas.drawCircle(center, 4, Paint()..color = AppColors.gaugeNeedle);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.speed != speed;
}
