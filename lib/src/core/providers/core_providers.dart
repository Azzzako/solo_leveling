import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../db/app_database.dart';
import '../storage/settings_store.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final user = ref.watch(authProvider).value;
  if (user == null) {
    throw StateError('La base de datos requiere una sesión iniciada');
  }
  final db = AppDatabase(user.id);
  ref.onDispose(db.close);
  return db;
});

final settingsStoreProvider = FutureProvider<SettingsStore>((ref) async {
  final user = await ref.watch(authProvider.future);
  if (user == null) {
    throw StateError('Los ajustes requieren una sesión iniciada');
  }
  return SettingsStore.open(user.id);
});

final todayProvider = Provider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});
