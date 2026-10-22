import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

class SystemPanel extends StatelessWidget {
  const SystemPanel({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
    this.glow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor ?? AppColors.panelBorder),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: AppColors.systemGlow.withValues(alpha: 0.25),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class SystemLabel extends StatelessWidget {
  const SystemLabel(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTypography.systemLabel.copyWith(color: color));
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        SystemLabel(title),
        const SizedBox(width: 12),
        const Expanded(child: Divider()),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    ),
  );
}

class StatTile extends StatelessWidget {
  const StatTile({
    required this.label,
    required this.value,
    super.key,
    this.color = AppColors.systemGlow,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => SystemPanel(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(label, style: AppTypography.statLabel, maxLines: 1),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: AppTypography.metricValue.copyWith(color: color),
            maxLines: 1,
          ),
        ),
      ],
    ),
  );
}

class XpBar extends StatelessWidget {
  const XpBar({required this.progress, super.key, this.height = 8});

  final double progress;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(height),
    child: LinearProgressIndicator(
      value: progress.clamp(0, 1),
      minHeight: height,
      backgroundColor: AppColors.voidBackground,
      valueColor: const AlwaysStoppedAnimation(AppColors.systemGlow),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({required this.message, super.key, this.icon});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SystemPanel(
    child: Row(
      children: [
        Icon(icon ?? Icons.radar, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Expanded(child: Text(message, style: AppTypography.caption)),
      ],
    ),
  );
}
