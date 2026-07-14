import 'package:flutter/material.dart';

import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';

/// A premium permission dialog requesting microphone access.
///
/// Accessible — screen reader friendly, large tap targets.
class PermissionDialog extends StatelessWidget {
  const PermissionDialog({
    super.key,
    this.onGrant,
    this.onDeny,
    this.onDismiss,
  });

  /// Called when the user grants permission.
  final VoidCallback? onGrant;

  /// Called when the user denies permission.
  final VoidCallback? onDeny;

  /// Called when the dialog is dismissed.
  final VoidCallback? onDismiss;

  /// Shows the permission dialog as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onGrant,
    VoidCallback? onDeny,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PhoenixRadius.xl),
        ),
      ),
      builder: (_) => PermissionDialog(
        onGrant: onGrant,
        onDeny: onDeny,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Microphone permission dialog',
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
                color: PhoenixColors.primaryContainer(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mic_rounded,
                size: 32,
                color: PhoenixColors.primary,
              ),
            ),
            SizedBox(height: PhoenixSpacing.lg),

            // ── Title ───────────────────────────────────────────
            Text(
              'Microphone Access',
              style: PhoenixTypography.h3.copyWith(
                color: PhoenixColors.textPrimary,
              ),
            ),
            SizedBox(height: PhoenixSpacing.sm),

            // ── Description ─────────────────────────────────────
            Text(
              'Phoenix Voice uses the microphone to recognise your '
              'commands and provide spoken responses.',
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
                onGrant?.call();
                Navigator.of(context).pop();
              },
              label: 'Grant Access',
              icon: Icons.check_rounded,
              fullWidth: true,
            ),
            SizedBox(height: PhoenixSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  onDeny?.call();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Not Now',
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
