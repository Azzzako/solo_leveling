import 'package:drift/drift.dart';

import 'missions_table.dart';

@DataClassName('MissionSubtask')
class MissionSubtasks extends Table {
  TextColumn get id => text()();
  TextColumn get missionId =>
      text().references(Missions, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  IntColumn get target => integer()();
  IntColumn get progress => integer().withDefault(const Constant(0))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
