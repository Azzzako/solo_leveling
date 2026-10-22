import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/system_widgets.dart';
import '../../domain/backup_format.dart';
import '../providers/backup_provider.dart';
import '../screens/backup_screen.dart';

class BackupNudge extends ConsumerWidget {
  const BackupNudge({required this.hasProgress, super.key});

  final bool hasProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last = ref.watch(lastBackupProvider);
    if (!hasProgress || !last.hasValue) return const SizedBox.shrink();
    final today = ref.watch(todayProvider);
    if (!backupIsStale(last.value, today)) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SystemPanel(
        borderColor: AppColors.gold.withValues(alpha: 0.6),
        padding: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push(BackupScreen.path),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.save_alt, color: AppColors.gold),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${backupAgeLabel(last.value, today)} Respalda tu '
                    'progreso para no perderlo.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.gold,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.gold),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
