import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling/src/core/db/app_database.dart';
import 'package:solo_leveling/src/core/providers/core_providers.dart';
import 'package:solo_leveling/src/features/auth/domain/auth_user.dart';
import 'package:solo_leveling/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:solo_leveling/src/features/missions/domain/interview_catalog.dart';
import 'package:solo_leveling/src/features/missions/presentation/providers/missions_provider.dart';
import 'package:solo_leveling/src/features/player/presentation/providers/player_provider.dart';

Future<List<Mission>> _completedWithoutSubtasks(
  ProviderContainer container,
  DateTime day,
) async {
  final repository = container.read(missionRepositoryProvider);
  final done = <Mission>[];
  for (final mission in await repository.dailyMissionsOn(day)) {
    final subtasks = await repository.subtasksOf(mission.id);
    if (subtasks.isNotEmpty) continue;
    done.add(mission);
  }
  return done;
}

class _StubAuth extends AuthController {
  @override
  Future<AuthUser?> build() async =>
      const AuthUser(id: 'test-user', email: 'cazador@test.dev');
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        authProvider.overrideWith(_StubAuth.new),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('ensure genera el stack y los providers lo ven', () async {
    container.listen(
      ensureDailyMissionsProvider,
      (_, _) {},
      fireImmediately: true,
    );
    container.listen(dailyMissionsProvider, (_, _) {}, fireImmediately: true);
    container.listen(todaySubtasksProvider, (_, _) {}, fireImmediately: true);
    container.listen(
      todayCompletionsProvider,
      (_, _) {},
      fireImmediately: true,
    );

    await container.read(ensureDailyMissionsProvider.future);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final missions = container.read(dailyMissionsProvider);
    final subtasks = container.read(todaySubtasksProvider);
    final completions = container.read(todayCompletionsProvider);

    expect(missions.hasError, isFalse, reason: '${missions.error}');
    expect(missions.value, hasLength(7));
    expect(subtasks.hasError, isFalse, reason: '${subtasks.error}');
    expect(subtasks.value, hasLength(7));
    expect(completions.value, isEmpty);

    final summary = container.read(dailySummaryProvider).value;
    expect(summary?.total, 7);
    expect(summary?.xp, 0);
  });

  group('liquidación del castigo', () {
    Future<DailySettlement> settle() =>
        container.read(dailySettlementProvider.future);

    test('un día sin completar resta el XP de sus misiones', () async {
      final today = DateTime.now();
      final yesterday = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(const Duration(days: 1));
      await container
          .read(missionRepositoryProvider)
          .generateDailyMissions(yesterday, level: 1);
      container.listen(
        dailySettlementProvider,
        (_, _) {},
        fireImmediately: true,
      );

      final settlement = await settle();

      expect(settlement.daysSettled, 1);
      expect(settlement.penaltyApplied, dailyStackXp);
      expect(container.read(playerProvider).value!.totalXp, -dailyStackXp);
      expect(container.read(playerProvider).value!.inDebt, isTrue);
      expect(container.read(playerProvider).value!.level, 1);
    });

    test('solo se castiga lo que quedó sin hacer', () async {
      final today = DateTime.now();
      final yesterday = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(const Duration(days: 1));
      final repository = container.read(missionRepositoryProvider);
      await repository.generateDailyMissions(yesterday, level: 1);
      for (final mission in await repository.dailyMissionsOn(yesterday)) {
        final subtasks = await repository.subtasksOf(mission.id);
        if (subtasks.isNotEmpty) continue;
        await db
            .into(db.missionCompletions)
            .insert(
              MissionCompletionsCompanion.insert(
                id: 'done-${mission.id}',
                missionId: mission.id,
                completedAt: DateTime(
                  yesterday.year,
                  yesterday.month,
                  yesterday.day,
                  20,
                ),
                xpEarned: mission.xpReward,
              ),
            );
      }
      container.listen(
        dailySettlementProvider,
        (_, _) {},
        fireImmediately: true,
      );

      final settlement = await settle();

      final completed = await _completedWithoutSubtasks(container, yesterday);
      final expected =
          dailyStackXp -
          completed.fold<int>(0, (sum, mission) => sum + mission.xpReward);
      expect(settlement.penaltyApplied, expected);
      expect(container.read(playerProvider).value!.totalXp, -expected);
    });

    test('los días sin abrir la app también se cobran', () async {
      final today = DateTime.now();
      final base = DateTime(today.year, today.month, today.day);
      final firstDay = base.subtract(const Duration(days: 3));
      await container
          .read(missionRepositoryProvider)
          .generateDailyMissions(firstDay, level: 1);
      final settings = await container.read(settingsStoreProvider.future);
      await settings.writeLastSettledDate(
        firstDay.subtract(const Duration(days: 1)),
      );
      container.listen(
        dailySettlementProvider,
        (_, _) {},
        fireImmediately: true,
      );

      final settlement = await settle();

      expect(settlement.daysSettled, 3);
      expect(settlement.daysPenalized, 3);
      expect(settlement.penaltyApplied, dailyStackXp * 3);
      expect(container.read(playerProvider).value!.totalXp, -dailyStackXp * 3);
    });

    test('no cobra dos veces el mismo día', () async {
      container.listen(
        dailySettlementProvider,
        (_, _) {},
        fireImmediately: true,
      );
      await settle();
      container.invalidate(dailySettlementProvider);

      final second = await settle();

      expect(second.daysSettled, 0);
      expect(second.penaltyApplied, 0);
    });
  });

  test('releer el provider no duplica el stack', () async {
    container.listen(
      ensureDailyMissionsProvider,
      (_, _) {},
      fireImmediately: true,
    );
    await container.read(ensureDailyMissionsProvider.future);
    container.invalidate(ensureDailyMissionsProvider);
    await container.read(ensureDailyMissionsProvider.future);

    final repository = container.read(missionRepositoryProvider);
    expect(await repository.dailyMissionsOn(DateTime.now()), hasLength(7));
  });

  test(
    'una versión nueva del catálogo rehace el día y respeta lo hecho',
    () async {
      final repository = container.read(missionRepositoryProvider);
      final today = DateTime.now();
      await repository.applyStack(
        goal: DailyGoal.fisico,
        answers: const {'training': 'strength', 'intensity': 'soft'},
        day: today,
        level: 1,
      );
      final exercise = (await repository.dailyMissionsOn(today)).first;
      final series = await repository.subtasksOf(exercise.id);
      await (db.update(db.missionSubtasks)
            ..where((s) => s.id.equals(series.last.id)))
          .write(const MissionSubtasksCompanion(target: Value(6)));
      await repository.registerSubtaskProgress(
        series.first.id,
        amount: series.first.target,
      );
      await (db.update(db.userPreferences))
          .write(const UserPreferencesCompanion(stackVersion: Value(1)));

      container.listen(
        ensureDailyMissionsProvider,
        (_, _) {},
        fireImmediately: true,
      );
      await container.read(ensureDailyMissionsProvider.future);

      final rebuilt = (await repository.dailyMissionsOn(today)).first;
      final after = await repository.subtasksOf(rebuilt.id);
      expect(after.map((s) => s.target), everyElement(30));
      expect(after.first.progress, 30);
      expect(after.skip(1).map((s) => s.progress), everyElement(0));
      expect(rebuilt.progress, 1);
      expect(
        (await repository.userPreference())!.stackVersion,
        stackFormatVersion,
      );
    },
  );

  group('racha', () {
    Future<void> ready() async {
      container.listen(
        ensureDailyMissionsProvider,
        (_, _) {},
        fireImmediately: true,
      );
      await container.read(ensureDailyMissionsProvider.future);
    }

    Future<Mission> water() async {
      final missions = await container
          .read(missionRepositoryProvider)
          .dailyMissionsOn(DateTime.now());
      return missions.firstWhere((m) => m.title.startsWith('Toma'));
    }

    test('cumplir arranca la racha y deshacer la regresa', () async {
      await ready();
      final action = container.read(registerMissionProgressProvider);
      final mission = await water();

      final reward = await action.complete(mission);
      expect(reward.xpEarned, mission.xpReward);
      expect(container.read(playerProvider).value!.streak, 1);

      await action.undoMission(mission);
      final stats = container.read(playerProvider).value!;
      expect(stats.streak, 0);
      expect(stats.lastCompletion, isNull);
      expect(stats.totalXp, 0);

      await action.complete(mission);
      expect(container.read(playerProvider).value!.streak, 1);
    });

    test('reiniciar el día no deja una racha regalada', () async {
      final repository = container.read(missionRepositoryProvider);
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      await repository.generateDailyMissions(yesterday, level: 1);
      final old = (await repository.dailyMissionsOn(yesterday)).first;
      await db
          .into(db.missionCompletions)
          .insert(
            MissionCompletionsCompanion.insert(
              id: 'ayer',
              missionId: old.id,
              completedAt: DateTime(
                yesterday.year,
                yesterday.month,
                yesterday.day,
                20,
              ),
              xpEarned: 0,
            ),
          );
      await ready();
      expect(container.read(playerProvider).value!.streak, 1);

      final action = container.read(registerMissionProgressProvider);
      await action.complete(await water());
      expect(container.read(playerProvider).value!.streak, 2);

      await action.resetToday();
      expect(container.read(playerProvider).value!.streak, 1);
    });
  });
}
