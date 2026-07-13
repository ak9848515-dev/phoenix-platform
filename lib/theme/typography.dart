import 'package:flutter/material.dart';

import '../core/design/theme/phoenix_typography.dart';

/// Defines the Material 3-inspired text styles for the application.
///
/// These tokens delegate to the [PhoenixTypography] design system.
class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => PhoenixTypography.toMaterialTextTheme();
}
