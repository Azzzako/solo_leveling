import 'mission_difficulty.dart';

enum DailyGoal {
  fisico('físico'),
  productividad('productividad'),
  enfoque('enfoque'),
  relaciones('relaciones');

  const DailyGoal(this.label);

  final String label;

  static DailyGoal fromId(String id) =>
      DailyGoal.values.firstWhere((goal) => goal.name == id);
}

class SubtaskDraft {
  const SubtaskDraft({
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

class MissionDraft {
  const MissionDraft({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.xpReward,
    this.target = 1,
    this.subtasks = const <SubtaskDraft>[],
  });

  final String title;
  final String description;
  final MissionDifficulty difficulty;
  final int xpReward;
  final int target;
  final List<SubtaskDraft> subtasks;

  bool get hasSubtasks => subtasks.isNotEmpty;

  int get subtaskCount => subtasks.length;

  MissionDraft scaleBy(double factor) => MissionDraft(
    title: title,
    description: description,
    difficulty: difficulty,
    xpReward: xpReward,
    target: (target * factor).round().clamp(1, 1 << 20),
    subtasks: [
      for (final subtask in subtasks)
        SubtaskDraft(
          title: subtask.title,
          base: (subtask.base * factor).round().clamp(1, 1 << 20),
          perLevel: subtask.perLevel,
          maxLevel: subtask.maxLevel,
        ),
    ],
  );

  MissionDraft withXp(int xp) => MissionDraft(
    title: title,
    description: description,
    difficulty: difficulty,
    xpReward: xp,
    target: target,
    subtasks: subtasks,
  );
}

class InterviewOption {
  const InterviewOption({
    required this.id,
    required this.label,
    this.draft,
    this.scalePrevious,
  });

  final String id;
  final String label;
  final MissionDraft? draft;
  final double? scalePrevious;
}

class InterviewQuestion {
  const InterviewQuestion({
    required this.id,
    required this.prompt,
    required this.hint,
    required this.options,
  });

  final String id;
  final String prompt;
  final String hint;
  final List<InterviewOption> options;

  bool get isModifier =>
      options.every((option) => option.scalePrevious != null);

  InterviewOption optionById(String? id) {
    for (final option in options) {
      if (option.id == id) return option;
    }
    return options.first;
  }
}

class GoalInterview {
  const GoalInterview({required this.goal, required this.questions});

  final DailyGoal goal;
  final List<InterviewQuestion> questions;

  int get questionCount => questions.length;
}

const _pets = 'Mascotas';
const _gym = 'Entrenar en el gimnasio';
const _craft = 'Hobbies manuales';
const _friends = 'Quedar con amistades';
const _family = 'Salir con la familia';
const _volunteer = 'Voluntariado o comunidad';

MissionDraft _strength({int base = 50}) => MissionDraft(
  title: 'Hacer ejercicio',
  description:
      'Completa las cuatro series. La misión cierra al terminar todas.',
  difficulty: MissionDifficulty.medium,
  xpReward: 100,
  subtasks: [
    SubtaskDraft(title: 'Flexiones', base: base, perLevel: 2),
    SubtaskDraft(title: 'Abdominales', base: base + 10, perLevel: 2),
    SubtaskDraft(title: 'Sentadillas', base: base, perLevel: 2),
    SubtaskDraft(
      title: 'Dominadas',
      base: (base / 5).round().clamp(1, 60),
      perLevel: 1,
    ),
  ],
);

MissionDraft _cardio({int minutes = 20}) => MissionDraft(
  title: 'Hacer cardio',
  description: 'Tres bloques. La misión cierra al completar cada uno.',
  difficulty: MissionDifficulty.medium,
  xpReward: 100,
  subtasks: [
    SubtaskDraft(title: 'Calentamiento', base: (minutes / 4).round()),
    SubtaskDraft(title: 'Cardio principal', base: minutes),
    SubtaskDraft(title: 'Enfriamiento', base: (minutes / 4).round()),
  ],
);

MissionDraft _stretch({int minutes = 12}) => MissionDraft(
  title: 'Estiramientos',
  description: 'Tres bloques de movilidad para el cuerpo.',
  difficulty: MissionDifficulty.trivial,
  xpReward: 60,
  subtasks: [
    SubtaskDraft(title: 'Cuello y hombros', base: (minutes / 3).round()),
    SubtaskDraft(title: 'Espalda y cadera', base: (minutes / 3).round()),
    SubtaskDraft(title: 'Piernas', base: (minutes / 3).round()),
  ],
);

MissionDraft _steps({required int steps}) => MissionDraft(
  title: 'Camina $steps pasos',
  description: 'Camina lo suficiente para desbloquear el siguiente rango.',
  difficulty: MissionDifficulty.easy,
  xpReward: 90,
  target: steps,
);

final hydrationDraft = MissionDraft(
  title: 'Bebe 2 litros de agua',
  description: 'Mantén la hidratación durante todo el día.',
  difficulty: MissionDifficulty.trivial,
  xpReward: 40,
  target: 2,
);

MissionDraft _sleep({int hours = 7}) => MissionDraft(
  title: 'Duerme $hours horas',
  description: 'El descanso también entrena.',
  difficulty: MissionDifficulty.medium,
  xpReward: 60,
  target: hours,
);

MissionDraft _reading({int pages = 10}) => MissionDraft(
  title: 'Lee $pages páginas',
  description: 'Libro físico o digital.',
  difficulty: MissionDifficulty.easy,
  xpReward: 50,
  target: pages,
);

MissionDraft _meditation({int minutes = 10}) => MissionDraft(
  title: 'Medita $minutes minutos',
  description: 'Silencio mental para recuperar concentración.',
  difficulty: MissionDifficulty.easy,
  xpReward: 45,
  target: minutes,
);

MissionDraft _meals({required bool snack}) => MissionDraft(
  title: 'Comer sano',
  description: snack
      ? 'Las tres comidas y el tentempié. Cierra al completar cada una.'
      : 'Las tres comidas del día. Cierra al completar cada una.',
  difficulty: MissionDifficulty.medium,
  xpReward: 80,
  subtasks: [
    SubtaskDraft(title: 'Desayuno', base: 1),
    SubtaskDraft(title: 'Comida', base: 1),
    SubtaskDraft(title: 'Cena', base: 1),
    if (snack) SubtaskDraft(title: 'Tentempié', base: 1),
  ],
);

MissionDraft _journal({int lines = 5}) => MissionDraft(
  title: 'Escribe el diario',
  description: 'Anota lo que importa del día antes de dormir.',
  difficulty: MissionDifficulty.trivial,
  xpReward: 45,
  target: lines,
);

MissionDraft _focus({String task = 'tu tarea clave'}) => MissionDraft(
  title: 'Trabaja en $task',
  description: 'Móvil en otra habitación y notificaciones cerradas.',
  difficulty: MissionDifficulty.hard,
  xpReward: 100,
  target: 25,
);

MissionDraft _plan({int minutes = 10}) => MissionDraft(
  title: 'Prepara el día',
  description: 'Escribe las tres tareas que quieres cerrar mañana.',
  difficulty: MissionDifficulty.easy,
  xpReward: 70,
  target: minutes,
);

MissionDraft _closeDay() => MissionDraft(
  title: 'Cierra el día',
  description: 'Termina lo pendiente y deja el plan de mañana escrito.',
  difficulty: MissionDifficulty.medium,
  xpReward: 80,
);

MissionDraft _phoneOff({int minutes = 30}) => MissionDraft(
  title: 'Primera hora sin pantallas',
  description: 'El móvil sin tocar durante la primera franja del día.',
  difficulty: MissionDifficulty.medium,
  xpReward: 70,
  target: minutes,
);

MissionDraft _language({int minutes = 15}) => MissionDraft(
  title: 'Practica el idioma',
  description: 'Estudio activo, no solo lectura pasiva.',
  difficulty: MissionDifficulty.medium,
  xpReward: 80,
  target: minutes,
);

MissionDraft _breathing({int minutes = 5}) => MissionDraft(
  title: 'Respira y calmlyrate',
  description: 'Respiración lenta antes de empezar a trabajar.',
  difficulty: MissionDifficulty.trivial,
  xpReward: 45,
  target: minutes,
);

MissionDraft _gratitude() => MissionDraft(
  title: 'Tres cosas buenas',
  description: 'Anota tres cosas del día por las que dar las gracias.',
  difficulty: MissionDifficulty.trivial,
  xpReward: 50,
);

MissionDraft _qualityTime({required int minutes, required String who}) =>
    MissionDraft(
      title: 'Tiempo de calidad',
      description: '$minutes minutos con $who, sin pantallas de por medio.',
      difficulty: MissionDifficulty.medium,
      xpReward: 90,
      target: minutes,
    );

MissionDraft _contact({required String who}) => MissionDraft(
  title: 'Contacta con $who',
  description: 'Una llamada o un mensaje que empiece algo, no solo un "hola".',
  difficulty: MissionDifficulty.easy,
  xpReward: 80,
);

MissionDraft _hobby({required String hobby, int minutes = 30}) => MissionDraft(
  title: hobby,
  description: '$minutes minutos de algo que te guste de verdad.',
  difficulty: MissionDifficulty.trivial,
  xpReward: 35,
  target: minutes,
);

final interviews = <GoalInterview>[
  GoalInterview(
    goal: DailyGoal.fisico,
    questions: [
      InterviewQuestion(
        id: 'training',
        prompt: '¿Qué entrenas?',
        hint: 'El trabajo principal de tu día.',
        options: [
          InterviewOption(id: 'strength', label: 'Fuerza', draft: _strength()),
          InterviewOption(id: 'cardio', label: 'Cardio', draft: _cardio()),
          InterviewOption(
            id: 'mobility',
            label: 'Movilidad',
            draft: _stretch(),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'intensity',
        prompt: '¿Con qué intensidad?',
        hint: 'Las reps y los minutos escalan con tu nivel.',
        options: [
          InterviewOption(id: 'normal', label: 'Media', scalePrevious: 1),
          InterviewOption(id: 'soft', label: 'Suave', scalePrevious: 0.6),
          InterviewOption(id: 'hard', label: 'Exigente', scalePrevious: 1.5),
        ],
      ),
      InterviewQuestion(
        id: 'meals',
        prompt: '¿Cómo son tus comidas?',
        hint: 'La misión se cierra cuando cumples todas.',
        options: [
          InterviewOption(
            id: 'three',
            label: 'Tres comidas',
            draft: _meals(snack: false),
          ),
          InterviewOption(
            id: 'snack',
            label: 'Tres y tentempié',
            draft: _meals(snack: true),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'steps',
        prompt: '¿Cuántos pasos al día?',
        hint: 'Elige un número que puedas cumplir casi siempre.',
        options: [
          InterviewOption(id: '5k', label: '5 000', draft: _steps(steps: 5000)),
          InterviewOption(
            id: '10k',
            label: '10 000',
            draft: _steps(steps: 10000),
          ),
          InterviewOption(
            id: '15k',
            label: '15 000',
            draft: _steps(steps: 15000),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'recovery',
        prompt: '¿Qué te falta para recuperarte?',
        hint: 'El descanso también entrena.',
        options: [
          InterviewOption(id: 'sleep', label: 'Dormir bien', draft: _sleep()),
          InterviewOption(
            id: 'read',
            label: 'Desconectar leyendo',
            draft: _reading(),
          ),
          InterviewOption(
            id: 'calm',
            label: 'Calma mental',
            draft: _meditation(),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'hobby',
        prompt: '¿Qué haces que te gusta?',
        hint: 'Una misión para que el día no sea solo trabajo.',
        options: [
          InterviewOption(
            id: 'pets',
            label: _pets,
            draft: _hobby(hobby: 'Juega con las mascotas'),
          ),
          InterviewOption(
            id: 'gym',
            label: _gym,
            draft: _hobby(hobby: 'Ve al gimnasio'),
          ),
          InterviewOption(
            id: 'craft',
            label: _craft,
            draft: _hobby(hobby: 'Trabaja en tus hobbies'),
          ),
          InterviewOption(
            id: 'friends',
            label: _friends,
            draft: _hobby(hobby: 'Queda con amistades'),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'extra',
        prompt: '¿Qué te suma más?',
        hint: 'La última misión del día.',
        options: [
          InterviewOption(id: 'read', label: 'Leer', draft: _reading()),
          InterviewOption(
            id: 'stretch',
            label: 'Estiramientos',
            draft: _stretch(minutes: 10),
          ),
        ],
      ),
    ],
  ),
  GoalInterview(
    goal: DailyGoal.productividad,
    questions: [
      InterviewQuestion(
        id: 'anchor',
        prompt: '¿Cuál es tu tarea ancla?',
        hint: 'Lo que más pesa en tu trabajo.',
        options: [
          InterviewOption(
            id: 'write',
            label: 'Escribir',
            draft: _focus(task: 'escribir'),
          ),
          InterviewOption(
            id: 'code',
            label: 'Programar',
            draft: _focus(task: 'programar'),
          ),
          InterviewOption(
            id: 'study',
            label: 'Estudiar',
            draft: _focus(task: 'estudiar'),
          ),
          InterviewOption(
            id: 'organize',
            label: 'Ordenar tareas',
            draft: _focus(task: 'ordenar tus tareas'),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'blocks',
        prompt: '¿Cuánto dura cada bloque?',
        hint: 'Cuanto más largo, más cuesta mantenerlo.',
        options: [
          InterviewOption(id: 'short', label: '25 minutos', scalePrevious: 1),
          InterviewOption(
            id: 'medium',
            label: '45 minutos',
            scalePrevious: 1.8,
          ),
          InterviewOption(id: 'long', label: '60 minutos', scalePrevious: 2.4),
        ],
      ),
      InterviewQuestion(
        id: 'distraction',
        prompt: '¿Qué te rompe el foco?',
        hint: 'Atacamos lo que más te distrae.',
        options: [
          InterviewOption(
            id: 'phone',
            label: 'El móvil',
            draft: _phoneOff(minutes: 30),
          ),
          InterviewOption(
            id: 'notifications',
            label: 'Notificaciones',
            draft: _phoneOff(minutes: 45),
          ),
          InterviewOption(
            id: 'thoughts',
            label: 'La cabeza',
            draft: _meditation(),
          ),
          InterviewOption(id: 'tired', label: 'El cansancio', draft: _sleep()),
        ],
      ),
      InterviewQuestion(
        id: 'closing',
        prompt: '¿Cómo sueles cerrar el día?',
        hint: 'Un día bien cerrado se nota al siguiente.',
        options: [
          InterviewOption(
            id: 'close_tasks',
            label: 'Cierro las tareas',
            draft: _closeDay(),
          ),
          InterviewOption(
            id: 'plan_next',
            label: 'Escribo el plan de mañana',
            draft: _plan(),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'energy',
        prompt: '¿Qué te da energía?',
        hint: 'Sin energía no hay foco.',
        options: [
          InterviewOption(
            id: 'walk',
            label: 'Caminar',
            draft: _steps(steps: 8000),
          ),
          InterviewOption(
            id: 'food',
            label: 'Comer bien',
            draft: _meals(snack: false),
          ),
          InterviewOption(
            id: 'water',
            label: 'Beber agua',
            draft: _hydration(),
          ),
          InterviewOption(id: 'sleep', label: 'Dormir', draft: _sleep()),
        ],
      ),
      InterviewQuestion(
        id: 'hobby',
        prompt: '¿Qué haces que te gusta?',
        hint: 'Una misión para que el día no sea solo trabajo.',
        options: [
          InterviewOption(
            id: 'craft',
            label: _craft,
            draft: _hobby(hobby: 'Trabaja en tus hobbies'),
          ),
          InterviewOption(
            id: 'pets',
            label: _pets,
            draft: _hobby(hobby: 'Juega con las mascotas'),
          ),
          InterviewOption(
            id: 'friends',
            label: _friends,
            draft: _hobby(hobby: 'Queda con amistades'),
          ),
          InterviewOption(
            id: 'read',
            label: 'Leer',
            draft: _hobby(hobby: 'Lee por placer', minutes: 20),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'extra',
        prompt: '¿Qué te suma más?',
        hint: 'La última misión del día.',
        options: [
          InterviewOption(id: 'read', label: 'Leer', draft: _reading()),
          InterviewOption(
            id: 'stretch',
            label: 'Estiramientos',
            draft: _stretch(minutes: 10),
          ),
        ],
      ),
    ],
  ),
  GoalInterview(
    goal: DailyGoal.enfoque,
    questions: [
      InterviewQuestion(
        id: 'technique',
        prompt: '¿Qué técnica te funciona?',
        hint: 'La principal de tu día.',
        options: [
          InterviewOption(
            id: 'meditate',
            label: 'Meditar',
            draft: _meditation(minutes: 10),
          ),
          InterviewOption(
            id: 'journal',
            label: 'Escribir el diario',
            draft: _journal(),
          ),
          InterviewOption(
            id: 'breathing',
            label: 'Respiración',
            draft: _breathing(),
          ),
          InterviewOption(
            id: 'language',
            label: 'Practicar un idioma',
            draft: _language(),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'minutes',
        prompt: '¿Cuánto le dedicas?',
        hint: 'Mejor poco y todos los días que mucho y un día sí.',
        options: [
          InterviewOption(id: 'ten', label: '10 minutos', scalePrevious: 1),
          InterviewOption(id: 'twenty', label: '20 minutos', scalePrevious: 2),
          InterviewOption(id: 'thirty', label: '30 minutos', scalePrevious: 3),
        ],
      ),
      InterviewQuestion(
        id: 'distraction',
        prompt: '¿Qué te dispersa?',
        hint: 'Vamos a por eso primero.',
        options: [
          InterviewOption(id: 'phone', label: 'El móvil', draft: _phoneOff()),
          InterviewOption(id: 'noise', label: 'El ruido', draft: _breathing()),
          InterviewOption(
            id: 'thoughts',
            label: 'La cabeza',
            draft: _journal(),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'reading',
        prompt: '¿Cuánto lees?',
        hint: 'Lectura deliberada, no scroll.',
        options: [
          InterviewOption(
            id: 'ten_pages',
            label: '10 páginas',
            draft: _reading(pages: 10),
          ),
          InterviewOption(
            id: 'twenty_pages',
            label: '20 páginas',
            draft: _reading(pages: 20),
          ),
          InterviewOption(
            id: 'thirty_pages',
            label: '30 páginas',
            draft: _reading(pages: 30),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'routine',
        prompt: '¿Tienes rutina de mañana?',
        hint: 'El primer bloque del día se decide la noche anterior.',
        options: [
          InterviewOption(id: 'yes', label: 'Sí, la tengo', draft: _plan()),
          InterviewOption(
            id: 'no',
            label: 'Quiero montarla',
            draft: _closeDay(),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'hobby',
        prompt: '¿Qué haces que te gusta?',
        hint: 'Una misión para que el día no sea solo trabajo.',
        options: [
          InterviewOption(
            id: 'pets',
            label: _pets,
            draft: _hobby(hobby: 'Juega con las mascotas'),
          ),
          InterviewOption(
            id: 'craft',
            label: _craft,
            draft: _hobby(hobby: 'Trabaja en tus hobbies'),
          ),
          InterviewOption(
            id: 'family',
            label: _family,
            draft: _hobby(hobby: 'Sal con la familia'),
          ),
          InterviewOption(
            id: 'walk',
            label: 'Caminar',
            draft: _hobby(hobby: 'Camina sin auriculares', minutes: 20),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'extra',
        prompt: '¿Qué te suma más?',
        hint: 'La última misión del día.',
        options: [
          InterviewOption(
            id: 'walk',
            label: 'Caminar',
            draft: _steps(steps: 8000),
          ),
          InterviewOption(
            id: 'stretch',
            label: 'Estiramientos',
            draft: _stretch(minutes: 10),
          ),
        ],
      ),
    ],
  ),
  GoalInterview(
    goal: DailyGoal.relaciones,
    questions: [
      InterviewQuestion(
        id: 'who',
        prompt: '¿Con quién quieres estar más?',
        hint: 'La relación que quieres cuidar.',
        options: [
          InterviewOption(
            id: 'partner',
            label: 'Pareja',
            draft: _qualityTime(minutes: 20, who: 'tu pareja'),
          ),
          InterviewOption(
            id: 'family',
            label: 'Familia',
            draft: _qualityTime(minutes: 20, who: 'tu familia'),
          ),
          InterviewOption(
            id: 'friends',
            label: 'Amistades',
            draft: _qualityTime(minutes: 20, who: 'tus amistades'),
          ),
          InterviewOption(
            id: 'community',
            label: 'Comunidad',
            draft: _qualityTime(minutes: 20, who: 'tu comunidad'),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'quality',
        prompt: '¿Cuánto tiempo de calidad?',
        hint: 'Sin pantallas, mirándose a la cara.',
        options: [
          InterviewOption(id: 'ten', label: '10 minutos', scalePrevious: 0.5),
          InterviewOption(id: 'twenty', label: '20 minutos', scalePrevious: 1),
          InterviewOption(
            id: 'thirty',
            label: '30 minutos',
            scalePrevious: 1.5,
          ),
        ],
      ),
      InterviewQuestion(
        id: 'care',
        prompt: '¿Qué necesitas para cuidar la relación?',
        hint: 'El detalle que más cuesta.',
        options: [
          InterviewOption(
            id: 'call',
            label: 'Llamar',
            draft: _contact(who: 'quien quieres'),
          ),
          InterviewOption(
            id: 'plan',
            label: 'Quedar planeado',
            draft: _qualityTime(minutes: 30, who: 'tu gente'),
          ),
          InterviewOption(
            id: 'listen',
            label: 'Escuchar sin móvil',
            draft: _qualityTime(minutes: 20, who: 'con atención'),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'gratitude',
        prompt: '¿Das las gracias?',
        hint: 'Un minuto al día cambia el ánimo de la casa.',
        options: [
          InterviewOption(
            id: 'yes',
            label: 'Sí, a diario',
            draft: _gratitude(),
          ),
          InterviewOption(
            id: 'sometimes',
            label: 'A veces',
            draft: _gratitude(),
          ),
          InterviewOption(id: 'no', label: 'Nunca', draft: _journal()),
        ],
      ),
      InterviewQuestion(
        id: 'move',
        prompt: '¿Qué haces por ti?',
        hint: 'Para estar bien con los demás.',
        options: [
          InterviewOption(
            id: 'training',
            label: 'Entrenar',
            draft: _strength(base: 40),
          ),
          InterviewOption(
            id: 'walk',
            label: 'Caminar',
            draft: _steps(steps: 8000),
          ),
          InterviewOption(id: 'sleep', label: 'Dormir', draft: _sleep()),
          InterviewOption(
            id: 'eat',
            label: 'Comer bien',
            draft: _meals(snack: false),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'hobby',
        prompt: '¿Qué haces que te gusta?',
        hint: 'Una misión para que el día no sea solo deber.',
        options: [
          InterviewOption(
            id: 'pets',
            label: _pets,
            draft: _hobby(hobby: 'Juega con las mascotas'),
          ),
          InterviewOption(
            id: 'friends',
            label: _friends,
            draft: _hobby(hobby: 'Queda con amistades'),
          ),
          InterviewOption(
            id: 'craft',
            label: _craft,
            draft: _hobby(hobby: 'Trabaja en tus hobbies'),
          ),
          InterviewOption(
            id: 'volunteer',
            label: _volunteer,
            draft: _hobby(hobby: 'Ayuda en la comunidad'),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'extra',
        prompt: '¿Qué te suma más?',
        hint: 'La última misión del día.',
        options: [
          InterviewOption(id: 'read', label: 'Leer', draft: _reading()),
          InterviewOption(
            id: 'walk',
            label: 'Caminar',
            draft: _steps(steps: 8000),
          ),
        ],
      ),
    ],
  ),
];

GoalInterview interviewFor(DailyGoal goal) =>
    interviews.firstWhere((interview) => interview.goal == goal);

const dailyStackXp = 420;

const stackFormatVersion = 1;

List<MissionDraft> buildStack(DailyGoal goal, Map<String, String> answers) {
  final interview = interviewFor(goal);
  final drafts = <MissionDraft>[];
  for (final question in interview.questions) {
    final option = question.optionById(answers[question.id]);
    final scale = option.scalePrevious;
    if (scale != null) {
      if (drafts.isNotEmpty) {
        drafts[drafts.length - 1] = drafts.last.scaleBy(scale);
      }
      continue;
    }
    final draft = option.draft;
    if (draft != null) {
      drafts.add(draft);
    }
  }
  drafts.add(hydrationDraft);
  return _disambiguate(normalizeXp(drafts, dailyStackXp));
}

List<MissionDraft> normalizeXp(List<MissionDraft> drafts, int total) {
  if (drafts.isEmpty) return drafts;
  final weights = drafts.fold<int>(0, (sum, draft) => sum + draft.xpReward);
  if (weights <= 0) return drafts;
  const minimum = 20;
  final shares = <int>[];
  var assigned = 0;
  for (var i = 0; i < drafts.length; i++) {
    final value = i == drafts.length - 1
        ? total - assigned
        : (drafts[i].xpReward * total / weights).round().clamp(
            minimum,
            1 << 20,
          );
    shares.add(value);
    assigned += value;
  }
  return [
    for (var i = 0; i < drafts.length; i++)
      drafts[i].withXp(shares[i] < minimum ? minimum : shares[i]),
  ];
}

List<MissionDraft> _disambiguate(List<MissionDraft> drafts) {
  final counts = <String, int>{};
  for (final draft in drafts) {
    counts[draft.title] = (counts[draft.title] ?? 0) + 1;
  }
  if (counts.values.every((count) => count <= 1)) return drafts;
  final seen = <String, int>{};
  return [
    for (final draft in drafts)
      if ((counts[draft.title] ?? 0) <= 1)
        draft
      else
        _renamed(
          draft,
          '${draft.title} ${(seen[draft.title] = (seen[draft.title] ?? 0) + 1)}',
        ),
  ];
}

MissionDraft _renamed(MissionDraft draft, String title) => MissionDraft(
  title: title,
  description: draft.description,
  difficulty: draft.difficulty,
  xpReward: draft.xpReward,
  target: draft.target,
  subtasks: draft.subtasks,
);

MissionDraft _hydration() => hydrationDraft;

List<MissionDraft> defaultStack() => buildStack(DailyGoal.fisico, const {});
