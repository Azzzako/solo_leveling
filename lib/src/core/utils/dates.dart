DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime nextDay(DateTime day) => DateTime(day.year, day.month, day.day + 1);

DateTime previousDay(DateTime day) =>
    DateTime(day.year, day.month, day.day - 1);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

int daysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
