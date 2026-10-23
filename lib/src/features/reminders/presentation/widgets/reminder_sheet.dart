import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/system_widgets.dart';
import '../../domain/reminder_plan.dart';
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

  Future<void> _toggle(bool on) async {
    final controller = ref.read(reminderSettingsProvider.notifier);
    if (!on) {
      setState(() => _denied = false);
      return controller.disable();
    }
    final granted = await controller.enable();
    if (mounted) setState(() => _denied = !granted);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(reminderSettingsProvider).value;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SystemLabel('RECORDATORIOS', color: AppColors.systemGlow),
            const SizedBox(height: 8),
            Text(
              'Te avisan cada $reminderEveryHours horas mientras te falten '
              'misiones: $reminderScheduleLabel. De '
              '${formatTime(reminderDayEndHour, 0)} a '
              '${formatTime(reminderDayStartHour, 0)} no llega nada. Cuando '
              'cumples todo, se detienen por hoy.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: 8),
            if (settings == null)
              const Center(child: CircularProgressIndicator())
            else ...[
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: settings.enabled,
                onChanged: _toggle,
                title: Text('Activar', style: AppTypography.bodyStrong),
              ),
              if (_denied)
                Text(
                  'Sin permiso de notificaciones. Actívalo en los ajustes del '
                  'teléfono para recibir los recordatorios.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                'Pueden llegar unos minutos tarde por el ahorro de batería.',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
