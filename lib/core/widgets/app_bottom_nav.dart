import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_strings.dart';

/// مقصدهای منطقی برنامه (هم‌راستا با IndexedStack در AppShell).
class NavDest {
  static const home = 0; // خانه (نمای ناوبری)
  static const routes = 1; // مسیرها
  static const favorites = 2; // علاقه‌مندی‌ها
  static const search = 3; // جستجو
  static const voice = 4; // صدا
  static const settings = 5; // تنظیمات
}

class _Slot {
  final IconData icon;
  final String label;
  final int dest;
  final bool center;
  const _Slot(this.icon, this.label, this.dest, {this.center = false});
}

/// نوار ناوبری پایین با دو حالت مطابق تصاویر مرجع:
///  • حالت «خانه» (روی نمای ناوبری): مسیرها · علاقه‌مندی‌ها · [جستجو] · صدا · تنظیمات
///  • حالت «صفحات داخلی»: جستجو · علاقه‌مندی‌ها · [خانه] · صدا · تنظیمات
/// آیتم مرکزی داخل یک دایره‌ی فیروزه‌ای نورانی برجسته می‌شود.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  bool get _homeVariant => currentIndex == NavDest.home;

  /// آیتم‌ها به ترتیب دیداریِ راست‌به‌چپ (RTL) مطابق عکس‌ها.
  List<_Slot> get _slots => _homeVariant
      ? const [
          _Slot(Icons.route_rounded, AppStrings.navRoutes, NavDest.routes),
          _Slot(Icons.star_rounded, AppStrings.navFavorites, NavDest.favorites),
          _Slot(Icons.search_rounded, AppStrings.navSearch, NavDest.search,
              center: true),
          _Slot(Icons.volume_up_rounded, AppStrings.navVoice, NavDest.voice),
          _Slot(Icons.settings_rounded, AppStrings.navSettings,
              NavDest.settings),
        ]
      : const [
          _Slot(Icons.search_rounded, AppStrings.navSearch, NavDest.search),
          _Slot(Icons.star_rounded, AppStrings.navFavorites, NavDest.favorites),
          _Slot(Icons.home_rounded, AppStrings.navHome, NavDest.home,
              center: true),
          _Slot(Icons.volume_up_rounded, AppStrings.navVoice, NavDest.voice),
          _Slot(Icons.settings_rounded, AppStrings.navSettings,
              NavDest.settings),
        ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D1420) : AppColors.surfaceLight;
    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: _slots.map((s) {
              final active = s.dest == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(s.dest),
                  child: s.center
                      ? _centerItem(s)
                      : _normalItem(s, active, isDark),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _centerItem(_Slot s) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.14),
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withOpacity(0.5),
                  blurRadius: 16,
                  spreadRadius: 1),
            ],
          ),
          child: Icon(s.icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(height: 2),
        Text(s.label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
      ],
    );
  }

  Widget _normalItem(_Slot s, bool active, bool isDark) {
    final color = active
        ? AppColors.primary
        : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(s.icon, size: 24, color: color),
        const SizedBox(height: 3),
        Text(
          s.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: color,
          ),
        ),
      ],
    );
  }
}
