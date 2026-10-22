import 'package:drift/drift.dart';

import '../../features/goals/data/goals_table.dart';
import '../../features/missions/data/mission_subtasks_table.dart';
import '../../features/missions/data/missions_table.dart';
import '../../features/missions/domain/mission_difficulty.dart';
import 'connection/connection.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Goals, Missions, MissionCompletions, MissionSubtasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(missionSubtasks);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
