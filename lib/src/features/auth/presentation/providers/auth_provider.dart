import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_user.dart';

final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  if (!SupabaseConfig.isConfigured) {
    throw StateError(SupabaseConfig.missingFieldsMessage);
  }
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return AuthRepository(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    prefs: prefs,
  );
});

final authProvider = AsyncNotifierProvider<AuthController, AuthUser?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AuthUser?> {
  @override
  Future<AuthUser?> build() async {
    if (!SupabaseConfig.isConfigured) return null;
    final repository = await ref.watch(authRepositoryProvider.future);
    final result = await repository.restore();
    _offline = result.offline;
    return result.user;
  }

  bool _offline = false;

  bool get offline => _offline;

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await (await ref.read(authRepositoryProvider.future))
          .signIn(email: email, password: password);
      _offline = result.offline;
      return result.user;
    });
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await (await ref.read(authRepositoryProvider.future))
          .signUp(email: email, password: password);
      _offline = result.offline;
      return result.user;
    });
  }

  Future<void> signOut() async {
    final repository = await ref.read(authRepositoryProvider.future);
    await repository.signOut();
    state = const AsyncData(null);
  }
}
