import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// پنل بالایی: فلش پیچ + مسافت + متن دستور، به‌همراه ردیف آمار
/// (زمان رسیدن، مسافت باقی‌مانده، زمان باقی‌مانده) و فلش جمع‌شدن.
class NavigationInstructionPanel extends StatelessWidget {
  final String distanceText;
  final String instructionPrefix; // "به سمت"
  final String instructionHighlight; // "شیخ"
  final String instructionSuffix; // "بهایی شمالی"
  final String arrivalTime;
  final String remainingDistance;
  final String remainingTime;
  final VoidCallback? onExpandTap;

  const NavigationInstructionPanel({
    super.key,
    required this.distanceText,
    required this.instructionPrefix,
    required this.instructionHighlight,
    required this.instructionSuffix,
    required this.arrivalTime,
    required this.remainingDistance,
    required this.remainingTime,
    this.onExpandTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panelBackground.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              children: [
                _TurnArrowIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(distanceText, style: AppTextStyles.distanceHero),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.instructionText,
                          children: [
                            TextSpan(text: '$instructionPrefix '),
                            TextSpan(
                              text: instructionHighlight,
                              style: AppTextStyles.instructionHighlight,
                            ),
                            TextSpan(text: ' $instructionSuffix'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.access_time_rounded,
                    value: arrivalTime,
                    label: 'زمان رسیدن',
                  ),
                ),
                _verticalDivider(),
                Expanded(
                  child: _StatItem(
                    value: remainingDistance,
                    label: 'مسافت باقی‌مانده',
                  ),
                ),
                _verticalDivider(),
                Expanded(
                  child: _StatItem(
                    value: remainingTime,
                    label: 'زمان باقی‌مانده',
                  ),
                ),
                GestureDetector(
                  onTap: onExpandTap,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() => Container(
        width: 1,
        height: 30,
        color: AppColors.divider,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );
}

class _StatItem extends StatelessWidget {
  final IconData? icon;
  final String value;
  final String label;
  const _StatItem({this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(value, style: AppTextStyles.statValue),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.statLabel),
      ],
    );
  }
}

class _TurnArrowIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      child: CustomPaint(
        size: const Size(46, 46),
        painter: _TurnLeftArrowPainter(),
      ),
    );
  }
}

/// فلش پیچ به چپ به‌سبک نشانه‌های مسیریابی (نارنجی).
class _TurnLeftArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textHighlightOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.75, size.height * 0.15)
      ..lineTo(size.width * 0.75, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.85,
        size.width * 0.40,
        size.height * 0.85,
      )
      ..lineTo(size.width * 0.15, size.height * 0.85);

    canvas.drawPath(path, paint);

    // سر فلش
    final headPaint = Paint()
      ..color = AppColors.textHighlightOrange
      ..style = PaintingStyle.fill;
    final headPath = Path()
      ..moveTo(size.width * 0.28, size.height * 0.62)
      ..lineTo(size.width * 0.05, size.height * 0.85)
      ..lineTo(size.width * 0.28, size.height * 1.02)
      ..close();
    canvas.drawPath(headPath, headPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
