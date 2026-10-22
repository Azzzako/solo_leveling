import '../../../core/utils/dates.dart';

enum GoalReward {
  small('Chica', 250),
  medium('Mediana', 500),
  large('Grande', 1000),
  epic('Épica', 2000);

  const GoalReward(this.label, this.xp);

  final String label;
  final int xp;
}

bool isOverdue(DateTime deadline, DateTime today) =>
    daysBetween(today, deadline) < 0;

String deadlineLabel(DateTime deadline, DateTime today) {
  final days = daysBetween(today, deadline);
  return switch (days) {
    0 => 'Vence hoy',
    1 => 'Vence mañana',
    -1 => 'Venció ayer',
    > 1 => 'Vence en $days días',
    _ => 'Venció hace ${-days} días',
  };
}
