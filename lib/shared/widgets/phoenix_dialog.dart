import 'package:flutter/material.dart';

import '../../core/design/theme/phoenix_colors.dart';
import '../../core/design/theme/phoenix_spacing.dart';

/// PhoenixDialog — shared dialog and snackbar utilities.
///
/// Standardizes confirmation dialogs, snackbars, bottom sheets, and
/// alerts across the entire application. One source of truth for
/// Phoenix UX patterns.
class PhoenixDialog {
  PhoenixDialog._();

  // ── Confirmation ─────────────────────────────────────────────────

  /// Shows a confirmation dialog with cancel and confirm buttons.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    Color? confirmColor,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: confirmColor ?? PhoenixColors.primary),
              const SizedBox(width: PhoenixSpacing.sm),
            ],
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: confirmColor != null
                ? FilledButton.styleFrom(backgroundColor: confirmColor)
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Shows a delete confirmation dialog with warning styling.
  static Future<bool> confirmDelete(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Delete',
  }) {
    return confirm(
      context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      confirmColor: PhoenixColors.error,
      icon: Icons.warning_rounded,
    );
  }

  /// Shows a simple info dialog.
  static Future<void> info(
    BuildContext context, {
    required String title,
    required String message,
    String buttonLabel = 'Got it',
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }

  // ── SnackBars ────────────────────────────────────────────────────

  /// Shows a floating success snackbar.
  static void success(BuildContext context, String message) {
    _showSnackBar(context, message, PhoenixColors.success, Icons.check_circle_rounded);
  }

  /// Shows a floating warning snackbar.
  static void warning(BuildContext context, String message) {
    _showSnackBar(context, message, PhoenixColors.warning, Icons.warning_rounded);
  }

  /// Shows a floating error snackbar.
  static void error(BuildContext context, String message) {
    _showSnackBar(context, message, PhoenixColors.error, Icons.error_rounded);
  }

  /// Shows a floating info snackbar.
  static void infoSnack(BuildContext context, String message) {
    _showSnackBar(context, message, PhoenixColors.primary, Icons.info_outline_rounded);
  }

  static void _showSnackBar(
      BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: PhoenixSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(PhoenixSpacing.md),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Bottom Sheets ────────────────────────────────────────────────

  /// Shows a modal bottom sheet with the given content.
  static Future<T?> sheet<T>(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              PhoenixSpacing.lg, PhoenixSpacing.sm, PhoenixSpacing.lg, PhoenixSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: PhoenixSpacing.md),
              Text(title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: PhoenixSpacing.md),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
