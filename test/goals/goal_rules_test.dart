import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling/src/features/goals/domain/goal_rules.dart';

void main() {
  final today = DateTime(2026, 10, 22, 15);

  test('deadlineLabel describe cuánto falta o cuánto pasó', () {
    expect(deadlineLabel(DateTime(2026, 10, 22), today), 'Vence hoy');
    expect(deadlineLabel(DateTime(2026, 10, 23), today), 'Vence mañana');
    expect(deadlineLabel(DateTime(2026, 10, 30), today), 'Vence en 8 días');
    expect(deadlineLabel(DateTime(2026, 10, 21), today), 'Venció ayer');
    expect(deadlineLabel(DateTime(2026, 10, 12), today), 'Venció hace 10 días');
  });

  test('isOverdue solo a partir del día siguiente', () {
    expect(isOverdue(DateTime(2026, 10, 22), today), isFalse);
    expect(isOverdue(DateTime(2026, 10, 21), today), isTrue);
  });

  test('las recompensas van de menor a mayor', () {
    final xp = GoalReward.values.map((r) => r.xp).toList();
    expect(xp, [...xp]..sort());
    expect(GoalReward.medium.xp, 500);
  });
}
