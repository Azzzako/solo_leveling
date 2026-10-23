import '../../../core/utils/dates.dart';
import '../../../core/utils/formatters.dart';

const reminderDayStartHour = 7;

const reminderDayEndHour = 23;

const reminderEveryHours = 4;

const reminderHorizonDays = 12;

const reminderTitle = 'Sistema · misiones pendientes';

final reminderHours = List<int>.unmodifiable([
  for (
    var hour = reminderDayStartHour;
    hour <= reminderDayEndHour;
    hour += reminderEveryHours
  )
    hour,
]);

String get reminderScheduleLabel =>
    reminderHours.map((hour) => formatTime(hour, 0)).join(', ');

class ReminderSettings {
  const ReminderSettings({required this.enabled, required this.asked});

  final bool enabled;
  final bool asked;
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

int reminderIdFor(DateTime day, int slot) =>
    (day.year * 10000 + day.month * 100 + day.day) * 10 + slot;

List<PlannedReminder> planReminders({
  required DateTime now,
  required int pendingToday,
  required int xpAtStakeToday,
  int days = reminderHorizonDays,
}) {
  final today = dateOnly(now);
  final reminders = <PlannedReminder>[];
  for (var offset = 0; offset < days; offset++) {
    final isToday = offset == 0;
    if (isToday && pendingToday <= 0) continue;
    final day = DateTime(today.year, today.month, today.day + offset);
    for (var slot = 0; slot < reminderHours.length; slot++) {
      final at = DateTime(day.year, day.month, day.day, reminderHours[slot]);
      if (!at.isAfter(now)) continue;
      reminders.add(
        PlannedReminder(
          id: reminderIdFor(day, slot),
          at: at,
          title: reminderTitle,
          body: _body(
            isToday: isToday,
            isLast: slot == reminderHours.length - 1,
            pending: pendingToday,
            xp: xpAtStakeToday,
          ),
        ),
      );
    }
  }
  return reminders;
}

String _body({
  required bool isToday,
  required bool isLast,
  required int pending,
  required int xp,
}) {
  final closing = isLast
      ? 'Última llamada: lo que no cumplas antes de medianoche se cobra.'
      : 'Lo que no cumplas se cobra como castigo.';
  if (!isToday) return 'Revisa tus misiones de hoy. $closing';
  return 'Te ${pending == 1 ? 'falta' : 'faltan'} '
      '${pluralize(pending, 'misión', 'misiones')} de hoy '
      '(${formatNumber(xp)} XP en juego). $closing';
}
