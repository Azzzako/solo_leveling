import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';

class GoalRepository {
  GoalRepository(this._db, {this.uuid = const Uuid()});

  final AppDatabase _db;
  final Uuid uuid;

  Stream<List<Goal>> watchActive() =>
      (_db.select(_db.goals)
            ..where((g) => g.isArchived.equals(false))
            ..orderBy([(g) => OrderingTerm.asc(g.createdAt)]))
          .watch();

  Stream<List<Goal>> watchAll() => (_db.select(
    _db.goals,
  )..orderBy([(g) => OrderingTerm.asc(g.createdAt)])).watch();

  Future<Goal> create({
    required String title,
    String description = '',
    int xpReward = 500,
    DateTime? deadline,
  }) async {
    final id = uuid.v4();
    final goal = GoalsCompanion.insert(
      id: id,
      title: title,
      description: Value(description),
      xpReward: Value(xpReward),
      deadline: Value(deadline),
      createdAt: DateTime.now(),
    );
    await _db.into(_db.goals).insert(goal);
    return (_db.select(_db.goals)..where((g) => g.id.equals(id))).getSingle();
  }

  Future<void> update(Goal goal) => _db.update(_db.goals).replace(goal);

  Future<void> archive(String id) async {
    await (_db.update(_db.goals)..where((g) => g.id.equals(id))).write(
      const GoalsCompanion(isArchived: Value(true)),
    );
  }

  Future<void> complete(String id, DateTime at) async {
    await (_db.update(_db.goals)..where((g) => g.id.equals(id))).write(
      GoalsCompanion(completedAt: Value(at), isArchived: Value(true)),
    );
  }

  Future<void> delete(String id) =>
      (_db.delete(_db.goals)..where((g) => g.id.equals(id))).go();
}
