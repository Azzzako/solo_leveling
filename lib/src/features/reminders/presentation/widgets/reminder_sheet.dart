import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/adaptive_pickers.dart';
import '../../../../core/widgets/system_widgets.dart';
import '../providers/reminder_provider.dart';

Future<void> showReminderSheet(BuildContext context) => showModalBottomSheet(
  context: context,
  backgroundColor: AppColors.panel,
  builder: (context) => const _ReminderSheet(),
);

class _ReminderSheet extends ConsumerStatefulWidget {
  const _ReminderSheet();

  @override
  ConsumerState<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends ConsumerState<_ReminderSheet> {
  bool _denied = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(reminderSettingsProvider).value;
    final controller = ref.read(reminderSettingsProvider.notifier);

    Future<void> toggle(bool on) async {
      if (!on) {
        setState(() => _denied = false);
        return controller.disable();
      }
      final granted = await controller.enable();
      if (mounted) setState(() => _denied = !granted);
    }

    Future<void> chooseTime() async {
      final current = settings;
      if (current == null) return;
      final picked = await pickTime(
        context,
        initial: TimeOfDay(hour: current.hour, minute: current.minute),
        title: 'Hora del recordatorio',
      );
      if (picked == null) return;
      await controller.setTime(picked.hour * 60 + picked.minute);
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SystemLabel(
              'RECORDATORIO DIARIO',
              color: AppColors.systemGlow,
            ),
            const SizedBox(height: 8),
            Text(
              'Te avisa a la hora que elijas solo si ese día te faltan '
              'misiones. Puede llegar unos minutos tarde por el ahorro de '
              'batería.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: 8),
            if (settings == null)
              const Center(child: CircularProgressIndicator())
            else ...[
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: settings.enabled,
                onChanged: toggle,
                title: Text('Activar', style: AppTypography.bodyStrong),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: chooseTime,
                title: Text('Hora', style: AppTypography.bodyStrong),
                trailing: Text(
                  settings.timeLabel,
                  style: AppTypography.panelTitle.copyWith(
                    color: settings.enabled
                        ? AppColors.systemGlow
                        : AppColors.textMuted,
                  ),
                ),
              ),
              if (_denied)
                Text(
                  'Sin permiso de notificaciones. Actívalo en los ajustes del '
                  'teléfono para recibir el recordatorio.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.danger,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
