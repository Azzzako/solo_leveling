import '../../../core/utils/dates.dart';
import '../../../core/utils/formatters.dart';

const backupApp = 'solo_leveling';

const backupFormat = 1;

const backupMimeType = 'application/json';

class BackupException implements Exception {
  const BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BackupSummary {
  const BackupSummary({
    required this.exportedAt,
    required this.email,
    required this.totalXp,
    required this.days,
    required this.completions,
    required this.goals,
  });

  final DateTime exportedAt;
  final String email;
  final int totalXp;
  final int days;
  final int completions;
  final int goals;
}

String backupFileName(DateTime at) =>
    'solo_leveling_respaldo_'
    '${at.year}-${at.month.toString().padLeft(2, '0')}-'
    '${at.day.toString().padLeft(2, '0')}.json';

String describeBackup(BackupSummary summary) {
  final from = summary.email.isEmpty ? '' : ' de ${summary.email}';
  return 'Respaldo$from del ${formatDate(summary.exportedAt)}: '
      '${formatNumber(summary.totalXp)} XP, '
      '${pluralize(summary.days, 'día', 'días')} con misiones, '
      '${pluralize(summary.completions, 'misión cumplida', 'misiones cumplidas')} '
      'y ${pluralize(summary.goals, 'meta', 'metas')}.';
}

const backupStaleDays = 7;

bool backupIsStale(DateTime? last, DateTime today) =>
    last == null || daysBetween(last, today) >= backupStaleDays;

String backupAgeLabel(DateTime? last, DateTime today) {
  if (last == null) return 'Nunca has hecho un respaldo.';
  final days = daysBetween(last, today);
  final when = switch (days) {
    <= 0 => 'hoy',
    1 => 'ayer',
    _ => 'hace $days días',
  };
  return 'Último respaldo: $when (${formatDate(last)}).';
}
