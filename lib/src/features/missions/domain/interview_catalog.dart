import '../../../core/utils/formatters.dart';
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
    required this.kind,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.xpReward,
    this.target = 1,
    this.subtasks = const <SubtaskDraft>[],
  });

  static const targetToken = '{n}';

  final String kind;
  final String title;
  final String description;
  final MissionDifficulty difficulty;
  final int xpReward;
  final int target;
  final List<SubtaskDraft> subtasks;

  bool get hasSubtasks => subtasks.isNotEmpty;

  int get subtaskCount => subtasks.length;

  MissionDraft _copy({
    String? title,
    String? description,
    int? xpReward,
    int? target,
    List<SubtaskDraft>? subtasks,
  }) => MissionDraft(
    kind: kind,
    title: title ?? this.title,
    description: description ?? this.description,
    difficulty: difficulty,
    xpReward: xpReward ?? this.xpReward,
    target: target ?? this.target,
    subtasks: subtasks ?? this.subtasks,
  );

  MissionDraft scaleBy(double factor) => _copy(
    target: (target * factor).round().clamp(1, 1 << 20),
    subtasks: [
      for (final subtask in subtasks)
        subtask.perLevel > 0
            ? SubtaskDraft(
                title: subtask.title,
                base: subtask.base,
                perLevel: (subtask.perLevel * factor).round().clamp(1, 1 << 10),
                maxLevel: subtask.maxLevel,
              )
            : SubtaskDraft(
                title: subtask.title,
                base: (subtask.base * factor).round().clamp(1, 1 << 20),
                maxLevel: subtask.maxLevel,
              ),
    ],
  );

  MissionDraft withXp(int xp) => _copy(xpReward: xp);

  MissionDraft resolved() {
    final amount = formatNumber(target);
    return _copy(
      title: title.replaceAll(targetToken, amount),
      description: description.replaceAll(targetToken, amount),
    );
  }
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
const _gym = 'Ir al gimnasio';
const _craft = 'Manualidades o hobbies';
const _friends = 'Salir con amigos';
const _family = 'Salir con la familia';
const _volunteer = 'Voluntariado o comunidad';

const strengthBaseReps = 30;

const strengthRepsPerLevel = 2;

MissionDraft _strength() => MissionDraft(
  kind: 'fuerza',
  title: 'Haz ejercicio',
  description:
      'Completa las cuatro series. Las repeticiones suben con tu nivel.',
  difficulty: MissionDifficulty.medium,
  xpReward: 100,
  subtasks: [
    for (final exercise in const [
      'Lagartijas',
      'Abdominales',
      'Sentadillas',
      'Dominadas',
    ])
      SubtaskDraft(
        title: exercise,
        base: strengthBaseReps,
        perLevel: strengthRepsPerLevel,
      ),
  ],
);

MissionDraft _cardio({int minutes = 20}) => MissionDraft(
  kind: 'cardio',
  title: 'Haz cardio',
  description: 'Tres bloques en minutos. Se cumple al terminar los tres.',
  difficulty: MissionDifficulty.medium,
  xpReward: 100,
  subtasks: [
    SubtaskDraft(title: 'Calentamiento', base: (minutes / 4).round()),
    SubtaskDraft(title: 'Cardio principal', base: minutes),
    SubtaskDraft(title: 'Enfriamiento', base: (minutes / 4).round()),
  ],
);

MissionDraft _stretch({int minutes = 12}) => MissionDraft(
  kind: 'estiramientos',
  title: 'Estírate',
  description: 'Tres bloques de movilidad, en minutos.',
  difficulty: MissionDifficulty.trivial,
  xpReward: 60,
  subtasks: [
    SubtaskDraft(title: 'Cuello y hombros', base: (minutes / 3).round()),
    SubtaskDraft(title: 'Espalda y cadera', base: (minutes / 3).round()),
    SubtaskDraft(title: 'Piernas', base: (minutes / 3).round()),
  ],
);

MissionDraft _steps({required int steps}) => MissionDraft(
  kind: 'pasos',
  title: 'Camina {n} pasos',
  description: 'Muévete a lo largo del día hasta llegar a la meta.',
  difficulty: MissionDifficulty.easy,
  xpReward: 90,
  target: steps,
);

const hydrationDraft = MissionDraft(
  kind: 'agua',
  title: 'Toma 2 litros de agua',
  description: 'Mantén tu hidratación durante todo el día.',
  difficulty: MissionDifficulty.trivial,
  xpReward: 40,
  target: 2,
);

MissionDraft _sleep({int hours = 7}) => MissionDraft(
  kind: 'sueño',
  title: 'Duerme {n} horas',
  description: 'El descanso también entrena.',
  difficulty: MissionDifficulty.medium,
  xpReward: 60,
  target: hours,
);

MissionDraft _reading({int pages = 10}) => MissionDraft(
  kind: 'lectura',
  title: 'Lee {n} páginas',
  description: 'Libro físico o digital, sin redes sociales de por medio.',
  difficulty: MissionDifficulty.easy,
  xpReward: 50,
  target: pages,
);

MissionDraft _meditation({int minutes = 10}) => MissionDraft(
  kind: 'meditación',
  title: 'Medita {n} minutos',
  description: 'Silencio mental para recuperar la concentración.',
  difficulty: MissionDifficulty.easy,
  xpReward: 45,
  target: minutes,
);

MissionDraft _meals({required bool snack}) => MissionDraft(
  kind: 'comidas',
  title: 'Come sano',
  description: snack
      ? 'Tus tres comidas y la colación, sanas. Se cumple al marcarlas todas.'
      : 'Tus tres comidas del día, sanas. Se cumple al marcarlas todas.',
  difficulty: MissionDifficulty.medium,
  xpReward: 80,
  subtasks: [
    SubtaskDraft(title: 'Desayuno', base: 1),
    SubtaskDraft(title: 'Comida', base: 1),
    SubtaskDraft(title: 'Cena', base: 1),
    if (snack) SubtaskDraft(title: 'Colación', base: 1),
  ],
);

MissionDraft _journal({int minutes = 10}) => MissionDraft(
  kind: 'diario',
  title: 'Escribe {n} minutos en tu diario',
  description: 'Saca de tu cabeza lo que traes antes de dormir.',
  difficulty: MissionDifficulty.trivial,
  xpReward: 45,
  target: minutes,
);

MissionDraft _focus({required String verb}) => MissionDraft(
  kind: 'foco',
  title: '$verb {n} minutos',
  description:
      'Un bloque sin distracciones: celular en otro cuarto y '
      'notificaciones apagadas.',
  difficulty: MissionDifficulty.hard,
  xpReward: 100,
  target: 25,
);

MissionDraft _plan({int minutes = 10}) => MissionDraft(
  kind: 'plan',
  title: 'Planea el día de mañana',
  description: 'Anota las tres tareas que quieres sacar mañana.',
  difficulty: MissionDifficulty.easy,
  xpReward: 70,
  target: minutes,
);

MissionDraft _closeDay() => MissionDraft(
  kind: 'cierre',
  title: 'Cierra el día',
  description: 'Termina tus pendientes y deja escrito el plan de mañana.',
  difficulty: MissionDifficulty.medium,
  xpReward: 80,
);

MissionDraft _phoneOff({int minutes = 30}) => MissionDraft(
  kind: 'celular',
  title: 'Despierta sin celular',
  description: 'Los primeros {n} minutos del día sin tocar el celular.',
  difficulty: MissionDifficulty.medium,
  xpReward: 70,
  target: minutes,
);

MissionDraft _language({int minutes = 15}) => MissionDraft(
  kind: 'idioma',
  title: 'Practica tu idioma {n} minutos',
  description: 'Estudio activo: hablar, escribir o hacer ejercicios.',
  difficulty: MissionDifficulty.medium,
  xpReward: 80,
  target: minutes,
);

MissionDraft _breathing({int minutes = 5}) => MissionDraft(
  kind: 'respiración',
  title: 'Respira con calma {n} minutos',
  description: 'Respiración lenta antes de ponerte a trabajar.',
  difficulty: MissionDifficulty.trivial,
  xpReward: 45,
  target: minutes,
);

MissionDraft _gratitude() => MissionDraft(
  kind: 'gratitud',
  title: 'Anota tres cosas buenas',
  description: 'Tres cosas del día que agradeces.',
  difficulty: MissionDifficulty.trivial,
  xpReward: 50,
);

MissionDraft _qualityTime({required int minutes, required String who}) =>
    MissionDraft(
      kind: 'tiempo_calidad',
      title: 'Tiempo de calidad',
      description: '{n} minutos con $who, sin pantallas de por medio.',
      difficulty: MissionDifficulty.medium,
      xpReward: 90,
      target: minutes,
    );

MissionDraft _contact() => MissionDraft(
  kind: 'contacto',
  title: 'Llama o escríbele a alguien que quieres',
  description: 'Un mensaje o llamada que abra plática, no solo un "hola".',
  difficulty: MissionDifficulty.easy,
  xpReward: 80,
);

MissionDraft _planMeet() => MissionDraft(
  kind: 'plan_social',
  title: 'Agenda un plan',
  description: 'Propón una salida o una reunión con alguien importante.',
  difficulty: MissionDifficulty.easy,
  xpReward: 80,
);

MissionDraft _listen({int minutes = 15}) => MissionDraft(
  kind: 'escucha',
  title: 'Escucha sin celular',
  description: 'Una plática de {n} minutos poniendo toda tu atención.',
  difficulty: MissionDifficulty.easy,
  xpReward: 80,
  target: minutes,
);

MissionDraft _hobby({
  required String kind,
  required String title,
  int minutes = 30,
}) => MissionDraft(
  kind: kind,
  title: title,
  description: '{n} minutos de algo que de verdad disfrutes.',
  difficulty: MissionDifficulty.trivial,
  xpReward: 35,
  target: minutes,
);

MissionDraft _petsHobby() =>
    _hobby(kind: 'mascotas', title: 'Juega con tus mascotas');

MissionDraft _craftHobby() =>
    _hobby(kind: 'hobby', title: 'Dedícale tiempo a tu hobby');

MissionDraft _friendsHobby() =>
    _hobby(kind: 'amigos', title: 'Sal con tus amigos');

final interviews = <GoalInterview>[
  GoalInterview(
    goal: DailyGoal.fisico,
    questions: [
      InterviewQuestion(
        id: 'training',
        prompt: '¿Qué entrenas?',
        hint: 'Tu entrenamiento principal del día.',
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
        hint:
            'Fuerza: todas las series empiezan en 30 y la intensidad marca '
            'cuántas repeticiones subes por nivel (1, 2 o 3). Cardio y '
            'movilidad: ajusta los minutos.',
        options: [
          InterviewOption(id: 'normal', label: 'Media', scalePrevious: 1),
          InterviewOption(id: 'soft', label: 'Suave', scalePrevious: 0.6),
          InterviewOption(id: 'hard', label: 'Exigente', scalePrevious: 1.5),
        ],
      ),
      InterviewQuestion(
        id: 'meals',
        prompt: '¿Cómo son tus comidas?',
        hint: 'La misión se cumple cuando marcas todas.',
        options: [
          InterviewOption(
            id: 'three',
            label: 'Tres comidas',
            draft: _meals(snack: false),
          ),
          InterviewOption(
            id: 'snack',
            label: 'Tres comidas y una colación',
            draft: _meals(snack: true),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'steps',
        prompt: '¿Cuántos pasos al día?',
        hint: 'Elige una cifra que puedas cumplir casi siempre.',
        options: [
          InterviewOption(id: '5k', label: '5,000', draft: _steps(steps: 5000)),
          InterviewOption(
            id: '10k',
            label: '10,000',
            draft: _steps(steps: 10000),
          ),
          InterviewOption(
            id: '15k',
            label: '15,000',
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
            label: 'Desconectarme leyendo',
            draft: _reading(),
          ),
          InterviewOption(
            id: 'calm',
            label: 'Calmar la mente',
            draft: _meditation(),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'hobby',
        prompt: '¿Qué te gusta hacer?',
        hint: 'Una misión para que el día no sea solo deber.',
        options: [
          InterviewOption(id: 'pets', label: _pets, draft: _petsHobby()),
          InterviewOption(
            id: 'gym',
            label: _gym,
            draft: _hobby(kind: 'gimnasio', title: 'Ve al gimnasio'),
          ),
          InterviewOption(id: 'craft', label: _craft, draft: _craftHobby()),
          InterviewOption(
            id: 'friends',
            label: _friends,
            draft: _friendsHobby(),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'extra',
        prompt: '¿Qué más te suma?',
        hint: 'La última misión del día.',
        options: [
          InterviewOption(id: 'read', label: 'Leer', draft: _reading()),
          InterviewOption(
            id: 'stretch',
            label: 'Estirarme',
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
        prompt: '¿Cuál es tu tarea principal?',
        hint: 'Lo que más pesa en tu trabajo o en tus estudios.',
        options: [
          InterviewOption(
            id: 'write',
            label: 'Escribir',
            draft: _focus(verb: 'Escribe'),
          ),
          InterviewOption(
            id: 'code',
            label: 'Programar',
            draft: _focus(verb: 'Programa'),
          ),
          InterviewOption(
            id: 'study',
            label: 'Estudiar',
            draft: _focus(verb: 'Estudia'),
          ),
          InterviewOption(
            id: 'organize',
            label: 'Organizar pendientes',
            draft: _focus(verb: 'Organiza tus pendientes'),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'blocks',
        prompt: '¿Cuánto dura cada bloque de trabajo?',
        hint: 'Entre más largo, más cuesta sostenerlo.',
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
        prompt: '¿Qué te rompe la concentración?',
        hint: 'Atacamos lo que más te distrae.',
        options: [
          InterviewOption(
            id: 'phone',
            label: 'El celular',
            draft: _phoneOff(minutes: 30),
          ),
          InterviewOption(
            id: 'notifications',
            label: 'Las notificaciones',
            draft: _phoneOff(minutes: 45),
          ),
          InterviewOption(
            id: 'thoughts',
            label: 'Mi propia cabeza',
            draft: _meditation(),
          ),
          InterviewOption(id: 'tired', label: 'El cansancio', draft: _sleep()),
        ],
      ),
      InterviewQuestion(
        id: 'closing',
        prompt: '¿Cómo cierras tu día?',
        hint: 'Un día bien cerrado se nota al siguiente.',
        options: [
          InterviewOption(
            id: 'close_tasks',
            label: 'Termino mis pendientes',
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
        hint: 'Sin energía no hay concentración.',
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
            label: 'Tomar agua',
            draft: hydrationDraft,
          ),
          InterviewOption(id: 'sleep', label: 'Dormir', draft: _sleep()),
        ],
      ),
      InterviewQuestion(
        id: 'hobby',
        prompt: '¿Qué te gusta hacer?',
        hint: 'Una misión para que el día no sea solo deber.',
        options: [
          InterviewOption(id: 'craft', label: _craft, draft: _craftHobby()),
          InterviewOption(id: 'pets', label: _pets, draft: _petsHobby()),
          InterviewOption(
            id: 'friends',
            label: _friends,
            draft: _friendsHobby(),
          ),
          InterviewOption(
            id: 'read',
            label: 'Leer',
            draft: _hobby(kind: 'lectura', title: 'Lee por gusto', minutes: 20),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'extra',
        prompt: '¿Qué más te suma?',
        hint: 'La última misión del día.',
        options: [
          InterviewOption(id: 'read', label: 'Leer', draft: _reading()),
          InterviewOption(
            id: 'stretch',
            label: 'Estirarme',
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
        hint: 'Tu práctica principal del día.',
        options: [
          InterviewOption(
            id: 'meditate',
            label: 'Meditar',
            draft: _meditation(minutes: 10),
          ),
          InterviewOption(
            id: 'journal',
            label: 'Escribir un diario',
            draft: _journal(minutes: 10),
          ),
          InterviewOption(
            id: 'breathing',
            label: 'Respirar',
            draft: _breathing(minutes: 10),
          ),
          InterviewOption(
            id: 'language',
            label: 'Practicar un idioma',
            draft: _language(minutes: 10),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'minutes',
        prompt: '¿Cuánto tiempo le dedicas?',
        hint: 'Mejor poco y diario que mucho de vez en cuando.',
        options: [
          InterviewOption(id: 'ten', label: '10 minutos', scalePrevious: 1),
          InterviewOption(id: 'twenty', label: '20 minutos', scalePrevious: 2),
          InterviewOption(id: 'thirty', label: '30 minutos', scalePrevious: 3),
        ],
      ),
      InterviewQuestion(
        id: 'distraction',
        prompt: '¿Qué te dispersa?',
        hint: 'Vamos primero por eso.',
        options: [
          InterviewOption(id: 'phone', label: 'El celular', draft: _phoneOff()),
          InterviewOption(id: 'noise', label: 'El ruido', draft: _breathing()),
          InterviewOption(
            id: 'thoughts',
            label: 'Mi propia cabeza',
            draft: _journal(),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'reading',
        prompt: '¿Cuánto lees?',
        hint: 'Lectura con intención, no scroll.',
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
        prompt: '¿Tienes una rutina por la mañana?',
        hint: 'Tu primer bloque del día se decide la noche anterior.',
        options: [
          InterviewOption(id: 'yes', label: 'Sí, ya la tengo', draft: _plan()),
          InterviewOption(
            id: 'no',
            label: 'Quiero armarla',
            draft: _closeDay(),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'hobby',
        prompt: '¿Qué te gusta hacer?',
        hint: 'Una misión para que el día no sea solo deber.',
        options: [
          InterviewOption(id: 'pets', label: _pets, draft: _petsHobby()),
          InterviewOption(id: 'craft', label: _craft, draft: _craftHobby()),
          InterviewOption(
            id: 'family',
            label: _family,
            draft: _hobby(kind: 'familia', title: 'Sal con tu familia'),
          ),
          InterviewOption(
            id: 'walk',
            label: 'Caminar',
            draft: _hobby(
              kind: 'pasos',
              title: 'Camina sin audífonos',
              minutes: 20,
            ),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'extra',
        prompt: '¿Qué más te suma?',
        hint: 'La última misión del día.',
        options: [
          InterviewOption(
            id: 'walk',
            label: 'Caminar',
            draft: _steps(steps: 8000),
          ),
          InterviewOption(
            id: 'stretch',
            label: 'Estirarme',
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
        prompt: '¿Con quién quieres pasar más tiempo?',
        hint: 'La relación que quieres cuidar.',
        options: [
          InterviewOption(
            id: 'partner',
            label: 'Mi pareja',
            draft: _qualityTime(minutes: 20, who: 'tu pareja'),
          ),
          InterviewOption(
            id: 'family',
            label: 'Mi familia',
            draft: _qualityTime(minutes: 20, who: 'tu familia'),
          ),
          InterviewOption(
            id: 'friends',
            label: 'Mis amigos',
            draft: _qualityTime(minutes: 20, who: 'tus amigos'),
          ),
          InterviewOption(
            id: 'community',
            label: 'Mi comunidad',
            draft: _qualityTime(minutes: 20, who: 'tu comunidad'),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'quality',
        prompt: '¿Cuánto tiempo de calidad al día?',
        hint: 'Sin pantallas, frente a frente.',
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
        prompt: '¿Qué se te dificulta más con la gente que quieres?',
        hint: 'El detalle que más se te pasa.',
        options: [
          InterviewOption(
            id: 'call',
            label: 'Llamar o escribir',
            draft: _contact(),
          ),
          InterviewOption(
            id: 'plan',
            label: 'Hacer planes',
            draft: _planMeet(),
          ),
          InterviewOption(
            id: 'listen',
            label: 'Escuchar sin celular',
            draft: _listen(),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'gratitude',
        prompt: '¿Sueles dar las gracias?',
        hint: 'Un minuto al día cambia el ánimo en casa.',
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
          InterviewOption(id: 'no', label: 'Casi nunca', draft: _journal()),
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
            draft: _strength(),
          ),
          InterviewOption(
            id: 'walk',
            label: 'Caminar',
            draft: _steps(steps: 8000),
          ),
          InterviewOption(id: 'sleep', label: 'Dormir bien', draft: _sleep()),
          InterviewOption(
            id: 'eat',
            label: 'Comer bien',
            draft: _meals(snack: false),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'hobby',
        prompt: '¿Qué te gusta hacer?',
        hint: 'Una misión para que el día no sea solo deber.',
        options: [
          InterviewOption(id: 'pets', label: _pets, draft: _petsHobby()),
          InterviewOption(
            id: 'friends',
            label: _friends,
            draft: _friendsHobby(),
          ),
          InterviewOption(id: 'craft', label: _craft, draft: _craftHobby()),
          InterviewOption(
            id: 'volunteer',
            label: _volunteer,
            draft: _hobby(kind: 'comunidad', title: 'Ayuda en tu comunidad'),
          ),
        ],
      ),
      InterviewQuestion(
        id: 'extra',
        prompt: '¿Qué más te suma?',
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

final _fallbacks = <DailyGoal, List<MissionDraft>>{
  DailyGoal.fisico: [
    _stretch(minutes: 10),
    _meditation(),
    _reading(),
    _sleep(),
    _gratitude(),
    _journal(),
  ],
  DailyGoal.productividad: [
    _reading(),
    _stretch(minutes: 10),
    _meditation(),
    _gratitude(),
    _journal(),
    _steps(steps: 8000),
  ],
  DailyGoal.enfoque: [
    _gratitude(),
    _reading(),
    _stretch(minutes: 10),
    _meditation(),
    _sleep(),
    _steps(steps: 8000),
  ],
  DailyGoal.relaciones: [
    _gratitude(),
    _reading(),
    _stretch(minutes: 10),
    _sleep(),
    _meditation(),
    _steps(steps: 8000),
  ],
};

GoalInterview interviewFor(DailyGoal goal) =>
    interviews.firstWhere((interview) => interview.goal == goal);

const dailyStackXp = 420;

const dailyStackSize = 7;

const stackFormatVersion = 3;

List<MissionDraft> buildStack(DailyGoal goal, Map<String, String> answers) {
  final drafts = <MissionDraft>[];
  void add(MissionDraft draft) => drafts.add(_unique(goal, draft, drafts));

  for (final question in interviewFor(goal).questions) {
    final option = question.optionById(answers[question.id]);
    final scale = option.scalePrevious;
    if (scale != null) {
      if (drafts.isNotEmpty) {
        drafts[drafts.length - 1] = drafts.last.scaleBy(scale);
      }
      continue;
    }
    final draft = option.draft;
    if (draft != null) add(draft);
  }
  add(hydrationDraft);
  return [
    for (final draft in normalizeXp(drafts, dailyStackXp)) draft.resolved(),
  ];
}

MissionDraft _unique(
  DailyGoal goal,
  MissionDraft draft,
  List<MissionDraft> taken,
) {
  bool isTaken(MissionDraft candidate) =>
      taken.any((existing) => existing.kind == candidate.kind);
  if (!isTaken(draft)) return draft;
  return _fallbacks[goal]!.firstWhere(
    (candidate) => !isTaken(candidate),
    orElse: () => throw StateError('Sin misión de respaldo para ${goal.name}'),
  );
}

List<MissionDraft> normalizeXp(
  List<MissionDraft> drafts,
  int total, {
  int minimum = 20,
}) {
  if (drafts.isEmpty) return drafts;
  final weights = drafts.fold<int>(0, (sum, draft) => sum + draft.xpReward);
  if (weights <= 0) return drafts;

  final exact = [for (final draft in drafts) draft.xpReward * total / weights];
  final shares = [
    for (final value in exact)
      value.floor() < minimum ? minimum : value.floor(),
  ];
  var missing = total - shares.fold<int>(0, (sum, value) => sum + value);

  final byRemainder = List<int>.generate(drafts.length, (i) => i)
    ..sort((a, b) {
      final diff = (exact[b] - exact[b].floor()).compareTo(
        exact[a] - exact[a].floor(),
      );
      return diff != 0 ? diff : a.compareTo(b);
    });
  for (var i = 0; missing > 0; i++) {
    shares[byRemainder[i % drafts.length]]++;
    missing--;
  }
  while (missing < 0) {
    var largest = -1;
    for (var i = 0; i < shares.length; i++) {
      if (shares[i] > minimum && (largest < 0 || shares[i] > shares[largest])) {
        largest = i;
      }
    }
    if (largest < 0) break;
    shares[largest]--;
    missing++;
  }

  return [for (var i = 0; i < drafts.length; i++) drafts[i].withXp(shares[i])];
}

List<MissionDraft> defaultStack() => buildStack(DailyGoal.fisico, const {});
