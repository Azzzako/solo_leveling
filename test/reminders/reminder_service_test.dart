import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling/src/features/reminders/data/reminder_service.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  test('la zona se llama UTC, nombre válido en iOS y en Android', () {
    expect(reminderUtc.name, 'UTC');
  });

  test('conserva el instante exacto del aviso', () {
    final at = DateTime(2026, 10, 22, 20, 30);
    final scheduled = tz.TZDateTime.from(at.toUtc(), reminderUtc);

    expect(scheduled.millisecondsSinceEpoch, at.millisecondsSinceEpoch);
    expect(scheduled.timeZoneOffset, Duration.zero);
  });
}
