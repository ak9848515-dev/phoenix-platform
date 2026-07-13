import 'package:flutter/material.dart';

import '../../core/design/theme/phoenix_colors.dart';
import '../../core/design/theme/phoenix_radius.dart';
import '../../core/design/theme/phoenix_spacing.dart';
import '../../core/design/theme/phoenix_typography.dart';

/// A premium primary action button for the Phoenix Platform.
///
/// Uses the Phoenix Design System tokens for consistent styling.
class PhoenixPrimaryButton extends StatelessWidget {
  const PhoenixPrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.fullWidth = false,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: PhoenixSpacing.sm),
        ],
        Text(label),
      ],
    );

    final content = fullWidth
        ? SizedBox(
            width: double.infinity,
            child: Center(child: buttonChild),
          )
        : buttonChild;

    return ElevatedButton(
      onPressed: onPressed,
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
      child: content,
    );
  }
}
