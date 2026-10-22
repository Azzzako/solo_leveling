import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/dates.dart';
import '../../../player/domain/player_stats.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../data/mission_repository.dart';

final missionRepositoryProvider = Provider<MissionRepository>(
  (ref) => MissionRepository(ref.watch(appDatabaseProvider)),
);
final dailyMissionsProvider = StreamProvider<List<Mission>>((ref) {
  final day = ref.watch(todayProvider);
  return ref.watch(missionRepositoryProvider).watchDaily(day);
});
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

class PlayerEffects {
  PlayerEffects(Ref ref)
    : _repository = ref.read(missionRepositoryProvider),
      _player = ref.read(playerProvider.notifier),
      _today = ref.read(todayProvider);

  final MissionRepository _repository;
  final PlayerController _player;
  final DateTime _today;

  Future<int> level() async => (await _player.current()).level;

  Future<RewardResult> reward(int xp) async {
    final result = await _player.grantXp(xp);
    await syncStreak();
    return result;
  }

  Future<void> penalize(int xp) => _player.revokeXp(xp);

  Future<ResetOutcome> refund(ResetOutcome outcome) async {
    if (outcome.xpRefunded > 0) await _player.revokeXp(outcome.xpRefunded);
    await syncStreak();
    return outcome;
  }

  Future<void> syncStreak() async {
    final times = await _repository.completionTimes();
    await _player.syncStreak(
      streak: PlayerStats.streakFrom(times, _today),
      lastCompletion: times.isEmpty ? null : times.first,
    );
  }
}

final ensureDailyMissionsProvider = FutureProvider<void>((ref) async {
  final settlement = ref.watch(dailySettlementProvider.future);
  final settingsStore = ref.watch(settingsStoreProvider.future);
  final repository = ref.watch(missionRepositoryProvider);
  final day = ref.watch(todayProvider);
  final effects = PlayerEffects(ref);

  await settlement;
  final settings = await settingsStore;
  final level = await effects.level();

  final stackChanged = await repository.ensureStackSeeded();
  final existing = await repository.dailyMissionsOn(day);
  if (existing.isEmpty) {
    await repository.generateDailyMissions(day, level: level);
  } else if (stackChanged ||
      !await repository.stackMatchesTemplates(existing)) {
    await effects.refund(await repository.rebuildDay(day, level: level));
  }
  await settings.writeDailyMissionsSeed(day);
});

const maxSettledGapDays = 90;

class DailySettlement {
  const DailySettlement({
    required this.daysSettled,
    required this.penaltyApplied,
    this.daysPenalized = 0,
  });

  final int daysSettled;
  final int daysPenalized;
  final int penaltyApplied;
}

final dailySettlementProvider = FutureProvider<DailySettlement>((ref) async {
  final settingsStore = ref.watch(settingsStoreProvider.future);
  final repository = ref.watch(missionRepositoryProvider);
  final today = ref.watch(todayProvider);
  final effects = PlayerEffects(ref);
  final settings = await settingsStore;

  final yesterday = previousDay(today);
  final lastSettled = settings.lastSettledDate;
  var day = lastSettled == null ? yesterday : nextDay(dateOnly(lastSettled));
  final oldestAllowed = DateTime(
    today.year,
    today.month,
    today.day - maxSettledGapDays,
  );
  if (day.isBefore(oldestAllowed)) day = oldestAllowed;

  var daysSettled = 0;
  var daysPenalized = 0;
  var penalty = 0;
  while (day.isBefore(today)) {
    final dayPenalty = await repository.penaltyForDay(day);
    if (dayPenalty > 0) daysPenalized++;
    penalty += dayPenalty;
    daysSettled++;
    day = nextDay(day);
  }
  if (daysSettled > 0 || lastSettled == null) {
    await settings.writeLastSettledDate(yesterday);
  }
  if (penalty > 0) await effects.penalize(penalty);
  await effects.syncStreak();

  return DailySettlement(
    daysSettled: daysSettled,
    daysPenalized: daysPenalized,
    penaltyApplied: penalty,
  );
});

final registerMissionProgressProvider = Provider<MissionProgressAction>(
  (ref) => MissionProgressAction(ref),
);

class MissionProgressAction {
  MissionProgressAction(this._ref);
  final Ref _ref;

  Future<RewardResult> _reward(
    PlayerEffects effects,
    MissionCompletionOutcome outcome,
  ) async {
    if (!outcome.missionCompleted) return const RewardResult.none();
    return effects.reward(outcome.xpEarned);
  }

  Future<RewardResult> advance(Mission mission, {int amount = 1}) async {
    final effects = PlayerEffects(_ref);
    final repository = _ref.read(missionRepositoryProvider);
    return _reward(
      effects,
      await repository.registerProgress(mission.id, amount: amount),
    );
  }

  Future<RewardResult> complete(Mission mission) =>
      advance(mission, amount: mission.target);

  Future<RewardResult> advanceSubtask(
    MissionSubtask subtask, {
    int amount = 1,
  }) async {
    final effects = PlayerEffects(_ref);
    final outcome = await _ref
        .read(missionRepositoryProvider)
        .registerSubtaskProgress(subtask.id, amount: amount);
    return _reward(effects, outcome.mission);
  }

  Future<RewardResult> completeSubtask(MissionSubtask subtask) =>
      advanceSubtask(subtask, amount: subtask.target - subtask.progress);

  Future<ResetOutcome> resetToday() async {
    final effects = PlayerEffects(_ref);
    final repository = _ref.read(missionRepositoryProvider);
    return effects.refund(await repository.resetDay(_ref.read(todayProvider)));
  }

  Future<ResetOutcome> undoMission(Mission mission) async {
    final effects = PlayerEffects(_ref);
    final repository = _ref.read(missionRepositoryProvider);
    return effects.refund(await repository.resetMission(mission.id));
  }

  Future<ResetOutcome> undoSubtask(MissionSubtask subtask) async {
    final effects = PlayerEffects(_ref);
    final repository = _ref.read(missionRepositoryProvider);
    return effects.refund(await repository.resetSubtask(subtask.id));
  }
}
