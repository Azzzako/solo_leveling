import 'package:flutter/material.dart';

import '../../../core/utils/dates.dart';

enum HunterRank {
  e('E', 'Despertado'),
  d('D', 'Aprendiz'),
  c('C', 'Promesa'),
  b('B', 'Constante'),
  a('A', 'Brillante'),
  s('S', 'Élite'),
  ss('SS', 'Leyenda'),
  sss('SSS', 'Monarca');

  const HunterRank(this.label, this.title);

  final String label;
  final String title;

  static HunterRank fromLevel(int level) => switch (level) {
    < 4 => HunterRank.e,
    < 8 => HunterRank.d,
    < 14 => HunterRank.c,
    < 22 => HunterRank.b,
    < 32 => HunterRank.a,
    < 45 => HunterRank.s,
    < 60 => HunterRank.ss,
    _ => HunterRank.sss,
  };

  Color get color => switch (this) {
    HunterRank.e => const Color(0xFF8FA6C4),
    HunterRank.d => const Color(0xFF8FA6C4),
    HunterRank.c => const Color(0xFF35E08A),
    HunterRank.b => const Color(0xFF2E9BFF),
    HunterRank.a => const Color(0xFF9D7BFF),
    HunterRank.s => const Color(0xFFFFC24B),
    HunterRank.ss => const Color(0xFFFF9F45),
    HunterRank.sss => const Color(0xFFFF4D6D),
  };
}

class PlayerStats {
  const PlayerStats({
    required this.name,
    required this.totalXp,
    required this.streak,
    this.lastCompletion,
  });

  final String name;
  final int totalXp;
  final int streak;
  final DateTime? lastCompletion;

  int get level => levelForXp(totalXp);

  HunterRank get rank => HunterRank.fromLevel(level);

  bool get inDebt => totalXp < 0;

  int get xpIntoLevel => totalXp - totalXpForLevel(level);

  int get xpNeededForNext => xpToNext(level);

  double get levelProgress =>
      xpNeededForNext == 0 ? 1 : xpIntoLevel / xpNeededForNext;

  static int xpToNext(int level) => 325 + (level - 1) * 122;

  static int totalXpForLevel(int level) {
    var total = 0;
    for (var i = 1; i < level; i++) {
      total += xpToNext(i);
    }
    return total;
  }

  static int levelForXp(int xp) {
    var level = 1;
    var remaining = xp;
    if (remaining <= 0) return level;
    while (remaining >= xpToNext(level)) {
      remaining -= xpToNext(level);
      level++;
    }
    return level;
  }

  PlayerStats copyWith({
    String? name,
    int? totalXp,
    int? streak,
    DateTime? lastCompletion,
    bool clearLastCompletion = false,
  }) => PlayerStats(
    name: name ?? this.name,
    totalXp: totalXp ?? this.totalXp,
    streak: streak ?? this.streak,
    lastCompletion: clearLastCompletion
        ? null
        : (lastCompletion ?? this.lastCompletion),
  );

  static int streakFrom(Iterable<DateTime> completions, DateTime today) {
    final days = {for (final completion in completions) dateOnly(completion)};
    var cursor = dateOnly(today);
    if (!days.contains(cursor)) cursor = previousDay(cursor);
    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = previousDay(cursor);
    }
    return streak;
  }
}
