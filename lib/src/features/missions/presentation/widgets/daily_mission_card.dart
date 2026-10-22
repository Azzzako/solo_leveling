import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../data/mission_repository.dart';
import '../../domain/subtask_step.dart';
import '../providers/missions_provider.dart';
import 'mission_card.dart';

class DailyMissionCard extends ConsumerWidget {
  const DailyMissionCard({
    required this.mission,
    required this.completed,
    required this.subtasks,
    super.key,
  });

  final Mission mission;
  final bool completed;
  final List<MissionSubtask> subtasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) => MissionCard(
    mission: mission,
    completed: completed,
    subtasks: subtasks,
    onComplete: () => _complete(context, ref),
    onUndo: () => _undoMission(context, ref),
    onSubtaskComplete: (s) => _advance(context, ref, s, s.target - s.progress),
    onSubtaskStep: (s) => _advance(context, ref, s, subtaskStepFor(s.target)),
    onSubtaskUndo: (s) => _undoSubtask(context, ref, s),
  );

  Future<void> _complete(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(registerMissionProgressProvider)
        .complete(mission);
    if (!context.mounted || result.xpEarned == 0) return;
    _showReward(context, result);
  }

  Future<void> _advance(
    BuildContext context,
    WidgetRef ref,
    MissionSubtask subtask,
    int amount,
  ) async {
    final result = await ref
        .read(registerMissionProgressProvider)
        .advanceSubtask(subtask, amount: amount);
    if (!context.mounted) return;
    if (result.xpEarned > 0) {
      _showReward(context, result);
      return;
    }
    final progress = (subtask.progress + amount).clamp(0, subtask.target);
    showSystemSnack(
      context,
      '${subtask.title}: ${formatNumber(progress)}/'
      '${formatNumber(subtask.target)}',
    );
  }

  Future<void> _undoMission(BuildContext context, WidgetRef ref) async {
    final outcome = await ref
        .read(registerMissionProgressProvider)
        .undoMission(mission);
    if (context.mounted) _showUndo(context, outcome);
  }

  Future<void> _undoSubtask(
    BuildContext context,
    WidgetRef ref,
    MissionSubtask subtask,
  ) async {
    final outcome = await ref
        .read(registerMissionProgressProvider)
        .undoSubtask(subtask);
    if (context.mounted) _showUndo(context, outcome);
  }

  void _showUndo(BuildContext context, ResetOutcome outcome) => showSystemSnack(
    context,
    outcome.xpRefunded > 0
        ? 'Se deshizo · -${formatNumber(outcome.xpRefunded)} XP'
        : 'Se deshizo',
  );

  void _showReward(BuildContext context, RewardResult result) =>
      showRewardSnack(
        context,
        label: 'Misión cumplida',
        xp: result.xpEarned,
        leveledUp: result.leveledUp,
        newLevel: result.newLevel,
      );
}
