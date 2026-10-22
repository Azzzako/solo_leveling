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
  static const _kSettledDate = 'hunter_penalty_settled_date';

  static const xpCurveVersion = 3;

  static const _levelScaleByCurveVersion = <int, double>{1: 0.35, 2: 1, 3: 1};

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
    final stored = _prefs.getInt(_kXpCurveVersion) ?? 0;
    if (stored >= xpCurveVersion) return false;
    final stats = readStats();
    await writeStats(
      stats.copyWith(totalXp: rescaleXp(stats.totalXp, from: stored)),
    );
    await _prefs.setInt(_kXpCurveVersion, xpCurveVersion);
    return true;
  }

  DateTime? get lastSettledDate {
    final millis = _prefs.getInt(_kSettledDate);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> writeLastSettledDate(DateTime date) =>
      _prefs.setInt(_kSettledDate, date.millisecondsSinceEpoch);

  static int rescaleXp(int totalXp, {int from = 1}) {
    if (totalXp <= 0) return totalXp;
    final oldNeed = xpToNextInCurve(
      oldLevelForXp(totalXp, curve: from),
      curve: from,
    );
    final oldLevel = oldLevelForXp(totalXp, curve: from);
    final oldBase = totalXpForLevelInCurve(oldLevel, curve: from);
    final progress = oldNeed == 0 ? 0.0 : (totalXp - oldBase) / oldNeed;
    final newLevel = (oldLevel * (_levelScaleByCurveVersion[from] ?? 1))
        .round()
        .clamp(1, 999);
    final newBase = PlayerStats.totalXpForLevel(newLevel);
    final newNeed = PlayerStats.xpToNext(newLevel);
    return newBase + (progress * newNeed).round();
  }

  static int xpToNextInCurve(int level, {required int curve}) =>
      switch (curve) {
        1 => 100 + (level - 1) * 50,
        2 => 200 + (level - 1) * 75,
        _ => PlayerStats.xpToNext(level),
      };

  static int totalXpForLevelInCurve(int level, {required int curve}) {
    var total = 0;
    for (var i = 1; i < level; i++) {
      total += xpToNextInCurve(i, curve: curve);
    }
    return total;
  }

  static int oldLevelForXp(int xp, {required int curve}) {
    var level = 1;
    var remaining = xp;
    if (remaining <= 0) return level;
    while (remaining >= xpToNextInCurve(level, curve: curve)) {
      remaining -= xpToNextInCurve(level, curve: curve);
      level++;
    }
    return level;
  }
}
