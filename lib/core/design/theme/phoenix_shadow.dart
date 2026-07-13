import 'package:flutter/material.dart';

/// Elevation and shadow tokens for the Phoenix Design System.
///
/// Shadows are intentionally soft and subtle, never harsh.
/// The scale mirrors common Material elevation values but
/// uses warmer, lower-contrast shadow colors.
class PhoenixShadow {
  PhoenixShadow._();

  // ── Elevation values ──────────────────────────────────────────────

  /// 0 – no elevation (default).
  static const double none = 0;

  /// 1 – subtle card hover state.
  static const double sm = 1;

  /// 2 – default card elevation.
  static const double md = 2;

  /// 4 – elevated elements (dialogs, bottom sheets).
  static const double lg = 4;

  /// 8 – modal / overlay elements.
  static const double xl = 8;

  // ── Convenient box shadows ────────────────────────────────────────

  /// Subtle shadow for cards at rest.
  static List<BoxShadow> get cardRest => [
        BoxShadow(
          color: const Color(0x14000000),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  /// Slightly deeper shadow for hovered / pressed cards.
  static List<BoxShadow> get cardHover => [
        BoxShadow(
          color: const Color(0x1A000000),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  /// Shadow for elevated surfaces (dialogs, modals).
  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: const Color(0x1F000000),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: const Color(0x0A000000),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];
}
