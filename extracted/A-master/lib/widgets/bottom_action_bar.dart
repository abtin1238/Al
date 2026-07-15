import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// نوار پایین اپ شامل چهار آیکون ثانویه و یک دکمه‌ی جستجوی مرکزی برجسته.
class BottomActionBar extends StatelessWidget {
  final VoidCallback? onRouteTap;
  final VoidCallback? onSaveTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onVoiceTap;
  final VoidCallback? onSettingsTap;

  const BottomActionBar({
    super.key,
    this.onRouteTap,
    this.onSaveTap,
    this.onSearchTap,
    this.onVoiceTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bottomBarBackground.withOpacity(0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BarItem(icon: Icons.alt_route_rounded, label: 'مسیر', onTap: onRouteTap),
          _BarItem(icon: Icons.download_rounded, label: 'ذخیره', onTap: onSaveTap),
          _SearchButton(onTap: onSearchTap),
          _BarItem(icon: Icons.volume_up_rounded, label: 'صدا', onTap: onVoiceTap),
          _BarItem(icon: Icons.settings_rounded, label: 'تنظیمات', onTap: onSettingsTap),
        ],
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _BarItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 22),
              const SizedBox(height: 5),
              Text(label, style: AppTextStyles.bottomBarLabel),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _SearchButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.panelBackgroundElevated,
            border: Border.all(color: AppColors.accentBlue, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentBlue.withOpacity(0.45),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.search_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
