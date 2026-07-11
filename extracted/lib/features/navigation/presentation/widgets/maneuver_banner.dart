import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/route_info.dart';

/// بنر دستور مانور بالای صفحه (مثلاً «۳۵۰ متر به سمت شیخ بهایی شمالی»).
class ManeuverBanner extends StatelessWidget {
  final String distance;
  final String instruction;
  final ManeuverType type;
  final String remainingTime;
  final String remainingDistance;
  final String eta;

  const ManeuverBanner({
    super.key,
    required this.distance,
    required this.instruction,
    required this.type,
    required this.remainingTime,
    required this.remainingDistance,
    required this.eta,
  });

  IconData get _icon {
    switch (type) {
      case ManeuverType.turnRight:
      case ManeuverType.slightRight:
        return Icons.turn_right_rounded;
      case ManeuverType.turnLeft:
      case ManeuverType.slightLeft:
        return Icons.turn_left_rounded;
      case ManeuverType.uTurn:
        return Icons.u_turn_left_rounded;
      case ManeuverType.roundabout:
        return Icons.rotate_right_rounded;
      case ManeuverType.arrive:
        return Icons.flag_rounded;
      default:
        return Icons.straight_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDark),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // آیکون مانور با هاله‌ی سبز/فیروزه‌ای
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_icon, color: AppColors.success, size: 38),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(distance,
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(instruction,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stat('زمان رسیدن', eta),
              _stat('مسافت مانده', remainingDistance),
              _stat('زمان باقی‌مانده', remainingTime),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textMutedDark)),
      ],
    );
  }
}
