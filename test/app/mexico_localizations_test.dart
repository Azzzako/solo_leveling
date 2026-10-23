import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling/src/app/mexico_localizations.dart';

void main() {
  Future<BuildContext> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: appLocale,
        supportedLocales: const [appLocale],
        localizationsDelegates: MexicoMaterialLocalizations.delegates,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 20, minute: 0),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return tester.element(find.text('abrir'));
  }

  testWidgets('las horas se muestran en formato de 12 horas', (tester) async {
    final context = await pump(tester);
    final l10n = MaterialLocalizations.of(context);

    expect(
      l10n.formatTimeOfDay(const TimeOfDay(hour: 20, minute: 0)),
      '8:00 p. m.',
    );
    expect(
      l10n.formatTimeOfDay(const TimeOfDay(hour: 7, minute: 5)),
      '7:05 a. m.',
    );
    expect(l10n.cancelButtonLabel, 'Cancelar');
    expect(l10n.okButtonLabel, 'Aceptar');
  });

  testWidgets('el selector de hora deja elegir a. m. o p. m.', (tester) async {
    await pump(tester);

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.text('a. m.'), findsOneWidget);
    expect(find.text('p. m.'), findsOneWidget);

    await tester.tap(find.text('a. m.'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
