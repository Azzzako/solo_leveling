import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling/src/core/utils/formatters.dart';
import 'package:solo_leveling/src/features/reminders/domain/reminder_plan.dart';

void main() {
  final morning = DateTime(2026, 10, 22, 9);

  test('programa hoy y los siguientes 13 días a la hora elegida', () {
    final plan = planReminders(
      now: morning,
      minutes: 20 * 60 + 30,
      pendingToday: 3,
      xpAtStakeToday: 180,
    );

    expect(plan, hasLength(reminderHorizonDays));
    expect(plan.first.at, DateTime(2026, 10, 22, 20, 30));
    expect(plan.first.id, 20261022);
    expect(
      plan.first.body,
      startsWith('Te faltan 3 misiones de hoy (180 XP en juego).'),
    );
    expect(plan[1].at, DateTime(2026, 10, 23, 20, 30));
    expect(plan[1].body, startsWith('Revisa tus misiones de hoy.'));
    expect(plan.map((r) => r.id).toSet(), hasLength(reminderHorizonDays));
  });

  test('si hoy ya cumpliste todo, no avisa hoy', () {
    final plan = planReminders(
      now: morning,
      minutes: 20 * 60,
      pendingToday: 0,
      xpAtStakeToday: 0,
    );

    expect(plan, hasLength(reminderHorizonDays - 1));
    expect(plan.first.id, 20261023);
  });

  test('si la hora de hoy ya pasó, empieza mañana', () {
    final plan = planReminders(
      now: DateTime(2026, 10, 22, 21),
      minutes: 20 * 60,
      pendingToday: 5,
      xpAtStakeToday: 300,
    );

    expect(plan.first.at, DateTime(2026, 10, 23, 20));
  });

  test('singular con una misión pendiente', () {
    final plan = planReminders(
      now: morning,
      minutes: 20 * 60,
      pendingToday: 1,
      xpAtStakeToday: 37,
    );

    expect(plan.first.body, startsWith('Te falta 1 misión de hoy (37 XP'));
  });

  test('los ids cruzan meses sin chocar', () {
    final plan = planReminders(
      now: DateTime(2026, 12, 30, 8),
      minutes: 20 * 60,
      pendingToday: 1,
      xpAtStakeToday: 10,
      days: 4,
    );

    expect(plan.map((r) => r.id), [20261230, 20261231, 20270101, 20270102]);
  });

  test('formatTime usa 12 horas con a. m. y p. m.', () {
    expect(formatTime(20, 0), '8:00 p. m.');
    expect(formatTime(0, 30), '12:30 a. m.');
    expect(formatTime(12, 5), '12:05 p. m.');
    expect(formatTime(7, 45), '7:45 a. m.');
  });

  test('la configuración expone hora y minuto', () {
    const settings = ReminderSettings(
      enabled: true,
      minutes: 21 * 60 + 15,
      asked: true,
    );

    expect(settings.hour, 21);
    expect(settings.minute, 15);
    expect(settings.timeLabel, '9:15 p. m.');
  });
}
