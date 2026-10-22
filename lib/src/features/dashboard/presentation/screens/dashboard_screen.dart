import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/system_widgets.dart';
import '../../../backup/presentation/widgets/backup_nudge.dart';
import '../../../missions/presentation/providers/missions_provider.dart';
import '../../../missions/presentation/widgets/daily_mission_card.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/presentation/widgets/player_status_panel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(ensureDailyMissionsProvider);
    final settlement = ref.watch(dailySettlementProvider).value;
    final stats = ref.watch(playerProvider);
    final summary = ref.watch(dailySummaryProvider).value;
    final missions = ref.watch(dailyMissionsProvider);
    final subtasks = ref.watch(todaySubtasksProvider);
    final doneIds = {
      for (final c
          in ref.watch(todayCompletionsProvider).value ??
              const <MissionCompletion>[])
        c.missionId,
    };

    final pending =
        missions.value?.where((m) => !doneIds.contains(m.id)).toList() ??
        const <Mission>[];
    final todayXp = summary?.xp ?? 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        stats.when(
          data: (s) => PlayerStatusPanel(
            stats: s,
            todayCompleted: summary?.completed ?? 0,
            todayTotal: summary?.total ?? 0,
            onRename: () => _rename(context, ref, s.name),
          ),
          loading: () => const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, s) => ErrorState(message: '$e'),
        ),
        BackupNudge(
          hasProgress:
              (stats.value?.totalXp ?? 0) != 0 || (summary?.completed ?? 0) > 0,
        ),
        if (settlement != null && settlement.penaltyApplied > 0) ...[
          const SizedBox(height: 12),
          _PenaltyNotice(settlement: settlement),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'XP HOY',
                value: '+${formatNumber(todayXp)}',
                color: AppColors.systemGlow,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                label: 'PENDIENTES',
                value: '${summary?.remaining ?? 0}',
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                label: 'PROGRESO',
                value: '${((summary?.progress ?? 0) * 100).round()}%',
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const SectionHeader('PRÓXIMAS MISIONES'),
        if (missions.isLoading && !missions.hasValue)
          const Center(child: CircularProgressIndicator())
        else if (pending.isEmpty)
          const EmptyState(
            message: 'Cumpliste todas las misiones de hoy. Descansa, cazador.',
            icon: Icons.local_fire_department,
          )
        else
          ...pending
              .take(3)
              .map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DailyMissionCard(
                    mission: m,
                    completed: false,
                    subtasks: (subtasks.value ?? const <MissionSubtask>[])
                        .where((s) => s.missionId == m.id)
                        .toList(growable: false),
                  ),
                ),
              ),
      ],
    );
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _RenameDialog(initial: current),
    );
    if (name == null) return;
    await ref.read(playerProvider.notifier).rename(name);
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial});

  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() => Navigator.pop(context, _controller.text);

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AppColors.panel,
    title: Text('Tu nombre de cazador', style: AppTypography.bodyStrong),
    content: TextField(
      controller: _controller,
      autofocus: true,
      maxLength: 24,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(hintText: 'Cazador'),
      onSubmitted: (_) => _save(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(onPressed: _save, child: const Text('Guardar')),
    ],
  );
}

class _PenaltyNotice extends StatelessWidget {
  const _PenaltyNotice({required this.settlement});

  final DailySettlement settlement;

  @override
  Widget build(BuildContext context) => SystemPanel(
    borderColor: AppColors.danger.withValues(alpha: 0.6),
    child: Row(
      children: [
        const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Castigo del sistema: -${formatNumber(settlement.penaltyApplied)} '
            'XP por ${pluralize(settlement.daysPenalized, 'día', 'días')} '
            'sin cumplir.',
            style: AppTypography.caption.copyWith(color: AppColors.danger),
          ),
        ),
      ],
    ),
  );
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
