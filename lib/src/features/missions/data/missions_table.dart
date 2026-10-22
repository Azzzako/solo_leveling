import 'package:drift/drift.dart';

import '../../goals/data/goals_table.dart';
import '../domain/mission_difficulty.dart';

@DataClassName('Mission')
class Missions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get goalId =>
      text().nullable().references(Goals, #id, onDelete: KeyAction.setNull)();
  IntColumn get difficulty => intEnum<MissionDifficulty>()();
  IntColumn get xpReward => integer()();
  IntColumn get progress => integer().withDefault(const Constant(0))();
  IntColumn get target => integer().withDefault(const Constant(1))();
  BoolColumn get isDaily => boolean().withDefault(const Constant(true))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MissionCompletion')
class MissionCompletions extends Table {
  TextColumn get id => text()();
  TextColumn get missionId => text()();
  DateTimeColumn get completedAt => dateTime()();
  IntColumn get xpEarned => integer()();
  BoolColumn get levelUp => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
