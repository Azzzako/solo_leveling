import '../../../core/utils/dates.dart';
import '../../../core/utils/formatters.dart';

const reminderHorizonDays = 14;

const defaultReminderMinutes = 20 * 60;

const reminderTitle = 'Sistema · misiones pendientes';

class ReminderSettings {
  const ReminderSettings({
    required this.enabled,
    required this.minutes,
    required this.asked,
  });

  final bool enabled;
  final int minutes;
  final bool asked;

  int get hour => minutes ~/ 60;

  int get minute => minutes % 60;

  String get timeLabel => formatTime(hour, minute);
}

class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
  });

  final int id;
  final DateTime at;
  final String title;
  final String body;
}

int reminderIdFor(DateTime day) => day.year * 10000 + day.month * 100 + day.day;

List<PlannedReminder> planReminders({
  required DateTime now,
  required int minutes,
  required int pendingToday,
  required int xpAtStakeToday,
  int days = reminderHorizonDays,
}) {
  final today = dateOnly(now);
  final reminders = <PlannedReminder>[];
  for (var offset = 0; offset < days; offset++) {
    final reminder = _reminderFor(
      day: DateTime(today.year, today.month, today.day + offset),
      minutes: minutes,
      now: now,
      isToday: offset == 0,
      pendingToday: pendingToday,
      xpAtStakeToday: xpAtStakeToday,
    );
    if (reminder != null) reminders.add(reminder);
  }
  return reminders;
}

PlannedReminder? _reminderFor({
  required DateTime day,
  required int minutes,
  required DateTime now,
  required bool isToday,
  required int pendingToday,
  required int xpAtStakeToday,
}) {
  final at = DateTime(
    day.year,
    day.month,
    day.day,
    minutes ~/ 60,
    minutes % 60,
  );
  if (!at.isAfter(now)) return null;
  if (isToday && pendingToday <= 0) return null;
  return PlannedReminder(
    id: reminderIdFor(day),
    at: at,
    title: reminderTitle,
    body: isToday
        ? 'Te ${pendingToday == 1 ? 'falta' : 'faltan'} '
              '${pluralize(pendingToday, 'misión', 'misiones')} de hoy '
              '(${formatNumber(xpAtStakeToday)} XP en juego). Lo que no '
              'cumplas se cobra como castigo.'
        : 'Revisa tus misiones de hoy. Lo que no cumplas se cobra como '
              'castigo.',
  );
}
