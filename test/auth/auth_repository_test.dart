import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gotrue/gotrue.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling/src/features/auth/data/auth_repository.dart';

const _url = 'https://proyecto.supabase.co';
const _anonKey = 'anon-key';

http.Response _json(int status, Map<String, dynamic> body) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

Map<String, dynamic> _userJson(String id, String email) => {
  'id': id,
  'aud': 'authenticated',
  'role': 'authenticated',
  'email': email,
  'app_metadata': {
    'provider': 'email',
    'providers': ['email'],
  },
  'user_metadata': <String, dynamic>{},
  'identities': <dynamic>[],
  'created_at': '2026-10-01T00:00:00Z',
  'updated_at': '2026-10-01T00:00:00Z',
};

String _jwt(Map<String, dynamic> claims) {
  final header = base64Url.encode(
    utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})),
  );
  final payload = base64Url.encode(utf8.encode(jsonEncode(claims)));
  return '$header.$payload.firma';
}

String _accessToken({required bool expired}) => _jwt({
  'sub': 'uid',
  'role': 'authenticated',
  'aud': 'authenticated',
  'exp':
      (expired
              ? DateTime.now().subtract(const Duration(hours: 1))
              : DateTime.now().add(const Duration(hours: 1)))
          .millisecondsSinceEpoch ~/
      1000,
});

Map<String, dynamic> _sessionJson(
  String id,
  String email, {
  bool expired = false,
}) => {
  'access_token': _accessToken(expired: expired),
  'refresh_token': 'refresh-token',
  'token_type': 'bearer',
  'expires_in': 3600,
  'user': _userJson(id, email),
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<AuthRepository> build(http.Client client) async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    return AuthRepository(
      url: _url,
      anonKey: _anonKey,
      prefs: prefs,
      httpClient: client,
    );
  }

  group('signIn', () {
    test('guarda sesión y usuario en el dispositivo', () async {
      final repository = await build(
        MockClient((request) async {
          expect(request.url.path, '/auth/v1/token');
          return _json(200, _sessionJson('uid-1', 'cazador@test.dev'));
        }),
      );

      final result = await repository.signIn(
        email: 'cazador@test.dev',
        password: 'hunter2',
      );

      expect(result.isSignedIn, isTrue);
      expect(result.user!.id, 'uid-1');
      expect(result.offline, isFalse);
      expect(prefs.getString('supabase_session_json'), isNotNull);
      expect(prefs.getString('supabase_cached_user'), contains('uid-1'));
    });

    test('propaga el error de credenciales inválidas', () async {
      final repository = await build(
        MockClient(
          (request) async => _json(400, {
            'code': 'invalid_credentials',
            'msg': 'Invalid login credentials',
          }),
        ),
      );

      await expectLater(
        repository.signIn(email: 'cazador@test.dev', password: 'mal'),
        throwsA(
          isA<AuthException>()
              .having((e) => e.statusCode, 'statusCode', '400')
              .having(
                (e) => e.message,
                'message',
                contains('Invalid login credentials'),
              ),
        ),
      );
      expect(prefs.getString('supabase_cached_user'), isNull);
    });
  });

  group('signUp', () {
    test('crea la cuenta y deja sesión iniciada', () async {
      final repository = await build(
        MockClient(
          (request) async =>
              _json(200, _sessionJson('uid-2', 'nuevo@test.dev')),
        ),
      );

      final result = await repository.signUp(
        email: 'nuevo@test.dev',
        password: 'hunter2',
      );

      expect(result.user!.id, 'uid-2');
      expect(
        prefs.getString('supabase_cached_user'),
        contains('nuevo@test.dev'),
      );
    });

    test('avisa cuando hay que confirmar el correo', () async {
      final repository = await build(
        MockClient(
          (request) async =>
              _json(200, {'confirmation_sent_at': '2026-10-22T10:00:00Z'}),
        ),
      );

      await expectLater(
        repository.signUp(email: 'nuevo@test.dev', password: 'hunter2'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('restore', () {
    test('sin sesión guardada devuelve signed out', () async {
      final repository = await build(MockClient((_) async => _json(200, {})));

      final result = await repository.restore();

      expect(result.isSignedIn, isFalse);
    });

    test('renueva la sesión caducada contra el servidor', () async {
      var refreshCalls = 0;
      final repository = await build(
        MockClient((request) async {
          if (request.url.query.contains('grant_type=refresh_token')) {
            refreshCalls++;
          }
          return _json(200, _sessionJson('uid-1', 'cazador@test.dev'));
        }),
      );
      await prefs.setString(
        'supabase_cached_user',
        jsonEncode({'id': 'uid-1', 'email': 'cazador@test.dev'}),
      );
      await prefs.setString(
        'supabase_session_json',
        jsonEncode(_sessionJson('uid-1', 'cazador@test.dev', expired: true)),
      );

      final result = await repository.restore();

      expect(result.user!.id, 'uid-1');
      expect(result.offline, isFalse);
      expect(refreshCalls, greaterThanOrEqualTo(1));
      expect(prefs.getString('supabase_session_json'), isNotNull);
    });

    test('una sesión vigente no necesita red', () async {
      var calls = 0;
      final repository = await build(
        MockClient((request) async {
          calls++;
          return _json(200, _sessionJson('uid-1', 'cazador@test.dev'));
        }),
      );
      await repository.signIn(email: 'cazador@test.dev', password: 'hunter2');
      calls = 0;

      final result = await repository.restore();

      expect(result.user!.id, 'uid-1');
      expect(result.offline, isFalse);
      expect(calls, 0);
    });

    test('sin red sigue con la sesión cacheada', () async {
      final repository = await build(
        MockClient((request) async => throw const SocketFailure()),
      );
      await prefs.setString(
        'supabase_cached_user',
        jsonEncode({'id': 'uid-3', 'email': 'offline@test.dev'}),
      );
      await prefs.setString(
        'supabase_session_json',
        jsonEncode(_sessionJson('uid-3', 'offline@test.dev', expired: true)),
      );

      final result = await repository.restore();

      expect(result.user!.id, 'uid-3');
      expect(result.offline, isTrue);
    });

    test(
      'un token rechazado deja la sesión cacheada en modo offline',
      () async {
        final repository = await build(
          MockClient(
            (request) async => _json(401, {
              'code': 'refresh_token_not_found',
              'msg': 'Invalid Refresh Token',
            }),
          ),
        );
        await prefs.setString(
          'supabase_cached_user',
          jsonEncode({'id': 'uid-4', 'email': 'caducada@test.dev'}),
        );
        await prefs.setString(
          'supabase_session_json',
          jsonEncode(_sessionJson('uid-4', 'caducada@test.dev', expired: true)),
        );

        final result = await repository.restore();

        expect(result.user!.id, 'uid-4');
        expect(result.offline, isTrue);
      },
    );

    test('usuario cacheado sin sesión entra igual', () async {
      final repository = await build(
        MockClient((request) async => throw const SocketFailure()),
      );
      await prefs.setString(
        'supabase_cached_user',
        jsonEncode({'id': 'uid-6', 'email': 'solo@test.dev'}),
      );

      final result = await repository.restore();

      expect(result.user!.id, 'uid-6');
      expect(result.offline, isTrue);
    });

    test('un json corrupto no rompe el arranque', () async {
      final repository = await build(MockClient((_) async => _json(200, {})));
      await prefs.setString('supabase_cached_user', 'no-es-json');

      final result = await repository.restore();

      expect(result.isSignedIn, isFalse);
    });
  });

  group('signOut', () {
    test('limpia la sesión local aunque el servidor falle', () async {
      final repository = await build(
        MockClient((request) async => throw const SocketFailure()),
      );
      await prefs.setString(
        'supabase_cached_user',
        jsonEncode({'id': 'uid-5', 'email': 'salir@test.dev'}),
      );

      await repository.signOut();

      expect(prefs.getString('supabase_cached_user'), isNull);
      expect(prefs.getString('supabase_session_json'), isNull);
    });
  });
}

class SocketFailure implements Exception {
  const SocketFailure();
}
