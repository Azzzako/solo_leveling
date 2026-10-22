import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling/src/features/missions/domain/interview_catalog.dart';
import 'package:solo_leveling/src/features/missions/domain/mission_difficulty.dart';

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
      expect(stack.first.title, 'Haz ejercicio');
      expect(stack.last.title, 'Toma 2 litros de agua');
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
          'Haz cardio',
          'Camina 15,000 pasos',
          'Juega con tus mascotas',
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

      expect(soft.first.subtasks.map((s) => s.base), everyElement(30));
      expect(hard.first.subtasks.map((s) => s.base), everyElement(30));
      expect(soft.first.subtasks.map((s) => s.perLevel), everyElement(1));
      expect(hard.first.subtasks.map((s) => s.perLevel), everyElement(3));
      expect(soft.first.title, hard.first.title);
      expect(soft, hasLength(7));
    });

    test('la intensidad sigue ajustando los minutos de cardio', () {
      final soft = buildStack(DailyGoal.fisico, const {
        'training': 'cardio',
        'intensity': 'soft',
      });
      final hard = buildStack(DailyGoal.fisico, const {
        'training': 'cardio',
        'intensity': 'hard',
      });

      expect(
        soft.first.subtasks[1].base,
        lessThan(hard.first.subtasks[1].base),
      );
    });

    test('todas las series de fuerza arrancan en 30 en cualquier meta', () {
      for (final goal in DailyGoal.values) {
        for (final answers in _combinations(goal)) {
          for (final draft in buildStack(goal, answers)) {
            if (draft.kind != 'fuerza') continue;
            expect(draft.subtasks, hasLength(4));
            expect(
              draft.subtasks.map((s) => s.targetAt(1)),
              everyElement(30),
              reason: '$goal $answers',
            );
            expect(
              draft.subtasks.map((s) => s.perLevel),
              everyElement(greaterThanOrEqualTo(1)),
            );
          }
        }
      }
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
      expect(exercise.subtasks.map((s) => s.title), [
        'Lagartijas',
        'Abdominales',
        'Sentadillas',
        'Dominadas',
      ]);
      for (final series in exercise.subtasks) {
        expect(series.targetAt(1), 30);
        expect(series.targetAt(2), 32);
        expect(series.targetAt(10), 48);
        expect(series.targetAt(30), 88);
        expect(series.targetAt(99), 88);
      }
    });

    test('las misiones sin series no escalan con el nivel', () {
      final water = buildStack(DailyGoal.fisico, const {}).last;

      expect(water.subtasks, isEmpty);
      expect(water.target, 2);
    });

    test('nunca repite el mismo tipo de misión', () {
      for (final goal in DailyGoal.values) {
        for (final answers in _combinations(goal)) {
          final kinds = buildStack(goal, answers).map((d) => d.kind).toList();
          expect(kinds.toSet().length, 7, reason: '$goal $answers: $kinds');
        }
      }
    });

    test('ningún texto deja el marcador {n} sin resolver', () {
      for (final goal in DailyGoal.values) {
        for (final answers in _combinations(goal)) {
          for (final draft in buildStack(goal, answers)) {
            expect(draft.title, isNot(contains('{n}')));
            expect(draft.description, isNot(contains('{n}')));
          }
        }
      }
    });

    test('el título refleja el ajuste de minutos', () {
      final focus = buildStack(DailyGoal.enfoque, const {
        'technique': 'meditate',
        'minutes': 'twenty',
      });
      final work = buildStack(DailyGoal.productividad, const {
        'anchor': 'code',
        'blocks': 'long',
      });
      final people = buildStack(DailyGoal.relaciones, const {
        'who': 'partner',
        'quality': 'thirty',
      });

      expect(focus.first.title, 'Medita 20 minutos');
      expect(focus.first.target, 20);
      expect(work.first.title, 'Programa 60 minutos');
      expect(people.first.description, startsWith('30 minutos con tu pareja'));
    });

    test('elegir agua como energía no duplica la hidratación', () {
      final stack = buildStack(DailyGoal.productividad, const {
        'energy': 'water',
      });

      expect(stack.where((d) => d.kind == 'agua'), hasLength(1));
      expect(stack, hasLength(7));
    });

    test('sin palabras de España en los textos', () {
      final banned = RegExp(
        r'móvil|tentempié|auricular|quedar|queda con|montar|vale|ordenador',
        caseSensitive: false,
      );
      for (final interview in interviews) {
        for (final question in interview.questions) {
          expect(question.prompt, isNot(matches(banned)));
          expect(question.hint, isNot(matches(banned)));
          for (final option in question.options) {
            expect(option.label, isNot(matches(banned)));
            final draft = option.draft;
            if (draft == null) continue;
            expect(draft.title, isNot(matches(banned)));
            expect(draft.description, isNot(matches(banned)));
          }
        }
      }
    });

    test('el stack por defecto es el de físico', () {
      final stack = defaultStack();

      expect(stack, hasLength(7));
      expect(stack.map((d) => d.title), contains('Haz ejercicio'));
      expect(stack.map((d) => d.title), contains('Come sano'));
    });
  });

  group('normalizeXp', () {
    MissionDraft draft(int xp) => MissionDraft(
      kind: 'k$xp',
      title: 't$xp',
      description: 'd',
      difficulty: MissionDifficulty.easy,
      xpReward: xp,
    );

    test('reparte exactamente el total aunque los pesos sean raros', () {
      final cases = <List<int>>[
        [1, 1000, 1000],
        [33, 33, 33, 1],
        [100, 80, 90, 60, 35, 50, 40],
        [7, 7, 7, 7, 7, 7, 7],
      ];
      for (final weights in cases) {
        final shares = normalizeXp([
          for (final w in weights) draft(w),
        ], dailyStackXp).map((d) => d.xpReward).toList();
        expect(
          shares.fold<int>(0, (a, b) => a + b),
          dailyStackXp,
          reason: '$weights',
        );
        expect(shares.every((x) => x >= 20), isTrue, reason: '$shares');
      }
    });

    test('respeta la proporción de los pesos', () {
      final shares = normalizeXp([
        draft(100),
        draft(50),
      ], 300).map((d) => d.xpReward).toList();
      expect(shares, [200, 100]);
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
