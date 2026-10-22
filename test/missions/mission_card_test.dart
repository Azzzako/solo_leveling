import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling/src/core/db/app_database.dart';
import 'package:solo_leveling/src/features/missions/domain/mission_difficulty.dart';
import 'package:solo_leveling/src/features/missions/presentation/widgets/mission_card.dart';

Mission _mission(int progress) => Mission(
  id: 'm',
  title: 'Haz ejercicio',
  description: 'Completa las cuatro series.',
  difficulty: MissionDifficulty.medium,
  xpReward: 92,
  progress: progress,
  target: 4,
  isDaily: true,
  isActive: true,
  sortOrder: 0,
  createdAt: DateTime(2026, 10, 22),
);

MissionSubtask _series(String title, int progress, int target, int order) =>
    MissionSubtask(
      id: title,
      missionId: 'm',
      title: title,
      target: target,
      progress: progress,
      sortOrder: order,
      createdAt: DateTime(2026, 10, 22),
    );

void main() {
  testWidgets('todas las barras de una misión quedan alineadas', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: MissionCard(
              mission: _mission(1),
              completed: false,
              onComplete: () {},
              onUndo: () {},
              onSubtaskUndo: (_) {},
              subtasks: [
                _series('Lagartijas', 30, 30, 0),
                _series('Abdominales', 8, 30, 1),
                _series('Sentadillas', 0, 30, 2),
                _series('Dominadas', 12, 30, 3),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final bars = find.byType(LinearProgressIndicator);
    expect(bars, findsNWidgets(4));
    final rights = [
      for (var i = 0; i < 4; i++) tester.getTopRight(bars.at(i)).dx,
    ];
    final lefts = [
      for (var i = 0; i < 4; i++) tester.getTopLeft(bars.at(i)).dx,
    ];

    expect(rights.toSet(), hasLength(1), reason: '$rights');
    expect(lefts.toSet(), hasLength(1), reason: '$lefts');
    expect(find.text('Avance 1/4'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('las barras terminan igual en todas las tarjetas', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    final water = Mission(
      id: 'w',
      title: 'Toma 2 litros de agua',
      description: 'Mantén tu hidratación.',
      difficulty: MissionDifficulty.trivial,
      xpReward: 37,
      progress: 0,
      target: 2,
      isDaily: true,
      isActive: true,
      sortOrder: 1,
      createdAt: DateTime(2026, 10, 22),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                MissionCard(
                  mission: _mission(0),
                  completed: false,
                  onComplete: () {},
                  subtasks: [_series('Lagartijas', 0, 30, 0)],
                ),
                MissionCard(mission: water, completed: true, onComplete: () {}),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final bars = find.byType(LinearProgressIndicator);
    expect(bars, findsNWidgets(2));
    expect(
      tester.getTopRight(bars.at(1)).dx,
      tester.getTopRight(bars.at(0)).dx,
    );
    expect(find.text('1/1'), findsOneWidget);
    await tester.binding.setSurfaceSize(null);
  });
}
