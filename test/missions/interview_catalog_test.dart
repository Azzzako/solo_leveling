import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling/src/features/missions/domain/interview_catalog.dart';

void main() {
  group('catálogo', () {
    test('4 metas con 7 preguntas cada una y una de ajuste', () {
      expect(DailyGoal.values, hasLength(4));
      expect(interviews, hasLength(4));
      for (final interview in interviews) {
        expect(
          interview.questions,
          hasLength(7),
          reason: '${interview.goal.name} debe tener 7 preguntas',
        );
        expect(
          interview.questions.where((q) => q.isModifier),
          hasLength(1),
          reason: '${interview.goal.name} necesita una pregunta de ajuste',
        );
        for (final question in interview.questions) {
          expect(question.options.length, greaterThanOrEqualTo(2));
          for (final option in question.options) {
            expect(
              option.draft != null || option.scalePrevious != null,
              isTrue,
              reason: '${interview.goal.name}/${question.id}/${option.id}',
            );
          }
        }
      }
    });

    test('los ids de pregunta son únicos dentro de cada meta', () {
      for (final interview in interviews) {
        final ids = interview.questions.map((q) => q.id).toSet();
        expect(ids.length, interview.questions.length);
      }
    });

    test('DailyGoal.fromId lee el id guardado', () {
      for (final goal in DailyGoal.values) {
        expect(DailyGoal.fromId(goal.name), goal);
      }
    });
  });

  group('buildStack', () {
    test('sin respuestas usa la primera opción de cada pregunta', () {
      final stack = buildStack(DailyGoal.fisico, const {});

      expect(stack, hasLength(7));
      expect(stack.first.title, 'Hacer ejercicio');
      expect(stack.last.title, 'Bebe 2 litros de agua');
    });

    test('respeta las respuestas elegidas', () {
      final stack = buildStack(DailyGoal.fisico, const {
        'training': 'cardio',
        'steps': '15k',
        'hobby': 'pets',
      });

      expect(
        stack.map((d) => d.title),
        containsAll(<String>[
          'Hacer cardio',
          'Camina 15000 pasos',
          'Juega con las mascotas',
        ]),
      );
    });

    test('nunca devuelve títulos repetidos en ninguna combinación', () {
      for (final goal in DailyGoal.values) {
        for (final answers in _combinations(goal)) {
          final titles = buildStack(goal, answers).map((d) => d.title).toList();
          expect(titles, hasLength(7), reason: '$goal $answers');
          expect(titles.toSet().length, 7, reason: '$goal $answers: $titles');
        }
      }
    });

    test('el XP diario es idéntico en todas las metas y combinaciones', () {
      for (final goal in DailyGoal.values) {
        for (final answers in _combinations(goal)) {
          final total = buildStack(
            goal,
            answers,
          ).fold<int>(0, (sum, draft) => sum + draft.xpReward);
          expect(total, dailyStackXp, reason: '${goal.name} $answers');
        }
      }
    });

    test('toda misión paga al menos 20 XP y tiene textos', () {
      for (final goal in DailyGoal.values) {
        for (final draft in buildStack(goal, const {})) {
          expect(draft.xpReward, greaterThanOrEqualTo(20));
          expect(draft.title.trim(), isNotEmpty);
          expect(draft.description.trim(), isNotEmpty);
          expect(draft.target, greaterThan(0));
        }
      }
    });

    test('la pregunta de intensidad ajusta la misión anterior', () {
      final soft = buildStack(DailyGoal.fisico, const {
        'training': 'strength',
        'intensity': 'soft',
      });
      final hard = buildStack(DailyGoal.fisico, const {
        'training': 'strength',
        'intensity': 'hard',
      });

      expect(
        soft.first.subtasks.first.base,
        lessThan(hard.first.subtasks.first.base),
      );
      expect(soft.first.title, hard.first.title);
      expect(soft, hasLength(7));
    });

    test('el ajuste de foco cambia los minutos del bloque', () {
      final short = buildStack(DailyGoal.productividad, const {
        'anchor': 'code',
        'blocks': 'short',
      });
      final long = buildStack(DailyGoal.productividad, const {
        'anchor': 'code',
        'blocks': 'long',
      });

      expect(short.first.target, 25);
      expect(long.first.target, 60);
    });

    test('ignora respuestas que no existen', () {
      expect(
        buildStack(DailyGoal.enfoque, const {'inventada': 'x'}),
        hasLength(7),
      );
    });

    test('las series de fuerza escalan con el nivel', () {
      final exercise = buildStack(DailyGoal.fisico, const {
        'training': 'strength',
        'intensity': 'normal',
      }).first;

      expect(exercise.subtasks, hasLength(4));
      expect(exercise.subtasks.first.targetAt(1), 50);
      expect(exercise.subtasks.first.targetAt(10), 68);
      expect(exercise.subtasks.first.targetAt(30), 108);
      expect(exercise.subtasks.last.targetAt(1), 10);
      expect(exercise.subtasks.last.targetAt(10), 19);
    });

    test('las misiones sin series no escalan con el nivel', () {
      final water = buildStack(DailyGoal.fisico, const {}).last;

      expect(water.subtasks, isEmpty);
      expect(water.target, 2);
    });

    test('el stack por defecto es el de físico', () {
      final stack = defaultStack();

      expect(stack, hasLength(7));
      expect(stack.map((d) => d.title), contains('Hacer ejercicio'));
      expect(stack.map((d) => d.title), contains('Comer sano'));
    });
  });
}

List<Map<String, String>> _combinations(DailyGoal goal) {
  var combinations = <Map<String, String>>[{}];
  for (final question in interviewFor(goal).questions) {
    final next = <Map<String, String>>[];
    for (final base in combinations) {
      for (final option in question.options) {
        next.add({...base, question.id: option.id});
      }
    }
    combinations = next;
  }
  return combinations;
}
