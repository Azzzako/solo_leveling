import 'package:flutter/material.dart';

enum HunterRank {
  e('E', 'Despiadto'),
  d('D', 'Inútil'),
  c('C', 'Promesa'),
  b('B', 'Constante'),
  a('A', 'Brillante'),
  s('S', 'Sombrío'),
  ss('SS', 'Élite'),
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

  int get xpIntoLevel => totalXp - totalXpForLevel(level);

  int get xpNeededForNext => xpToNext(level);

  double get levelProgress =>
      xpNeededForNext == 0 ? 1 : xpIntoLevel / xpNeededForNext;

  static int xpToNext(int level) => 200 + (level - 1) * 75;

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
  }) => PlayerStats(
    name: name ?? this.name,
    totalXp: totalXp ?? this.totalXp,
    streak: streak ?? this.streak,
    lastCompletion: lastCompletion ?? this.lastCompletion,
  );

  static int streakAfterCompletion({
    required int currentStreak,
    required DateTime today,
    required DateTime? lastCompletion,
  }) {
    if (lastCompletion == null) return 1;
    final last = DateTime(
      lastCompletion.year,
      lastCompletion.month,
      lastCompletion.day,
    );
    final day = DateTime(today.year, today.month, today.day);
    final diff = day.difference(last).inDays;
    if (diff == 0) return currentStreak;
    if (diff == 1) return currentStreak + 1;
    return 1;
  }
}
