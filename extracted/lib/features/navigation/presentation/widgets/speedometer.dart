import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// سرعت‌سنج دایره‌ای (سرعت لحظه‌ای) — مطابق تصویر نمای ناوبری.
class Speedometer extends StatelessWidget {
  final int speed;
  final bool overLimit;
  const Speedometer({super.key, required this.speed, this.overLimit = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceDark.withOpacity(0.9),
        border: Border.all(
          color: overLimit ? AppColors.danger : AppColors.borderDark,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$speed',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: overLimit ? AppColors.danger : Colors.white)),
          const Text('km/h',
              style: TextStyle(fontSize: 10, color: AppColors.textMutedDark)),
        ],
      ),
    );
  }
}

/// نشانگر محدودیت سرعت (دایره‌ی قرمز) — مطابق تصویر.
class SpeedLimitSign extends StatelessWidget {
  final int limit;
  const SpeedLimitSign({super.key, required this.limit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.danger, width: 5),
      ),
      alignment: Alignment.center,
      child: Text('$limit',
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.black)),
    );
  }
}
