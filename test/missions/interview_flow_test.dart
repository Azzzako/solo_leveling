import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling/src/core/db/app_database.dart';
import 'package:solo_leveling/src/core/providers/core_providers.dart';
import 'package:solo_leveling/src/features/missions/data/mission_repository.dart';
import 'package:solo_leveling/src/features/missions/domain/interview_catalog.dart';
import 'package:solo_leveling/src/features/missions/presentation/providers/interview_provider.dart';
import 'package:solo_leveling/src/features/missions/presentation/providers/missions_provider.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('usuario nuevo', () {
    test('no tiene preferencias y el stack se siembra por defecto', () async {
      final state = await container.read(userPreferencesProvider.future);

      expect(state.configured, isFalse);
      expect(state.goal, isNull);

      await container.read(missionRepositoryProvider).ensureStackSeeded();
      final templates = await container
          .read(missionRepositoryProvider)
          .stackTemplates();
      expect(templates, hasLength(7));
      expect(templates.first.goal, DailyGoal.fisico);
    });
  });

  group('guardar la entrevista', () {
    test('persiste el stack elegido y sus respuestas', () async {
      final repository = container.read(missionRepositoryProvider);
      await repository.applyStack(
        goal: DailyGoal.productividad,
        answers: const {'anchor': 'code', 'blocks': 'medium'},
        day: DateTime.now(),
        level: 1,
      );

      final preference = await repository.userPreference();
      final answers = repository.decodeAnswers(preference!.answers);

      expect(preference.goal, DailyGoal.productividad);
      expect(preference.source, 'interview');
      expect(answers['anchor'], 'code');
      expect(answers['blocks'], 'medium');

      final state = await container.read(userPreferencesProvider.future);
      expect(state.configured, isTrue);
      expect(state.goal, DailyGoal.productividad);

      final templates = await repository.stackTemplates();
      expect(templates, hasLength(7));
      expect(
        templates.map((t) => t.title).toSet(),
        buildStack(DailyGoal.productividad, const {
          'anchor': 'code',
          'blocks': 'medium',
        }).map((d) => d.title).toSet(),
      );
    });

    test(
      'el día siguiente usa el stack nuevo con las reps escaladas',
      () async {
        final repository = container.read(missionRepositoryProvider);
        final today = DateTime.now();
        await repository.applyStack(
          goal: DailyGoal.fisico,
          answers: const {'training': 'strength', 'intensity': 'hard'},
          day: today,
          level: 10,
        );
        final missions = await repository.dailyMissionsOn(today);
        final exercise = missions.first;
        final subtasks = await repository.subtasksOf(exercise.id);
        final base = buildStack(DailyGoal.fisico, const {
          'training': 'strength',
          'intensity': 'hard',
        }).first;

        expect(exercise.title, base.title);
        expect(
          subtasks.map((s) => s.target).toList(),
          base.subtasks.map((s) => s.targetAt(10)).toList(),
        );
      },
    );

    test('cambiar de stack marca el día actual para reconstruirse', () async {
      final repository = container.read(missionRepositoryProvider);
      final today = DateTime.now();
      await repository.generateDailyMissions(today, level: 1);
      final before = await repository.dailyMissionsOn(today);

      await repository.applyStack(
        goal: DailyGoal.enfoque,
        answers: const {'technique': 'journal'},
        day: today,
        level: 1,
      );

      final after = await repository.dailyMissionsOn(today);
      expect(after.map((m) => m.title), isNot(before.map((m) => m.title)));
      expect(
        after.map((m) => m.title),
        buildStack(DailyGoal.enfoque, const {
          'technique': 'journal',
        }).map((d) => d.title),
      );
    });

    test(
      'saltar deja la rutina de ejemplo y cuenta como configurado',
      () async {
        await container
            .read(missionRepositoryProvider)
            .applyStack(
              goal: DailyGoal.fisico,
              answers: const {},
              day: DateTime.now(),
              level: 1,
              source: PreferenceSource.skipped,
            );

        final preference = await container
            .read(missionRepositoryProvider)
            .userPreference();
        final state = await container.read(userPreferencesProvider.future);

        expect(preference!.source, PreferenceSource.skipped);
        expect(state.configured, isTrue);
        expect(state.goal, DailyGoal.fisico);
      },
    );

    test('la siembra automática no cuenta como entrevista hecha', () async {
      await container.read(missionRepositoryProvider).ensureStackSeeded();

      final state = await container.read(userPreferencesProvider.future);

      expect(state.configured, isFalse);
    });

    test(
      'cambiar de stack conserva lo cumplido que sigue en la rutina',
      () async {
        final repository = container.read(missionRepositoryProvider);
        final today = DateTime.now();
        await repository.applyStack(
          goal: DailyGoal.fisico,
          answers: const {'training': 'strength'},
          day: today,
          level: 1,
        );
        final before = await repository.dailyMissionsOn(today);
        final water = before.firstWhere((m) => m.title.startsWith('Toma'));
        final exercise = before.first;
        await repository.registerProgress(water.id, amount: water.target);
        for (final s in await repository.subtasksOf(exercise.id)) {
          await repository.registerSubtaskProgress(s.id, amount: s.target);
        }

        final outcome = await repository.applyStack(
          goal: DailyGoal.fisico,
          answers: const {'training': 'cardio'},
          day: today,
          level: 1,
        );

        final after = await repository.dailyMissionsOn(today);
        final completions = await repository.watchCompletionsOn(today).first;
        final keptWater = after.firstWhere((m) => m.title == water.title);
        expect(after.first.title, 'Haz cardio');
        expect(outcome.completionsRemoved, 1);
        expect(outcome.xpRefunded, exercise.xpReward);
        expect(completions.map((c) => c.missionId), [keptWater.id]);
        expect(keptWater.progress, keptWater.target);
        expect(await repository.penaltyForDay(today), isNot(dailyStackXp));
      },
    );
  });
}
