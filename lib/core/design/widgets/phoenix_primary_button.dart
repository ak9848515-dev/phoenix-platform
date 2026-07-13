import 'package:flutter/material.dart';

import '../theme/phoenix_colors.dart';
import '../theme/phoenix_radius.dart';
import '../theme/phoenix_spacing.dart';
import '../theme/phoenix_typography.dart';

/// A premium primary action button for the Phoenix Design System.
///
/// Supports:
/// - Filled style (primary color)
/// - Disabled state
/// - Loading state (shows a [CircularProgressIndicator])
/// - Optional leading icon
/// - Full-width mode
class PhoenixPrimaryButton extends StatelessWidget {
  const PhoenixPrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.fullWidth = false,
    this.isLoading = false,
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

  /// Whether to show a loading spinner.
  final bool isLoading;

  /// Whether the button is disabled (overrides [onPressed]).
  final bool isDisabled;

  bool get _isEffectivelyDisabled => isDisabled || isLoading || onPressed == null;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: _isEffectivelyDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: PhoenixColors.primary,
        foregroundColor: PhoenixColors.onPrimary,
        disabledBackgroundColor: PhoenixColors.textDisabled,
        disabledForegroundColor: PhoenixColors.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: PhoenixSpacing.xl,
          vertical: PhoenixSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: PhoenixRadius.mdRadius,
        ),
        textStyle: PhoenixTypography.label.copyWith(
          color: PhoenixColors.onPrimary,
        ),
      ),
      child: _buildChild(),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(PhoenixColors.onPrimary),
        ),
      );
    }

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
