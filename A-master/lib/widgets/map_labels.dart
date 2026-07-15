import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// برچسب نام خیابان به‌صورت کپسول تیره روی نقشه (مثل «بلوار میرداماد»).
class StreetLabel extends StatelessWidget {
  final String text;
  const StreetLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.panelBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(text, style: AppTextStyles.streetLabel),
    );
  }
}

/// حباب آبی با آیکون پیچ + برچسب نام خیابان بعدی، که روی محل پیچ مسیر می‌نشیند.
class TurnBubbleLabel extends StatelessWidget {
  final String label;
  const TurnBubbleLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.mapBackground,
            border: Border.all(color: AppColors.accentBlue, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentBlue.withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.turn_left_rounded,
            color: AppColors.accentBlue,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.panelBackground.withOpacity(0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text(label, style: AppTextStyles.turnLabel),
        ),
      ],
    );
  }
}
