import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abtin_navigator/core/widgets/app_shell.dart';
import 'package:abtin_navigator/core/theme/app_theme.dart';

void main() {
  testWidgets('AppShell builds and shows bottom navigation', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Directionality(
            textDirection: TextDirection.rtl,
            child: AppShell(),
          ),
        ),
      ),
    );
    // نوار ناوبری پایین با ۵ برچسب باید نمایش داده شود.
    expect(find.text('جستجو'), findsWidgets);
    expect(find.text('صدا'), findsWidgets);
    expect(find.text('تنظیمات'), findsWidgets);
  });
}
