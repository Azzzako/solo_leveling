import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling/src/app/app.dart';
import 'package:solo_leveling/src/core/db/app_database.dart';
import 'package:solo_leveling/src/core/providers/core_providers.dart';
import 'package:solo_leveling/src/features/auth/domain/auth_user.dart';
import 'package:solo_leveling/src/features/auth/presentation/providers/auth_provider.dart';

class _StubAuth extends AuthController {
  @override
  Future<AuthUser?> build() async =>
      const AuthUser(id: 'test-user', email: 'cazador@test.dev');
}

void main() {
  testWidgets('primer uso: entrevista, inicio, misiones y metas', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    Future<void> settle() async {
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)),
        );
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          authProvider.overrideWith(_StubAuth.new),
        ],
        child: const SoloLevelingApp(),
      ),
    );
    await settle();

    expect(find.text('¿Cuál es tu objetivo?'), findsOneWidget);
    await tester.tap(find.text('Mejorar mi físico'));
    await settle();

    for (var step = 0; step < 7; step++) {
      expect(find.text('${step + 1}/7'), findsOneWidget);
      final options = find.byIcon(Icons.radio_button_unchecked);
      await tester.tap(options.first);
      await settle();
    }
    expect(find.text('GUARDAR Y EMPEZAR'), findsOneWidget);
    await tester.tap(find.text('GUARDAR Y EMPEZAR'));
    await settle();

    expect(find.text('ESTADO'), findsOneWidget);
    expect(find.text('PRÓXIMAS MISIONES'), findsOneWidget);
    expect(find.text('Haz ejercicio'), findsOneWidget);

    await tester.tap(find.text('CAZADOR'));
    await settle();
    await tester.enterText(find.byType(TextField), 'Sung Jin-Woo');
    await tester.tap(find.text('Guardar'));
    await settle();
    expect(tester.takeException(), isNull);
    expect(find.text('SUNG JIN-WOO'), findsOneWidget);

    await tester.tap(find.text('Misiones'));
    await settle();
    expect(find.text('MISIONES DIARIAS'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Toma 2 litros de agua'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await settle();

    await tester.tap(find.text('Toma 2 litros de agua'));
    await settle();
    expect(find.textContaining('Misión cumplida'), findsOneWidget);

    await tester.tap(find.text('Metas'));
    await settle();
    expect(find.text('METAS ACTIVAS'), findsOneWidget);
    await tester.tap(find.text('NUEVA META'));
    await settle();
    await tester.enterText(find.byType(TextField).first, 'Correr 10 km');
    await settle();
    await tester.tap(find.text('CREAR META'));
    await settle();
    expect(find.text('Correr 10 km'), findsOneWidget);

    await tester.tap(find.text('Cumplida'));
    await settle();
    await tester.tap(find.text('Sí, la cumplí'));
    await settle();
    expect(find.text('METAS CUMPLIDAS'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await settle();
    await tester.binding.setSurfaceSize(null);
  });
}
