import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/widgets/system_widgets.dart';
import '../../../missions/presentation/providers/missions_provider.dart';
import '../../../missions/presentation/widgets/mission_card.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/presentation/widgets/player_status_panel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(ensureDailyMissionsProvider);
    final stats = ref.watch(playerProvider);
    final summary = ref.watch(dailySummaryProvider);
    final missions = ref.watch(dailyMissionsProvider);
    final subtasks = ref.watch(todaySubtasksProvider);
    final doneIds = ref.watch(todayCompletionsProvider).value == null
        ? <String>{}
        : {
            for (final c in ref.read(todayCompletionsProvider).value!)
              c.missionId,
          };

    final pending =
        missions.value?.where((m) => !doneIds.contains(m.id)).toList() ??
        const [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        stats.when(
          data: (s) => PlayerStatusPanel(
            stats: s,
            todayCompleted: summary.value?.completed ?? 0,
            todayTotal: summary.value?.total ?? 0,
          ),
          loading: () => const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, s) => ErrorState(message: '$e'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'XP HOY',
                value: '+${summary.value?.xp ?? 0}',
                color: AppColors.systemGlow,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                label: 'PENDIENTES',
                value: '${summary.value?.remaining ?? 0}',
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                label: 'PROGRESO',
                value: '${((summary.value?.progress ?? 0) * 100).round()}%',
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const SectionHeader('PRÓXIMAS MISIONES'),
        if (pending.isEmpty)
          const EmptyState(
            message:
                'Todas las misiones del día completadas. Descansa, cazador.',
            icon: Icons.local_fire_department,
          )
        else
          ...pending
              .take(3)
              .map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: MissionCard(
                    mission: m,
                    completed: false,
                    subtasks: (subtasks.value ?? const <MissionSubtask>[])
                        .where((s) => s.missionId == m.id)
                        .toList(growable: false),
                    onSubtaskComplete: (s) =>
                        _reward(context, ref, s, complete: true),
                    onSubtaskStep: (s) => _reward(context, ref, s, step: true),
                    onSubtaskUndo: (s) =>
                        _undo(context, ref, s, undoMission: false),
                    onUndo: () => _undo(context, ref, m),
                    onComplete: () => _complete(context, ref, m),
                  ),
                ),
              ),
      ],
    );
  }

  Future<void> _complete(BuildContext context, WidgetRef ref, Mission m) async {
    final result = await ref.read(registerMissionProgressProvider).complete(m);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            result.leveledUp
                ? '¡SUBISTE DE NIVEL! Nivel ${result.newLevel}'
                : '+${result.xpEarned} XP',
            style: AppTypography.bodyStrong,
          ),
        ),
      );
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

  Future<void> _reward(
    BuildContext context,
    WidgetRef ref,
    MissionSubtask subtask, {
    bool complete = false,
    bool step = false,
  }) async {
    final action = ref.read(registerMissionProgressProvider);
    final result = complete
        ? await action.completeSubtask(subtask)
        : await action.advanceSubtask(subtask, amount: subtaskStep);
    if (!context.mounted || (result.xpEarned == 0 && !step)) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            result.leveledUp
                ? '¡SUBISTE DE NIVEL! Nivel ${result.newLevel}'
                : result.xpEarned > 0
                ? '+${result.xpEarned} XP'
                : '${subtask.title}: ${subtask.progress}/${subtask.target}',
            style: AppTypography.bodyStrong,
          ),
        ),
      );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) => SystemPanel(
    borderColor: AppColors.danger,
    child: Text(message, style: AppTypography.caption),
  );
}
