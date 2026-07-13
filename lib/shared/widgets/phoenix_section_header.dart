import 'package:flutter/material.dart';

import '../../core/design/theme/phoenix_colors.dart';
import '../../core/design/theme/phoenix_spacing.dart';
import '../../core/design/theme/phoenix_typography.dart';

/// A section header for the Phoenix Platform.
///
/// Uses the Phoenix Design System tokens for consistent styling.
class PhoenixSectionHeader extends StatelessWidget {
  const PhoenixSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final Widget? actions;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: PhoenixTypography.h3),
                if (subtitle != null) ...[
                  const SizedBox(height: PhoenixSpacing.xs),
                  Text(
                    subtitle!,
                    style: PhoenixTypography.bodySmall.copyWith(
                      color: PhoenixColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) ...[
            const SizedBox(width: PhoenixSpacing.sm),
            actions!,
          ],
        ],
      ),
    );
  }
}
