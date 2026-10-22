import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/system_widgets.dart';

const _actionSlot = 40.0;
const _actionGap = 8.0;
const _barGap = 10.0;
const _maxSubtaskTitleWidth = 140.0;
const _titleReference = 'Espalda y cadera';
const _counterReference = '00/00';

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
    final progress = completed
        ? 1.0
        : mission.target == 0
        ? 1.0
        : (mission.progress / mission.target).clamp(0.0, 1.0);
    final counterWidth = _widest(context, AppTypography.counter, [
      _counterReference,
      for (final subtask in subtasks) _counterSample(subtask.target),
    ]);
    final titleWidth = math.min(
      _widest(context, AppTypography.body, [
        _titleReference,
        for (final subtask in subtasks) subtask.title,
      ]),
      _maxSubtaskTitleWidth,
    );

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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
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
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                '+${formatNumber(mission.xpReward)} XP',
                                style: AppTypography.caption.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (mission.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            mission.description,
                            style: AppTypography.caption,
                          ),
                        ],
                        const SizedBox(height: 10),
                        if (hasSubtasks)
                          Text(
                            'Avance ${_counter(mission.progress, mission.target)}',
                            style: AppTypography.counter,
                          )
                        else
                          _BarRow(
                            progress: progress,
                            height: 6,
                            counter: _counter(completed ? 1 : 0, 1),
                            counterWidth: counterWidth,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: _actionGap),
                  SizedBox(
                    width: _actionSlot,
                    height: 32,
                    child: completed && onUndo != null
                        ? _UndoButton(tooltip: 'Deshacer', onPressed: onUndo!)
                        : Icon(
                            completed
                                ? Icons.verified
                                : Icons.radio_button_unchecked,
                            color: completed ? color : AppColors.textMuted,
                            size: 22,
                          ),
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
                    titleWidth: titleWidth,
                    counterWidth: counterWidth,
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

String _counter(int progress, int target) =>
    '${formatNumber(progress)}/${formatNumber(target)}';

String _counterSample(int target) => _counter(target, target);

double _widest(BuildContext context, TextStyle style, List<String> texts) =>
    texts.map((text) => _measure(context, text, style)).fold(0.0, math.max);

double _measure(BuildContext context, String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: DefaultTextStyle.of(context).style.merge(style),
    ),
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 1,
  )..layout();
  final width = painter.width.ceilToDouble();
  painter.dispose();
  return width;
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.progress,
    required this.height,
    required this.counter,
    required this.counterWidth,
  });

  final double progress;
  final double height;
  final String counter;
  final double counterWidth;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: XpBar(progress: progress, height: height),
      ),
      const SizedBox(width: _barGap),
      SizedBox(
        width: counterWidth,
        child: Text(
          counter,
          maxLines: 1,
          textAlign: TextAlign.right,
          style: AppTypography.counter,
        ),
      ),
    ],
  );
}

class _SubtaskRow extends StatelessWidget {
  const _SubtaskRow({
    required this.subtask,
    required this.color,
    required this.titleWidth,
    required this.counterWidth,
    this.onTap,
    this.onStep,
    this.onUndo,
  });

  final MissionSubtask subtask;
  final Color color;
  final double titleWidth;
  final double counterWidth;
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
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: done ? color : AppColors.textMuted,
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: titleWidth,
              child: Text(
                subtask.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body.copyWith(
                  color: done ? AppColors.textSecondary : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: _barGap),
            Expanded(
              child: _BarRow(
                progress: progress,
                height: 4,
                counter: _counter(subtask.progress, subtask.target),
                counterWidth: counterWidth,
              ),
            ),
            const SizedBox(width: _actionGap),
            SizedBox(
              width: _actionSlot,
              height: 40,
              child: done
                  ? _UndoButton(
                      tooltip: 'Deshacer',
                      onPressed: onUndo ?? () {},
                      enabled: onUndo != null,
                    )
                  : IconButton(
                      tooltip: 'Sumar',
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
  });

  final String tooltip;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    padding: EdgeInsets.zero,
    visualDensity: VisualDensity.compact,
    icon: Icon(
      Icons.undo,
      size: 18,
      color: enabled ? AppColors.textSecondary : AppColors.textMuted,
    ),
    onPressed: enabled ? onPressed : null,
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
