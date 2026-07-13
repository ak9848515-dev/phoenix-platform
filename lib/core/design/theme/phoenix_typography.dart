import 'package:flutter/material.dart';

/// The professional typography system for the Phoenix Design System.
///
/// Designed for readability and a timeless, editorial feel.
/// Three heading levels (H1–H3), body, caption, and supporting styles.
/// Font weights are kept consistent: light (300) never used;
/// regular (400), medium (500), semi-bold (600), and bold (700)
/// are the only weights.
class PhoenixTypography {
  PhoenixTypography._();

  // ── Family ────────────────────────────────────────────────────────

  /// Default system font family. For production, replace with a
  /// custom typeface (e.g. Inter, SF Pro, or EB Garamond for headings).
  static const String fontFamily = '';

  // ── Headings ──────────────────────────────────────────────────────

  /// H1 – hero / page titles.
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
  );

  /// H2 – section titles.
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.25,
  );

  /// H3 – card / group titles.
  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0,
  );

  // ── Body ──────────────────────────────────────────────────────────

  /// Body – primary reading text.
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.15,
  );

  /// Body small – secondary / supporting text.
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
  );

  // ── Caption / Label ───────────────────────────────────────────────

  /// Caption – small metadata, timestamps, footnotes.
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.4,
  );

  /// Label – UI labels, button text, tab text.
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );

  /// Small label – badges, chips, small UI indicators.
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // ── Numeric / Stat ────────────────────────────────────────────────

  /// Large numeric value (e.g. XP count, level number).
  static const TextStyle statValue = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.5,
  );

  /// Medium stat label.
  static const TextStyle statLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
  );

  // ── Material TextTheme adapter ────────────────────────────────────

  /// Produces a [TextTheme] that maps Phoenix styles to Material 3 slots
  /// so [Theme.of(context).textTheme] works as expected.
  static TextTheme toMaterialTextTheme() {
    return TextTheme(
      // Display (H1 equivalent)
      displayLarge: h1,
      displayMedium: h2,
      displaySmall: h3,

      // Headline (use our H2/H3 for lower headline levels)
      headlineMedium: h2,
      headlineSmall: h3,

      // Title (card titles etc.)
      titleLarge: h3,
      titleMedium: body.copyWith(fontWeight: FontWeight.w500),
      titleSmall: bodySmall.copyWith(fontWeight: FontWeight.w500),

      // Body
      bodyLarge: body,
      bodyMedium: bodySmall,
      bodySmall: caption,

      // Label
      labelLarge: label,
      labelMedium: labelSmall,
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0.5,
      ),
    );
  }
}
