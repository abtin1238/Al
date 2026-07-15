import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

/// تابلوی گرد استاندارد محدودیت سرعت (حاشیه قرمز، زمینه سفید).
class SpeedLimitSign extends StatelessWidget {
  final int limit;
  const SpeedLimitSign({super.key, required this.limit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0292E), width: 8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE0292E).withOpacity(0.45),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$limit',
        style: AppTextStyles.speedLimitValue.copyWith(color: Colors.black),
      ),
    );
  }
}
