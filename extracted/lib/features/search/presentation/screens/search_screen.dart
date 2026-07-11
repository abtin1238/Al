import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_ui.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../navigation/data/sample_data.dart';
import '../../../navigation/domain/entities/place.dart';

/// دکمه‌ی میان‌بر بالای صفحه (خانه، محل کار، ...).
class _Shortcut {
  final IconData icon;
  final String label;
  final Color color;
  const _Shortcut(this.icon, this.label, this.color);
}

/// صفحه‌ی جستجوی آفلاین (مطابق تصاویر «جستجو»).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  List<Place> _results = [];
  bool _searching = false;

  static const _shortcuts = [
    _Shortcut(Icons.home_rounded, AppStrings.home, AppColors.primary),
    _Shortcut(Icons.work_rounded, AppStrings.work, AppColors.primary),
    _Shortcut(Icons.star_rounded, AppStrings.navFavorites, AppColors.primary),
    _Shortcut(Icons.local_gas_station_rounded, AppStrings.fuel, AppColors.primary),
    _Shortcut(Icons.apps_rounded, AppStrings.more, AppColors.primary),
  ];

  static const _categories = [
    _Shortcut(Icons.restaurant_rounded, 'رستوران', AppColors.poiRestaurant),
    _Shortcut(Icons.local_cafe_rounded, 'کافی‌شاپ', AppColors.poiCafe),
    _Shortcut(Icons.shopping_bag_rounded, 'مراکز خرید', AppColors.poiShopping),
    _Shortcut(Icons.hotel_rounded, 'هتل', AppColors.poiHotel),
    _Shortcut(Icons.park_rounded, 'پارک و تفریح', AppColors.poiPark),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// جستجوی محلی روی داده‌های آفلاین (بدون شبکه).
  void _onSearch(String q) {
    if (q.trim().isEmpty) {
      setState(() {
        _searching = false;
        _results = [];
      });
      return;
    }
    final all = [
      ...SampleData.miladResults,
      ...SampleData.nearbyPlaces,
      ...SampleData.favoritePlaces,
    ];
    setState(() {
      _searching = true;
      _results = all
          .where((p) =>
              p.title.contains(q) ||
              p.subtitle.contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.navSearch)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _searchBar(),
          const SizedBox(height: 16),
          if (_searching)
            ..._buildResults()
          else
            ..._buildDiscovery(),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.textSecondaryDark),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: _onSearch,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: AppStrings.searchHint,
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            icon: Icon(_searching ? Icons.close_rounded : Icons.mic_rounded,
                color: AppColors.primary),
            onPressed: () {
              _controller.clear();
              _onSearch('');
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildResults() {
    return [
      SectionHeader('نتایج جستجو (${_results.length})'),
      ..._results.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PlaceRow(place: p, showDistance: true),
          )),
      if (_results.isEmpty)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text('نتیجه‌ای یافت نشد',
                style: TextStyle(color: AppColors.textSecondaryDark)),
          ),
        ),
    ];
  }

  List<Widget> _buildDiscovery() {
    return [
      // میان‌برها
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _shortcuts
            .map((s) => _ShortcutButton(shortcut: s))
            .toList(),
      ),
      const SectionHeader('دسته‌بندی‌های محبوب'),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _categories
            .map((s) => _CategoryCircle(shortcut: s))
            .toList(),
      ),
      const SectionHeader('اخیراً جستجو شده'),
      ...SampleData.recentSearches.map((p) => _RecentRow(place: p)),
      const SectionHeader('مکان‌های پیشنهادی نزدیک شما'),
      ...SampleData.nearbyPlaces.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PlaceRow(place: p, showDistance: true),
          )),
      const SizedBox(height: 16),
    ];
  }
}

class _ShortcutButton extends StatelessWidget {
  final _Shortcut shortcut;
  const _ShortcutButton({required this.shortcut});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Icon(shortcut.icon, color: shortcut.color, size: 26),
        ),
        const SizedBox(height: 6),
        Text(shortcut.label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _CategoryCircle extends StatelessWidget {
  final _Shortcut shortcut;
  const _CategoryCircle({required this.shortcut});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: shortcut.color.withOpacity(0.14),
            border: Border.all(color: shortcut.color.withOpacity(0.4)),
          ),
          child: Icon(shortcut.icon, color: shortcut.color, size: 26),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 62,
          child: Text(shortcut.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10)),
        ),
      ],
    );
  }
}

class _RecentRow extends StatelessWidget {
  final Place place;
  const _RecentRow({required this.place});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: AppColors.surfaceElevatedDark,
        child: Icon(Icons.history_rounded, color: AppColors.textSecondaryDark),
      ),
      title: Text(place.title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: Text(place.subtitle,
          style: const TextStyle(fontSize: 12)),
    );
  }
}

class _PlaceRow extends StatelessWidget {
  final Place place;
  final bool showDistance;
  const _PlaceRow({required this.place, this.showDistance = false});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {},
      child: Row(
        children: [
          GlowIcon(CategoryUi.icon(place.category),
              color: CategoryUi.color(place.category), size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(place.subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondaryDark)),
              ],
            ),
          ),
          if (showDistance && place.distanceKm != null)
            Text('${place.distanceKm} کیلومتر',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.primary)),
        ],
      ),
    );
  }
}
