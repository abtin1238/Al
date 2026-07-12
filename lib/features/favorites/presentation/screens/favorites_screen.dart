import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_ui.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../navigation/data/sample_data.dart';
import '../../../navigation/domain/entities/place.dart';

/// صفحه‌ی مکان‌های مورد علاقه (مطابق تصویر «مکان‌های مورد علاقه»).
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مکان‌های مورد علاقه'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _searchBar(),
          const SizedBox(height: 16),
          // دسته‌های میان‌بر
          SizedBox(
            height: 96,
            child: Row(
              children: [
                Expanded(
                    child: _QuickCategory(
                        SampleData.favoriteCategories[0], primary: true)),
                const SizedBox(width: 10),
                Expanded(child: _QuickCategory(SampleData.favoriteCategories[1])),
                const SizedBox(width: 10),
                Expanded(child: _QuickCategory(SampleData.favoriteCategories[5])),
                const SizedBox(width: 10),
                const Expanded(child: _AddCategory()),
              ],
            ),
          ),
          const SectionHeader('دسته‌ها'),
          ...SampleData.favoriteCategories.map((c) => _CategoryRow(category: c)),
          const SectionHeader('مکان‌های ذخیره‌شده'),
          ...SampleData.favoritePlaces.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _FavoritePlaceCard(place: p),
              )),
          const SizedBox(height: 8),
          _addPlaceButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: const [
          Icon(Icons.search_rounded, color: AppColors.textSecondaryDark),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'جستجو در مکان‌های مورد علاقه',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addPlaceButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
      ),
      child: const Center(
        child: Text('+ افزودن مکان جدید',
            style: TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _QuickCategory extends StatelessWidget {
  final FavoriteCategory category;
  final bool primary;
  const _QuickCategory(this.category, {this.primary = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: primary
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.borderDark),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CategoryUi.icon(category.icon),
              color: AppColors.primary, size: 26),
          const SizedBox(height: 6),
          Text(category.name,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          Text('${category.placeCount} مکان',
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textMutedDark)),
        ],
      ),
    );
  }
}

class _AddCategory extends StatelessWidget {
  const _AddCategory();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedDark,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_rounded, color: AppColors.textSecondaryDark, size: 26),
          SizedBox(height: 6),
          Text('دسته جدید',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final FavoriteCategory category;
  const _CategoryRow({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        leading: const Icon(Icons.more_vert_rounded,
            color: AppColors.textMutedDark),
        title: Text(category.name,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        subtitle: Text('${category.placeCount} مکان',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12)),
        trailing: CircleAvatar(
          radius: 20,
          backgroundColor: CategoryUi.color(category.icon).withOpacity(0.2),
          child: Icon(CategoryUi.icon(category.icon),
              color: CategoryUi.color(category.icon), size: 22),
        ),
      ),
    );
  }
}

class _FavoritePlaceCard extends StatelessWidget {
  final Place place;
  const _FavoritePlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.gold),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(place.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(place.subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondaryDark)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // مینی‌مپ جای‌نما
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.surfaceElevatedDark,
                ),
                child: const Icon(Icons.location_on_rounded,
                    color: AppColors.primary),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _FavAction(Icons.share_rounded, 'اشتراک‌گذاری'),
              _FavAction(Icons.edit_rounded, 'ویرایش'),
              _FavAction(Icons.navigation_rounded, 'مسیریابی'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FavAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FavAction(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
