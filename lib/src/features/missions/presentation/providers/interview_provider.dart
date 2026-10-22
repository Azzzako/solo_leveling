import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/mission_repository.dart';
import '../../domain/interview_catalog.dart';
import 'missions_provider.dart';

final userPreferencesProvider = FutureProvider<InterviewState>((ref) async {
  final repository = ref.watch(missionRepositoryProvider);
  final preference = await repository.userPreference();
  return preference == null
      ? const InterviewState.fresh()
      : InterviewState(
          goal: preference.goal,
          answers: repository.decodeAnswers(preference.answers),
          configured: PreferenceSource.isConfigured(preference.source),
        );
});

final interviewControllerProvider =
    NotifierProvider<InterviewController, InterviewState>(
      InterviewController.new,
    );

class InterviewState {
  const InterviewState({
    required this.goal,
    required this.answers,
    required this.configured,
    this.step = 0,
  });

  const InterviewState.fresh()
    : goal = null,
      answers = const {},
      configured = false,
      step = 0;

  final DailyGoal? goal;
  final Map<String, String> answers;
  final bool configured;
  final int step;

  bool get isChoosingGoal => goal == null;

  List<InterviewQuestion> get questions =>
      goal == null ? const [] : interviewFor(goal!).questions;

  InterviewQuestion? get currentQuestion {
    final list = questions;
    if (list.isEmpty || step >= list.length) return null;
    return list[step];
  }

  bool get isLastStep => step == questions.length - 1;

  bool get canAdvance {
    final question = currentQuestion;
    return question != null && answers.containsKey(question.id);
  }

  double get progress {
    if (goal == null) return 0;
    return questions.isEmpty ? 0 : (step + 1) / questions.length;
  }

  String? answerFor(String questionId) => answers[questionId];

  InterviewState copyWith({
    DailyGoal? goal,
    Map<String, String>? answers,
    bool? configured,
    int? step,
    bool clearGoal = false,
  }) => InterviewState(
    goal: clearGoal ? null : (goal ?? this.goal),
    answers: answers ?? this.answers,
    configured: configured ?? this.configured,
    step: step ?? this.step,
  );
}

class InterviewController extends Notifier<InterviewState> {
  @override
  InterviewState build() {
    final loaded = ref.watch(userPreferencesProvider).value;
    if (loaded == null) return const InterviewState.fresh();
    return loaded.configured ? loaded : const InterviewState.fresh();
  }

  void chooseGoal(DailyGoal goal) {
    state = InterviewState(
      goal: goal,
      answers: const {},
      configured: false,
      step: 0,
    );
  }

  void answer(String optionId) {
    final question = state.currentQuestion;
    if (question == null) return;
    state = state.copyWith(
      answers: {...state.answers, question.id: optionId},
      step: state.isLastStep ? state.step : state.step + 1,
    );
  }

  void next() {
    if (!state.canAdvance || state.isLastStep) return;
    state = state.copyWith(step: state.step + 1);
  }

  void back() {
    if (state.step == 0) {
      state = state.copyWith(clearGoal: true, step: 0);
      return;
    }
    state = state.copyWith(step: state.step - 1);
  }

  Future<void> finish() async {
    final goal = state.goal;
    if (goal == null) return;
    await _persist(goal, state.answers, PreferenceSource.interview);
  }

  Future<void> skip() => _persist(
    state.goal ?? DailyGoal.fisico,
    const {},
    PreferenceSource.skipped,
  );

  Future<void> _persist(
    DailyGoal goal,
    Map<String, String> answers,
    String source,
  ) async {
    final effects = PlayerEffects(ref);
    final repository = ref.read(missionRepositoryProvider);
    final day = ref.read(todayProvider);
    final outcome = await repository.applyStack(
      goal: goal,
      answers: answers,
      day: day,
      level: await effects.level(),
      source: source,
    );
    await effects.refund(outcome);
    ref.invalidate(userPreferencesProvider);
    ref.invalidate(ensureDailyMissionsProvider);
  }

  void restart() {
    final loaded = ref.read(userPreferencesProvider).value;
    state = InterviewState(
      goal: state.goal ?? loaded?.goal,
      answers: state.answers.isEmpty
          ? (loaded?.answers ?? const <String, String>{})
          : state.answers,
      configured: false,
      step: 0,
    );
  }
}
