import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/storage/settings_store.dart';
import '../../domain/player_stats.dart';

class PlayerController extends AsyncNotifier<PlayerStats> {
  @override
  Future<PlayerStats> build() async {
    final settings = await ref.watch(settingsStoreProvider.future);
    await settings.applyXpCurveMigration();
    return settings.readStats();
  }

  SettingsStore get _settings =>
      ref.read(settingsStoreProvider).value ??
      (throw StateError('SettingsStore no inicializado'));

  Future<PlayerStats> current() async => state.value ?? await future;

  Future<void> _save(PlayerStats next) async {
    state = AsyncData(next);
    await _settings.writeStats(next);
  }

  Future<void> rename(String name) async {
    final stats = state.value ?? await future;
    final trimmed = name.trim();
    await _save(
      stats.copyWith(
        name: trimmed.isEmpty ? SettingsStore.defaultName : trimmed,
      ),
    );
  }

  Future<RewardResult> grantXp(int amount) async {
    final stats = state.value ?? await future;
    if (amount <= 0) {
      return RewardResult(xpEarned: 0, leveledUp: false, newLevel: stats.level);
    }
    final next = stats.copyWith(totalXp: stats.totalXp + amount);
    await _save(next);
    return RewardResult(
      xpEarned: amount,
      leveledUp: next.level > stats.level,
      newLevel: next.level,
    );
  }

  Future<PlayerStats> revokeXp(int amount) async {
    final stats = state.value ?? await future;
    if (amount <= 0) return stats;
    final next = stats.copyWith(totalXp: stats.totalXp - amount);
    await _save(next);
    return next;
  }

  Future<void> syncStreak({
    required int streak,
    required DateTime? lastCompletion,
  }) async {
    final stats = state.value ?? await future;
    if (stats.streak == streak && stats.lastCompletion == lastCompletion) {
      return;
    }
    await _save(
      stats.copyWith(
        streak: streak,
        lastCompletion: lastCompletion,
        clearLastCompletion: lastCompletion == null,
      ),
    );
  }
}

class RewardResult {
  const RewardResult({
    required this.xpEarned,
    required this.leveledUp,
    required this.newLevel,
  });

  const RewardResult.none() : xpEarned = 0, leveledUp = false, newLevel = 0;

  final int xpEarned;
  final bool leveledUp;
  final int newLevel;
}

final playerProvider = AsyncNotifierProvider<PlayerController, PlayerStats>(
  PlayerController.new,
);
