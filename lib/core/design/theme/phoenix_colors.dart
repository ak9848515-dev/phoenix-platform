import 'package:flutter/material.dart';

/// The refined color palette for the Phoenix Design System.
///
/// A classical, elegant, minimal, and professional palette.
/// Deep Royal Blue anchors the brand. Gold is reserved exclusively for
/// achievements and premium elements. Chromatic accent colors are used
/// sparingly to preserve a timeless, editorial feel.
///
/// Light theme tokens are the primary target; dark tokens are defined
/// alongside so the architecture is ready for dark mode.
class PhoenixColors {
  PhoenixColors._();

  // ── Brand & Semantic ──────────────────────────────────────────────

  /// Deep Royal Blue – the primary brand anchor.
  static const Color primary = Color(0xFF1E3A8A);

  /// Primary hover/pressed state tint.
  static const Color primaryLight = Color(0xFF2D4FA8);

  /// Primary at 12% opacity – useful for subtle tinted containers.
  static Color primaryContainer(double opacity) =>
      primary.withValues(alpha: opacity);

  // ── Surfaces (Light) ──────────────────────────────────────────────

  /// Warm off-white page background.
  static const Color background = Color(0xFFFAFAFA);

  /// Pure white card surface.
  static const Color surface = Color(0xFFFFFFFF);

  /// Subtle surface tint for nested containers (light grey).
  static const Color surfaceVariant = Color(0xFFF3F4F6);

  /// Light border / divider.
  static const Color border = Color(0xFFE5E7EB);

  // ── Text (Light) ──────────────────────────────────────────────────

  /// Primary text – near-black for maximum readability.
  static const Color textPrimary = Color(0xFF1F2937);

  /// Secondary / muted text.
  static const Color textSecondary = Color(0xFF6B7280);

  /// Disabled / hint text.
  static const Color textDisabled = Color(0xFF9CA3AF);

  /// Text on primary surface (always white).
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ── Semantic States ───────────────────────────────────────────────

  /// Success – professional emerald.
  static const Color success = Color(0xFF059669);

  /// Success container tint.
  static Color successContainer(double opacity) =>
      success.withValues(alpha: opacity);

  /// Warning – subdued gold (not bright yellow). Used for
  /// achievements and premium indicators.
  static const Color warning = Color(0xFFD97706);

  /// Warning container tint.
  static Color warningContainer(double opacity) =>
      warning.withValues(alpha: opacity);

  /// Error – soft red.
  static const Color error = Color(0xFFDC2626);

  /// Error container tint.
  static Color errorContainer(double opacity) =>
      error.withValues(alpha: opacity);

  // ── Achievement / Premium ─────────────────────────────────────────

  /// A warm gold reserved exclusively for achievement highlights,
  /// badges, and premium feature indicators.
  static const Color gold = Color(0xFFD97706);

  /// Gold at 12% opacity for achievement background glows.
  static Color goldContainer(double opacity) =>
      gold.withValues(alpha: opacity);

  // ── Additional Accents ──────────────────────────────────────────

  /// Info / learning accent — calm blue.
  static const Color info = Color(0xFF2563EB);

  /// Violet accent for career readiness visuals.
  static const Color career = Color(0xFF7C3AED);

  /// Career container tint.
  static Color careerContainer(double opacity) =>
      career.withValues(alpha: opacity);

  // ── Shadows ───────────────────────────────────────────────────────

  /// Soft black used for drop-shadows.
  static const Color shadow = Color(0x1A000000);

  /// Medium-soft shadow (slightly denser).
  static const Color shadowMedium = Color(0x33000000);

  // ── Dark Mode Surfaces (architecture-ready) ───────────────────────

  static const Color darkBackground = Color(0xFF111827);
  static const Color darkSurface = Color(0xFF1F2937);
  static const Color darkSurfaceVariant = Color(0xFF374151);
  static const Color darkBorder = Color(0xFF4B5563);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFFD1D5DB);
  static const Color darkTextDisabled = Color(0xFF6B7280);
}
