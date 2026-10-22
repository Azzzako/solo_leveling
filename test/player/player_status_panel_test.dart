import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling/src/features/player/domain/player_stats.dart';
import 'package:solo_leveling/src/features/player/presentation/widgets/player_status_panel.dart';

void main() {
  Future<void> pumpPanel(WidgetTester tester, PlayerStats stats) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlayerStatusPanel(
            stats: stats,
            todayCompleted: 0,
            todayTotal: 7,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('con XP normal muestra el progreso del nivel', (tester) async {
    await pumpPanel(
      tester,
      PlayerStats(name: 'Cazador', totalXp: 200, streak: 3),
    );

    expect(find.text('200 / 325 XP'), findsOneWidget);
    expect(find.textContaining('DEUDA'), findsNothing);
  });

  testWidgets('en deuda muestra la cantidad en rojo', (tester) async {
    await pumpPanel(
      tester,
      PlayerStats(name: 'Cazador', totalXp: -880, streak: 0),
    );

    expect(find.text('DEUDA 880 XP'), findsOneWidget);
    expect(find.text('-880 XP'), findsOneWidget);
    expect(find.text('RANGO E'), findsOneWidget);
    expect(find.text('NIVEL'), findsOneWidget);
  });
}
