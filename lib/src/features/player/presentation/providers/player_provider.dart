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

  Future<void> rename(String name) async {
    final stats = state.value ?? await future;
    final next = stats.copyWith(
      name: name.trim().isEmpty ? 'Cazador' : name.trim(),
    );
    state = AsyncData(next);
    await _settings.writeStats(next);
  }

  Future<RewardResult> rewardMission(int xpEarned) async {
    final stats = state.value ?? await future;
    final now = DateTime.now();
    final before = stats.level;
    final next = stats.copyWith(
      totalXp: stats.totalXp + xpEarned,
      streak: PlayerStats.streakAfterCompletion(
        currentStreak: stats.streak,
        today: now,
        lastCompletion: stats.lastCompletion,
      ),
      lastCompletion: now,
    );
    state = AsyncData(next);
    await _settings.writeStats(next);
    return RewardResult(
      xpEarned: xpEarned,
      leveledUp: next.level > before,
      newLevel: next.level,
    );
  }

  Future<PlayerStats> revokeXp(int amount, {bool resetStreak = true}) async {
    if (amount <= 0) return state.value ?? await future;
    final stats = state.value ?? await future;
    final today = ref.read(todayProvider);
    final last = stats.lastCompletion;
    final streakStartedToday =
        resetStreak &&
        stats.streak <= 1 &&
        last != null &&
        last.year == today.year &&
        last.month == today.month &&
        last.day == today.day;
    final next = stats.copyWith(
      totalXp: stats.totalXp - amount,
      streak: streakStartedToday ? 0 : stats.streak,
      lastCompletion: streakStartedToday ? null : last,
    );
    state = AsyncData(next);
    await _settings.writeStats(next);
    return next;
  }
}

class RewardResult {
  const RewardResult({
    required this.xpEarned,
    required this.leveledUp,
    required this.newLevel,
  });

  final int xpEarned;
  final bool leveledUp;
  final int newLevel;
}

final playerProvider = AsyncNotifierProvider<PlayerController, PlayerStats>(
  PlayerController.new,
);
