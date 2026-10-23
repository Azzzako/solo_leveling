String formatNumber(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/'
    '${date.year}';

String pluralize(int count, String singular, String plural) =>
    '${formatNumber(count)} ${count == 1 ? singular : plural}';

String formatTime(int hour, int minute) {
  final twelve = hour % 12 == 0 ? 12 : hour % 12;
  final period = hour < 12 ? 'a. m.' : 'p. m.';
  return '$twelve:${minute.toString().padLeft(2, '0')} $period';
}
