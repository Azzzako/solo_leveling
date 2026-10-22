import 'dart:convert';

import 'package:gotrue/gotrue.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/auth_user.dart';

class AuthResult {
  const AuthResult({required this.user, this.offline = false});

  const AuthResult.signedOut() : user = null, offline = false;

  final AuthUser? user;
  final bool offline;

  bool get isSignedIn => user != null;
}

class AuthRepository {
  AuthRepository({
    required String url,
    required String anonKey,
    required this.prefs,
    http.Client? httpClient,
  }) : _client = GoTrueClient(
         url: '$url/auth/v1',
         headers: {'apikey': anonKey, 'Authorization': 'Bearer $anonKey'},
         autoRefreshToken: true,
         flowType: AuthFlowType.implicit,
         httpClient: httpClient,
       );

  static const _kSession = 'supabase_session_json';
  static const _kCachedUser = 'supabase_cached_user';

  final SharedPreferences prefs;
  final GoTrueClient _client;

  Future<AuthResult> restore() async {
    final rawUser = prefs.getString(_kCachedUser);
    if (rawUser == null) return const AuthResult.signedOut();

    AuthUser cached;
    try {
      cached = AuthUser.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
    } on FormatException {
      await _clear();
      return const AuthResult.signedOut();
    }

    final session = prefs.getString(_kSession);
    if (session != null) {
      try {
        final response = await _client.recoverSession(session);
        final user = response.user;
        if (user != null) {
          await _persist(response);
          return AuthResult(user: _toAuthUser(user));
        }
      } on AuthException {
        return AuthResult(user: cached, offline: true);
      } on Exception {
        return AuthResult(user: cached, offline: true);
      }
    }

    return AuthResult(user: cached, offline: true);
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException('Respuesta sin usuario');
    }
    await _persist(response);
    return AuthResult(user: _toAuthUser(user));
  }

  Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.signUp(
      email: email.trim(),
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException(
        'Revisa tu correo para confirmar la cuenta antes de entrar.',
      );
    }
    await _persist(response);
    return AuthResult(user: _toAuthUser(user));
  }

  Future<void> signOut() async {
    try {
      await _client.signOut();
    } on Exception {
      // sin red la sesión local se limpia igualmente
    }
    await _clear();
  }

  Future<void> _persist(AuthResponse response) async {
    final session = response.session;
    if (session != null) {
      await prefs.setString(_kSession, jsonEncode(session.toJson()));
    }
    final user = response.user;
    if (user != null) {
      await prefs.setString(
        _kCachedUser,
        jsonEncode(_toAuthUser(user).toJson()),
      );
    }
  }

  Future<void> _clear() async {
    await prefs.remove(_kSession);
    await prefs.remove(_kCachedUser);
  }

  AuthUser _toAuthUser(User user) =>
      AuthUser(id: user.id, email: user.email ?? '');
}
