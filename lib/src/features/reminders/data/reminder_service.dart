import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminder_plan.dart';

final reminderUtc = tz.Location('UTC', [tz.minTime], [0], [tz.TimeZone.UTC]);

abstract class ReminderService {
  Future<bool> requestPermission();

  Future<void> replaceAll(List<PlannedReminder> reminders);

  Future<void> cancelAll();
}

class NoopReminderService implements ReminderService {
  const NoopReminderService();

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async {}

  @override
  Future<void> cancelAll() async {}
}

class LocalReminderService implements ReminderService {
  LocalReminderService();

  static const _channelId = 'daily_reminder';

  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _ready;

  Future<void> _init() => _ready ??= _plugin
      .initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      )
      .then((_) {});

  @override
  Future<bool> requestPermission() async {
    await _init();
    final granted = switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission(),
      TargetPlatform.iOS =>
        await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, sound: true),
      _ => false,
    };
    return granted ?? false;
  }

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async {
    await _init();
    await _plugin.cancelAll();
    for (final reminder in reminders) {
      await _plugin.zonedSchedule(
        id: reminder.id,
        scheduledDate: tz.TZDateTime.from(reminder.at.toUtc(), reminderUtc),
        title: reminder.title,
        body: reminder.body,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Recordatorio diario',
            channelDescription: 'Aviso cuando te faltan misiones del día.',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBanner: true,
            presentList: true,
            presentSound: true,
          ),
        ),
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    await _init();
    await _plugin.cancelAll();
  }
}
