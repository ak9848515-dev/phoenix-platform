import 'package:flutter/material.dart';

import '../theme/phoenix_colors.dart';
import '../theme/phoenix_radius.dart';
import '../theme/phoenix_spacing.dart';
import '../theme/phoenix_typography.dart';

/// A premium secondary (outlined) action button for the Phoenix Design System.
///
/// Supports:
/// - Outlined style (primary border + text)
/// - Disabled state
/// - Optional leading icon
/// - Full-width mode
class PhoenixSecondaryButton extends StatelessWidget {
  const PhoenixSecondaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.fullWidth = false,
    this.isDisabled = false,
  });

  /// Callback when the button is pressed. If null the button is disabled.
  final VoidCallback? onPressed;

  /// The button label.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether the button stretches to full width.
  final bool fullWidth;

  /// Whether the button is disabled (overrides [onPressed]).
  final bool isDisabled;

  bool get _isEffectivelyDisabled => isDisabled || onPressed == null;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: _isEffectivelyDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: PhoenixColors.primary,
        disabledForegroundColor: PhoenixColors.textDisabled,
        side: BorderSide(
          color: _isEffectivelyDisabled
              ? PhoenixColors.border
              : PhoenixColors.primary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: PhoenixSpacing.xl,
          vertical: PhoenixSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: PhoenixRadius.mdRadius,
        ),
        textStyle: PhoenixTypography.label,
      ),
      child: _buildChild(),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildChild() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: PhoenixSpacing.sm),
          Text(label),
        ],
      );
    }

    return Text(label);
  }
}
