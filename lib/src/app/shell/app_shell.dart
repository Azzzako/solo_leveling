import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/supabase_config.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/missions/presentation/providers/interview_provider.dart';
import '../../features/missions/presentation/screens/interview_screen.dart';
import '../../features/missions/presentation/screens/missions_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

class _SystemHeader extends ConsumerWidget {
  const _SystemHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final email = auth.value?.email ?? '';
    final label = email.isEmpty ? 'SOLO LEVELING' : email;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Icon(Icons.radar, color: AppColors.systemGlow, size: 20),
          const SizedBox(width: 10),
          Text('SISTEMA', style: AppTypography.systemLabel),
          const Spacer(),
          if (ref.watch(authProvider.notifier).offline) ...[
            Tooltip(
              message: 'Sesión sin conexión',
              child: Icon(
                Icons.cloud_off_outlined,
                size: 14,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.systemLabel.copyWith(
                color: AppColors.textMuted,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: 'Cambiar el stack de misiones',
            child: IconButton(
              iconSize: 18,
              visualDensity: VisualDensity.compact,
              color: AppColors.textMuted,
              icon: const Icon(Icons.tune),
              onPressed: () => _startReconfigure(context, ref),
            ),
          ),
          Tooltip(
            message: 'Cambiar de cuenta',
            child: IconButton(
              iconSize: 18,
              visualDensity: VisualDensity.compact,
              color: AppColors.textMuted,
              icon: const Icon(Icons.logout),
              onPressed: () => _confirmSignOut(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startReconfigure(BuildContext context, WidgetRef ref) async {
    ref.read(interviewControllerProvider.notifier).restart();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const InterviewScreen(reconfigure: true),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.panel,
        title: Text('Cambiar de cuenta', style: AppTypography.bodyStrong),
        content: Text(
          'Tu progreso se queda en este dispositivo. Tendrás que entrar de '
          'nuevo con ${SupabaseConfig.isConfigured ? 'tu correo' : 'la configuración del proyecto'}.',
          style: AppTypography.caption,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authProvider.notifier).signOut();
  }
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
