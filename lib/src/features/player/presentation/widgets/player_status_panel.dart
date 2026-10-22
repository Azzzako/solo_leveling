import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/system_widgets.dart';
import '../../domain/player_stats.dart';

class PlayerStatusPanel extends StatelessWidget {
  const PlayerStatusPanel({
    required this.stats,
    required this.todayCompleted,
    required this.todayTotal,
    super.key,
    this.onRename,
  });

  final PlayerStats stats;
  final int todayCompleted;
  final int todayTotal;
  final VoidCallback? onRename;

  @override
  Widget build(BuildContext context) {
    final rank = stats.rank;
    return SystemPanel(
      glow: !stats.inDebt,
      borderColor: (stats.inDebt ? AppColors.danger : rank.color).withValues(
        alpha: 0.6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SystemLabel('ESTADO', color: rank.color),
              const Spacer(),
              SystemLabel('RANGO ${rank.label}', color: rank.color),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NIVEL',
                    style: AppTypography.systemLabel.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text('${stats.level}', style: AppTypography.levelNumber),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: onRename,
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              stats.name.toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.panelTitle,
                            ),
                          ),
                          if (onRename != null) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(rank.title, style: AppTypography.caption),
                    const SizedBox(height: 10),
                    XpBar(progress: stats.levelProgress),
                    const SizedBox(height: 6),
                    Text(
                      stats.inDebt
                          ? 'DEUDA ${formatNumber(stats.totalXp.abs())} XP'
                          : '${formatNumber(stats.xpIntoLevel)} / '
                                '${formatNumber(stats.xpNeededForNext)} XP',
                      style: AppTypography.caption.copyWith(
                        color: stats.inDebt ? AppColors.danger : null,
                        fontWeight: stats.inDebt ? FontWeight.w700 : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniStat(
                icon: stats.inDebt ? Icons.trending_down : Icons.bolt,
                label: '${formatNumber(stats.totalXp)} XP',
                color: stats.inDebt ? AppColors.danger : AppColors.systemGlow,
              ),
              _MiniStat(
                icon: Icons.local_fire_department,
                label: pluralize(stats.streak, 'día', 'días'),
                color: AppColors.gold,
              ),
              _MiniStat(
                icon: Icons.check_circle,
                label: '$todayCompleted/$todayTotal',
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05);
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.voidBackground,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.35)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.caption.copyWith(color: color)),
      ],
    ),
  );
}
