import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/missions/presentation/providers/interview_provider.dart';
import '../features/missions/presentation/screens/interview_screen.dart';
import 'shell/app_shell.dart';

const interviewPath = '/entrevista';

final loginPath = '/login';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.onDispose(refresh.dispose);
  ref.listen(authProvider, (_, _) => refresh.bump());
  ref.listen(userPreferencesProvider, (_, _) => refresh.bump());

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loading = auth.isLoading;
      final signedIn = auth.value != null;
      final location = state.matchedLocation;
      final onLogin = location == loginPath;
      final onInterview = location == interviewPath;

      if (loading) return onLogin || onInterview ? null : loginPath;
      if (!signedIn) return onLogin ? null : loginPath;
      if (onLogin) return AppRoutes.dashboard;

      final interview = ref.read(userPreferencesProvider);
      final needsInterview = interview.value?.configured == false;
      if (needsInterview && !onInterview) return interviewPath;
      if (!needsInterview && onInterview) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: interviewPath,
        builder: (context, state) => const InterviewScreen(reconfigure: false),
      ),
      GoRoute(
        path: '$interviewPath/reconfigurar',
        builder: (context, state) => const InterviewScreen(reconfigure: true),
      ),
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

class _RouterRefresh extends ChangeNotifier {
  void bump() => notifyListeners();
}
