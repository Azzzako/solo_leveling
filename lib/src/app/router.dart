import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'shell/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          for (final branch in AppRoutes.branches)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: branch.path,
                  builder: (context, state) => branch.screen,
                ),
              ],
            ),
        ],
      ),
    ],
  );
});
