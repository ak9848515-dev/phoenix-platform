import 'package:flutter/material.dart';

import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';

/// A reusable secondary action button used across all experience screens.
///
/// Displays an icon and label inside a rounded, tinted container.
/// Uses the Phoenix Design System tokens for consistent styling.
class ExperienceSecondaryButton extends StatelessWidget {
  const ExperienceSecondaryButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PhoenixColors.surfaceVariant,
      borderRadius: BorderRadius.circular(PhoenixRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PhoenixRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PhoenixSpacing.md,
            vertical: PhoenixSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: PhoenixColors.textSecondary),
              const SizedBox(width: PhoenixSpacing.sm),
              Text(
                label,
                style: PhoenixTypography.label.copyWith(
                  color: PhoenixColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
