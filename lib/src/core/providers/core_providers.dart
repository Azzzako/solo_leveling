import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../storage/settings_store.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final settingsStoreProvider = FutureProvider<SettingsStore>(
  (ref) => SettingsStore.open(),
);

final todayProvider = Provider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});
