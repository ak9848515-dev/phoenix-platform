import 'package:flutter/material.dart';

/// Border radius tokens for the Phoenix Design System.
///
/// Cards consistently use 20px radius. Smaller components
/// use proportional values from the same scale.
class PhoenixRadius {
  PhoenixRadius._();

  // ── Raw values ────────────────────────────────────────────────────

  /// 8px – small elements (chips, badges, small icons).
  static const double sm = 8.0;

  /// 12px – medium elements (buttons, input fields).
  static const double md = 12.0;

  /// 16px – large elements (dialogs, bottom sheets).
  static const double lg = 16.0;

  /// 20px – cards (standard card radius).
  static const double xl = 20.0;

  /// 24px – hero sections, prominent containers.
  static const double xxl = 24.0;

  // ── Convenient BorderRadius constants ─────────────────────────────

  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlRadius =
      BorderRadius.all(Radius.circular(xxl));
}
