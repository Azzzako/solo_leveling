import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/system_widgets.dart';
import '../providers/missions_provider.dart';
import '../widgets/daily_mission_card.dart';

class MissionsScreen extends ConsumerWidget {
  const MissionsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(ensureDailyMissionsProvider);
    final missions = ref.watch(dailyMissionsProvider);
    final completions = ref.watch(todayCompletionsProvider);
    final subtasks = ref.watch(todaySubtasksProvider);
    final doneIds = {
      for (final c in completions.value ?? const <MissionCompletion>[])
        c.missionId,
    };
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
                  'Sin misiones por ahora. El sistema genera las de hoy en '
                  'un momento.',
            )
          else
            ...list.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DailyMissionCard(
                  mission: m,
                  completed: doneIds.contains(m.id),
                  subtasks: (subtasks.value ?? const <MissionSubtask>[])
                      .where((s) => s.missionId == m.id)
                      .toList(growable: false),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmAction(
      context,
      title: 'Reiniciar el día',
      message:
          'Borra el progreso de las misiones de hoy y sus series, y descuenta '
          'el XP que ya ganaste con ellas.',
      confirmLabel: 'Reiniciar',
    );
    if (!confirmed || !context.mounted) return;

    final result = await ref.read(registerMissionProgressProvider).resetToday();
    if (!context.mounted) return;
    showSystemSnack(
      context,
      result.xpRefunded > 0
          ? 'Día reiniciado · -${formatNumber(result.xpRefunded)} XP'
          : 'Día reiniciado',
    );
  }
}
