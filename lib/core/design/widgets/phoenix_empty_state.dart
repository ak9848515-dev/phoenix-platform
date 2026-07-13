import 'package:flutter/material.dart';

import '../theme/phoenix_colors.dart';
import '../theme/phoenix_spacing.dart';
import '../theme/phoenix_typography.dart';

/// A premium empty state display for the Phoenix Design System.
///
/// Used when lists are empty, search yields no results, or a feature
/// has no content yet.
///
/// Includes an optional icon, title, message, and action button.
class PhoenixEmptyState extends StatelessWidget {
  const PhoenixEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.action,
    this.padding = const EdgeInsets.all(PhoenixSpacing.xxl),
  });

  /// The title displayed prominently.
  final String title;

  /// The descriptive message below the title.
  final String message;

  /// Optional icon (displayed above the title).
  final IconData? icon;

  /// Optional action widget (e.g. a [PhoenixPrimaryButton]).
  final Widget? action;

  /// Padding around the entire empty state.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon!,
                size: 48,
                color: PhoenixColors.textDisabled,
              ),
              SizedBox(height: PhoenixSpacing.lg),
            ],
            Text(
              title,
              style: PhoenixTypography.h3.copyWith(
                color: PhoenixColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: PhoenixSpacing.sm),
            Text(
              message,
              style: PhoenixTypography.body.copyWith(
                color: PhoenixColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              SizedBox(height: PhoenixSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
