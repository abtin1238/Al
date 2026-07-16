import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abtin_navigator/core/bootstrap.dart';
import 'package:abtin_navigator/core/database/app_database.dart';
import 'package:abtin_navigator/core/services/routing_service.dart';
import 'package:abtin_navigator/core/theme/app_theme.dart';
import 'package:abtin_navigator/core/widgets/app_shell.dart';
import 'package:abtin_navigator/core/providers/app_providers.dart';

void main() {
  testWidgets('AppShell builds and shows bottom navigation', (tester) async {
    final db = await AppDatabase.openInMemory();
    final routing = RoutingService()..ensureOfflineGraphLoaded();
    final bootstrap = AppBootstrap(database: db, routingService: routing);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appBootstrapProvider.overrideWithValue(bootstrap),
          routingServiceProvider.overrideWithValue(routing),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Directionality(
            textDirection: TextDirection.rtl,
            child: AppShell(),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('جستجو'), findsWidgets);
    expect(find.text('صدا'), findsWidgets);
    expect(find.text('تنظیمات'), findsWidgets);

    db.close();
  });
}
