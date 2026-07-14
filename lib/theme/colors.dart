import 'package:flutter/material.dart';

import '../core/design/theme/phoenix_colors.dart';

/// Defines the application's semantic color palette and shared color tokens.
///
/// These constants delegate to the [PhoenixColors] design system tokens
/// so the entire app stays consistent.
class AppColors {
  AppColors._();

  static const Color primary = PhoenixColors.primary;
  static const Color secondary = PhoenixColors.primary;
  static const Color success = PhoenixColors.success;
  static const Color warning = PhoenixColors.warning;
  static const Color error = PhoenixColors.error;

  static const Color darkBackground = PhoenixColors.darkBackground;
  static const Color surface = PhoenixColors.darkSurface;
  static const Color lightSurface = PhoenixColors.background;
  static const Color onDarkBackground = PhoenixColors.darkTextPrimary;
  static const Color onLightSurface = PhoenixColors.textPrimary;
  static const Color info = PhoenixColors.info;
  static const Color border = PhoenixColors.border;
  static const Color darkBorder = PhoenixColors.darkBorder;
}
