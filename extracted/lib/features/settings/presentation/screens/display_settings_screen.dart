import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';

class DisplaySettingsScreen extends ConsumerWidget {
  const DisplaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final routing = ref.watch(routingSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات نمایش')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          const SectionHeader('ظاهر برنامه'),
          AppCard(
            child: Row(
              children: [
                const Icon(Icons.dark_mode_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('تم تیره',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      Text('نمایش تیره برای رانندگی شب',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryDark)),
                    ],
                  ),
                ),
                Switch(
                  value: mode == ThemeMode.dark,
                  onChanged: (v) =>
                      ref.read(themeModeProvider.notifier).state =
                          v ? ThemeMode.dark : ThemeMode.light,
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AppCard(
            child: Row(
              children: [
                const Icon(Icons.brightness_auto_rounded,
                    color: AppColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('تم خودکار شب/روز',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      Text('بر اساس ساعت دستگاه',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryDark)),
                    ],
                  ),
                ),
                Switch(
                  value: mode == ThemeMode.system,
                  onChanged: (v) =>
                      ref.read(themeModeProvider.notifier).state =
                          v ? ThemeMode.system : ThemeMode.dark,
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SectionHeader('نقشه و ناوبری'),
          AppCard(
            child: Row(
              children: [
                const Icon(Icons.directions_car_rounded,
                    color: AppColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('نمایش خودرو روی نقشه',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      Text('پیکان روی موقعیت شما',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryDark)),
                    ],
                  ),
                ),
                Switch(
                  value: routing.showVehicle,
                  onChanged: (v) =>
                      ref.read(routingSettingsProvider.notifier).setShowVehicle(v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AppCard(
            child: Row(
              children: [
                const Icon(Icons.headlights_rounded,
                    color: AppColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('چراغ‌های جلو در شب',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      Text('روشن کردن خودکار در تم تیره',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryDark)),
                    ],
                  ),
                ),
                Switch(
                  value: routing.headlightsAtNight,
                  onChanged: (v) =>
                      ref.read(routingSettingsProvider.notifier).setHeadlights(v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
