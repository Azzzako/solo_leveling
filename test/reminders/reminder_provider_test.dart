import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling/src/core/db/app_database.dart';
import 'package:solo_leveling/src/core/providers/core_providers.dart';
import 'package:solo_leveling/src/features/auth/domain/auth_user.dart';
import 'package:solo_leveling/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:solo_leveling/src/features/missions/domain/interview_catalog.dart';
import 'package:solo_leveling/src/features/missions/presentation/providers/missions_provider.dart';
import 'package:solo_leveling/src/features/reminders/data/reminder_service.dart';
import 'package:solo_leveling/src/features/reminders/domain/reminder_plan.dart';
import 'package:solo_leveling/src/features/reminders/presentation/providers/reminder_provider.dart';

class _StubAuth extends AuthController {
  @override
  Future<AuthUser?> build() async =>
      const AuthUser(id: 'test-user', email: 'cazador@test.dev');
}

class _FakeReminders implements ReminderService {
  bool granted = true;
  int permissionRequests = 0;
  int cancels = 0;
  List<PlannedReminder> scheduled = const [];

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return granted;
  }

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async {
    scheduled = reminders;
  }

  @override
  Future<void> cancelAll() async {
    cancels++;
    scheduled = const [];
  }
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late _FakeReminders reminders;
  final now = DateTime.now();
  final morning = DateTime(now.year, now.month, now.day, 8);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    reminders = _FakeReminders();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        authProvider.overrideWith(_StubAuth.new),
        reminderServiceProvider.overrideWithValue(reminders),
        reminderClockProvider.overrideWithValue(() => morning),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> sync() async {
    container.listen(reminderSyncProvider, (_, _) {}, fireImmediately: true);
    container.listen(dailySummaryProvider, (_, _) {}, fireImmediately: true);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    await container.read(reminderSyncProvider.future);
  }

  Future<void> ready() async {
    container.listen(
      ensureDailyMissionsProvider,
      (_, _) {},
      fireImmediately: true,
    );
    await container.read(ensureDailyMissionsProvider.future);
  }

  test('apagado por defecto: no programa nada', () async {
    await ready();
    await sync();

    final settings = await container.read(reminderSettingsProvider.future);
    expect(settings.enabled, isFalse);
    expect(settings.minutes, defaultReminderMinutes);
    expect(reminders.scheduled, isEmpty);
    expect(reminders.cancels, greaterThan(0));
  });

  test('al activarlo avisa hoy con lo que falta y lo actualiza', () async {
    await ready();
    final granted = await container
        .read(reminderSettingsProvider.notifier)
        .enable(minutes: 21 * 60);
    expect(granted, isTrue);
    await sync();

    expect(reminders.scheduled, hasLength(reminderHorizonDays));
    expect(reminders.scheduled.first.at.hour, 21);
    expect(
      reminders.scheduled.first.body,
      startsWith('Te faltan 7 misiones de hoy ($dailyStackXp XP en juego).'),
    );

    final water =
        (await container.read(missionRepositoryProvider).dailyMissionsOn(now))
            .firstWhere((m) => m.title.startsWith('Toma'));
    await container.read(registerMissionProgressProvider).complete(water);
    await sync();

    expect(
      reminders.scheduled.first.body,
      startsWith(
        'Te faltan 6 misiones de hoy '
        '(${dailyStackXp - water.xpReward} XP en juego).',
      ),
    );
  });

  test('sin permiso queda apagado y no vuelve a preguntar solo', () async {
    reminders.granted = false;
    final controller = container.read(reminderSettingsProvider.notifier);

    await controller.enableIfNeverAsked();
    await controller.enableIfNeverAsked();

    final settings = await container.read(reminderSettingsProvider.future);
    expect(settings.enabled, isFalse);
    expect(settings.asked, isTrue);
    expect(reminders.permissionRequests, 1);
  });

  test('apagarlo cancela los avisos', () async {
    await ready();
    final controller = container.read(reminderSettingsProvider.notifier);
    await controller.enable();
    await sync();
    expect(reminders.scheduled, isNotEmpty);

    await controller.disable();
    await sync();

    expect(reminders.scheduled, isEmpty);
  });
}
