import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/widgets/system_widgets.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../providers/missions_provider.dart';
import '../widgets/mission_card.dart';

class MissionsScreen extends ConsumerWidget {
  const MissionsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(ensureDailyMissionsProvider);
    final missions = ref.watch(dailyMissionsProvider);
    final completions = ref.watch(todayCompletionsProvider);
    final subtasks = ref.watch(todaySubtasksProvider);
    final doneIds = completions.value == null
        ? <String>{}
        : {for (final c in completions.value!) c.missionId};
    return missions.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (list) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          SectionHeader(
            'MISIONES DIARIAS',
            trailing: TextButton.icon(
              onPressed: list.isEmpty
                  ? null
                  : () => _confirmReset(context, ref),
              icon: const Icon(Icons.restart_alt, size: 16),
              label: const Text('Reiniciar'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                textStyle: AppTypography.systemLabel.copyWith(fontSize: 10),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
            ),
          ),
          if (list.isEmpty)
            const EmptyState(
              message:
                  'Sin misiones hoy. El sistema genera el nuevo set al '
                  'reiniciar el día.',
            )
          else
            ...list.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MissionCard(
                  mission: m,
                  completed: doneIds.contains(m.id),
                  subtasks: _subtasksOf(subtasks.value, m.id),
                  onSubtaskComplete: (s) => _completeSubtask(context, ref, s),
                  onSubtaskStep: (s) =>
                      _completeSubtask(context, ref, s, amount: subtaskStep),
                  onSubtaskUndo: (s) =>
                      _undo(context, ref, s, undoMission: false),
                  onUndo: () => _undo(context, ref, m),
                  onComplete: () => _complete(context, ref, m),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<MissionSubtask> _subtasksOf(
    List<MissionSubtask>? all,
    String missionId,
  ) {
    if (all == null) return const [];
    return all.where((s) => s.missionId == missionId).toList(growable: false);
  }

  Future<void> _undo(
    BuildContext context,
    WidgetRef ref,
    Object target, {
    bool undoMission = true,
  }) async {
    final action = ref.read(registerMissionProgressProvider);
    final outcome = undoMission
        ? await action.undoMission(target as Mission)
        : await action.undoSubtask(target as MissionSubtask);
    if (!context.mounted) return;
    final message = outcome.xpRefunded > 0
        ? 'Deshecho · -${outcome.xpRefunded} XP'
        : 'Deshecho';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message, style: AppTypography.bodyStrong)),
      );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.panel,
        title: Text('Reiniciar el día', style: AppTypography.bodyStrong),
        content: Text(
          'Borra el progreso de las misiones de hoy, sus subtareas y '
          'devuelve el XP ya ganado con ellas.',
          style: AppTypography.caption,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final result = await ref.read(registerMissionProgressProvider).resetToday();
    if (!context.mounted) return;
    final message = result.xpRefunded > 0
        ? 'Día reiniciado · -${result.xpRefunded} XP'
        : 'Día reiniciado';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message, style: AppTypography.bodyStrong)),
      );
  }

  Future<void> _complete(
    BuildContext context,
    WidgetRef ref,
    Mission mission,
  ) async {
    final result = await ref
        .read(registerMissionProgressProvider)
        .complete(mission);
    if (!context.mounted) return;
    _showReward(context, result);
  }

  Future<void> _completeSubtask(
    BuildContext context,
    WidgetRef ref,
    MissionSubtask subtask, {
    int? amount,
  }) async {
    final action = ref.read(registerMissionProgressProvider);
    final result = amount == null
        ? await action.completeSubtask(subtask)
        : await action.advanceSubtask(subtask, amount: amount);
    if (!context.mounted) return;
    if (result.xpEarned == 0) return;
    _showReward(context, result);
  }

  void _showReward(BuildContext context, RewardResult result) {
    final message = switch ((result.leveledUp, result.xpEarned)) {
      (true, final xp) =>
        '¡SUBISTE DE NIVEL! Nivel ${result.newLevel} · +$xp XP',
      (false, 0) => 'Misión completada',
      (_, final xp) => '+$xp XP',
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                result.leveledUp ? Icons.bolt : Icons.check,
                color: result.leveledUp ? AppColors.gold : AppColors.success,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message, style: AppTypography.bodyStrong)),
            ],
          ),
        ),
      );
  }
}

typedef RewardLike = ({bool leveledUp, int xpEarned, int newLevel});
