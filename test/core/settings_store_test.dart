import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling/src/core/storage/settings_store.dart';
import 'package:solo_leveling/src/features/player/domain/player_stats.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('migración v1 → v2', () {
    test('3250 XP de la curva vieja bajan a un nivel bajo', () {
      final rescaled = SettingsStore.rescaleXp(3250, from: 1);

      expect(PlayerStats.levelForXp(rescaled), 4);
    });

    test('conserva el progreso dentro del nivel', () {
      final half = 3250 + 100;
      final rescaled = SettingsStore.rescaleXp(half, from: 1);
      final level = PlayerStats.levelForXp(rescaled);

      expect(level, 4);
      expect(rescaled, greaterThan(PlayerStats.totalXpForLevel(4)));
      expect(rescaled, lessThan(PlayerStats.totalXpForLevel(5)));
    });

    test('sin XP no inventa progreso', () {
      expect(SettingsStore.rescaleXp(0, from: 1), 0);
    });

    test('siempre baja el nivel o lo mantiene', () {
      for (final xp in [1, 500, 5000, 60000, 500000]) {
        final rescaled = SettingsStore.rescaleXp(xp, from: 1);
        expect(
          PlayerStats.levelForXp(rescaled),
          lessThanOrEqualTo(PlayerStats.levelForXp(xp)),
        );
      }
    });
  });

  group('migración v2 → v3', () {
    test('conserva el nivel y convierte el progreso', () {
      final oldLevel = SettingsStore.oldLevelForXp(8900, curve: 2);
      final rescaled = SettingsStore.rescaleXp(8900, from: 2);

      expect(oldLevel, 14);
      expect(PlayerStats.levelForXp(rescaled), 14);
      expect(rescaled, greaterThan(PlayerStats.totalXpForLevel(14)));
      expect(rescaled, lessThan(PlayerStats.totalXpForLevel(15)));
    });

    test('no amplifica ni reduce el nivel', () {
      for (final xp in [325, 2000, 8450, 60000]) {
        final oldLevel = SettingsStore.oldLevelForXp(xp, curve: 2);
        final rescaled = SettingsStore.rescaleXp(xp, from: 2);
        expect(PlayerStats.levelForXp(rescaled), oldLevel);
      }
    });

    test('la deuda en XP se respeta tal cual', () {
      expect(SettingsStore.rescaleXp(-1200, from: 2), -1200);
      expect(SettingsStore.rescaleXp(0, from: 2), 0);
    });
  });

  group('applyXpCurveMigration', () {
    test('reescala una sola vez y marca la versión', () async {
      SharedPreferences.setMockInitialValues({
        'hunter_total_xp': 8900,
        'hunter_streak': 7,
        'hunter_name': 'Cazador',
        'hunter_xp_curve_version': 2,
      });
      final store = await SettingsStore.open();

      expect(await store.applyXpCurveMigration(), isTrue);

      final migrated = store.readStats();
      expect(migrated.level, 14);
      expect(migrated.streak, 7);
      expect(migrated.totalXp, greaterThan(PlayerStats.totalXpForLevel(14)));

      expect(await store.applyXpCurveMigration(), isFalse);
    });

    test('una deuda de XP sobrevive a la migración', () async {
      SharedPreferences.setMockInitialValues({
        'hunter_total_xp': -880,
        'hunter_xp_curve_version': 2,
      });
      final store = await SettingsStore.open();

      expect(await store.applyXpCurveMigration(), isTrue);
      expect(store.readStats().totalXp, -880);
      expect(store.readStats().level, 1);
    });
  });

  group('fecha de liquidación del castigo', () {
    test('guarda y lee el último día liquidado', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await SettingsStore.open();
      expect(store.lastSettledDate, isNull);

      final settled = DateTime(2026, 10, 21);
      await store.writeLastSettledDate(settled);

      expect(store.lastSettledDate, settled);
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
