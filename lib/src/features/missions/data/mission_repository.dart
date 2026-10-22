import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../domain/daily_stack.dart';
import '../domain/mission_difficulty.dart';

class MissionCompletionOutcome {
  const MissionCompletionOutcome({
    required this.xpEarned,
    required this.missionCompleted,
  });

  const MissionCompletionOutcome.noop()
    : xpEarned = 0,
      missionCompleted = false;

  final int xpEarned;
  final bool missionCompleted;
}

class ResetOutcome {
  const ResetOutcome({
    required this.missionsCleared,
    required this.completionsRemoved,
    required this.xpRefunded,
  });

  final int missionsCleared;
  final int completionsRemoved;
  final int xpRefunded;
}

class SubtaskProgressOutcome {
  const SubtaskProgressOutcome({
    required this.subtaskCompleted,
    required this.mission,
  });

  final bool subtaskCompleted;
  final MissionCompletionOutcome mission;
}

class MissionRepository {
  MissionRepository(this._db, {this.uuid = const Uuid()});

  final AppDatabase _db;
  final Uuid uuid;

  Stream<List<Mission>> watchActive() =>
      (_db.select(_db.missions)
            ..where((m) => m.isActive.equals(true))
            ..orderBy([
              (m) => OrderingTerm.asc(m.sortOrder),
              (m) => OrderingTerm.asc(m.createdAt),
            ]))
          .watch();

  Stream<List<Mission>> watchDaily(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.missions)
          ..where(
            (m) =>
                m.isDaily.equals(true) &
                m.isActive.equals(true) &
                m.dueDate.isBiggerOrEqualValue(start) &
                m.dueDate.isSmallerThanValue(end),
          )
          ..orderBy([(m) => OrderingTerm.asc(m.sortOrder)]))
        .watch();
  }

  Stream<List<MissionCompletion>> watchCompletionsOn(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.missionCompletions)
          ..where(
            (c) =>
                c.completedAt.isBiggerOrEqualValue(start) &
                c.completedAt.isSmallerThanValue(end),
          )
          ..orderBy([(c) => OrderingTerm.desc(c.completedAt)]))
        .watch();
  }

  Stream<List<MissionSubtask>> watchSubtasksForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final query =
        _db.select(_db.missionSubtasks).join([
            innerJoin(
              _db.missions,
              _db.missions.id.equalsExp(_db.missionSubtasks.missionId),
            ),
          ])
          ..where(
            _db.missions.isDaily.equals(true) &
                _db.missions.dueDate.isBiggerOrEqualValue(start) &
                _db.missions.dueDate.isSmallerThanValue(end),
          )
          ..orderBy([OrderingTerm.asc(_db.missionSubtasks.sortOrder)]);
    return query.watch().map(
      (rows) => rows
          .map((row) => row.readTable(_db.missionSubtasks))
          .toList(growable: false),
    );
  }

  Future<List<MissionSubtask>> subtasksOf(String missionId) =>
      (_db.select(_db.missionSubtasks)
            ..where((s) => s.missionId.equals(missionId))
            ..orderBy([(s) => OrderingTerm.asc(s.sortOrder)]))
          .get();

  Future<List<Mission>> dailyMissionsOn(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.missions)
          ..where(
            (m) =>
                m.isDaily.equals(true) &
                m.dueDate.isBiggerOrEqualValue(start) &
                m.dueDate.isSmallerThanValue(end),
          )
          ..orderBy([(m) => OrderingTerm.asc(m.sortOrder)]))
        .get();
  }

  Future<Mission> create({
    required String title,
    String description = '',
    String? goalId,
    MissionDifficulty difficulty = MissionDifficulty.medium,
    int target = 1,
    bool isDaily = false,
    DateTime? dueDate,
  }) async {
    final id = uuid.v4();
    await _db
        .into(_db.missions)
        .insert(
          MissionsCompanion.insert(
            id: id,
            title: title,
            description: Value(description),
            goalId: Value(goalId),
            difficulty: difficulty,
            xpReward: difficulty.baseXp,
            target: Value(target),
            isDaily: Value(isDaily),
            dueDate: Value(dueDate),
            createdAt: DateTime.now(),
          ),
        );
    return (_db.select(
      _db.missions,
    )..where((m) => m.id.equals(id))).getSingle();
  }

  Future<MissionCompletionOutcome> registerProgress(
    String missionId, {
    int amount = 1,
    bool complete = false,
  }) async {
    final mission = await _missionById(missionId);
    if (mission == null) return const MissionCompletionOutcome.noop();
    final subtasks = await subtasksOf(missionId);
    if (subtasks.isNotEmpty) return const MissionCompletionOutcome.noop();

    final nextProgress = complete || mission.progress + amount >= mission.target
        ? mission.target
        : mission.progress + amount;

    return _settleProgress(mission, nextProgress);
  }

  Future<SubtaskProgressOutcome> registerSubtaskProgress(
    String subtaskId, {
    int amount = 1,
  }) async {
    final subtask = await (_db.select(
      _db.missionSubtasks,
    )..where((s) => s.id.equals(subtaskId))).getSingleOrNull();
    if (subtask == null || subtask.progress >= subtask.target) {
      return const SubtaskProgressOutcome(
        subtaskCompleted: false,
        mission: MissionCompletionOutcome.noop(),
      );
    }

    final next = (subtask.progress + amount).clamp(0, subtask.target);
    await (_db.update(_db.missionSubtasks)
          ..where((s) => s.id.equals(subtaskId)))
        .write(MissionSubtasksCompanion(progress: Value(next)));

    if (next < subtask.target) {
      return const SubtaskProgressOutcome(
        subtaskCompleted: false,
        mission: MissionCompletionOutcome.noop(),
      );
    }

    final mission = await _missionById(subtask.missionId);
    if (mission == null) {
      return const SubtaskProgressOutcome(
        subtaskCompleted: true,
        mission: MissionCompletionOutcome.noop(),
      );
    }

    final done = await subtasksOf(mission.id);
    final completedCount = done.where((s) => s.progress >= s.target).length;
    final outcome = await _settleProgress(
      mission,
      completedCount.clamp(0, mission.target),
    );
    return SubtaskProgressOutcome(subtaskCompleted: true, mission: outcome);
  }

  Future<MissionCompletionOutcome> _settleProgress(
    Mission mission,
    int nextProgress,
  ) async {
    final finished = nextProgress >= mission.target;

    await (_db.update(_db.missions)..where((m) => m.id.equals(mission.id)))
        .write(MissionsCompanion(progress: Value(nextProgress)));

    if (!finished) return const MissionCompletionOutcome.noop();

    final alreadyLogged = await (_db.select(
      _db.missionCompletions,
    )..where((c) => c.missionId.equals(mission.id))).get();
    if (alreadyLogged.isNotEmpty) {
      return const MissionCompletionOutcome.noop();
    }

    await _db
        .into(_db.missionCompletions)
        .insert(
          MissionCompletionsCompanion.insert(
            id: uuid.v4(),
            missionId: mission.id,
            completedAt: DateTime.now(),
            xpEarned: mission.xpReward,
          ),
        );

    return MissionCompletionOutcome(
      xpEarned: mission.xpReward,
      missionCompleted: true,
    );
  }

  Future<Mission?> _missionById(String id) => (_db.select(
    _db.missions,
  )..where((m) => m.id.equals(id))).getSingleOrNull();

  Future<void> delete(String id) async {
    await (_db.delete(
      _db.missionSubtasks,
    )..where((s) => s.missionId.equals(id))).go();
    await (_db.delete(
      _db.missionCompletions,
    )..where((c) => c.missionId.equals(id))).go();
    await (_db.delete(_db.missions)..where((m) => m.id.equals(id))).go();
  }

  Future<void> reactivate(String id) async {
    await (_db.update(_db.missions)..where((m) => m.id.equals(id))).write(
      MissionsCompanion(progress: const Value(0)),
    );
    await (_db.update(_db.missionSubtasks)
          ..where((s) => s.missionId.equals(id)))
        .write(const MissionSubtasksCompanion(progress: Value(0)));
    await (_db.delete(
      _db.missionCompletions,
    )..where((c) => c.missionId.equals(id))).go();
  }

  Future<void> clearDailyMissions(DateTime day) async {
    final missions = await dailyMissionsOn(day);
    for (final mission in missions) {
      await delete(mission.id);
    }
  }

  Future<int> penaltyForDay(DateTime day) async {
    final missions = await dailyMissionsOn(day);
    if (missions.isEmpty) return 0;
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final completions =
        await (_db.select(_db.missionCompletions)..where(
              (c) =>
                  c.completedAt.isBiggerOrEqualValue(start) &
                  c.completedAt.isSmallerThanValue(end),
            ))
            .get();
    final doneIds = {for (final c in completions) c.missionId};
    var penalty = 0;
    for (final mission in missions) {
      if (!doneIds.contains(mission.id)) penalty += mission.xpReward;
    }
    return penalty;
  }

  Future<ResetOutcome> resetMission(String missionId) async {
    final mission = await _missionById(missionId);
    if (mission == null) {
      return const ResetOutcome(
        missionsCleared: 0,
        completionsRemoved: 0,
        xpRefunded: 0,
      );
    }

    final completions = await (_db.select(
      _db.missionCompletions,
    )..where((c) => c.missionId.equals(missionId))).get();
    var refunded = 0;
    for (final completion in completions) {
      refunded += completion.xpEarned;
      await (_db.delete(
        _db.missionCompletions,
      )..where((c) => c.id.equals(completion.id))).go();
    }

    await (_db.update(_db.missions)..where((m) => m.id.equals(missionId)))
        .write(const MissionsCompanion(progress: Value(0)));
    await (_db.update(_db.missionSubtasks)
          ..where((s) => s.missionId.equals(missionId)))
        .write(const MissionSubtasksCompanion(progress: Value(0)));

    return ResetOutcome(
      missionsCleared: 1,
      completionsRemoved: completions.length,
      xpRefunded: refunded,
    );
  }

  Future<ResetOutcome> resetSubtask(String subtaskId) async {
    final subtask = await (_db.select(
      _db.missionSubtasks,
    )..where((s) => s.id.equals(subtaskId))).getSingleOrNull();
    if (subtask == null) {
      return const ResetOutcome(
        missionsCleared: 0,
        completionsRemoved: 0,
        xpRefunded: 0,
      );
    }

    final mission = await _missionById(subtask.missionId);
    await (_db.update(_db.missionSubtasks)
          ..where((s) => s.id.equals(subtaskId)))
        .write(const MissionSubtasksCompanion(progress: Value(0)));
    if (mission == null) {
      return const ResetOutcome(
        missionsCleared: 0,
        completionsRemoved: 0,
        xpRefunded: 0,
      );
    }

    final done = await subtasksOf(mission.id);
    final completed = done.where((s) => s.progress >= s.target).length;
    await (_db.update(_db.missions)..where((m) => m.id.equals(mission.id)))
        .write(MissionsCompanion(progress: Value(completed)));

    if (completed >= mission.target) {
      return const ResetOutcome(
        missionsCleared: 0,
        completionsRemoved: 0,
        xpRefunded: 0,
      );
    }

    final completions = await (_db.select(
      _db.missionCompletions,
    )..where((c) => c.missionId.equals(mission.id))).get();
    var refunded = 0;
    for (final completion in completions) {
      refunded += completion.xpEarned;
      await (_db.delete(
        _db.missionCompletions,
      )..where((c) => c.id.equals(completion.id))).go();
    }

    return ResetOutcome(
      missionsCleared: 0,
      completionsRemoved: completions.length,
      xpRefunded: refunded,
    );
  }

  Future<ResetOutcome> resetDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final completions =
        await (_db.select(_db.missionCompletions)..where(
              (c) =>
                  c.completedAt.isBiggerOrEqualValue(start) &
                  c.completedAt.isSmallerThanValue(end),
            ))
            .get();
    final missions = await dailyMissionsOn(day);

    var refunded = 0;
    for (final completion in completions) {
      refunded += completion.xpEarned;
      await (_db.delete(
        _db.missionCompletions,
      )..where((c) => c.id.equals(completion.id))).go();
    }

    for (final mission in missions) {
      await (_db.update(_db.missions)..where((m) => m.id.equals(mission.id)))
          .write(MissionsCompanion(progress: const Value(0)));
      await (_db.update(_db.missionSubtasks)
            ..where((s) => s.missionId.equals(mission.id)))
          .write(const MissionSubtasksCompanion(progress: Value(0)));
    }

    return ResetOutcome(
      missionsCleared: missions.length,
      completionsRemoved: completions.length,
      xpRefunded: refunded,
    );
  }

  bool matchesFixedStack(List<Mission> missions) {
    if (missions.length != fixedDailyStack.length) return false;
    for (var i = 0; i < fixedDailyStack.length; i++) {
      if (missions[i].title != fixedDailyStack[i].title) return false;
    }
    return true;
  }

  Future<int> generateDailyMissions(DateTime day, {required int level}) async {
    final existing = await dailyMissionsOn(day);
    if (existing.isNotEmpty) return 0;

    final due = DateTime(day.year, day.month, day.day, 23, 59);

    for (var i = 0; i < fixedDailyStack.length; i++) {
      final spec = fixedDailyStack[i];
      final missionId = uuid.v4();
      await _db
          .into(_db.missions)
          .insert(
            MissionsCompanion.insert(
              id: missionId,
              title: spec.title,
              description: Value(spec.description),
              difficulty: spec.difficulty,
              xpReward: spec.xpReward,
              target: Value(
                spec.hasSubtasks ? spec.subtasks.length : spec.target,
              ),
              isDaily: const Value(true),
              dueDate: Value(due),
              sortOrder: Value(i),
              createdAt: DateTime.now(),
            ),
          );

      for (var s = 0; s < spec.subtasks.length; s++) {
        final subtask = spec.subtasks[s];
        await _db
            .into(_db.missionSubtasks)
            .insert(
              MissionSubtasksCompanion.insert(
                id: uuid.v4(),
                missionId: missionId,
                title: subtask.title,
                target: subtask.targetAt(level),
                sortOrder: Value(s),
                createdAt: DateTime.now(),
              ),
            );
      }
    }

    return fixedDailyStack.length;
  }
}
