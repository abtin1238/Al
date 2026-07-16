import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../routing/presentation/screens/routing_settings_screen.dart';
import 'display_settings_screen.dart';
import 'offline_maps_screen.dart';
import 'sound_settings_screen.dart';
import 'traffic_settings_screen.dart';

class _SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? page;
  const _SettingItem(this.icon, this.title, this.subtitle, {this.page});
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navItems = <_SettingItem>[
      _SettingItem(Icons.navigation_rounded, AppStrings.routingSettings,
          'مسیرها، رنگ مسیر، خودرو و اعلان‌های مسیر',
          page: const RoutingSettingsScreen()),
      _SettingItem(Icons.map_rounded, AppStrings.mapSettings,
          'نمایش نقشه، لایه‌ها و دانلود نقشه‌ها',
          page: const OfflineMapsScreen()),
      _SettingItem(Icons.brightness_6_rounded, AppStrings.displaySettings,
          'ظاهر برنامه، تم و اندازه‌های نمایش',
          page: const DisplaySettingsScreen()),
      _SettingItem(Icons.volume_up_rounded, AppStrings.soundSettings,
          'راهنمای صوتی، صداها و اعلان‌ها',
          page: const SoundSettingsScreen()),
      _SettingItem(Icons.warning_amber_rounded, AppStrings.trafficSettings,
          'ترافیک لحظه‌ای، هشدارها و دوربین‌ها',
          page: const TrafficSettingsScreen()),
    ];

    final accountItems = <_SettingItem>[
      const _SettingItem(Icons.person_rounded, 'حساب کاربری',
          'ورود، همگام‌سازی و مدیریت حساب'),
      const _SettingItem(Icons.star_rounded, 'علاقه‌مندی‌ها و مکان‌ها',
          'خانه، محل کار و مکان‌های ذخیره‌شده'),
      const _SettingItem(Icons.history_rounded, 'تاریخچه مسیرها',
          'مسیرهای اخیر و جستجوها'),
    ];

    final generalItems = <_SettingItem>[
      const _SettingItem(Icons.language_rounded, 'زبان و واحدها',
          'زبان برنامه، واحدها و قالب زمان'),
      const _SettingItem(Icons.lock_rounded, 'حریم خصوصی',
          'مجوزها و مدیریت داده‌ها'),
      const _SettingItem(Icons.info_outline_rounded, 'درباره برنامه',
          'نسخه برنامه و اطلاعات بیشتر'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        children: [
          _profileCard(),
          const SectionHeader('مسیریابی و ناوبری'),
          ...navItems.map((e) => _row(context, e)),
          const SectionHeader('حساب کاربری و داده‌ها'),
          ...accountItems.map((e) => _row(context, e)),
          const SectionHeader('عمومی'),
          ...generalItems.map((e) => _row(context, e)),
          const SizedBox(height: 24),
          _logoutButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _profileCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: AppCard(
        onTap: () {},
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                color: AppColors.surfaceElevatedDark,
              ),
              child: const Icon(Icons.person_outline_rounded,
                  color: AppColors.primary, size: 30),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.guestUser,
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text(AppStrings.signInPrompt,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryDark)),
                ],
              ),
            ),
            const Icon(Icons.chevron_left_rounded,
                color: AppColors.textMutedDark),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, _SettingItem item) {
    final hasPage = item.page != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: hasPage
            ? () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => item.page!))
            : null,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: hasPage
                      ? AppColors.primary.withOpacity(0.12)
                      : AppColors.surfaceElevatedDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon,
                    color: hasPage
                        ? AppColors.primary
                        : AppColors.textMutedDark,
                    size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: hasPage
                                ? Colors.white
                                : AppColors.textMutedDark)),
                    const SizedBox(height: 2),
                    Text(item.subtitle,
                        style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondaryDark)),
                  ],
                ),
              ),
              Icon(
                hasPage
                    ? Icons.chevron_left_rounded
                    : Icons.lock_outline_rounded,
                color: AppColors.textMutedDark,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return Center(
      child: TextButton.icon(
        icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
        label: const Text('خروج از حساب',
            style: TextStyle(
                color: AppColors.danger,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
        onPressed: () {},
      ),
    );
  }
}
