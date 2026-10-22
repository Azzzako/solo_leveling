import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/widgets/system_widgets.dart';

const subtaskStep = 10;

class MissionCard extends StatelessWidget {
  const MissionCard({
    required this.mission,
    required this.completed,
    required this.onComplete,
    super.key,
    this.subtasks = const <MissionSubtask>[],
    this.onSubtaskComplete,
    this.onSubtaskStep,
    this.onUndo,
    this.onSubtaskUndo,
  });
  final Mission mission;
  final bool completed;
  final VoidCallback onComplete;
  final List<MissionSubtask> subtasks;
  final ValueChanged<MissionSubtask>? onSubtaskComplete;
  final ValueChanged<MissionSubtask>? onSubtaskStep;
  final VoidCallback? onUndo;
  final ValueChanged<MissionSubtask>? onSubtaskUndo;

  bool get hasSubtasks => subtasks.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final color = mission.difficulty.color;
    final progress = mission.target == 0
        ? 1.0
        : (mission.progress / mission.target).clamp(0.0, 1.0);
    return SystemPanel(
      borderColor: completed ? color.withValues(alpha: 0.5) : null,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: completed ? onUndo : (hasSubtasks ? null : onComplete),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RankBadge(
                    rank: mission.difficulty.rank,
                    color: color,
                    dimmed: completed,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mission.title,
                          style: AppTypography.bodyStrong.copyWith(
                            decoration: completed
                                ? TextDecoration.lineThrough
                                : null,
                            color: completed
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (mission.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            mission.description,
                            style: AppTypography.caption,
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: XpBar(progress: progress, height: 6),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${mission.progress}/${mission.target}',
                              style: AppTypography.caption,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '+${mission.xpReward} XP',
                              style: AppTypography.caption.copyWith(
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (completed && onUndo != null)
                    _UndoButton(tooltip: 'Deshacer', onPressed: onUndo!)
                  else
                    Icon(
                      completed ? Icons.verified : Icons.radio_button_unchecked,
                      color: completed ? color : AppColors.textMuted,
                      size: 22,
                    ),
                ],
              ),
              if (hasSubtasks) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 4),
                ...subtasks.map(
                  (s) => _SubtaskRow(
                    subtask: s,
                    color: color,
                    onTap: () => onSubtaskComplete?.call(s),
                    onStep: () => onSubtaskStep?.call(s),
                    onUndo: onSubtaskUndo == null
                        ? null
                        : () => onSubtaskUndo!.call(s),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms);
  }
}

class _SubtaskRow extends StatelessWidget {
  const _SubtaskRow({
    required this.subtask,
    required this.color,
    this.onTap,
    this.onStep,
    this.onUndo,
  });

  final MissionSubtask subtask;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onStep;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final done = subtask.progress >= subtask.target;
    final progress = subtask.target == 0
        ? 1.0
        : (subtask.progress / subtask.target).clamp(0.0, 1.0);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: done ? color : AppColors.textMuted,
            ),
            const SizedBox(width: 10),
            Text(
              subtask.title,
              style: AppTypography.body.copyWith(
                color: done ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: XpBar(progress: progress, height: 4)),
            const SizedBox(width: 10),
            Text(
              '${subtask.progress}/${subtask.target}',
              style: AppTypography.caption,
            ),
            if (done)
              _UndoButton(
                tooltip: 'Deshacer',
                onPressed: onUndo ?? () {},
                enabled: onUndo != null,
                size: 32,
              )
            else
              SizedBox(
                width: 40,
                height: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.add, size: 18, color: color),
                  onPressed: onStep,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UndoButton extends StatelessWidget {
  const _UndoButton({
    required this.tooltip,
    required this.onPressed,
    this.enabled = true,
    this.size = 40,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final bool enabled;
  final int size;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: SizedBox(
      width: size.toDouble(),
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        icon: Icon(
          Icons.undo,
          size: 18,
          color: enabled ? AppColors.textSecondary : AppColors.textMuted,
        ),
        onPressed: enabled ? onPressed : null,
      ),
    ),
  );
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({
    required this.rank,
    required this.color,
    required this.dimmed,
  });
  final String rank;
  final Color color;
  final bool dimmed;
  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: dimmed ? 0.08 : 0.18),
      border: Border.all(color: color.withValues(alpha: dimmed ? 0.3 : 0.8)),
    ),
    child: Text(
      rank,
      style: AppTypography.metricValue.copyWith(
        fontSize: 15,
        color: dimmed ? color.withValues(alpha: 0.5) : color,
      ),
    ),
  );
}
