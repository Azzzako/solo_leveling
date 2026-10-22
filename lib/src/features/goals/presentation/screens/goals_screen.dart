import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/system_widgets.dart';
import '../providers/goals_provider.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(activeGoalsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createGoal(context, ref),
        backgroundColor: AppColors.systemBlue,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: Text(
          'Nueva meta',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 12,
            letterSpacing: 1.2,
            color: Colors.black,
          ),
        ),
      ),
      body: goals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (list) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            const SectionHeader('METAS ACTIVAS'),
            if (list.isEmpty)
              const EmptyState(
                message: 'Sin metas. Define tu primer objetivo de largo plazo.',
                icon: Icons.flag,
              )
            else
              ...list.map(
                (g) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SystemPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g.title, style: AppTypography.bodyStrong),
                        if (g.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(g.description, style: AppTypography.caption),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.bolt, size: 14, color: AppColors.gold),
                            const SizedBox(width: 6),
                            Text(
                              '${g.xpReward} XP',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.gold,
                              ),
                            ),
                            const Spacer(),
                            if (g.deadline != null)
                              Text(
                                'Vence ${_formatDate(g.deadline!)}',
                                style: AppTypography.caption,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> _createGoal(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.panel,
        title: Text('Nueva meta', style: AppTypography.bodyStrong),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Ej: certificar Flutter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    final title = controller.text.trim();
    controller.dispose();
    if (created != true || title.isEmpty) return;
    await ref.read(goalRepositoryProvider).create(title: title);
  }
}
