import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling/src/core/utils/dates.dart';
import 'package:solo_leveling/src/core/utils/formatters.dart';

void main() {
  group('formatNumber', () {
    test('agrupa miles con coma, como en México', () {
      expect(formatNumber(0), '0');
      expect(formatNumber(999), '999');
      expect(formatNumber(1000), '1,000');
      expect(formatNumber(15000), '15,000');
      expect(formatNumber(1234567), '1,234,567');
      expect(formatNumber(-880), '-880');
      expect(formatNumber(-12500), '-12,500');
    });
  });

  test('pluralize usa singular solo con 1', () {
    expect(pluralize(1, 'día', 'días'), '1 día');
    expect(pluralize(0, 'día', 'días'), '0 días');
    expect(pluralize(12, 'día', 'días'), '12 días');
  });

  test('formatDate usa dd/mm/aaaa', () {
    expect(formatDate(DateTime(2026, 3, 7)), '07/03/2026');
  });

  group('fechas', () {
    test('nextDay y previousDay cruzan meses y años', () {
      expect(nextDay(DateTime(2026, 12, 31)), DateTime(2027));
      expect(previousDay(DateTime(2026, 3)), DateTime(2026, 2, 28));
    });

    test('daysBetween ignora la hora', () {
      expect(
        daysBetween(DateTime(2026, 10, 22, 23), DateTime(2026, 10, 23, 1)),
        1,
      );
      expect(daysBetween(DateTime(2026, 10, 22), DateTime(2026, 10, 20)), -2);
    });

    test('isSameDay compara solo la fecha', () {
      expect(
        isSameDay(DateTime(2026, 10, 22, 1), DateTime(2026, 10, 22, 23)),
        isTrue,
      );
      expect(
        isSameDay(DateTime(2026, 10, 22), DateTime(2026, 10, 23)),
        isFalse,
      );
    });
  });
}
