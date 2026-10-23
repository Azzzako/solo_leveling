import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling/src/app/mexico_localizations.dart';
import 'package:solo_leveling/src/core/widgets/adaptive_pickers.dart';

void main() {
  Future<void> pumpHost(
    WidgetTester tester,
    TargetPlatform platform,
    Future<Object?> Function(BuildContext context) open,
    void Function(Object? value) onResult,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: platform),
        locale: appLocale,
        supportedLocales: const [appLocale],
        localizationsDelegates: MexicoMaterialLocalizations.delegates,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => onResult(await open(context)),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('en iOS la hora usa la rueda nativa con a. m. y p. m.', (
    tester,
  ) async {
    Object? result;
    await pumpHost(
      tester,
      TargetPlatform.iOS,
      (context) => pickTime(
        context,
        initial: const TimeOfDay(hour: 20, minute: 15),
        title: 'Hora del recordatorio',
      ),
      (value) => result = value,
    );

    expect(find.byType(CupertinoDatePicker), findsOneWidget);
    expect(find.byType(TimePickerDialog), findsNothing);
    expect(find.text('Hora del recordatorio'), findsOneWidget);
    expect(find.text('a. m.'), findsOneWidget);
    expect(find.text('p. m.'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('Hora del recordatorio'),
        matching: find.byType(Material),
      ),
      findsWidgets,
    );

    await tester.tap(find.text('Listo'));
    await tester.pumpAndSettle();
    expect(result, const TimeOfDay(hour: 20, minute: 15));
  });

  testWidgets('en iOS cancelar no cambia nada', (tester) async {
    Object? result = 'sin tocar';
    await pumpHost(
      tester,
      TargetPlatform.iOS,
      (context) => pickTime(
        context,
        initial: const TimeOfDay(hour: 8, minute: 0),
        title: 'Hora',
      ),
      (value) => result = value,
    );

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });

  testWidgets('en Android sigue el reloj de Material', (tester) async {
    await pumpHost(
      tester,
      TargetPlatform.android,
      (context) => pickTime(
        context,
        initial: const TimeOfDay(hour: 20, minute: 0),
        title: 'Hora',
      ),
      (_) {},
    );

    expect(find.byType(TimePickerDialog), findsOneWidget);
    expect(find.byType(CupertinoDatePicker), findsNothing);
  });

  testWidgets('en iOS la fecha usa la rueda y respeta el rango', (
    tester,
  ) async {
    Object? result;
    await pumpHost(
      tester,
      TargetPlatform.iOS,
      (context) => pickDate(
        context,
        initial: DateTime(2020, 1, 1),
        first: DateTime(2026, 10, 22, 15),
        last: DateTime(2030, 12, 31),
        title: 'Fecha límite',
      ),
      (value) => result = value,
    );

    expect(find.byType(CupertinoDatePicker), findsOneWidget);
    await tester.tap(find.text('Listo'));
    await tester.pumpAndSettle();
    expect(result, DateTime(2026, 10, 22));
  });
}
