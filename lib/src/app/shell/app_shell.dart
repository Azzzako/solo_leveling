import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/missions/presentation/screens/missions_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _SystemHeader(),
            Expanded(child: navigationShell),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Panel',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Misiones',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'Metas',
          ),
        ],
      ),
    );
  }
}

class _SystemHeader extends StatelessWidget {
  const _SystemHeader();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Row(
      children: [
        Icon(Icons.radar, color: AppColors.systemGlow, size: 20),
        const SizedBox(width: 10),
        Text('SISTEMA', style: AppTypography.systemLabel),
        const Spacer(),
        Text(
          'SOLO LEVELING',
          style: AppTypography.systemLabel.copyWith(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}

/// Rutas disponibles para el shell.
class AppRoutes {
  static const dashboard = '/';
  static const missions = '/misiones';
  static const goals = '/metas';

  static const branches = <({String path, Widget screen})>[
    (path: dashboard, screen: DashboardScreen()),
    (path: missions, screen: MissionsScreen()),
    (path: goals, screen: GoalsScreen()),
  ];
}
