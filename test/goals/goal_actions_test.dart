import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling/src/core/db/app_database.dart';
import 'package:solo_leveling/src/core/providers/core_providers.dart';
import 'package:solo_leveling/src/features/auth/domain/auth_user.dart';
import 'package:solo_leveling/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:solo_leveling/src/features/goals/presentation/providers/goals_provider.dart';
import 'package:solo_leveling/src/features/player/presentation/providers/player_provider.dart';

class _StubAuth extends AuthController {
  @override
  Future<AuthUser?> build() async =>
      const AuthUser(id: 'test-user', email: 'cazador@test.dev');
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        authProvider.overrideWith(_StubAuth.new),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<int> xp() async =>
      (await container.read(playerProvider.future)).totalXp;

  test('cumplir una meta paga su XP una sola vez', () async {
    final actions = container.read(goalActionsProvider);
    final goal = await actions.create(
      title: '  Correr 10 km ',
      description: '',
      xpReward: 1000,
      deadline: DateTime(2026, 12, 31),
    );
    expect(goal.title, 'Correr 10 km');

    final first = await actions.complete(goal);
    final second = await actions.complete(goal);

    expect(first.xpEarned, 1000);
    expect(first.leveledUp, isTrue);
    expect(second.xpEarned, 0);
    expect(await xp(), 1000);

    final stored = await container
        .read(goalRepositoryProvider)
        .watchCompleted()
        .first;
    expect(stored.single.completedAt, isNotNull);
    expect(
      await container.read(goalRepositoryProvider).watchActive().first,
      isEmpty,
    );
  });

  test('reabrir devuelve la meta a activas y descuenta el XP', () async {
    final actions = container.read(goalActionsProvider);
    final goal = await actions.create(
      title: 'Leer 12 libros',
      description: 'Uno al mes',
      xpReward: 500,
    );
    await actions.complete(goal);

    final revoked = await actions.reopen(goal);
    final again = await actions.reopen(goal);

    expect(revoked, 500);
    expect(again, 0);
    expect(await xp(), 0);
    final active = await container
        .read(goalRepositoryProvider)
        .watchActive()
        .first;
    expect(active.single.completedAt, isNull);
  });

  test('eliminar una meta activa no toca el XP', () async {
    final actions = container.read(goalActionsProvider);
    final goal = await actions.create(
      title: 'Aprender a nadar',
      description: '',
      xpReward: 250,
    );

    await actions.delete(goal);

    expect(await xp(), 0);
    expect(
      await container.read(goalRepositoryProvider).watchAll().first,
      isEmpty,
    );
  });
}
