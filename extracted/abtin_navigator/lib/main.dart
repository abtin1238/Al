import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/bootstrap.dart';
import 'core/constants/app_strings.dart';
import 'core/providers/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_notification_banner.dart';
import 'core/widgets/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // بارگذاری دیتابیس رمزنگاری‌شده + موتور مسیریابی آفلاین
  final bootstrap = await AppBootstrap.init();

  runApp(
    ProviderScope(
      overrides: [
        appBootstrapProvider.overrideWithValue(bootstrap),
        routingServiceProvider.overrideWithValue(bootstrap.routingService),
      ],
      child: const AabtinApp(),
    ),
  );
}

/// ریشهٔ برنامهٔ «آبتین» با پشتیبانی کامل RTL و تم داینامیک.
class AabtinApp extends ConsumerWidget {
  const AabtinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [
        Locale('fa', 'IR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: AppNotificationOverlay(child: child!),
      ),
      home: const AppShell(),
    );
  }
}
