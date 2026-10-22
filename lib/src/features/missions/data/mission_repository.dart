import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
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

  Future<void> saveStack(DailyGoal goal, List<MissionDraft> drafts) async {
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
              stackVersion: const Value(1),
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
  }

  Future<void> ensureStackSeeded() async {
    if ((await stackTemplates()).isNotEmpty) return;
    final adopted = await _stackFromExistingMissions();
    if (adopted != null) {
      await saveStack(DailyGoal.fisico, adopted);
      await savePreferences(
        goal: DailyGoal.fisico,
        answers: const {},
        source: 'migrated',
      );
      return;
    }
    await saveStack(DailyGoal.fisico, defaultStack());
    await savePreferences(
      goal: DailyGoal.fisico,
      answers: const {},
      source: 'default',
    );
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

  Future<void> applyStack({
    required DailyGoal goal,
    required Map<String, String> answers,
    required DateTime day,
    required int level,
    String source = 'interview',
  }) async {
    await saveStack(goal, buildStack(goal, answers));
    await savePreferences(goal: goal, answers: answers, source: source);

    final existing = await dailyMissionsOn(day);
    if (existing.isEmpty) {
      await generateDailyMissions(day, level: level);
      return;
    }
    if (!await stackMatchesTemplates(existing)) {
      await clearDailyMissions(day);
      await generateDailyMissions(day, level: level);
    }
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
    }
    return true;
  }

  Future<int> generateDailyMissions(DateTime day, {required int level}) async {
    final existing = await dailyMissionsOn(day);
    if (existing.isNotEmpty) return 0;

    await ensureStackSeeded();
    final templates = await stackTemplates();
    final due = DateTime(day.year, day.month, day.day, 23, 59);

    for (final template in templates) {
      final subtasks = await stackSubtasksOf(template.id);
      final missionId = uuid.v4();
      await _db
          .into(_db.missions)
          .insert(
            MissionsCompanion.insert(
              id: missionId,
              title: template.title,
              description: Value(template.description),
              difficulty: template.difficulty,
              xpReward: template.xpReward,
              target: Value(
                subtasks.isEmpty ? template.target : subtasks.length,
              ),
              isDaily: const Value(true),
              dueDate: Value(due),
              sortOrder: Value(template.slot),
              createdAt: DateTime.now(),
            ),
          );
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

    return templates.length;
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
