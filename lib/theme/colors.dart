import 'package:flutter/material.dart';

/// Defines the application's semantic color palette and shared color tokens.
///
/// These constants are intentionally reusable so that the UI can stay
/// consistent across light and dark themes without introducing hard-coded
/// color values in individual widgets.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFFF97316);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  static const Color darkBackground = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color lightSurface = Color(0xFFF8FAFC);
  static const Color onDarkBackground = Color(0xFFF8FAFC);
  static const Color onLightSurface = Color(0xFF0F172A);
  static const Color border = Color(0xFFCBD5E1);
  static const Color darkBorder = Color(0xFF334155);
}
