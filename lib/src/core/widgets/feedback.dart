import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../utils/formatters.dart';

void showSystemSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message, style: AppTypography.bodyStrong)),
    );
}

void showRewardSnack(
  BuildContext context, {
  required String label,
  required int xp,
  required bool leveledUp,
  required int newLevel,
}) {
  final gained = '+${formatNumber(xp)} XP';
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              leveledUp ? Icons.bolt : Icons.check,
              color: leveledUp ? AppColors.gold : AppColors.success,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                leveledUp
                    ? '¡SUBISTE DE NIVEL! Nivel $newLevel · $gained'
                    : '$label · $gained',
                style: AppTypography.bodyStrong,
              ),
            ),
          ],
        ),
      ),
    );
}

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.panel,
      title: Text(title, style: AppTypography.bodyStrong),
      content: Text(message, style: AppTypography.caption),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
