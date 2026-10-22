import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/system_widgets.dart';
import '../../domain/backup_format.dart';
import '../providers/backup_provider.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  static const path = '/respaldo';

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } on BackupException catch (error) {
      if (mounted) showSystemSnack(context, error.message);
    } on Object {
      if (mounted) {
        showSystemSnack(
          context,
          'Algo falló con el archivo. Intenta de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export() => _run(() async {
    final saved = await ref.read(backupActionsProvider).export();
    if (!mounted || !saved) return;
    showSystemSnack(context, 'Respaldo guardado');
  });

  Future<void> _restore() => _run(() async {
    final actions = ref.read(backupActionsProvider);
    final snapshot = await actions.pick();
    if (snapshot == null || !mounted) return;
    final confirmed = await confirmAction(
      context,
      title: 'Restaurar respaldo',
      message:
          '${describeBackup(snapshot.summary)}\n\nSe reemplaza TODO tu '
          'progreso actual en este teléfono. Los días entre el respaldo y hoy '
          'no se cobran como castigo.',
      confirmLabel: 'Restaurar',
    );
    if (!confirmed) return;
    await actions.restore(snapshot);
    if (!mounted) return;
    showSystemSnack(context, 'Progreso restaurado');
    context.pop();
  });

  @override
  Widget build(BuildContext context) {
    final last = ref.watch(lastBackupProvider).value;
    final today = ref.watch(todayProvider);
    final stale = backupIsStale(last, today);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Volver',
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, size: 20),
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                const SystemLabel('RESPALDO'),
              ],
            ),
            const SizedBox(height: 12),
            SystemPanel(
              glow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tu progreso es tuyo', style: AppTypography.bodyStrong),
                  const SizedBox(height: 6),
                  Text(
                    'Todo vive solo en este teléfono. Si lo pierdes, lo '
                    'cambias o desinstalas la app, se pierde. Guarda un '
                    'respaldo seguido en Drive, en tu correo o en tu '
                    'computadora.',
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        stale ? Icons.warning_amber_rounded : Icons.verified,
                        size: 16,
                        color: stale ? AppColors.gold : AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          backupAgeLabel(last, today),
                          style: AppTypography.caption.copyWith(
                            color: stale ? AppColors.gold : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _busy ? null : _export,
              icon: const Icon(Icons.save_alt),
              label: Text(
                'EXPORTAR RESPALDO',
                style: AppTypography.panelTitle.copyWith(color: Colors.black),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.systemBlue,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : _restore,
              icon: const Icon(Icons.restore),
              label: const Text('Restaurar desde un archivo'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'El respaldo es un archivo .json con tu XP, racha, misiones, '
              'rutina y metas. No sale a internet: tú decides dónde guardarlo.',
              style: AppTypography.caption.copyWith(color: AppColors.textMuted),
            ),
            if (_busy) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
