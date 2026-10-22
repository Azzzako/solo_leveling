import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling/src/core/db/app_database.dart';
import 'package:solo_leveling/src/core/providers/core_providers.dart';
import 'package:solo_leveling/src/features/auth/domain/auth_user.dart';
import 'package:solo_leveling/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:solo_leveling/src/features/backup/presentation/providers/backup_provider.dart';
import 'package:solo_leveling/src/features/goals/presentation/providers/goals_provider.dart';
import 'package:solo_leveling/src/features/player/presentation/providers/player_provider.dart';

class _StubAuth extends AuthController {
  @override
  Future<AuthUser?> build() async =>
      const AuthUser(id: 'test-user', email: 'cazador@test.dev');
}

class _MemoryFiles implements BackupFiles {
  Uint8List? saved;
  String? name;
  bool cancel = false;

  @override
  Future<bool> save(String fileName, Uint8List bytes) async {
    if (cancel) return false;
    name = fileName;
    saved = bytes;
    return true;
  }

  @override
  Future<Uint8List?> pick() async => cancel ? null : saved;
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late _MemoryFiles files;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    files = _MemoryFiles();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        authProvider.overrideWith(_StubAuth.new),
        backupFilesProvider.overrideWithValue(files),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('exportar guarda el archivo y la fecha del respaldo', () async {
    expect(await container.read(lastBackupProvider.future), isNull);

    final saved = await container.read(backupActionsProvider).export();

    expect(saved, isTrue);
    expect(files.name, startsWith('solo_leveling_respaldo_'));
    expect(files.saved, isNotEmpty);
    expect(await container.read(lastBackupProvider.future), isNotNull);
  });

  test('cancelar el guardado no marca respaldo', () async {
    files.cancel = true;

    expect(await container.read(backupActionsProvider).export(), isFalse);
    expect(await container.read(lastBackupProvider.future), isNull);
  });

  test('restaurar regresa al estado del respaldo', () async {
    final goals = container.read(goalActionsProvider);
    final kept = await goals.create(
      title: 'Leer 12 libros',
      description: '',
      xpReward: 500,
    );
    await goals.complete(kept);
    await container.read(backupActionsProvider).export();

    final later = await goals.create(
      title: 'Meta después del respaldo',
      description: '',
      xpReward: 2000,
    );
    await goals.complete(later);
    expect((await container.read(playerProvider.future)).totalXp, 2500);

    final actions = container.read(backupActionsProvider);
    final snapshot = await actions.pick();
    await actions.restore(snapshot!);

    expect((await container.read(playerProvider.future)).totalXp, 500);
    final titles = (await db.select(db.goals).get()).map((g) => g.title);
    expect(titles, ['Leer 12 libros']);
  });
}
