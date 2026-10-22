import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../data/goal_repository.dart';

final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => GoalRepository(ref.watch(appDatabaseProvider)),
);

final activeGoalsProvider = StreamProvider<List<Goal>>(
  (ref) => ref.watch(goalRepositoryProvider).watchActive(),
);

final completedGoalsProvider = StreamProvider<List<Goal>>(
  (ref) => ref.watch(goalRepositoryProvider).watchCompleted(),
);

final allGoalsProvider = StreamProvider<List<Goal>>(
  (ref) => ref.watch(goalRepositoryProvider).watchAll(),
);

final goalActionsProvider = Provider<GoalActions>((ref) => GoalActions(ref));

class GoalActions {
  GoalActions(this._ref);

  final Ref _ref;

  GoalRepository get _repository => _ref.read(goalRepositoryProvider);

  Future<Goal> create({
    required String title,
    required String description,
    required int xpReward,
    DateTime? deadline,
  }) => _repository.create(
    title: title.trim(),
    description: description.trim(),
    xpReward: xpReward,
    deadline: deadline,
  );

  Future<RewardResult> complete(Goal goal) async {
    if (!await _repository.complete(goal.id, DateTime.now())) {
      return const RewardResult.none();
    }
    return _ref.read(playerProvider.notifier).grantXp(goal.xpReward);
  }

  Future<int> reopen(Goal goal) async {
    if (!await _repository.reopen(goal.id)) return 0;
    await _ref.read(playerProvider.notifier).revokeXp(goal.xpReward);
    return goal.xpReward;
  }

  Future<void> delete(Goal goal) => _repository.delete(goal.id);
}
