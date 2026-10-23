import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling/src/core/utils/formatters.dart';
import 'package:solo_leveling/src/features/reminders/domain/reminder_plan.dart';

void main() {
  test('cada 4 horas de 7:00 a. m. a 11:00 p. m.', () {
    expect(reminderHours, [7, 11, 15, 19, 23]);
    expect(
      reminderScheduleLabel,
      '7:00 a. m., 11:00 a. m., 3:00 p. m., 7:00 p. m., 11:00 p. m.',
    );
  });

  test('hoy solo programa las horas que faltan', () {
    final plan = planReminders(
      now: DateTime(2026, 10, 22, 12, 30),
      pendingToday: 3,
      xpAtStakeToday: 180,
    );
    final today = plan.where((r) => r.at.day == 22).toList();

    expect(today.map((r) => r.at.hour), [15, 19, 23]);
    expect(
      today.first.body,
      startsWith('Te faltan 3 misiones de hoy (180 XP en juego).'),
    );
    expect(today.last.body, contains('Última llamada'));
  });

  test('nunca avisa de noche', () {
    final plan = planReminders(
      now: DateTime(2026, 10, 22, 6),
      pendingToday: 7,
      xpAtStakeToday: 420,
    );

    for (final reminder in plan) {
      expect(reminder.at.hour, inInclusiveRange(7, 23));
      expect(reminder.at.minute, 0);
    }
  });

  test('si hoy ya cumpliste todo, no avisa hoy pero sí mañana', () {
    final plan = planReminders(
      now: DateTime(2026, 10, 22, 9),
      pendingToday: 0,
      xpAtStakeToday: 0,
    );

    expect(plan.where((r) => r.at.day == 22), isEmpty);
    expect(plan.first.at, DateTime(2026, 10, 23, 7));
    expect(plan.first.body, startsWith('Revisa tus misiones de hoy.'));
  });

  test('después de las 11 p. m. empieza mañana a las 7 a. m.', () {
    final plan = planReminders(
      now: DateTime(2026, 10, 22, 23, 30),
      pendingToday: 2,
      xpAtStakeToday: 100,
    );

    expect(plan.first.at, DateTime(2026, 10, 23, 7));
  });

  test('no pasa el límite de 64 avisos pendientes de iOS', () {
    final plan = planReminders(
      now: DateTime(2026, 10, 22, 0, 30),
      pendingToday: 7,
      xpAtStakeToday: 420,
    );

    expect(plan, hasLength(reminderHorizonDays * reminderHours.length));
    expect(plan.length, lessThanOrEqualTo(64));
  });

  test('ids únicos aunque cambie el mes o el año', () {
    final plan = planReminders(
      now: DateTime(2026, 12, 30, 8),
      pendingToday: 1,
      xpAtStakeToday: 10,
      days: 4,
    );

    expect(plan.map((r) => r.id).toSet(), hasLength(plan.length));
    expect(plan.first.id, 202612301);
    expect(plan.last.id, 202701024);
    expect(plan.every((r) => r.id < 2147483647), isTrue);
  });

  test('singular con una misión pendiente', () {
    final plan = planReminders(
      now: DateTime(2026, 10, 22, 8),
      pendingToday: 1,
      xpAtStakeToday: 37,
    );

    expect(plan.first.body, startsWith('Te falta 1 misión de hoy (37 XP'));
  });

  test('formatTime usa 12 horas con a. m. y p. m.', () {
    expect(formatTime(20, 0), '8:00 p. m.');
    expect(formatTime(0, 30), '12:30 a. m.');
    expect(formatTime(12, 5), '12:05 p. m.');
    expect(formatTime(7, 45), '7:45 a. m.');
  });
}
