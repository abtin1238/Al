import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'screens/navigation_screen.dart';

void main() {
  runApp(const NaviApp());
}

class NaviApp extends StatelessWidget {
  const NaviApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مسیریاب',
      debugShowCheckedModeBanner: false,
      // چون واسط کاربری فارسی است، جهت متن را راست‌به‌چپ تنظیم می‌کنیم.
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR'), Locale('en', 'US')],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.mapBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentBlue,
          surface: AppColors.panelBackground,
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const NavigationScreen(),
    );
  }
}
