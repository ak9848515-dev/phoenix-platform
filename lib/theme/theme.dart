import 'package:flutter/material.dart';

import '../core/design/theme/phoenix_theme.dart';

/// Provides the application's light and dark ThemeData definitions.
///
/// This centralizes visual configuration by delegating to the
/// [PhoenixTheme] design system.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => PhoenixTheme.light;

  static ThemeData get darkTheme => PhoenixTheme.dark;
}
