import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_ui.dart';
import '../../../../core/widgets/app_notification_banner.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../navigation/data/navigation_controller.dart';
import '../../../navigation/domain/entities/place.dart';

// ---- Provider علاقه‌مندی‌ها (ذخیره در SharedPreferences) ----

class FavoritesNotifier extends StateNotifier<List<Place>> {
  FavoritesNotifier() : super(const []) {
    _load();
  }

  static const _key = 'favorites_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = (jsonDecode(raw) as List)
          .map((e) => Place.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(state.map((p) => p.toJson()).toList()));
  }

  Future<void> add(Place place) async {
    if (state.any((p) => p.id == place.id)) return;
    state = [...state, place];
    await _save();
  }

  Future<void> remove(String id) async {
    state = state.where((p) => p.id != id).toList();
    await _save();
  }

  bool contains(String id) => state.any((p) => p.id == id);
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<Place>>(
        (ref) => FavoritesNotifier());

// ---- صفحه‌ی مکان‌های مورد علاقه ----

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final filtered = _query.isEmpty
        ? favorites
        : favorites
            .where((p) =>
                p.title.contains(_query) || p.subtitle.contains(_query))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('مکان‌های مورد علاقه'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_rounded),
            onPressed: () => _showAddDialog(context),
            tooltip: 'افزودن مکان',
          ),
        ],
      ),
      body: Column(
        children: [
          // ---- نوار جستجو ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded,
                      color: AppColors.textSecondaryDark),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      decoration: const InputDecoration(
                        hintText: 'جستجو در مکان‌های مورد علاقه',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---- لیست ----
          Expanded(
            child: filtered.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) =>
                        _FavCard(place: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_border_rounded,
              size: 72, color: AppColors.textMutedDark),
          const SizedBox(height: 16),
          const Text(
            'هنوز مکانی ذخیره نشده',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryDark),
          ),
          const SizedBox(height: 8),
          const Text(
            'از آیکون + در بالا یا از صفحه‌ی جستجو\nمکان‌های موردنظر را اضافه کنید',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, color: AppColors.textMutedDark),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_location_rounded),
            label: const Text('افزودن مکان'),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    // اینجا می‌ریم سراغ صفحه‌ی جستجو که کاربر مکان رو انتخاب کنه
    ref.read(bottomNavIndexProvider.notifier).state = 3;
    ref.read(appNotificationProvider.notifier).show(
          'مکان موردنظر را جستجو کنید و ستاره بزنید',
          type: AppNotifyType.info,
        );
  }
}

class _FavCard extends ConsumerWidget {
  final Place place;
  const _FavCard({required this.place});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          children: [
            Row(
              children: [
                // آیکون دسته
                GlowIcon(
                  CategoryUi.icon(place.category),
                  color: CategoryUi.color(place.category),
                  size: 48,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.title,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        place.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryDark),
                      ),
                    ],
                  ),
                ),
                // دکمه‌ی حذف
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.danger, size: 22),
                  onPressed: () async {
                    await ref
                        .read(favoritesProvider.notifier)
                        .remove(place.id);
                    ref.read(appNotificationProvider.notifier).show(
                          '${place.title} حذف شد',
                          type: AppNotifyType.info,
                        );
                  },
                ),
              ],
            ),
            const Divider(height: 20),
            // دکمه‌های اکشن
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionBtn(
                  icon: Icons.navigation_rounded,
                  label: 'مسیریابی',
                  color: AppColors.navSelected,
                  onTap: () => _navigate(context, ref),
                ),
                _ActionBtn(
                  icon: Icons.share_rounded,
                  label: 'اشتراک‌گذاری',
                  onTap: () {},
                ),
                _ActionBtn(
                  icon: Icons.edit_rounded,
                  label: 'ویرایش',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigate(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(appNotificationProvider.notifier);
    notifier.show('در حال محاسبه‌ی مسیر...', type: AppNotifyType.loading);
    try {
      final nav = ref.read(navigationControllerProvider);
      final origin = nav.position ?? defaultMapCenter;
      final routingService = ref.read(routingServiceProvider);
      final route = await routingService.route(origin, place.location);
      final ok =
          ref.read(navigationControllerProvider.notifier).startRoute(route);
      if (!ok) {
        notifier.show('مسیری یافت نشد', type: AppNotifyType.error);
        return;
      }
      notifier.show('مسیر ${route.distanceLabel} · ${route.durationLabel}',
          type: AppNotifyType.success);
      ref.read(bottomNavIndexProvider.notifier).state = 0;
    } catch (e) {
      notifier.show('خطا در دریافت مسیر', type: AppNotifyType.error);
    }
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
