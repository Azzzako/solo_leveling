import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling/src/core/storage/settings_store.dart';
import 'package:solo_leveling/src/features/player/domain/player_stats.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsStore.rescaleXp', () {
    test('3250 XP de la curva vieja (nivel 11) pasan a nivel 4', () {
      expect(SettingsStore.rescaleXp(3250), 825);
      expect(PlayerStats.levelForXp(825), 4);
    });

    test('conserva el progreso dentro del nivel', () {
      final half = 3250 + 100;
      final rescaled = SettingsStore.rescaleXp(half);
      final level = PlayerStats.levelForXp(rescaled);

      expect(level, 4);
      expect(rescaled, greaterThan(PlayerStats.totalXpForLevel(4)));
      expect(rescaled, lessThan(PlayerStats.totalXpForLevel(5)));
    });

    test('sin XP o con XP negativo no inventa progreso', () {
      expect(SettingsStore.rescaleXp(0), 0);
      expect(SettingsStore.rescaleXp(-50), 0);
    });

    test('siempre baja el nivel', () {
      for (final xp in [1, 500, 5000, 60000, 500000]) {
        final rescaled = SettingsStore.rescaleXp(xp);
        expect(
          PlayerStats.levelForXp(rescaled),
          lessThanOrEqualTo(PlayerStats.levelForXp(xp)),
        );
      }
    });
  });

  group('applyXpCurveMigration', () {
    test('reescala una sola vez y marca la versión', () async {
      SharedPreferences.setMockInitialValues({
        'hunter_total_xp': 3250,
        'hunter_streak': 7,
        'hunter_name': 'Cazador',
      });
      final store = await SettingsStore.open();

      expect(await store.applyXpCurveMigration(), isTrue);

      final migrated = store.readStats();
      expect(migrated.totalXp, 825);
      expect(migrated.level, 4);
      expect(migrated.streak, 7);

      expect(await store.applyXpCurveMigration(), isFalse);
      expect(store.readStats().totalXp, 825);
    });
  });

  group('seed de misiones diarias', () {
    test('guarda y lee la fecha de generación', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await SettingsStore.open();
      expect(store.dailyMissionsSeedDate, isNull);

      final day = DateTime(2026, 10, 22);
      await store.writeDailyMissionsSeed(day);

      expect(store.dailyMissionsSeedDate, day);
    });
  });
}
