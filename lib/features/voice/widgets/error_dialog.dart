import 'package:flutter/material.dart';

import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../core/design/widgets/phoenix_primary_button.dart';

/// A premium error dialog for voice-related errors.
///
/// Displays the error message with a retry option.
/// Accessible — screen reader friendly, large tap targets.
class VoiceErrorDialog extends StatelessWidget {
  const VoiceErrorDialog({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
  });

  /// The error message to display.
  final String message;

  /// Called when the user taps Retry.
  final VoidCallback? onRetry;

  /// Called when the dialog is dismissed.
  final VoidCallback? onDismiss;

  /// Shows the error dialog as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PhoenixRadius.xl),
        ),
      ),
      builder: (_) => VoiceErrorDialog(
        message: message,
        onRetry: onRetry,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Voice error dialog',
      child: Padding(
        padding: const EdgeInsets.all(PhoenixSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Handle ──────────────────────────────────────────
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PhoenixColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: PhoenixSpacing.xl),

            // ── Icon ────────────────────────────────────────────
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: PhoenixColors.errorContainer(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: PhoenixColors.error,
              ),
            ),
            SizedBox(height: PhoenixSpacing.lg),

            // ── Title ───────────────────────────────────────────
            Text(
              'Voice Error',
              style: PhoenixTypography.h3.copyWith(
                color: PhoenixColors.textPrimary,
              ),
            ),
            SizedBox(height: PhoenixSpacing.sm),

            // ── Message ─────────────────────────────────────────
            Text(
              message,
              textAlign: TextAlign.center,
              style: PhoenixTypography.bodySmall.copyWith(
                color: PhoenixColors.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: PhoenixSpacing.xl),

            // ── Actions ─────────────────────────────────────────
            PhoenixPrimaryButton(
              onPressed: () {
                onRetry?.call();
                Navigator.of(context).pop();
              },
              label: 'Try Again',
              icon: Icons.refresh_rounded,
              fullWidth: true,
            ),
            SizedBox(height: PhoenixSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  onDismiss?.call();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Dismiss',
                  style: PhoenixTypography.label.copyWith(
                    color: PhoenixColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
