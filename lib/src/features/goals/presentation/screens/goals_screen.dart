import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/adaptive_pickers.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/system_widgets.dart';
import '../../domain/goal_rules.dart';
import '../providers/goals_provider.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(activeGoalsProvider);
    final completed = ref.watch(completedGoalsProvider).value ?? const [];
    final today = ref.watch(todayProvider);

    return goals.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (list) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          SectionHeader(
            'METAS ACTIVAS',
            trailing: TextButton.icon(
              onPressed: () => _createGoal(context, ref),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Nueva'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.systemGlow,
                textStyle: AppTypography.systemLabel.copyWith(fontSize: 10),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
            ),
          ),
          if (list.isEmpty) ...[
            const EmptyState(
              message:
                  'Sin metas. Define un objetivo de largo plazo y gana XP '
                  'extra al cumplirlo.',
              icon: Icons.flag,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _createGoal(context, ref),
              icon: const Icon(Icons.add),
              label: Text(
                'NUEVA META',
                style: AppTypography.panelTitle.copyWith(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.systemBlue,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ] else
            for (final goal in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _GoalCard(
                  goal: goal,
                  today: today,
                  onComplete: () => _complete(context, ref, goal),
                  onDelete: () => _delete(context, ref, goal),
                ),
              ),
          if (completed.isNotEmpty) ...[
            const SizedBox(height: 16),
            const SectionHeader('METAS CUMPLIDAS'),
            for (final goal in completed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CompletedGoalCard(
                  goal: goal,
                  onReopen: () => _reopen(context, ref, goal),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _createGoal(BuildContext context, WidgetRef ref) async {
    final draft = await showModalBottomSheet<_GoalDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.panel,
      builder: (context) => const _GoalForm(),
    );
    if (draft == null) return;
    await ref
        .read(goalActionsProvider)
        .create(
          title: draft.title,
          description: draft.description,
          xpReward: draft.reward.xp,
          deadline: draft.deadline,
        );
  }

  Future<void> _complete(BuildContext context, WidgetRef ref, Goal goal) async {
    final confirmed = await confirmAction(
      context,
      title: 'Meta cumplida',
      message:
          '¿Ya cumpliste "${goal.title}"? Ganas '
          '${formatNumber(goal.xpReward)} XP.',
      confirmLabel: 'Sí, la cumplí',
    );
    if (!confirmed || !context.mounted) return;
    final result = await ref.read(goalActionsProvider).complete(goal);
    if (!context.mounted || result.xpEarned == 0) return;
    showRewardSnack(
      context,
      label: 'Meta cumplida',
      xp: result.xpEarned,
      leveledUp: result.leveledUp,
      newLevel: result.newLevel,
    );
  }

  Future<void> _reopen(BuildContext context, WidgetRef ref, Goal goal) async {
    final confirmed = await confirmAction(
      context,
      title: 'Reabrir meta',
      message:
          '"${goal.title}" vuelve a tus metas activas y se descuentan '
          '${formatNumber(goal.xpReward)} XP.',
      confirmLabel: 'Reabrir',
    );
    if (!confirmed || !context.mounted) return;
    final revoked = await ref.read(goalActionsProvider).reopen(goal);
    if (!context.mounted) return;
    showSystemSnack(
      context,
      revoked > 0
          ? 'Meta reabierta · -${formatNumber(revoked)} XP'
          : 'Meta reabierta',
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Goal goal) async {
    final confirmed = await confirmAction(
      context,
      title: 'Eliminar meta',
      message: 'Se borra "${goal.title}". No afecta tu XP.',
      confirmLabel: 'Eliminar',
    );
    if (!confirmed || !context.mounted) return;
    await ref.read(goalActionsProvider).delete(goal);
    if (context.mounted) showSystemSnack(context, 'Meta eliminada');
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.today,
    required this.onComplete,
    required this.onDelete,
  });

  final Goal goal;
  final DateTime today;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final deadline = goal.deadline;
    final overdue = deadline != null && isOverdue(deadline, today);
    return SystemPanel(
      borderColor: overdue ? AppColors.danger.withValues(alpha: 0.6) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(goal.title, style: AppTypography.bodyStrong),
              ),
              IconButton(
                tooltip: 'Eliminar',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline, size: 18),
                color: AppColors.textMuted,
                onPressed: onDelete,
              ),
            ],
          ),
          if (goal.description.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(goal.description, style: AppTypography.caption),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.bolt, size: 14, color: AppColors.gold),
              const SizedBox(width: 6),
              Text(
                '${formatNumber(goal.xpReward)} XP',
                style: AppTypography.caption.copyWith(color: AppColors.gold),
              ),
              const SizedBox(width: 12),
              if (deadline != null)
                Expanded(
                  child: Text(
                    '${deadlineLabel(deadline, today)} · '
                    '${formatDate(deadline)}',
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: overdue ? AppColors.danger : null,
                    ),
                  ),
                )
              else
                const Spacer(),
              TextButton.icon(
                onPressed: onComplete,
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Cumplida'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.success,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletedGoalCard extends StatelessWidget {
  const _CompletedGoalCard({required this.goal, required this.onReopen});

  final Goal goal;
  final VoidCallback onReopen;

  @override
  Widget build(BuildContext context) => SystemPanel(
    borderColor: AppColors.success.withValues(alpha: 0.4),
    child: Row(
      children: [
        const Icon(Icons.verified, color: AppColors.success, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.title,
                style: AppTypography.bodyStrong.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Cumplida el ${formatDate(goal.completedAt!)} · '
                '+${formatNumber(goal.xpReward)} XP',
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Reabrir',
          icon: const Icon(Icons.undo, size: 18),
          color: AppColors.textSecondary,
          onPressed: onReopen,
        ),
      ],
    ),
  );
}

class _GoalDraft {
  const _GoalDraft({
    required this.title,
    required this.description,
    required this.reward,
    required this.deadline,
  });

  final String title;
  final String description;
  final GoalReward reward;
  final DateTime? deadline;
}

class _GoalForm extends StatefulWidget {
  const _GoalForm();

  @override
  State<_GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<_GoalForm> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  GoalReward _reward = GoalReward.medium;
  DateTime? _deadline;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await pickDate(
      context,
      initial: _deadline ?? now.add(const Duration(days: 30)),
      first: now,
      last: DateTime(now.year + 5, 12, 31),
      title: 'Fecha límite',
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _submit() {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    Navigator.pop(
      context,
      _GoalDraft(
        title: title,
        description: _description.text,
        reward: _reward,
        deadline: _deadline,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      20 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SystemLabel('NUEVA META', color: AppColors.systemGlow),
        const SizedBox(height: 16),
        TextField(
          controller: _title,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Meta',
            hintText: 'Ej. Correr un medio maratón',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _description,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Detalles (opcional)'),
        ),
        const SizedBox(height: 16),
        Text('Recompensa', style: AppTypography.caption),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final reward in GoalReward.values)
              ChoiceChip(
                label: Text('${reward.label} · ${formatNumber(reward.xp)} XP'),
                selected: _reward == reward,
                onSelected: (_) => setState(() => _reward = reward),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickDeadline,
                icon: const Icon(Icons.event, size: 18),
                label: Text(
                  _deadline == null
                      ? 'Sin fecha límite'
                      : 'Vence el ${formatDate(_deadline!)}',
                ),
              ),
            ),
            if (_deadline != null)
              IconButton(
                tooltip: 'Quitar fecha',
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.textMuted,
                onPressed: () => setState(() => _deadline = null),
              ),
          ],
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _title.text.trim().isEmpty ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.systemBlue,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(
            'CREAR META',
            style: AppTypography.panelTitle.copyWith(color: Colors.black),
          ),
        ),
      ],
    ),
  );
}
