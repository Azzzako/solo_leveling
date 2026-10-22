import 'mission_difficulty.dart';

class SubtaskSpec {
  const SubtaskSpec({
    required this.title,
    required this.base,
    this.perLevel = 0,
    this.maxLevel = 30,
  });

  final String title;
  final int base;
  final int perLevel;
  final int maxLevel;

  int targetAt(int level) =>
      base + perLevel * ((level < 1 ? 1 : level).clamp(1, maxLevel) - 1);
}

class FixedMissionSpec {
  const FixedMissionSpec({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.xpReward,
    this.target = 1,
    this.subtasks = const <SubtaskSpec>[],
  });

  final String title;
  final String description;
  final MissionDifficulty difficulty;
  final int xpReward;
  final int target;
  final List<SubtaskSpec> subtasks;

  bool get hasSubtasks => subtasks.isNotEmpty;
}

const exerciseSubtasks = <SubtaskSpec>[
  SubtaskSpec(title: 'Flexiones', base: 50, perLevel: 2),
  SubtaskSpec(title: 'Abdominales', base: 60, perLevel: 2),
  SubtaskSpec(title: 'Sentadillas', base: 50, perLevel: 2),
  SubtaskSpec(title: 'Dominadas', base: 10, perLevel: 1),
];

const mealSubtasks = <SubtaskSpec>[
  SubtaskSpec(title: 'Desayuno', base: 1),
  SubtaskSpec(title: 'Comida', base: 1),
  SubtaskSpec(title: 'Cena', base: 1),
];

const fixedDailyStack = <FixedMissionSpec>[
  FixedMissionSpec(
    title: 'Hacer ejercicio',
    description:
        'Completa las cuatro series. La misión cierra al terminar todas.',
    difficulty: MissionDifficulty.medium,
    xpReward: 100,
    subtasks: exerciseSubtasks,
  ),
  FixedMissionSpec(
    title: 'Comer sano',
    description: 'Las tres comidas del día. Cierra al completar cada una.',
    difficulty: MissionDifficulty.medium,
    xpReward: 80,
    subtasks: mealSubtasks,
  ),
  FixedMissionSpec(
    title: 'Camina 10 mil pasos',
    description: 'Camina lo suficiente para desbloquear el siguiente rango.',
    difficulty: MissionDifficulty.easy,
    xpReward: 90,
    target: 10000,
  ),
  FixedMissionSpec(
    title: 'Toma 2 litros de agua',
    description: 'Mantén la hidratación durante todo el día.',
    difficulty: MissionDifficulty.trivial,
    xpReward: 40,
    target: 2,
  ),
  FixedMissionSpec(
    title: 'Lee 10 páginas',
    description: 'Libro físico o digital.',
    difficulty: MissionDifficulty.easy,
    xpReward: 50,
    target: 10,
  ),
  FixedMissionSpec(
    title: 'Medita 10 minutos',
    description: 'Silencio mental para recuperar concentración.',
    difficulty: MissionDifficulty.easy,
    xpReward: 45,
    target: 10,
  ),
  FixedMissionSpec(
    title: 'Juega con los gatos',
    description: 'Tiempo de juego y mimos, sin pantallas.',
    difficulty: MissionDifficulty.trivial,
    xpReward: 35,
  ),
];

int get fixedDailyXpTotal =>
    fixedDailyStack.fold(0, (sum, spec) => sum + spec.xpReward);

const fixedDailyMissionCount = 7;
