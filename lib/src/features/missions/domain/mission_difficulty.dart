import 'package:flutter/material.dart';

enum MissionDifficulty {
  trivial('D', 10),
  easy('C', 25),
  medium('B', 50),
  hard('A', 100),
  boss('S', 250);

  const MissionDifficulty(this.rank, this.baseXp);

  final String rank;
  final int baseXp;

  String get label => rank;

  Color get color => switch (this) {
    MissionDifficulty.trivial => const Color(0xFF8FA6C4),
    MissionDifficulty.easy => const Color(0xFF35E08A),
    MissionDifficulty.medium => const Color(0xFF2E9BFF),
    MissionDifficulty.hard => const Color(0xFF9D7BFF),
    MissionDifficulty.boss => const Color(0xFFFFC24B),
  };
}
