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

      final store = await SettingsStore.open('user-1');

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
      final store = await SettingsStore.open('user-1');

      expect(await store.applyXpCurveMigration(), isTrue);
      expect(store.readStats().totalXp, -880);
      expect(store.readStats().level, 1);
    });
  });

  group('aislamiento por usuario', () {
    test('cada usuario tiene su propio XP, nombre y racha', () async {
      SharedPreferences.setMockInitialValues({});
      final one = await SettingsStore.open('user-a');
      final two = await SettingsStore.open('user-b');

      await one.writeStats(PlayerStats(name: 'A', totalXp: 900, streak: 5));
      await two.writeStats(PlayerStats(name: 'B', totalXp: -200, streak: 0));

      expect(one.readStats().name, 'A');
      expect(one.readStats().totalXp, 900);
      expect(one.readStats().streak, 5);
      expect(two.readStats().name, 'B');
      expect(two.readStats().totalXp, -200);
      expect(two.readStats().streak, 0);
    });

    test('la curva y la liquidación también están aisladas', () async {
      SharedPreferences.setMockInitialValues({});
      final one = await SettingsStore.open('user-a');
      final two = await SettingsStore.open('user-b');

      expect(await one.applyXpCurveMigration(), isTrue);
      expect(await two.applyXpCurveMigration(), isTrue);
      await one.writeLastSettledDate(DateTime(2026, 10, 21));

      expect(one.lastSettledDate, DateTime(2026, 10, 21));
      expect(two.lastSettledDate, isNull);
      expect(await one.applyXpCurveMigration(), isFalse);
      expect(await two.applyXpCurveMigration(), isFalse);
    });

    test('el progreso antiguo solo se reclama una vez', () async {
      SharedPreferences.setMockInitialValues({'hunter_total_xp': 4400});
      final first = await SettingsStore.open('user-a');

      expect(first.readStats().totalXp, 4400);

      final second = await SettingsStore.open('user-b');
      expect(second.readStats().totalXp, 0);
    });
  });

  group('fecha de liquidación del castigo', () {
    test('guarda y lee el último día liquidado', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await SettingsStore.open('user-1');
      expect(store.lastSettledDate, isNull);

      final settled = DateTime(2026, 10, 21);
      await store.writeLastSettledDate(settled);

      expect(store.lastSettledDate, settled);
    });
  });

  group('seed de misiones diarias', () {
    test('guarda y lee la fecha de generación', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await SettingsStore.open('user-1');
      expect(store.dailyMissionsSeedDate, isNull);

      final day = DateTime(2026, 10, 22);
      await store.writeDailyMissionsSeed(day);

      expect(store.dailyMissionsSeedDate, day);
    });
  });

  group('última misión cumplida', () {
    test('guardar null la borra en vez de dejar 1970', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await SettingsStore.open('u1');
      await store.writeStats(
        PlayerStats(
          name: 'A',
          totalXp: 10,
          streak: 1,
          lastCompletion: DateTime(2026, 10, 22, 8),
        ),
      );
      expect(store.readStats().lastCompletion, DateTime(2026, 10, 22, 8));

      await store.writeStats(PlayerStats(name: 'A', totalXp: 10, streak: 0));

      expect(store.readStats().lastCompletion, isNull);
    });

    test('un 0 heredado se lee como sin fecha', () async {
      SharedPreferences.setMockInitialValues({
        'sl_legacy_claimed': true,
        'sl_u1::hunter_last_completion': 0,
      });
      final store = await SettingsStore.open('u1');

      expect(store.readStats().lastCompletion, isNull);
    });
  });
}
