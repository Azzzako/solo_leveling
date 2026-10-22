import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling/src/core/db/app_database.dart';
import 'package:solo_leveling/src/features/missions/data/mission_repository.dart';
import 'package:solo_leveling/src/features/missions/domain/daily_stack.dart';
import 'package:solo_leveling/src/features/missions/domain/mission_difficulty.dart';

void main() {
  late AppDatabase db;
  late MissionRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = MissionRepository(db);
  });

  tearDown(() => db.close());

  group('generateDailyMissions', () {
    final day = DateTime(2026, 10, 22);

    test('crea siempre el mismo stack fijo de 5 misiones', () async {
      final created = await repository.generateDailyMissions(day, level: 1);
      expect(created, fixedDailyStack.length);

      final missions = await repository.dailyMissionsOn(day);
      expect(missions.map((m) => m.title), fixedDailyStack.map((s) => s.title));
      expect(
        missions.map((m) => m.xpReward),
        fixedDailyStack.map((s) => s.xpReward),
      );
      expect(missions.fold(0, (sum, m) => sum + m.xpReward), 270);
    });

    test('el set es idéntico en cualquier día', () async {
      await repository.generateDailyMissions(day, level: 1);
      await repository.generateDailyMissions(
        day.add(const Duration(days: 3)),
        level: 1,
      );

      final first = await repository.dailyMissionsOn(day);
      final later = await repository.dailyMissionsOn(
        day.add(const Duration(days: 3)),
      );
      expect(later.map((m) => m.title), first.map((m) => m.title));
    });

    test('no duplica misiones si se regenera el mismo día', () async {
      await repository.generateDailyMissions(day, level: 1);
      final second = await repository.generateDailyMissions(day, level: 1);

      expect(second, 0);
      expect(await repository.dailyMissionsOn(day), hasLength(5));
    });

    test('la misión de ejercicio nace con 4 subtareas y target 4', () async {
      await repository.generateDailyMissions(day, level: 1);
      final missions = await repository.dailyMissionsOn(day);
      final exercise = missions.first;

      expect(exercise.target, 4);
      final subtasks = await repository.subtasksOf(exercise.id);
      expect(
        subtasks.map((s) => s.title),
        exerciseSubtasks.map((s) => s.title),
      );
      expect(subtasks.every((s) => s.progress == 0), isTrue);
      expect(subtasks.every((s) => s.target > 0), isTrue);
    });

    test('las subtareas escalan con el nivel', () async {
      final low = DateTime(2026, 10, 22);
      final high = DateTime(2026, 10, 23);
      await repository.generateDailyMissions(low, level: 1);
      await repository.generateDailyMissions(high, level: 20);

      Future<List<int>> targetsOn(DateTime d) async {
        final mission = (await repository.dailyMissionsOn(d)).first;
        final subtasks = await repository.subtasksOf(mission.id);
        return subtasks.map((s) => s.target).toList();
      }

      final lowTargets = await targetsOn(low);
      final highTargets = await targetsOn(high);

      expect(lowTargets, exerciseSubtasks.map((s) => s.targetAt(1)).toList());
      expect(highTargets, exerciseSubtasks.map((s) => s.targetAt(20)).toList());
      expect(highTargets.first, greaterThan(lowTargets.first));
      expect(highTargets, [88, 98, 88, 29]);
    });

    test(
      'matchesFixedStack distingue el stack fijo de misiones sueltas',
      () async {
        await repository.generateDailyMissions(day, level: 1);
        expect(
          repository.matchesFixedStack(await repository.dailyMissionsOn(day)),
          isTrue,
        );

        await repository.clearDailyMissions(day);
        await repository.create(
          title: 'Misión manual',
          isDaily: true,
          dueDate: day,
        );
        expect(
          repository.matchesFixedStack(await repository.dailyMissionsOn(day)),
          isFalse,
        );
      },
    );
  });

  group('subtareas de ejercicio', () {
    final day = DateTime(2026, 10, 22);

    test(
      'no se puede completar la primaria antes de todas las subtareas',
      () async {
        await repository.generateDailyMissions(day, level: 1);
        final exercise = (await repository.dailyMissionsOn(day)).first;
        final subtasks = await repository.subtasksOf(exercise.id);

        for (var i = 0; i < subtasks.length - 1; i++) {
          final outcome = await repository.registerSubtaskProgress(
            subtasks[i].id,
            amount: subtasks[i].target,
          );
          expect(outcome.subtaskCompleted, isTrue);
          expect(outcome.mission.missionCompleted, isFalse);
          expect(outcome.mission.xpEarned, 0);
        }

        final last = await repository.registerSubtaskProgress(
          subtasks.last.id,
          amount: subtasks.last.target,
        );
        expect(last.subtaskCompleted, isTrue);
        expect(last.mission.missionCompleted, isTrue);
        expect(last.mission.xpEarned, 100);
      },
    );

    test(
      'el progreso de la primaria cuenta las subtareas terminadas',
      () async {
        await repository.generateDailyMissions(day, level: 1);
        final exercise = (await repository.dailyMissionsOn(day)).first;
        final subtasks = await repository.subtasksOf(exercise.id);

        await repository.registerSubtaskProgress(
          subtasks.first.id,
          amount: subtasks.first.target,
        );
        await repository.registerSubtaskProgress(
          subtasks[1].id,
          amount: subtasks[1].target,
        );

        final updated = (await repository.dailyMissionsOn(day)).first;
        expect(updated.progress, 2);
        expect(updated.xpReward, 100);
      },
    );

    test(
      'progreso parcial por pasos de 10 reps no completa la subtarea',
      () async {
        await repository.generateDailyMissions(day, level: 1);
        final exercise = (await repository.dailyMissionsOn(day)).first;
        final subtasks = await repository.subtasksOf(exercise.id);

        final outcome = await repository.registerSubtaskProgress(
          subtasks.first.id,
          amount: 10,
        );
        expect(outcome.subtaskCompleted, isFalse);

        final refreshed = await repository.subtasksOf(exercise.id);
        expect(refreshed.first.progress, 10);
      },
    );

    test('no paga dos veces al reintentar una subtarea', () async {
      await repository.generateDailyMissions(day, level: 1);
      final exercise = (await repository.dailyMissionsOn(day)).first;
      final subtasks = await repository.subtasksOf(exercise.id);

      for (final s in subtasks) {
        await repository.registerSubtaskProgress(s.id, amount: s.target);
      }
      final again = await repository.registerSubtaskProgress(subtasks.first.id);

      expect(again.subtaskCompleted, isFalse);
      expect(again.mission.missionCompleted, isFalse);
      expect(again.mission.xpEarned, 0);
    });

    test(
      'registerProgress directo sobre una misión con subtareas es no-op',
      () async {
        await repository.generateDailyMissions(day, level: 1);
        final exercise = (await repository.dailyMissionsOn(day)).first;

        final outcome = await repository.registerProgress(exercise.id);
        expect(outcome.missionCompleted, isFalse);
        expect(outcome.xpEarned, 0);
      },
    );

    test('las misiones sin subtareas se completan con un toque', () async {
      await repository.generateDailyMissions(day, level: 1);
      final water = (await repository.dailyMissionsOn(day))[1];
      expect(water.title, 'Toma 2 litros de agua');
      expect(await repository.subtasksOf(water.id), isEmpty);

      final partial = await repository.registerProgress(water.id);
      expect(partial.missionCompleted, isFalse);

      final done = await repository.registerProgress(water.id);
      expect(done.missionCompleted, isTrue);
      expect(done.xpEarned, 40);
    });
  });

  group('reactivate y clearDailyMissions', () {
    final day = DateTime(2026, 10, 22);

    test('reactivate reinicia subtareas y completions', () async {
      await repository.generateDailyMissions(day, level: 1);
      final exercise = (await repository.dailyMissionsOn(day)).first;
      final subtasks = await repository.subtasksOf(exercise.id);
      for (final s in subtasks) {
        await repository.registerSubtaskProgress(s.id, amount: s.target);
      }

      await repository.reactivate(exercise.id);

      expect(
        (await repository.subtasksOf(exercise.id))
            .every((s) => s.progress == 0),
        isTrue,
      );
      expect((await repository.dailyMissionsOn(day)).first.progress, 0);
      expect(await repository.watchCompletionsOn(day).first, isEmpty);
    });

    test('clearDailyMissions borra misiones y subtareas del día', () async {
      await repository.generateDailyMissions(day, level: 1);
      final before = await repository.watchSubtasksForDay(day).first;
      expect(before, hasLength(4));

      await repository.clearDailyMissions(day);

      expect(await repository.dailyMissionsOn(day), isEmpty);
      expect(await repository.watchSubtasksForDay(day).first, isEmpty);
    });
  });

  group('resetMission y resetSubtask', () {
    final day = DateTime(2026, 10, 22);

    test(
      'resetSubtask quita una serie y baja el contador de la primaria',
      () async {
        await repository.generateDailyMissions(day, level: 1);
        final exercise = (await repository.dailyMissionsOn(day)).first;
        final subtasks = await repository.subtasksOf(exercise.id);

        await repository.registerSubtaskProgress(subtasks[0].id, amount: 50);
        await repository.registerSubtaskProgress(subtasks[1].id, amount: 60);
        expect((await repository.dailyMissionsOn(day)).first.progress, 2);

        final outcome = await repository.resetSubtask(subtasks[1].id);

        expect(outcome.xpRefunded, 0);
        final after = await repository.subtasksOf(exercise.id);
        expect(after[1].progress, 0);
        expect(after[0].progress, 50);
        expect((await repository.dailyMissionsOn(day)).first.progress, 1);
      },
    );

    test(
      'resetSubtask sobre la última serie deshace la misión y devuelve el XP',
      () async {
        await repository.generateDailyMissions(day, level: 1);
        final exercise = (await repository.dailyMissionsOn(day)).first;
        final subtasks = await repository.subtasksOf(exercise.id);
        for (final s in subtasks) {
          await repository.registerSubtaskProgress(s.id, amount: s.target);
        }
        expect((await repository.dailyMissionsOn(day)).first.progress, 4);

        final outcome = await repository.resetSubtask(subtasks.last.id);

        expect(outcome.completionsRemoved, 1);
        expect(outcome.xpRefunded, 100);
        expect(await repository.watchCompletionsOn(day).first, isEmpty);
        expect((await repository.dailyMissionsOn(day)).first.progress, 3);
      },
    );

    test('resetMission borra solo esa misión y devuelve su XP', () async {
      await repository.generateDailyMissions(day, level: 1);
      final missions = await repository.dailyMissionsOn(day);
      final exercise = missions.first;
      for (final s in await repository.subtasksOf(exercise.id)) {
        await repository.registerSubtaskProgress(s.id, amount: s.target);
      }
      await repository.registerProgress(missions[1].id, amount: 2);

      final outcome = await repository.resetMission(missions[1].id);

      expect(outcome.xpRefunded, 40);
      final after = await repository.dailyMissionsOn(day);
      expect(after[1].progress, 0);
      expect(after.first.progress, 4);
      expect(
        (await repository.subtasksOf(exercise.id))
            .every((s) => s.progress == s.target),
        isTrue,
      );
      expect(await repository.watchCompletionsOn(day).first, hasLength(1));
    });

    test('resetMission sobre ejercicio limpia también las subtareas', () async {
      await repository.generateDailyMissions(day, level: 1);
      final exercise = (await repository.dailyMissionsOn(day)).first;
      for (final s in await repository.subtasksOf(exercise.id)) {
        await repository.registerSubtaskProgress(s.id, amount: s.target);
      }

      final outcome = await repository.resetMission(exercise.id);

      expect(outcome.xpRefunded, 100);
      expect(
        (await repository.subtasksOf(exercise.id))
            .every((s) => s.progress == 0),
        isTrue,
      );
      expect((await repository.dailyMissionsOn(day)).first.progress, 0);
    });
  });

  group('resetDay', () {
    final day = DateTime(2026, 10, 22);

    test('borra completions, progreso y devuelve el XP del día', () async {
      await repository.generateDailyMissions(day, level: 1);
      final missions = await repository.dailyMissionsOn(day);
      final exercise = missions.first;
      final subtasks = await repository.subtasksOf(exercise.id);
      for (final s in subtasks) {
        await repository.registerSubtaskProgress(s.id, amount: s.target);
      }
      await repository.registerProgress(missions[1].id, amount: 2);

      final result = await repository.resetDay(day);

      expect(result.missionsCleared, 5);
      expect(result.completionsRemoved, 2);
      expect(result.xpRefunded, 140);
      expect(await repository.watchCompletionsOn(day).first, isEmpty);
      expect(
        (await repository.dailyMissionsOn(day)).every((m) => m.progress == 0),
        isTrue,
      );
      expect(
        (await repository.subtasksOf(exercise.id))
            .every((s) => s.progress == 0),
        isTrue,
      );
    });

    test('el stack sigue ahí y se puede volver a completar', () async {
      await repository.generateDailyMissions(day, level: 1);
      final missions = await repository.dailyMissionsOn(day);
      await repository.registerProgress(missions[1].id, amount: 2);
      await repository.resetDay(day);

      final again = await repository.registerProgress(
        missions[1].id,
        amount: 2,
      );
      expect(again.missionCompleted, isTrue);
      expect(again.xpEarned, 40);
      expect(await repository.dailyMissionsOn(day), hasLength(5));
    });

    test('no toca las misiones de otros días', () async {
      final yesterday = day.subtract(const Duration(days: 1));
      await repository.generateDailyMissions(yesterday, level: 1);
      final old = await repository.dailyMissionsOn(yesterday);
      await repository.registerProgress(old[2].id, amount: 10);
      await repository.generateDailyMissions(day, level: 1);

      final result = await repository.resetDay(day);

      expect(result.completionsRemoved, 1);
      expect(result.xpRefunded, 50);
      final untouched = await repository.dailyMissionsOn(yesterday);
      expect(untouched, hasLength(5));
      expect(untouched[2].progress, 10);
    });
  });

  group('registerProgress en misiones propias', () {
    test('paga XP plano según dificultad y una sola vez', () async {
      final mission = await repository.create(
        title: 'Camina 5000 pasos',
        difficulty: MissionDifficulty.medium,
        target: 3,
      );
      expect(mission.xpReward, MissionDifficulty.medium.baseXp);

      final partial = await repository.registerProgress(mission.id);
      expect(partial.missionCompleted, isFalse);
      expect(partial.xpEarned, 0);

      final done = await repository.registerProgress(mission.id, amount: 2);
      expect(done.missionCompleted, isTrue);
      expect(done.xpEarned, MissionDifficulty.medium.baseXp);

      final second = await repository.registerProgress(mission.id);
      expect(second.missionCompleted, isFalse);
      expect(second.xpEarned, 0);
    });
  });
}
