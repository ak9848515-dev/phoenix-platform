import 'package:flutter/widgets.dart';

/// The spacing scale for the Phoenix Design System.
///
/// Provides a consistent rhythm for padding, margins, and layout gaps
/// throughout the application. Based on a 4px base unit.
class PhoenixSpacing {
  PhoenixSpacing._();

  /// 4px – tightest spacing (icons near text, small gaps).
  static const double xs = 4.0;

  /// 8px – small spacing (between related elements).
  static const double sm = 8.0;

  /// 12px – default inline spacing.
  static const double md = 12.0;

  /// 16px – standard card padding, section gaps.
  static const double lg = 16.0;

  /// 20px – generous spacing between sections.
  static const double xl = 20.0;

  /// 24px – page-level padding, large gaps.
  static const double xxl = 24.0;

  /// 32px – extra-large grouping.
  static const double xxxl = 32.0;

  /// 48px – hero / screen-level padding.
  static const double huge = 48.0;

  // ── Convenient EdgeInsets constants ───────────────────────────────

  /// All-axis padding shortcuts.
  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allXl = EdgeInsets.all(xl);
  static const EdgeInsets allXxl = EdgeInsets.all(xxl);

  /// Symmetric horizontal padding.
  static const EdgeInsets hSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets hMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets hLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets hXl = EdgeInsets.symmetric(horizontal: xl);

  /// Symmetric vertical padding.
  static const EdgeInsets vSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets vMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets vLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets vXl = EdgeInsets.symmetric(vertical: xl);
}
