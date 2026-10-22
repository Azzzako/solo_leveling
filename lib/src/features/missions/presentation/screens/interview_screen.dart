import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/system_widgets.dart';
import '../../domain/interview_catalog.dart';
import '../providers/interview_provider.dart';

class InterviewScreen extends ConsumerStatefulWidget {
  const InterviewScreen({required this.reconfigure, super.key});

  final bool reconfigure;

  @override
  ConsumerState<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends ConsumerState<InterviewScreen> {
  bool _saving = false;

  Future<void> _save(Future<void> Function() action) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await action();
      if (mounted && widget.reconfigure && context.canPop()) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(interviewControllerProvider);
    final controller = ref.read(interviewControllerProvider.notifier);
    final reconfigure = widget.reconfigure;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              progress: state.progress,
              step: state.step,
              total: state.questions.length,
              onBack: state.step == 0 && state.goal == null
                  ? null
                  : controller.back,
              onClose: reconfigure ? () => context.pop() : null,
            ),
            Expanded(
              child: state.isChoosingGoal
                  ? _GoalPicker(onPicked: controller.chooseGoal)
                  : _QuestionView(state: state, controller: controller),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  if (!state.isChoosingGoal)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving || !state.canAdvance
                            ? null
                            : state.isLastStep
                            ? () => _save(controller.finish)
                            : controller.next,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.systemBlue,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          state.isLastStep ? 'GUARDAR Y EMPEZAR' : 'SIGUIENTE',
                          style: AppTypography.panelTitle.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: _saving ? null : () => _save(controller.skip),
                    child: Text(
                      'Usar la rutina de ejemplo',
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.progress,
    required this.step,
    required this.total,
    this.onBack,
    this.onClose,
  });

  final double progress;
  final int step;
  final int total;
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
    child: Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, size: 20),
              color: AppColors.textSecondary,
            ),
            Expanded(child: XpBar(progress: progress, height: 4)),
            const SizedBox(width: 12),
            Text(
              total == 0 ? 'OBJETIVO' : '${step + 1}/$total',
              style: AppTypography.systemLabel.copyWith(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
            if (onClose != null)
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, size: 20),
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ],
    ),
  );
}

class _GoalPicker extends StatelessWidget {
  const _GoalPicker({required this.onPicked});

  final ValueChanged<DailyGoal> onPicked;

  static const _icons = <DailyGoal, IconData>{
    DailyGoal.fisico: Icons.fitness_center,
    DailyGoal.productividad: Icons.bolt,
    DailyGoal.enfoque: Icons.center_focus_strong,
    DailyGoal.relaciones: Icons.favorite_outline,
  };

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
    children: [
      Text('¿Cuál es tu objetivo?', style: AppTypography.screenTitle),
      const SizedBox(height: 8),
      Text(
        'Con esto armamos tus siete misiones diarias. Puedes cambiarlas '
        'cuando quieras desde el ícono de ajustes.',
        style: AppTypography.caption,
      ),
      const SizedBox(height: 20),
      for (final goal in DailyGoal.values) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SystemPanel(
            padding: const EdgeInsets.all(14),
            child: InkWell(
              onTap: () => onPicked(goal),
              child: Row(
                children: [
                  Icon(_icons[goal], color: AppColors.systemGlow, size: 22),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _descriptions[goal]!.label,
                      style: AppTypography.bodyStrong,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ],
  );

  static final _descriptions = <DailyGoal, ({String label})>{
    DailyGoal.fisico: (label: 'Mejorar mi físico'),
    DailyGoal.productividad: (label: 'Mejorar mi productividad'),
    DailyGoal.enfoque: (label: 'Mejorar mi enfoque'),
    DailyGoal.relaciones: (label: 'Mejorar mis relaciones personales'),
  };
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({required this.state, required this.controller});

  final InterviewState state;
  final InterviewController controller;

  @override
  Widget build(BuildContext context) {
    final question = state.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      children: [
        Text(question.prompt, style: AppTypography.screenTitle),
        const SizedBox(height: 6),
        Text(question.hint, style: AppTypography.caption),
        const SizedBox(height: 20),
        for (final option in question.options) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OptionTile(
              label: option.label,
              selected: state.answerFor(question.id) == option.id,
              onTap: () => controller.answer(option.id),
            ),
          ),
        ],
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SystemPanel(
    padding: const EdgeInsets.all(14),
    glow: selected,
    borderColor: selected ? AppColors.systemGlow : null,
    child: InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            selected ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: selected ? AppColors.systemGlow : AppColors.textMuted,
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: AppTypography.bodyStrong)),
        ],
      ),
    ),
  );
}
