import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/supabase_config.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/backup/presentation/screens/backup_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/missions/presentation/providers/interview_provider.dart';
import '../../features/missions/presentation/screens/missions_screen.dart';
import '../../features/reminders/presentation/providers/reminder_provider.dart';
import '../../features/reminders/presentation/widgets/reminder_sheet.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(reminderSyncProvider);
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
            label: 'Inicio',
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
    final reminderOn =
        ref.watch(reminderSettingsProvider).value?.enabled ?? false;
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
            message: 'Cambiar mis misiones diarias',
            child: IconButton(
              iconSize: 18,
              visualDensity: VisualDensity.compact,
              color: AppColors.textMuted,
              icon: const Icon(Icons.tune),
              onPressed: () => _startReconfigure(context, ref),
            ),
          ),
          IconButton(
            tooltip: 'Respaldo',
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            color: AppColors.textMuted,
            icon: const Icon(Icons.save_alt),
            onPressed: () => context.push(AppRoutes.backup),
          ),
          IconButton(
            tooltip: 'Recordatorio',
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            color: reminderOn ? AppColors.systemGlow : AppColors.textMuted,
            icon: Icon(
              reminderOn
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_none,
            ),
            onPressed: () => showReminderSheet(context),
          ),
          Tooltip(
            message: 'Cerrar sesión',
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

  void _startReconfigure(BuildContext context, WidgetRef ref) {
    ref.read(interviewControllerProvider.notifier).restart();
    context.push(AppRoutes.reconfigure);
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.panel,
        title: Text('Cerrar sesión', style: AppTypography.bodyStrong),
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
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(reminderServiceProvider).cancelAll();
    await ref.read(authProvider.notifier).signOut();
  }
}

class AppRoutes {
  static const dashboard = '/';
  static const missions = '/misiones';
  static const goals = '/metas';
  static const interview = '/entrevista';
  static const reconfigure = '/entrevista/reconfigurar';
  static const backup = BackupScreen.path;

  static const branches = <({String path, Widget screen})>[
    (path: dashboard, screen: DashboardScreen()),
    (path: missions, screen: MissionsScreen()),
    (path: goals, screen: GoalsScreen()),
  ];
}
