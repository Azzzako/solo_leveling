import 'package:flutter/material.dart';

abstract final class AppColors {
  static const voidBackground = Color(0xFF05070D);
  static const surface = Color(0xFF0B101C);
  static const panel = Color(0xFF0E1A2B);
  static const panelBorder = Color(0xFF1E3A5F);

  static const systemBlue = Color(0xFF2E9BFF);
  static const systemGlow = Color(0xFF00C2FF);
  static const gold = Color(0xFFFFC24B);
  static const danger = Color(0xFFFF4D6D);
  static const success = Color(0xFF35E08A);
  static const purple = Color(0xFF9D7BFF);

  static const textPrimary = Color(0xFFEAF2FF);
  static const textSecondary = Color(0xFF8FA6C4);
  static const textMuted = Color(0xFF5A6E88);

  static const difficultyColors = <int, Color>{
    0: textMuted,
    1: success,
    2: systemBlue,
    3: purple,
    4: danger,
  };

  static Color forDifficulty(int value) =>
      difficultyColors[value] ?? systemBlue;
}
