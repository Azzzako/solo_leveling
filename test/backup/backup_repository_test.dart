import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling/src/core/db/app_database.dart';
import 'package:solo_leveling/src/core/storage/settings_store.dart';
import 'package:solo_leveling/src/features/backup/data/backup_repository.dart';
import 'package:solo_leveling/src/features/backup/domain/backup_format.dart';
import 'package:solo_leveling/src/features/goals/data/goal_repository.dart';
import 'package:solo_leveling/src/features/missions/data/mission_repository.dart';
import 'package:solo_leveling/src/features/player/domain/player_stats.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase sourceDb;
  late AppDatabase targetDb;
  late SettingsStore sourceSettings;
  late SettingsStore targetSettings;
  late BackupRepository source;
  late BackupRepository target;
  final today = DateTime(2026, 10, 22, 9);

  setUp(() async {
    SharedPreferences.setMockInitialValues({'sl_legacy_claimed': true});
    sourceDb = AppDatabase.forTesting(NativeDatabase.memory());
    targetDb = AppDatabase.forTesting(NativeDatabase.memory());
    sourceSettings = await SettingsStore.open('origen');
    targetSettings = await SettingsStore.open('destino');
    source = BackupRepository(sourceDb, sourceSettings);
    target = BackupRepository(targetDb, targetSettings);
  });

  tearDown(() async {
    await sourceDb.close();
    await targetDb.close();
  });

  Future<void> seedSource() async {
    final missions = MissionRepository(sourceDb);
    await missions.generateDailyMissions(DateTime(2026, 10, 20), level: 1);
    await missions.generateDailyMissions(DateTime(2026, 10, 21), level: 3);
    for (final mission in await missions.dailyMissionsOn(
      DateTime(2026, 10, 21),
    )) {
      if ((await missions.subtasksOf(mission.id)).isEmpty) {
        await missions.registerProgress(mission.id, amount: mission.target);
      }
    }
    final goal = await GoalRepository(sourceDb)
        .create(title: 'Correr 10 km', xpReward: 1000);
    await GoalRepository(sourceDb).complete(goal.id, DateTime(2026, 10, 21));
    await sourceSettings.writeStats(
      PlayerStats(
        name: 'Jin',
        totalXp: 1234,
        streak: 2,
        lastCompletion: DateTime(2026, 10, 21, 20),
      ),
    );
  }

  test('exportar y restaurar deja una copia idéntica', () async {
    await seedSource();
    await MissionRepository(targetDb)
        .generateDailyMissions(DateTime(2026, 9, 1), level: 1);
    await GoalRepository(targetDb).create(title: 'Meta que se va a borrar');
    await targetSettings.writeStats(
      PlayerStats(name: 'Otro', totalXp: -50, streak: 0),
    );
    await targetSettings.writeLastSettledDate(DateTime(2026, 9, 1));

    final bytes = await source.export(email: 'jin@correo.mx', at: today);
    final snapshot = target.parse(bytes);
    await target.restore(snapshot, today: today);

    Future<List<String>> ids(AppDatabase db) async => [
      for (final m in await db.select(db.missions).get()) m.id,
      for (final s in await db.select(db.missionSubtasks).get()) s.id,
      for (final c in await db.select(db.missionCompletions).get()) c.id,
      for (final g in await db.select(db.goals).get()) g.id,
      for (final t in await db.select(db.stackTemplates).get()) t.id,
      for (final t in await db.select(db.stackSubtasks).get()) t.id,
    ]..sort();

    expect(await ids(targetDb), await ids(sourceDb));
    expect(
      (await targetDb.select(targetDb.goals).getSingle()).completedAt,
      DateTime(2026, 10, 21),
    );
    expect(
      (await targetDb.select(targetDb.userPreferences).getSingle()).source,
      (await sourceDb.select(sourceDb.userPreferences).getSingle()).source,
    );

    final stats = targetSettings.readStats();
    expect(stats.name, 'Jin');
    expect(stats.totalXp, 1234);
    expect(stats.lastCompletion, DateTime(2026, 10, 21, 20));
    expect(targetSettings.lastSettledDate, DateTime(2026, 10, 21));

    expect(snapshot.summary.email, 'jin@correo.mx');
    expect(snapshot.summary.days, 2);
    expect(snapshot.summary.goals, 1);
    expect(snapshot.summary.totalXp, 1234);
    expect(snapshot.summary.completions, greaterThan(0));
    expect(describeBackup(snapshot.summary), contains('1,234 XP'));
  });

  group('archivos que no se aceptan', () {
    List<int> encode(Map<String, Object?> json) =>
        utf8.encode(jsonEncode(json));

    test('basura', () {
      expect(
        () => target.parse(utf8.encode('no soy json')),
        throwsA(isA<BackupException>()),
      );
    });

    test('json de otra app', () {
      expect(
        () => target.parse(encode({'app': 'otra', 'format': 1})),
        throwsA(isA<BackupException>()),
      );
    });

    test('formato o esquema más nuevo', () {
      for (final (format, schema) in [(backupFormat + 1, 1), (1, 999)]) {
        expect(
          () => target.parse(
            encode({
              'app': backupApp,
              'format': format,
              'schemaVersion': schema,
              'player': <String, Object?>{},
              'tables': <String, Object?>{},
            }),
          ),
          throwsA(
            isA<BackupException>().having(
              (e) => e.message,
              'message',
              contains('más nueva'),
            ),
          ),
        );
      }
    });

    test('una fila dañada', () async {
      final bytes = await source.export(email: '', at: today);
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      (json['tables'] as Map<String, dynamic>)['goals'] = [
        {'id': 1, 'title': null},
      ];

      expect(
        () => target.parse(encode(json)),
        throwsA(
          isA<BackupException>().having(
            (e) => e.message,
            'message',
            contains('goals'),
          ),
        ),
      );
    });
  });

  test('un respaldo inconsistente no toca el progreso actual', () async {
    await seedSource();
    await MissionRepository(targetDb)
        .generateDailyMissions(DateTime(2026, 9, 1), level: 1);
    await targetSettings.writeStats(
      PlayerStats(name: 'Otro', totalXp: 77, streak: 0),
    );
    final before = await targetDb.select(targetDb.missions).get();

    final bytes = await source.export(email: '', at: today);
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    final tables = json['tables'] as Map<String, dynamic>;
    tables['missions'] = <Object?>[];
    final snapshot = target.parse(utf8.encode(jsonEncode(json)));

    await expectLater(
      target.restore(snapshot, today: today),
      throwsA(isA<BackupException>()),
    );
    expect(
      await targetDb.select(targetDb.missions).get(),
      hasLength(before.length),
    );
    expect(targetSettings.readStats().totalXp, 77);
  });

  group('antigüedad del respaldo', () {
    test('sin respaldo o con más de 7 días está vencido', () {
      expect(backupIsStale(null, today), isTrue);
      expect(backupIsStale(DateTime(2026, 10, 15), today), isTrue);
      expect(backupIsStale(DateTime(2026, 10, 16), today), isFalse);
      expect(backupIsStale(DateTime(2026, 10, 22, 8), today), isFalse);
    });

    test('etiquetas en español', () {
      expect(backupAgeLabel(null, today), 'Nunca has hecho un respaldo.');
      expect(
        backupAgeLabel(DateTime(2026, 10, 22, 1), today),
        'Último respaldo: hoy (22/10/2026).',
      );
      expect(
        backupAgeLabel(DateTime(2026, 10, 21), today),
        'Último respaldo: ayer (21/10/2026).',
      );
      expect(
        backupAgeLabel(DateTime(2026, 10, 12), today),
        'Último respaldo: hace 10 días (12/10/2026).',
      );
    });

    test('nombre del archivo con fecha', () {
      expect(
        backupFileName(DateTime(2026, 3, 7, 18)),
        'solo_leveling_respaldo_2026-03-07.json',
      );
    });
  });
}
