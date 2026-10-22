import 'package:shared_preferences/shared_preferences.dart';

import '../../features/player/domain/player_stats.dart';

class SettingsStore {
  SettingsStore(this._prefs, {required this.userId});

  static const xpCurveVersion = 3;

  static const defaultName = 'Cazador';

  static const _levelScaleByCurveVersion = <int, double>{1: 0.35, 2: 1, 3: 1};

  final SharedPreferences _prefs;
  final String userId;

  String _key(String name) => 'sl_$userId::$name';

  static const _legacyKeys = <String>[
    'hunter_name',
    'hunter_total_xp',
    'hunter_streak',
    'hunter_last_completion',
    'daily_missions_seed_date',
    'hunter_xp_curve_version',
    'hunter_penalty_settled_date',
  ];

  static const _kLegacyClaimed = 'sl_legacy_claimed';

  static const _legacyRenames = <String, String>{
    'hunter_xp_curve_version': 'xp_curve_version',
  };

  static const _kXpCurveVersion = 'xp_curve_version';
  static const _kName = 'hunter_name';
  static const _kXp = 'hunter_total_xp';
  static const _kStreak = 'hunter_streak';
  static const _kLastCompletion = 'hunter_last_completion';
  static const _kMissionSeed = 'daily_missions_seed_date';
  static const _kSettledDate = 'hunter_penalty_settled_date';
  static const _kLastBackup = 'last_backup_at';

  static Future<SettingsStore> open(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final store = SettingsStore(prefs, userId: userId);
    await store.adoptLegacyProgressOnce();
    return store;
  }

  Future<void> adoptLegacyProgressOnce() async {
    if (_prefs.getBool(_kLegacyClaimed) ?? false) return;
    final present = _legacyKeys.where(_prefs.containsKey).toList();
    if (present.isEmpty) {
      await _prefs.setBool(_kLegacyClaimed, true);
      return;
    }
    for (final key in present) {
      final target = _key(_legacyRenames[key] ?? key);
      final value = _prefs.get(key);
      switch (value) {
        case final int number:
          await _prefs.setInt(target, number);
        case final double number:
          await _prefs.setDouble(target, number);
        case final bool flag:
          await _prefs.setBool(target, flag);
        case final String text:
          await _prefs.setString(target, text);
        case final List<String> items:
          await _prefs.setStringList(target, items);
        case _:
          break;
      }
      await _prefs.remove(key);
    }
    await _prefs.setBool(_kLegacyClaimed, true);
  }

  PlayerStats readStats() {
    final lastMillis = _prefs.getInt(_key(_kLastCompletion)) ?? 0;
    return PlayerStats(
      name: _prefs.getString(_key(_kName)) ?? defaultName,
      totalXp: _prefs.getInt(_key(_kXp)) ?? 0,
      streak: _prefs.getInt(_key(_kStreak)) ?? 0,
      lastCompletion: lastMillis <= 0
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastMillis),
    );
  }

  Future<void> writeStats(PlayerStats stats) async {
    await _prefs.setString(_key(_kName), stats.name);
    await _prefs.setInt(_key(_kXp), stats.totalXp);
    await _prefs.setInt(_key(_kStreak), stats.streak);
    final last = stats.lastCompletion;
    if (last == null) {
      await _prefs.remove(_key(_kLastCompletion));
    } else {
      await _prefs.setInt(_key(_kLastCompletion), last.millisecondsSinceEpoch);
    }
  }

  DateTime? get dailyMissionsSeedDate {
    final millis = _prefs.getInt(_key(_kMissionSeed));
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> writeDailyMissionsSeed(DateTime date) =>
      _prefs.setInt(_key(_kMissionSeed), date.millisecondsSinceEpoch);

  Future<bool> applyXpCurveMigration() async {
    final stored = _prefs.getInt(_key(_kXpCurveVersion)) ?? 0;
    if (stored >= xpCurveVersion) return false;
    final stats = readStats();
    await writeStats(
      stats.copyWith(totalXp: rescaleXp(stats.totalXp, from: stored)),
    );
    await _prefs.setInt(_key(_kXpCurveVersion), xpCurveVersion);
    return true;
  }

  DateTime? get lastSettledDate {
    final millis = _prefs.getInt(_key(_kSettledDate));
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> writeLastSettledDate(DateTime date) =>
      _prefs.setInt(_key(_kSettledDate), date.millisecondsSinceEpoch);

  DateTime? get lastBackupAt {
    final millis = _prefs.getInt(_key(_kLastBackup));
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> writeLastBackupAt(DateTime at) =>
      _prefs.setInt(_key(_kLastBackup), at.millisecondsSinceEpoch);

  Map<String, Object?> exportPlayer() {
    final stats = readStats();
    return {
      'name': stats.name,
      'totalXp': stats.totalXp,
      'streak': stats.streak,
      'lastCompletion': stats.lastCompletion?.millisecondsSinceEpoch,
      'xpCurveVersion': _prefs.getInt(_key(_kXpCurveVersion)) ?? xpCurveVersion,
    };
  }

  Future<void> importPlayer(
    Map<String, Object?> player, {
    required DateTime settledThrough,
  }) async {
    final last = player['lastCompletion'];
    await writeStats(
      PlayerStats(
        name: player['name'] as String? ?? defaultName,
        totalXp: player['totalXp'] as int? ?? 0,
        streak: player['streak'] as int? ?? 0,
        lastCompletion: last is int && last > 0
            ? DateTime.fromMillisecondsSinceEpoch(last)
            : null,
      ),
    );
    await _prefs.setInt(
      _key(_kXpCurveVersion),
      player['xpCurveVersion'] as int? ?? xpCurveVersion,
    );
    await writeLastSettledDate(settledThrough);
    await _prefs.remove(_key(_kMissionSeed));
  }

  static int rescaleXp(int totalXp, {int from = 1}) {
    if (totalXp <= 0) return totalXp;
    final oldLevel = oldLevelForXp(totalXp, curve: from);
    final oldNeed = xpToNextInCurve(oldLevel, curve: from);
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
