import 'package:drift/drift.dart';

import '../domain/interview_catalog.dart';
import '../domain/mission_difficulty.dart';

@DataClassName('StackTemplate')
class StackTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get goal => textEnum<DailyGoal>()();
  IntColumn get slot => integer()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get difficulty => intEnum<MissionDifficulty>()();
  IntColumn get xpReward => integer()();
  IntColumn get target => integer().withDefault(const Constant(1))();
  IntColumn get stackVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('StackSubtask')
class StackSubtasks extends Table {
  TextColumn get id => text()();
  TextColumn get templateId =>
      text().references(StackTemplates, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  IntColumn get base => integer()();
  IntColumn get perLevel => integer().withDefault(const Constant(0))();
  IntColumn get maxLevel => integer().withDefault(const Constant(30))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('UserPreference')
class UserPreferences extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get goal => textEnum<DailyGoal>()();
  TextColumn get answers => text().withDefault(const Constant('{}'))();
  TextColumn get source => text().withDefault(const Constant('interview'))();
  IntColumn get stackVersion => integer().withDefault(const Constant(1))();
  DateTimeColumn get configuredAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
