import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/storage/settings_store.dart';
import '../../../core/utils/dates.dart';
import '../domain/backup_format.dart';

class BackupSnapshot {
  const BackupSnapshot({
    required this.summary,
    required this.player,
    required this.goals,
    required this.missions,
    required this.subtasks,
    required this.completions,
    required this.templates,
    required this.templateSubtasks,
    required this.preferences,
  });

  final BackupSummary summary;
  final Map<String, Object?> player;
  final List<Goal> goals;
  final List<Mission> missions;
  final List<MissionSubtask> subtasks;
  final List<MissionCompletion> completions;
  final List<StackTemplate> templates;
  final List<StackSubtask> templateSubtasks;
  final List<UserPreference> preferences;
}

class BackupRepository {
  BackupRepository(this._db, this._settings);

  final AppDatabase _db;
  final SettingsStore _settings;

  Future<Uint8List> export({required String email, DateTime? at}) async {
    final exportedAt = at ?? DateTime.now();
    final document = <String, Object?>{
      'app': backupApp,
      'format': backupFormat,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': exportedAt.toIso8601String(),
      'email': email,
      'player': _settings.exportPlayer(),
      'tables': {
        'goals': _rows(await _db.select(_db.goals).get()),
        'missions': _rows(await _db.select(_db.missions).get()),
        'mission_subtasks': _rows(await _db.select(_db.missionSubtasks).get()),
        'mission_completions': _rows(
          await _db.select(_db.missionCompletions).get(),
        ),
        'stack_templates': _rows(await _db.select(_db.stackTemplates).get()),
        'stack_subtasks': _rows(await _db.select(_db.stackSubtasks).get()),
        'user_preferences': _rows(await _db.select(_db.userPreferences).get()),
      },
    };
    return Uint8List.fromList(utf8.encode(jsonEncode(document)));
  }

  BackupSnapshot parse(List<int> bytes) {
    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(bytes));
    } on FormatException {
      throw const BackupException('El archivo no es un respaldo válido.');
    }
    if (decoded is! Map<String, dynamic> || decoded['app'] != backupApp) {
      throw const BackupException('El archivo no es un respaldo de la app.');
    }
    final format = decoded['format'];
    final schema = decoded['schemaVersion'];
    if (format is! int || schema is! int) {
      throw const BackupException('El respaldo está incompleto.');
    }
    if (format > backupFormat || schema > _db.schemaVersion) {
      throw const BackupException(
        'Este respaldo viene de una versión más nueva de la app. '
        'Actualízala antes de restaurar.',
      );
    }
    final tables = decoded['tables'];
    final player = decoded['player'];
    if (tables is! Map<String, dynamic> || player is! Map<String, dynamic>) {
      throw const BackupException('El respaldo está incompleto.');
    }

    List<T> read<T>(String table, T Function(Map<String, dynamic>) fromJson) {
      final rows = tables[table] ?? const <Object?>[];
      if (rows is! List) {
        throw BackupException('El respaldo está dañado ($table).');
      }
      try {
        return [for (final row in rows) fromJson(row as Map<String, dynamic>)];
      } on Object {
        throw BackupException('El respaldo está dañado ($table).');
      }
    }

    final goals = read('goals', Goal.fromJson);
    final missions = read('missions', Mission.fromJson);
    final completions = read('mission_completions', MissionCompletion.fromJson);
    final exportedAt = DateTime.tryParse('${decoded['exportedAt']}');

    return BackupSnapshot(
      summary: BackupSummary(
        exportedAt: exportedAt ?? DateTime.now(),
        email: '${decoded['email'] ?? ''}',
        totalXp: player['totalXp'] as int? ?? 0,
        days: {
          for (final mission in missions)
            if (mission.isDaily && mission.dueDate != null)
              dateOnly(mission.dueDate!),
        }.length,
        completions: completions.length,
        goals: goals.length,
      ),
      player: player,
      goals: goals,
      missions: missions,
      subtasks: read('mission_subtasks', MissionSubtask.fromJson),
      completions: completions,
      templates: read('stack_templates', StackTemplate.fromJson),
      templateSubtasks: read('stack_subtasks', StackSubtask.fromJson),
      preferences: read('user_preferences', UserPreference.fromJson),
    );
  }

  Future<void> restore(
    BackupSnapshot snapshot, {
    required DateTime today,
  }) async {
    try {
      await _db.transaction(() async {
        await _db.delete(_db.missionSubtasks).go();
        await _db.delete(_db.missionCompletions).go();
        await _db.delete(_db.missions).go();
        await _db.delete(_db.goals).go();
        await _db.delete(_db.stackSubtasks).go();
        await _db.delete(_db.stackTemplates).go();
        await _db.delete(_db.userPreferences).go();
        await _db.batch((batch) {
          batch
            ..insertAll(_db.goals, snapshot.goals)
            ..insertAll(_db.missions, snapshot.missions)
            ..insertAll(_db.missionSubtasks, snapshot.subtasks)
            ..insertAll(_db.missionCompletions, snapshot.completions)
            ..insertAll(_db.stackTemplates, snapshot.templates)
            ..insertAll(_db.stackSubtasks, snapshot.templateSubtasks)
            ..insertAll(_db.userPreferences, snapshot.preferences);
        });
      });
    } on Object {
      throw const BackupException(
        'No se pudo restaurar: el respaldo tiene datos inconsistentes. '
        'Tu progreso actual no se tocó.',
      );
    }
    await _settings.importPlayer(
      snapshot.player,
      settledThrough: previousDay(dateOnly(today)),
    );
  }

  List<Map<String, dynamic>> _rows(List<DataClass> rows) => [
    for (final row in rows) row.toJson(),
  ];
}
