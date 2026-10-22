import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling/src/features/missions/domain/daily_stack.dart';
import 'package:solo_leveling/src/features/missions/domain/mission_difficulty.dart';

void main() {
  group('fixedDailyStack', () {
    test('son exactamente 7 misiones y en orden fijo', () {
      expect(fixedDailyStack, hasLength(fixedDailyMissionCount));
      expect(fixedDailyStack.map((s) => s.title), [
        'Hacer ejercicio',
        'Comer sano',
        'Camina 10 mil pasos',
        'Toma 2 litros de agua',
        'Lee 10 páginas',
        'Medita 10 minutos',
        'Juega con los gatos',
      ]);
    });

    test('ejercicio y comida tienen subtareas, el resto no', () {
      final withSubtasks = fixedDailyStack.where((s) => s.hasSubtasks);
      expect(withSubtasks.map((s) => s.title), [
        'Hacer ejercicio',
        'Comer sano',
      ]);
      expect(fixedDailyStack.first.subtasks, hasLength(4));
      expect(fixedDailyStack[1].subtasks, hasLength(3));
      expect(mealSubtasks.map((s) => s.title), ['Desayuno', 'Comida', 'Cena']);
    });

    test('el stack paga 440 XP al día', () {
      expect(fixedDailyXpTotal, 440);
      expect(fixedDailyStack.first.xpReward, 100);
      expect(fixedDailyStack[1].xpReward, 80);
      expect(fixedDailyStack[2].xpReward, 90);
    });

    test('las comidas valen 1 cada una y no escalan con el nivel', () {
      expect(mealSubtasks.every((s) => s.targetAt(1) == 1), isTrue);
      expect(mealSubtasks.every((s) => s.targetAt(40) == 1), isTrue);
    });

    test('cada misión tiene título, descripción y XP positivo', () {
      for (final spec in fixedDailyStack) {
        expect(spec.title, isNotEmpty);
        expect(spec.description, isNotEmpty);
        expect(spec.xpReward, greaterThan(0));
      }
    });
  });

  group('SubtaskSpec.targetAt', () {
    test('en el nivel 1 vale la base', () {
      expect(exerciseSubtasks.first.targetAt(1), 50);
    });

    test('sube de forma lineal con el nivel', () {
      expect(exerciseSubtasks.first.targetAt(10), 68);
      expect(exerciseSubtasks[3].targetAt(10), 19);
      expect(exerciseSubtasks.first.targetAt(20), 88);
    });

    test('se congela en maxLevel', () {
      expect(exerciseSubtasks.first.targetAt(30), 108);
      expect(exerciseSubtasks.first.targetAt(99), 108);
    });

    test('niveles inválidos no restan reps', () {
      expect(exerciseSubtasks.first.targetAt(0), 50);
      expect(exerciseSubtasks.first.targetAt(-5), 50);
    });
  });

  group('dificultades', () {
    test('el stack usa dificultades con rango y color definidos', () {
      for (final spec in fixedDailyStack) {
        expect(spec.difficulty.rank, isNotEmpty);
        expect(MissionDifficulty.values, contains(spec.difficulty));
      }
      expect(MissionDifficulty.boss.baseXp, 250);
    });
  });
}
