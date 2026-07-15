import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// پس‌زمینه‌ی نقشه‌ی شبانه: شبکه‌ی خیابان‌ها با بلوک‌های ساختمانی و یک پارک.
/// به‌صورت برداری (CustomPainter) رسم می‌شود تا بدون وابستگی به تصویر
/// یا سرویس نقشه‌ی خارجی، همان حس ماهواره‌ای شبانه را بدهد.
class NightMapBackground extends StatelessWidget {
  const NightMapBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CityGridPainter(),
      child: Container(),
    );
  }
}

class _CityGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = AppColors.mapBackground;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final rnd = _SeededRandom(42);

    // بلوک‌های شهری نامنظم (شبیه‌سازی ساختمان‌ها از نمای بالا)
    const cellSize = 46.0;
    final cols = (size.width / cellSize).ceil() + 1;
    final rows = (size.height / cellSize).ceil() + 1;

    final blockPaint = Paint()..style = PaintingStyle.fill;
    final gridLinePaint = Paint()
      ..color = AppColors.cityGrid
      ..strokeWidth = 1.2;

    // ناحیه‌ی پارک (سمت چپ-بالا مطابق طرح)
    final parkRect = Rect.fromLTWH(
      size.width * 0.02,
      size.height * 0.20,
      size.width * 0.30,
      size.height * 0.22,
    );

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final rect = Rect.fromLTWH(
          c * cellSize,
          r * cellSize,
          cellSize - 3,
          cellSize - 3,
        );

        if (parkRect.overlaps(rect)) {
          blockPaint.color = AppColors.parkGreen;
          canvas.drawRect(rect, blockPaint);
          continue;
        }

        final shade = rnd.nextDouble();
        blockPaint.color = Color.lerp(
          AppColors.cityGrid,
          AppColors.cityBlockLight,
          shade * 0.6,
        )!;
        canvas.drawRect(rect, blockPaint);
      }
    }

    // خطوط اصلی خیابان (عمودی/افقی پررنگ‌تر، شبیه بلوارهای اصلی)
    final avenuePaint = Paint()
      ..color = AppColors.mapBackground
      ..strokeWidth = 10;

    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      avenuePaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.52),
      Offset(size.width, size.height * 0.52),
      avenuePaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.78),
      Offset(size.width, size.height * 0.78),
      avenuePaint,
    );

    // وینیت تیره در بالا و پایین برای خوانایی پنل‌ها
    final vignette = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.mapBackground.withOpacity(0.85),
          Colors.transparent,
          Colors.transparent,
          AppColors.mapBackground.withOpacity(0.9),
        ],
        stops: const [0.0, 0.22, 0.7, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// یک تولیدکننده‌ی عدد شبه‌تصادفی ساده و قطعی (بدون وابستگی به dart:math Random
/// برای اطمینان از ثبات بصری بین فریم‌ها).
class _SeededRandom {
  int _seed;
  _SeededRandom(this._seed);

  double nextDouble() {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return (_seed % 1000) / 1000;
  }
}
