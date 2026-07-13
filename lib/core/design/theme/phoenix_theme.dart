import 'package:flutter/material.dart';

import 'phoenix_colors.dart';
import 'phoenix_radius.dart';
import 'phoenix_spacing.dart';
import 'phoenix_typography.dart';

/// The complete Phoenix Design System theme.
///
/// Wires [PhoenixColors], [PhoenixTypography], [PhoenixSpacing], and
/// [PhoenixRadius] into Material 3 [ThemeData] objects.
///
/// Light theme is the primary target. Dark theme architecture is ready
/// for future enablement.
class PhoenixTheme {
  PhoenixTheme._();

  // ── Light Theme ───────────────────────────────────────────────────

  /// The light [ThemeData] for the Phoenix Design System.
  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: PhoenixColors.primary,
      onPrimary: PhoenixColors.onPrimary,
      surface: PhoenixColors.surface,
      onSurface: PhoenixColors.textPrimary,
      surfaceContainerHighest: PhoenixColors.surfaceVariant,
      onSurfaceVariant: PhoenixColors.textSecondary,
      error: PhoenixColors.error,
      onError: PhoenixColors.onPrimary,
      outline: PhoenixColors.border,
      outlineVariant: PhoenixColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: PhoenixColors.background,
      textTheme: PhoenixTypography.toMaterialTextTheme(),

      // ── Card ───────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: PhoenixColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: PhoenixColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: PhoenixRadius.xlRadius,
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ── Button ─────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PhoenixColors.primary,
          foregroundColor: PhoenixColors.onPrimary,
          disabledBackgroundColor: PhoenixColors.textDisabled,
          disabledForegroundColor: PhoenixColors.onPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: PhoenixSpacing.xl,
            vertical: PhoenixSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: PhoenixRadius.mdRadius,
          ),
          textStyle: PhoenixTypography.label,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PhoenixColors.primary,
          disabledForegroundColor: PhoenixColors.textDisabled,
          side: BorderSide(color: PhoenixColors.primary),
          padding: EdgeInsets.symmetric(
            horizontal: PhoenixSpacing.xl,
            vertical: PhoenixSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: PhoenixRadius.mdRadius,
          ),
          textStyle: PhoenixTypography.label,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PhoenixColors.primary,
          disabledForegroundColor: PhoenixColors.textDisabled,
          padding: EdgeInsets.symmetric(
            horizontal: PhoenixSpacing.md,
            vertical: PhoenixSpacing.sm,
          ),
          textStyle: PhoenixTypography.label,
        ),
      ),

      // ── Input ──────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PhoenixColors.surfaceVariant,
        contentPadding: EdgeInsets.all(PhoenixSpacing.lg),
        border: OutlineInputBorder(
          borderRadius: PhoenixRadius.mdRadius,
          borderSide: BorderSide(color: PhoenixColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: PhoenixRadius.mdRadius,
          borderSide: BorderSide(color: PhoenixColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: PhoenixRadius.mdRadius,
          borderSide: BorderSide(color: PhoenixColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: PhoenixRadius.mdRadius,
          borderSide: BorderSide(color: PhoenixColors.error),
        ),
        labelStyle: PhoenixTypography.bodySmall.copyWith(
          color: PhoenixColors.textSecondary,
        ),
        hintStyle: PhoenixTypography.bodySmall.copyWith(
          color: PhoenixColors.textDisabled,
        ),
      ),

      // ── Divider ────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        space: PhoenixSpacing.sm,
        thickness: 1,
        color: PhoenixColors.border,
      ),

      // ── Chip ───────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: PhoenixColors.surfaceVariant,
        labelStyle: PhoenixTypography.labelSmall.copyWith(
          color: PhoenixColors.textSecondary,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: PhoenixRadius.smRadius,
        ),
      ),

      // ── Bottom Navigation ──────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: PhoenixColors.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PhoenixTypography.labelSmall.copyWith(
              color: PhoenixColors.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return PhoenixTypography.labelSmall.copyWith(
            color: PhoenixColors.textSecondary,
          );
        }),
      ),

      // ── AppBar ─────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: PhoenixColors.background,
        foregroundColor: PhoenixColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: PhoenixTypography.h3.copyWith(
          color: PhoenixColors.textPrimary,
        ),
      ),

      // ── Dialog ─────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: PhoenixColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: PhoenixRadius.lgRadius,
        ),
      ),

      // ── Bottom Sheet ───────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: PhoenixColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(PhoenixRadius.xl),
          ),
        ),
      ),

      // ── Tabs ───────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: PhoenixColors.primary,
        unselectedLabelColor: PhoenixColors.textSecondary,
        labelStyle: PhoenixTypography.label,
        unselectedLabelStyle: PhoenixTypography.label,
        indicatorColor: PhoenixColors.primary,
      ),

    );
  }

  // ── Dark Theme (Architecture Ready) ──────────────────────────────

  /// Architecture-ready dark [ThemeData].
  ///
  /// Not active by default. Enable by passing this to `MaterialApp.darkTheme`.
  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      primary: PhoenixColors.primary,
      onPrimary: PhoenixColors.onPrimary,
      surface: PhoenixColors.darkSurface,
      onSurface: PhoenixColors.darkTextPrimary,
      surfaceContainerHighest: PhoenixColors.darkSurfaceVariant,
      onSurfaceVariant: PhoenixColors.darkTextSecondary,
      error: PhoenixColors.error,
      onError: PhoenixColors.onPrimary,
      outline: PhoenixColors.darkBorder,
      outlineVariant: PhoenixColors.darkBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: PhoenixColors.darkBackground,
      textTheme: PhoenixTypography.toMaterialTextTheme().apply(
            bodyColor: PhoenixColors.darkTextPrimary,
            displayColor: PhoenixColors.darkTextPrimary,
          ),

      cardTheme: CardThemeData(
        color: PhoenixColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: PhoenixColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: PhoenixRadius.xlRadius,
        ),
        clipBehavior: Clip.antiAlias,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PhoenixColors.primary,
          foregroundColor: PhoenixColors.onPrimary,
          disabledBackgroundColor: PhoenixColors.darkTextDisabled,
          disabledForegroundColor: PhoenixColors.darkTextSecondary,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: PhoenixSpacing.xl,
            vertical: PhoenixSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: PhoenixRadius.mdRadius,
          ),
          textStyle: PhoenixTypography.label,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PhoenixColors.darkTextPrimary,
          disabledForegroundColor: PhoenixColors.darkTextDisabled,
          side: BorderSide(color: PhoenixColors.darkTextPrimary),
          padding: EdgeInsets.symmetric(
            horizontal: PhoenixSpacing.xl,
            vertical: PhoenixSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: PhoenixRadius.mdRadius,
          ),
          textStyle: PhoenixTypography.label,
        ),
      ),

      dividerTheme: const DividerThemeData(
        space: PhoenixSpacing.sm,
        thickness: 1,
        color: PhoenixColors.darkBorder,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: PhoenixColors.darkBackground,
        foregroundColor: PhoenixColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: PhoenixTypography.h3.copyWith(
          color: PhoenixColors.darkTextPrimary,
        ),
      ),
    );
  }
}
