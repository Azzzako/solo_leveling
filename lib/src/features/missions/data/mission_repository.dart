import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../../../core/utils/dates.dart';
import '../domain/interview_catalog.dart';
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

  const ResetOutcome.none()
    : missionsCleared = 0,
      completionsRemoved = 0,
      xpRefunded = 0;

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
    final start = dateOnly(day);
    final end = nextDay(start);
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
    final start = dateOnly(day);
    final end = nextDay(start);
    final query =
        _db.select(_db.missionCompletions).join([
            innerJoin(
              _db.missions,
              _db.missions.id.equalsExp(_db.missionCompletions.missionId),
            ),
          ])
          ..where(
            _db.missions.dueDate.isBiggerOrEqualValue(start) &
                _db.missions.dueDate.isSmallerThanValue(end),
          )
          ..orderBy([OrderingTerm.desc(_db.missionCompletions.completedAt)]);
    return query.watch().map(
      (rows) => rows
          .map((row) => row.readTable(_db.missionCompletions))
          .toList(growable: false),
    );
  }

  Stream<List<MissionSubtask>> watchSubtasksForDay(DateTime day) {
    final start = dateOnly(day);
    final end = nextDay(start);
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
    final start = dateOnly(day);
    final end = nextDay(start);
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
  }) => _db.transaction(
    () => _registerProgress(missionId, amount: amount, complete: complete),
  );

  Future<MissionCompletionOutcome> _registerProgress(
    String missionId, {
    required int amount,
    required bool complete,
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
  }) => _db.transaction(
    () => _registerSubtaskProgress(subtaskId, amount: amount),
  );

  Future<SubtaskProgressOutcome> _registerSubtaskProgress(
    String subtaskId, {
    required int amount,
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

  Future<List<MissionCompletion>> _completionsOf(Iterable<String> missionIds) {
    final ids = missionIds.toList(growable: false);
    if (ids.isEmpty) return Future.value(const []);
    return (_db.select(
      _db.missionCompletions,
    )..where((c) => c.missionId.isIn(ids))).get();
  }

  Future<int> penaltyForDay(DateTime day) async {
    final missions = await dailyMissionsOn(day);
    if (missions.isEmpty) return _missedDayPenalty(day);
    final completions = await _completionsOf(missions.map((m) => m.id));
    final doneIds = {for (final c in completions) c.missionId};
    var penalty = 0;
    for (final mission in missions) {
      if (!doneIds.contains(mission.id)) penalty += mission.xpReward;
    }
    return penalty;
  }

  Future<int> _missedDayPenalty(DateTime day) async {
    final first = await firstDailyMissionDay();
    if (first == null || dateOnly(day).isBefore(first)) return 0;
    final templates = await stackTemplates();
    return templates.fold<int>(0, (sum, t) => sum + t.xpReward);
  }

  Future<DateTime?> firstDailyMissionDay() async {
    final earliest = _db.missions.dueDate.min();
    final row =
        await (_db.selectOnly(_db.missions)
              ..addColumns([earliest])
              ..where(_db.missions.isDaily.equals(true)))
            .getSingleOrNull();
    final value = row?.read(earliest);
    return value == null ? null : dateOnly(value);
  }

  Future<List<DateTime>> completionTimes() async {
    final rows = await (_db.select(
      _db.missionCompletions,
    )..orderBy([(c) => OrderingTerm.desc(c.completedAt)])).get();
    return [for (final row in rows) row.completedAt];
  }

  Future<ResetOutcome> resetMission(String missionId) =>
      _db.transaction(() => _resetMission(missionId));

  Future<ResetOutcome> _resetMission(String missionId) async {
    final mission = await _missionById(missionId);
    if (mission == null) return const ResetOutcome.none();

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

  Future<ResetOutcome> resetSubtask(String subtaskId) =>
      _db.transaction(() => _resetSubtask(subtaskId));

  Future<ResetOutcome> _resetSubtask(String subtaskId) async {
    final subtask = await (_db.select(
      _db.missionSubtasks,
    )..where((s) => s.id.equals(subtaskId))).getSingleOrNull();
    if (subtask == null) return const ResetOutcome.none();

    final mission = await _missionById(subtask.missionId);
    await (_db.update(_db.missionSubtasks)
          ..where((s) => s.id.equals(subtaskId)))
        .write(const MissionSubtasksCompanion(progress: Value(0)));
    if (mission == null) return const ResetOutcome.none();

    final done = await subtasksOf(mission.id);
    final completed = done.where((s) => s.progress >= s.target).length;
    await (_db.update(_db.missions)..where((m) => m.id.equals(mission.id)))
        .write(MissionsCompanion(progress: Value(completed)));

    if (completed >= mission.target) return const ResetOutcome.none();

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

  Future<ResetOutcome> resetDay(DateTime day) => _db.transaction(() async {
    final missions = await dailyMissionsOn(day);
    final completions = await _completionsOf(missions.map((m) => m.id));

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
  });

  Stream<List<StackTemplate>> watchStackTemplates() => (_db.select(
    _db.stackTemplates,
  )..orderBy([(t) => OrderingTerm.asc(t.slot)])).watch();

  Future<List<StackTemplate>> stackTemplates() => (_db.select(
    _db.stackTemplates,
  )..orderBy([(t) => OrderingTerm.asc(t.slot)])).get();

  Future<List<StackSubtask>> stackSubtasksOf(String templateId) =>
      (_db.select(_db.stackSubtasks)
            ..where((s) => s.templateId.equals(templateId))
            ..orderBy([(s) => OrderingTerm.asc(s.sortOrder)]))
          .get();

  Future<UserPreference?> userPreference() => (_db.select(
    _db.userPreferences,
  )..where((p) => p.id.equals(1))).getSingleOrNull();

  Future<void> savePreferences({
    required DailyGoal goal,
    required Map<String, String> answers,
    required String source,
  }) async {
    await _db
        .into(_db.userPreferences)
        .insertOnConflictUpdate(
          UserPreferencesCompanion.insert(
            id: const Value(1),
            goal: goal,
            answers: Value(_encodeAnswers(answers)),
            source: Value(source),
            stackVersion: Value(stackFormatVersion),
            configuredAt: DateTime.now(),
          ),
        );
  }

  Future<void> saveStack(DailyGoal goal, List<MissionDraft> drafts) =>
      _db.transaction(() async {
        await _db.delete(_db.stackTemplates).go();
        for (var slot = 0; slot < drafts.length; slot++) {
          final draft = drafts[slot];
          final templateId = uuid.v4();
          await _db
              .into(_db.stackTemplates)
              .insert(
                StackTemplatesCompanion.insert(
                  id: templateId,
                  goal: goal,
                  slot: slot,
                  title: draft.title,
                  description: Value(draft.description),
                  difficulty: draft.difficulty,
                  xpReward: draft.xpReward,
                  target: Value(draft.target),
                  stackVersion: const Value(stackFormatVersion),
                ),
              );
          for (var order = 0; order < draft.subtasks.length; order++) {
            final subtask = draft.subtasks[order];
            await _db
                .into(_db.stackSubtasks)
                .insert(
                  StackSubtasksCompanion.insert(
                    id: uuid.v4(),
                    templateId: templateId,
                    title: subtask.title,
                    base: subtask.base,
                    perLevel: Value(subtask.perLevel),
                    maxLevel: Value(subtask.maxLevel),
                    sortOrder: Value(order),
                  ),
                );
          }
        }
      });

  Future<bool> ensureStackSeeded() async {
    if ((await stackTemplates()).isNotEmpty) return _refreshOutdatedStack();
    final adopted = await _stackFromExistingMissions();
    if (adopted != null) {
      await saveStack(DailyGoal.fisico, adopted);
      await savePreferences(
        goal: DailyGoal.fisico,
        answers: const {},
        source: PreferenceSource.migrated,
      );
      return true;
    }
    await saveStack(DailyGoal.fisico, defaultStack());
    await savePreferences(
      goal: DailyGoal.fisico,
      answers: const {},
      source: PreferenceSource.seeded,
    );
    return true;
  }

  Future<bool> _refreshOutdatedStack() async {
    final preference = await userPreference();
    if (preference == null || preference.stackVersion >= stackFormatVersion) {
      return false;
    }
    final regenerate = preference.source != PreferenceSource.migrated;
    if (regenerate) {
      await saveStack(
        preference.goal,
        buildStack(preference.goal, decodeAnswers(preference.answers)),
      );
    }
    await (_db.update(
      _db.userPreferences,
    )..where((p) => p.id.equals(preference.id))).write(
      const UserPreferencesCompanion(stackVersion: Value(stackFormatVersion)),
    );
    return regenerate;
  }

  Future<List<MissionDraft>?> _stackFromExistingMissions() async {
    final templates = _db.select(_db.missions)
      ..where((m) => m.isDaily.equals(true))
      ..orderBy([(m) => OrderingTerm.desc(m.dueDate)])
      ..limit(1);
    final last = await templates.getSingleOrNull();
    if (last == null) return null;

    final rows =
        await (_db.select(_db.missions)
              ..where(
                (m) =>
                    m.isDaily.equals(true) &
                    m.dueDate.isBiggerOrEqualValue(
                      DateTime(
                        last.dueDate!.year,
                        last.dueDate!.month,
                        last.dueDate!.day,
                      ),
                    ) &
                    m.dueDate.isSmallerThanValue(
                      DateTime(
                        last.dueDate!.year,
                        last.dueDate!.month,
                        last.dueDate!.day,
                      ).add(const Duration(days: 1)),
                    ),
              )
              ..orderBy([(m) => OrderingTerm.asc(m.sortOrder)]))
            .get();
    if (rows.isEmpty) return null;

    final drafts = <MissionDraft>[];
    for (final mission in rows) {
      final subtasks = await subtasksOf(mission.id);
      drafts.add(
        MissionDraft(
          kind: mission.title,
          title: mission.title,
          description: mission.description,
          difficulty: mission.difficulty,
          xpReward: mission.xpReward,
          target: mission.target,
          subtasks: [
            for (final subtask in subtasks)
              SubtaskDraft(title: subtask.title, base: subtask.target),
          ],
        ),
      );
    }
    return normalizeXp(drafts, dailyStackXp);
  }

  Future<ResetOutcome> applyStack({
    required DailyGoal goal,
    required Map<String, String> answers,
    required DateTime day,
    required int level,
    String source = PreferenceSource.interview,
  }) async {
    await saveStack(goal, buildStack(goal, answers));
    await savePreferences(goal: goal, answers: answers, source: source);

    final existing = await dailyMissionsOn(day);
    if (existing.isEmpty) {
      await generateDailyMissions(day, level: level);
      return const ResetOutcome.none();
    }
    if (await stackMatchesTemplates(existing)) {
      return const ResetOutcome.none();
    }
    return rebuildDay(day, level: level);
  }

  Future<bool> stackMatchesTemplates(List<Mission> missions) async {
    final templates = await stackTemplates();
    if (templates.isEmpty || missions.length != templates.length) return false;
    for (var i = 0; i < templates.length; i++) {
      final template = templates[i];
      final mission = missions[i];
      if (mission.title != template.title) return false;
      if (mission.xpReward != template.xpReward) return false;
      final subtasks = await stackSubtasksOf(template.id);
      final expected = subtasks.isEmpty ? template.target : subtasks.length;
      if (mission.target != expected) return false;
      final current = await subtasksOf(mission.id);
      if (current.map((s) => s.title).join('|') !=
          subtasks.map((s) => s.title).join('|')) {
        return false;
      }
    }
    return true;
  }

  Future<int> generateDailyMissions(DateTime day, {required int level}) async {
    await ensureStackSeeded();
    return _db.transaction(() async {
      if ((await dailyMissionsOn(day)).isNotEmpty) return 0;
      return (await _insertStack(day, level: level)).length;
    });
  }

  Future<ResetOutcome> rebuildDay(DateTime day, {required int level}) async {
    await ensureStackSeeded();
    return _db.transaction(() async {
      final previous = await dailyMissionsOn(day);
      final created = await _insertStack(day, level: level);
      var removed = 0;
      var refunded = 0;
      for (final old in previous) {
        final completions = await _completionsOf([old.id]);
        final match = created.where(
          (m) => m.title == old.title && m.target == old.target,
        );
        if (match.isEmpty) {
          removed += completions.length;
          refunded += completions.fold<int>(0, (sum, c) => sum + c.xpEarned);
        } else {
          await _carryOver(old, match.first, completed: completions.isNotEmpty);
        }
        await delete(old.id);
      }
      return ResetOutcome(
        missionsCleared: previous.length,
        completionsRemoved: removed,
        xpRefunded: refunded,
      );
    });
  }

  Future<void> _carryOver(
    Mission from,
    Mission to, {
    required bool completed,
  }) async {
    final oldSubtasks = await subtasksOf(from.id);
    final newSubtasks = await subtasksOf(to.id);
    var progress = completed ? to.target : from.progress.clamp(0, to.target);
    if (newSubtasks.isNotEmpty) {
      var done = 0;
      for (final subtask in newSubtasks) {
        final old = oldSubtasks.where((s) => s.title == subtask.title);
        final oldDone =
            old.isNotEmpty && old.first.progress >= old.first.target;
        final next = completed || oldDone
            ? subtask.target
            : (old.isEmpty ? 0 : old.first.progress.clamp(0, subtask.target));
        if (next >= subtask.target) done++;
        await (_db.update(_db.missionSubtasks)
              ..where((s) => s.id.equals(subtask.id)))
            .write(MissionSubtasksCompanion(progress: Value(next)));
      }
      progress = done;
    }
    await (_db.update(_db.missions)..where((m) => m.id.equals(to.id))).write(
      MissionsCompanion(progress: Value(progress)),
    );
    await (_db.update(_db.missionCompletions)
          ..where((c) => c.missionId.equals(from.id)))
        .write(MissionCompletionsCompanion(missionId: Value(to.id)));
  }

  Future<List<Mission>> _insertStack(DateTime day, {required int level}) async {
    final templates = await stackTemplates();
    final due = DateTime(day.year, day.month, day.day, 23, 59);
    final created = <Mission>[];

    for (final template in templates) {
      final subtasks = await stackSubtasksOf(template.id);
      final missionId = uuid.v4();
      final row = MissionsCompanion.insert(
        id: missionId,
        title: template.title,
        description: Value(template.description),
        difficulty: template.difficulty,
        xpReward: template.xpReward,
        target: Value(subtasks.isEmpty ? template.target : subtasks.length),
        isDaily: const Value(true),
        dueDate: Value(due),
        sortOrder: Value(template.slot),
        createdAt: DateTime.now(),
      );
      created.add(await _db.into(_db.missions).insertReturning(row));
      for (var order = 0; order < subtasks.length; order++) {
        final subtask = subtasks[order];
        await _db
            .into(_db.missionSubtasks)
            .insert(
              MissionSubtasksCompanion.insert(
                id: uuid.v4(),
                missionId: missionId,
                title: subtask.title,
                target: _subtaskTarget(subtask, level),
                sortOrder: Value(order),
                createdAt: DateTime.now(),
              ),
            );
      }
    }
    return created;
  }

  int _subtaskTarget(StackSubtask subtask, int level) =>
      subtask.base +
      subtask.perLevel *
          ((level < 1 ? 1 : level).clamp(1, subtask.maxLevel) - 1);

  String _encodeAnswers(Map<String, String> answers) => jsonEncode(answers);

  Map<String, String> decodeAnswers(String raw) {
    if (raw.trim().isEmpty) return const {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return const {};
    return decoded.map((key, value) => MapEntry(key, '$value'));
  }
}

abstract final class PreferenceSource {
  static const interview = 'interview';
  static const skipped = 'skipped';
  static const seeded = 'default';
  static const migrated = 'migrated';

  static bool isConfigured(String source) =>
      source == interview || source == skipped;
}
