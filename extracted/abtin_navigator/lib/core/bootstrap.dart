import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'security/secure_key_store.dart';
import 'services/routing_service.dart';

/// وضعیت راه‌اندازی اولیه اپ (دیتابیس + موتور مسیریابی).
class AppBootstrap {
  AppBootstrap({
    required this.database,
    required this.routingService,
  });

  final AppDatabase database;
  final RoutingService routingService;

  static Future<AppBootstrap> init() async {
    final passphrase = await SecureKeyStore.getOrCreatePassphrase();
    AppDatabase db;
    try {
      db = await AppDatabase.open(passphrase: passphrase);
    } catch (e, st) {
      // در محیط تست/دسکتاپ بدون SQLCipher بومی، به حافظه برمی‌گردیم.
      debugPrint('SQLCipher open failed, falling back to memory: $e\n$st');
      db = await AppDatabase.openInMemory();
    }

    final routing = RoutingService();
    routing.ensureOfflineGraphLoaded();

    return AppBootstrap(database: db, routingService: routing);
  }

  void dispose() {
    database.close();
  }
}

/// Provider سراسری bootstrap (override در main).
final appBootstrapProvider = Provider<AppBootstrap>((ref) {
  throw UnimplementedError('appBootstrapProvider must be overridden in main');
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return ref.watch(appBootstrapProvider).database;
});
