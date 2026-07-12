import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

/// صفحه‌ی «مسیرها» — تاریخچه و مسیرهای ذخیره‌شده (کاملاً آفلاین از دیتابیس محلی).
class RoutesScreen extends ConsumerWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // در نسخه‌ی کامل از جدول routes در Drift/SQLite خوانده می‌شود.
    const items = <_RouteItem>[
      _RouteItem('خانه ← محل کار', '۱۲.۴ کیلومتر · ۲۲ دقیقه', Icons.work_rounded),
      _RouteItem('میدان آزادی', '۷.۲ کیلومتر · ۱۴ دقیقه', Icons.history_rounded),
      _RouteItem('پارک ملت', '۴.۸ کیلومتر · ۹ دقیقه', Icons.park_rounded),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.routesTitle)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final it = items[i];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Icon(it.icon, color: AppColors.primary),
              ),
              title: Text(it.title,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(it.subtitle,
                  style: const TextStyle(color: AppColors.textMutedDark)),
              trailing: const Icon(Icons.chevron_left_rounded,
                  color: AppColors.textMutedDark),
            ),
          );
        },
      ),
    );
  }
}

class _RouteItem {
  final String title;
  final String subtitle;
  final IconData icon;
  const _RouteItem(this.title, this.subtitle, this.icon);
}
