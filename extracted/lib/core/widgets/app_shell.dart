import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import 'app_bottom_nav.dart';
import '../../features/navigation/presentation/screens/navigation_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/voice/presentation/screens/voice_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

/// پوسته‌ی اصلی برنامه با IndexedStack برای حفظ وضعیت هر تب.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(bottomNavIndexProvider);
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          NavigationScreen(),
          FavoritesScreen(),
          SearchScreen(),
          VoiceScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: index,
        onTap: (i) => ref.read(bottomNavIndexProvider.notifier).state = i,
      ),
    );
  }
}
