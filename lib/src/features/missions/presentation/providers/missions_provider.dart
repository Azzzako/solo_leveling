import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../data/mission_repository.dart';

final missionRepositoryProvider = Provider<MissionRepository>(
  (ref) => MissionRepository(ref.watch(appDatabaseProvider)),
);
final dailyMissionsProvider = StreamProvider<List<Mission>>((ref) {
  final day = ref.watch(todayProvider);
  return ref.watch(missionRepositoryProvider).watchDaily(day);
});
final activeMissionsProvider = StreamProvider<List<Mission>>(
  (ref) => ref.watch(missionRepositoryProvider).watchActive(),
);
final todayCompletionsProvider = StreamProvider<List<MissionCompletion>>((ref) {
  final day = ref.watch(todayProvider);
  return ref.watch(missionRepositoryProvider).watchCompletionsOn(day);
});
final todaySubtasksProvider = StreamProvider<List<MissionSubtask>>((ref) {
  final day = ref.watch(todayProvider);
  return ref.watch(missionRepositoryProvider).watchSubtasksForDay(day);
});

class DailySummary {
  const DailySummary({
    required this.total,
    required this.completed,
    required this.xp,
  });
  final int total;
  final int completed;
  final int xp;
  double get progress => total == 0 ? 0 : completed / total;
  int get remaining => total - completed;
  static DailySummary from(
    List<Mission> missions,
    List<MissionCompletion> done,
  ) {
    final completedIds = {for (final c in done) c.missionId};
    return DailySummary(
      total: missions.length,
      completed: missions.where((m) => completedIds.contains(m.id)).length,
      xp: done.fold(0, (sum, c) => sum + c.xpEarned),
    );
  }
}

final dailySummaryProvider = Provider<AsyncValue<DailySummary>>((ref) {
  final missions = ref.watch(dailyMissionsProvider);
  final done = ref.watch(todayCompletionsProvider);
  return missions.when(
    data: (m) => done.when(
      data: (c) => AsyncData(DailySummary.from(m, c)),
      loading: () => const AsyncLoading(),
      error: (e, s) => AsyncError(e, s),
    ),
    loading: () => const AsyncLoading(),
    error: (e, s) => AsyncError(e, s),
  );
});
final ensureDailyMissionsProvider = FutureProvider<void>((ref) async {
  final settings = await ref.watch(settingsStoreProvider.future);
  final stats = await ref.watch(playerProvider.future);
  final repository = ref.watch(missionRepositoryProvider);
  final day = ref.watch(todayProvider);

  final existing = await repository.dailyMissionsOn(day);
  final needsRebuild =
      existing.isNotEmpty && !repository.matchesFixedStack(existing);
  final seed = settings.dailyMissionsSeedDate;
  final alreadySeeded =
      seed != null &&
      seed.year == day.year &&
      seed.month == day.month &&
      seed.day == day.day;

  if (needsRebuild) {
    await repository.clearDailyMissions(day);
  } else if (existing.isNotEmpty || alreadySeeded) {
    return;
  }

  await repository.generateDailyMissions(day, level: stats.level);
  await settings.writeDailyMissionsSeed(day);
});
const maxSettledGapDays = 90;

class DailySettlement {
  const DailySettlement({
    required this.daysSettled,
    required this.penaltyApplied,
  });

  final int daysSettled;
  final int penaltyApplied;
}

final dailySettlementProvider = FutureProvider<DailySettlement>((ref) async {
  final settings = await ref.watch(settingsStoreProvider.future);
  final repository = ref.watch(missionRepositoryProvider);
  final today = ref.watch(todayProvider);

  final lastSettled = settings.lastSettledDate;
  final first = lastSettled == null
      ? DateTime(
          today.year,
          today.month,
          today.day,
        ).subtract(const Duration(days: 1))
      : DateTime(
          lastSettled.year,
          lastSettled.month,
          lastSettled.day,
        ).add(const Duration(days: 1));

  var day = first;
  var daysSettled = 0;
  var penalty = 0;
  while (day.isBefore(today) && daysSettled < maxSettledGapDays) {
    final dayPenalty = await repository.penaltyForDay(day);
    if (dayPenalty > 0) {
      await ref
          .read(playerProvider.notifier)
          .revokeXp(dayPenalty, resetStreak: false);
    }
    penalty += dayPenalty;
    daysSettled++;
    day = day.add(const Duration(days: 1));
  }

  final settledThrough = DateTime(
    today.year,
    today.month,
    today.day,
  ).subtract(const Duration(days: 1));
  if (daysSettled > 0 || lastSettled == null) {
    await settings.writeLastSettledDate(settledThrough);
  }

  return DailySettlement(daysSettled: daysSettled, penaltyApplied: penalty);
});

final registerMissionProgressProvider = Provider<MissionProgressAction>(
  (ref) => MissionProgressAction(ref),
);

class MissionProgressAction {
  MissionProgressAction(this._ref);
  final Ref _ref;

  Future<RewardResult> _reward(MissionCompletionOutcome outcome) async {
    if (!outcome.missionCompleted) {
      return const RewardResult(xpEarned: 0, leveledUp: false, newLevel: 0);
    }
    final reward = await _ref
        .read(playerProvider.notifier)
        .rewardMission(outcome.xpEarned);
    return RewardResult(
      xpEarned: reward.xpEarned,
      leveledUp: reward.leveledUp,
      newLevel: reward.leveledUp
          ? reward.newLevel
          : (_ref.read(playerProvider).value?.level ?? 0),
    );
  }

  Future<RewardResult> advance(Mission mission, {int amount = 1}) async =>
      _reward(
        await _ref
            .read(missionRepositoryProvider)
            .registerProgress(mission.id, amount: amount),
      );

  Future<RewardResult> complete(Mission mission) =>
      advance(mission, amount: mission.target);

  Future<RewardResult> advanceSubtask(
    MissionSubtask subtask, {
    int amount = 1,
  }) async {
    final outcome = await _ref
        .read(missionRepositoryProvider)
        .registerSubtaskProgress(subtask.id, amount: amount);
    return _reward(outcome.mission);
  }

  Future<RewardResult> completeSubtask(MissionSubtask subtask) =>
      advanceSubtask(subtask, amount: subtask.target - subtask.progress);

  Future<ResetOutcome> _settle(ResetOutcome outcome) async {
    if (outcome.xpRefunded > 0) {
      await _ref.read(playerProvider.notifier).revokeXp(outcome.xpRefunded);
    }
    return outcome;
  }

  Future<ResetOutcome> resetToday() async {
    final day = _ref.read(todayProvider);
    return _settle(await _ref.read(missionRepositoryProvider).resetDay(day));
  }

  Future<ResetOutcome> undoMission(Mission mission) async {
    return _settle(
      await _ref.read(missionRepositoryProvider).resetMission(mission.id),
    );
  }

  Future<ResetOutcome> undoSubtask(MissionSubtask subtask) async {
    return _settle(
      await _ref.read(missionRepositoryProvider).resetSubtask(subtask.id),
    );
  }
}
