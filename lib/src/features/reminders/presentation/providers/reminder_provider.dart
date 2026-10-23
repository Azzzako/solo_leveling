import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../missions/presentation/providers/missions_provider.dart';
import '../../data/reminder_service.dart';
import '../../domain/reminder_plan.dart';

final reminderServiceProvider = Provider<ReminderService>(
  (ref) => kIsWeb ? const NoopReminderService() : LocalReminderService(),
);

final reminderClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final reminderSettingsProvider =
    AsyncNotifierProvider<ReminderSettingsController, ReminderSettings>(
      ReminderSettingsController.new,
    );

class ReminderSettingsController extends AsyncNotifier<ReminderSettings> {
  @override
  Future<ReminderSettings> build() async {
    final settings = await ref.watch(settingsStoreProvider.future);
    return ReminderSettings(
      enabled: settings.reminderEnabled,
      asked: settings.reminderAsked,
    );
  }

  Future<bool> enable() async {
    final service = ref.read(reminderServiceProvider);
    final granted = await service.requestPermission();
    await _save(enabled: granted);
    return granted;
  }

  Future<void> enableIfNeverAsked() async {
    final current = state.value ?? await future;
    if (current.asked) return;
    await enable();
  }

  Future<void> disable() => _save(enabled: false);

  Future<void> _save({required bool enabled}) async {
    final settings = await ref.read(settingsStoreProvider.future);
    await settings.writeReminder(enabled: enabled);
    state = AsyncData(ReminderSettings(enabled: enabled, asked: true));
  }
}

final reminderSyncProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(reminderServiceProvider);
  final clock = ref.watch(reminderClockProvider);
  final settingsFuture = ref.watch(reminderSettingsProvider.future);
  ref.watch(todayProvider);
  final today = ref.watch(
    dailySummaryProvider.select(
      (summary) => summary.value == null
          ? null
          : (pending: summary.value!.remaining, xp: summary.value!.pendingXp),
    ),
  );

  final settings = await settingsFuture;
  if (!settings.enabled) {
    await service.cancelAll();
    return;
  }
  if (today == null) return;
  await service.replaceAll(
    planReminders(
      now: clock(),
      pendingToday: today.pending,
      xpAtStakeToday: today.xp,
    ),
  );
});
