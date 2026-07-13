import 'package:flutter/material.dart';

import '../../core/design/theme/phoenix_colors.dart';
import '../../core/design/theme/phoenix_radius.dart';
import '../../core/design/theme/phoenix_spacing.dart';
import '../../core/design/theme/phoenix_typography.dart';

/// A premium empty state display for the Phoenix Platform.
///
/// Uses the Phoenix Design System tokens for consistent styling.
class PhoenixEmptyState extends StatelessWidget {
  const PhoenixEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.action,
  });

  final String title;
  final String message;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PhoenixSpacing.xl),
      decoration: BoxDecoration(
        color: PhoenixColors.surfaceVariant,
        borderRadius: PhoenixRadius.xlRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 40, color: PhoenixColors.primary),
            const SizedBox(height: PhoenixSpacing.md),
          ],
          Text(
            title,
            style: PhoenixTypography.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: PhoenixSpacing.sm),
          Text(
            message,
            style: PhoenixTypography.bodySmall.copyWith(
              color: PhoenixColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: PhoenixSpacing.md),
            action!,
          ],
        ],
      ),
    );
  }
}
