import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const _display = 'Orbitron';
  static const _body = 'Rajdhani';

  static const systemLabel = TextStyle(
    fontFamily: _display,
    fontSize: 12,
    letterSpacing: 2.4,
    color: AppColors.systemBlue,
  );

  static const screenTitle = TextStyle(
    fontFamily: _display,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.6,
    color: AppColors.textPrimary,
  );

  static const panelTitle = TextStyle(
    fontFamily: _display,
    fontSize: 13,
    letterSpacing: 1.8,
    color: AppColors.textPrimary,
  );

  static const statLabel = TextStyle(
    fontFamily: _display,
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textMuted,
  );

  static const levelNumber = TextStyle(
    fontFamily: _display,
    fontSize: 44,
    fontWeight: FontWeight.w700,
    height: 1,
    color: AppColors.textPrimary,
  );

  static const metricValue = TextStyle(
    fontFamily: _display,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.systemGlow,
  );

  static const body = TextStyle(
    fontFamily: _body,
    fontSize: 15,
    color: AppColors.textPrimary,
  );

  static const bodyStrong = TextStyle(
    fontFamily: _body,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const caption = TextStyle(
    fontFamily: _body,
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static const counter = TextStyle(
    fontFamily: _body,
    fontSize: 13,
    fontFeatures: [FontFeature.tabularFigures()],
    color: AppColors.textSecondary,
  );
}
