import 'package:shared_preferences/shared_preferences.dart';

import '../../features/player/domain/player_stats.dart';

class SettingsStore {
  SettingsStore(this._prefs);

  static const _kName = 'hunter_name';
  static const _kXp = 'hunter_total_xp';
  static const _kStreak = 'hunter_streak';
  static const _kLastCompletion = 'hunter_last_completion';
  static const _kMissionSeed = 'daily_missions_seed_date';
  static const _kXpCurveVersion = 'hunter_xp_curve_version';

  static const xpCurveVersion = 2;

  static const _levelRescaleRatio = 0.35;

  final SharedPreferences _prefs;

  static Future<SettingsStore> open() async =>
      SettingsStore(await SharedPreferences.getInstance());

  PlayerStats readStats() => PlayerStats(
    name: _prefs.getString(_kName) ?? 'Cazador',
    totalXp: _prefs.getInt(_kXp) ?? 0,
    streak: _prefs.getInt(_kStreak) ?? 0,
    lastCompletion: _prefs.getInt(_kLastCompletion) == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(_prefs.getInt(_kLastCompletion)!),
  );

  Future<void> writeStats(PlayerStats stats) async {
    await _prefs.setString(_kName, stats.name);
    await _prefs.setInt(_kXp, stats.totalXp);
    await _prefs.setInt(_kStreak, stats.streak);
    final last = stats.lastCompletion;
    await _prefs.setInt(
      _kLastCompletion,
      last == null ? 0 : last.millisecondsSinceEpoch,
    );
  }

  DateTime? get dailyMissionsSeedDate {
    final millis = _prefs.getInt(_kMissionSeed);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> writeDailyMissionsSeed(DateTime date) =>
      _prefs.setInt(_kMissionSeed, date.millisecondsSinceEpoch);

  Future<bool> applyXpCurveMigration() async {
    if ((_prefs.getInt(_kXpCurveVersion) ?? 0) >= xpCurveVersion) return false;
    final stats = readStats();
    await writeStats(stats.copyWith(totalXp: rescaleXp(stats.totalXp)));
    await _prefs.setInt(_kXpCurveVersion, xpCurveVersion);
    return true;
  }

  static int rescaleXp(int totalXp) {
    if (totalXp <= 0) return 0;
    final oldLevel = _oldLevelForXp(totalXp);
    final oldNeed = _oldXpToNext(oldLevel);
    final oldBase = _oldTotalXpForLevel(oldLevel);
    final progress = oldNeed == 0 ? 0.0 : (totalXp - oldBase) / oldNeed;
    final newLevel = (oldLevel * _levelRescaleRatio).round().clamp(1, 999);
    final newBase = PlayerStats.totalXpForLevel(newLevel);
    final newNeed = PlayerStats.xpToNext(newLevel);
    return newBase + (progress * newNeed).round();
  }

  static int _oldXpToNext(int level) => 100 + (level - 1) * 50;

  static int _oldTotalXpForLevel(int level) {
    var total = 0;
    for (var i = 1; i < level; i++) {
      total += _oldXpToNext(i);
    }
    return total;
  }

  static int _oldLevelForXp(int xp) {
    var level = 1;
    var remaining = xp;
    while (remaining >= _oldXpToNext(level)) {
      remaining -= _oldXpToNext(level);
      level++;
    }
    return level;
  }
}
