import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../db/app_database.dart';
import '../storage/settings_store.dart';
import '../utils/dates.dart';

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

class TodayNotifier extends Notifier<DateTime> {
  Timer? _midnight;

  @override
  DateTime build() {
    ref.onDispose(() => _midnight?.cancel());
    return _scheduleFrom(DateTime.now());
  }

  void refresh() {
    final today = _scheduleFrom(DateTime.now());
    if (today != state) state = today;
  }

  DateTime _scheduleFrom(DateTime now) {
    _midnight?.cancel();
    final today = dateOnly(now);
    _midnight = Timer(
      nextDay(today).difference(now) + const Duration(seconds: 1),
      refresh,
    );
    return today;
  }
}

final todayProvider = NotifierProvider<TodayNotifier, DateTime>(
  TodayNotifier.new,
);
