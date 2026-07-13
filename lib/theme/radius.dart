import 'package:flutter/material.dart';

import '../core/design/theme/phoenix_radius.dart';

/// Defines reusable border radius tokens for components and surfaces.
///
/// These constants delegate to the [PhoenixRadius] design system tokens.
class AppRadius {
  AppRadius._();

  static const double sm = PhoenixRadius.sm;
  static const double md = PhoenixRadius.md;
  static const double lg = PhoenixRadius.lg;
  static const double xl = PhoenixRadius.xl;

  static const BorderRadius smRadius = PhoenixRadius.smRadius;
  static const BorderRadius mdRadius = PhoenixRadius.mdRadius;
  static const BorderRadius lgRadius = PhoenixRadius.lgRadius;
  static const BorderRadius xlRadius = PhoenixRadius.xlRadius;
}
