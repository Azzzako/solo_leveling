import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling/src/core/db/app_database.dart';
import 'package:solo_leveling/src/core/providers/core_providers.dart';
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
    expect(missions.value, hasLength(5));
    expect(subtasks.hasError, isFalse, reason: '${subtasks.error}');
    expect(subtasks.value, hasLength(4));
    expect(completions.value, isEmpty);

    final summary = container.read(dailySummaryProvider).value;
    expect(summary?.total, 5);
    expect(summary?.xp, 0);
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
    expect(await repository.dailyMissionsOn(DateTime.now()), hasLength(5));
  });
}
