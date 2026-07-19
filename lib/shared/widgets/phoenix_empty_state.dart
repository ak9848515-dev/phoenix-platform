import 'package:flutter/material.dart';

import '../../core/design/theme/phoenix_colors.dart';
import '../../core/design/theme/phoenix_radius.dart';
import '../../core/design/theme/phoenix_spacing.dart';

/// A meaningful empty state display for the Phoenix Platform.
///
/// Every empty state includes:
/// 1. Friendly illustration icon with gradient background
/// 2. Clear explanation of why this area is empty
/// 3. Positive message to motivate the user
/// 4. Primary action CTA
/// 5. Optional secondary action CTA
///
/// An empty screen should never feel like a dead end.
/// Uses the Phoenix Design System for premium, consistent styling.
class PhoenixEmptyState extends StatelessWidget {
  const PhoenixEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.positiveMessage,
    this.primaryAction,
    this.secondaryAction,
    this.iconColor,
  });

  /// The icon representing this empty area.
  final IconData icon;

  /// Short title explaining the empty state.
  final String title;

  /// Detailed explanation of why this area is empty.
  final String message;

  /// Optional positive/encouraging message.
  final String? positiveMessage;

  /// Primary call-to-action widget.
  final Widget? primaryAction;

  /// Optional secondary call-to-action widget.
  final Widget? secondaryAction;

  /// Optional icon color override. Defaults to [PhoenixColors.primary].
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? PhoenixColors.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PhoenixSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Friendly illustration with gradient background
            Semantics(
              excludeSemantics: true,
              child: Container(
                padding: const EdgeInsets.all(PhoenixSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.12),
                      color.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: PhoenixRadius.xlRadius,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: PhoenixSpacing.xl),

            // 2. Clear title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: PhoenixSpacing.sm),

            // 3. Explanation
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            // 4. Positive message
            if (positiveMessage != null) ...[
              const SizedBox(height: PhoenixSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PhoenixSpacing.md,
                  vertical: PhoenixSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.06),
                  borderRadius: PhoenixRadius.smRadius,
                ),
                child: Text(
                  positiveMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            // 5. Primary action (with animation support)
            if (primaryAction != null) ...[
              const SizedBox(height: PhoenixSpacing.xl),
              primaryAction!,
            ],

            // 6. Secondary action
            if (secondaryAction != null) ...[
              const SizedBox(height: PhoenixSpacing.sm),
              secondaryAction!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A compact inline empty state suitable for embedding inside cards.
///
/// Same visual pattern as [PhoenixEmptyState] but without the outer
/// centering and padding — designed to sit inside a card's padding.
/// Uses the Phoenix Design System tokens.
class InlineEmptyState extends StatelessWidget {
  const InlineEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.positiveMessage,
    this.primaryAction,
    this.secondaryAction,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? positiveMessage;
  final Widget? primaryAction;
  final Widget? secondaryAction;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? PhoenixColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Semantics(
          excludeSemantics: true,
          child: Container(
            padding: const EdgeInsets.all(PhoenixSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.12),
                  color.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: PhoenixRadius.mdRadius,
            ),
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: PhoenixSpacing.md),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PhoenixSpacing.xs),
        Text(
          message,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        if (positiveMessage != null) ...[
          const SizedBox(height: PhoenixSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PhoenixSpacing.sm,
              vertical: PhoenixSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: PhoenixRadius.smRadius,
            ),
            child: Text(
              positiveMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        if (primaryAction != null) ...[
          const SizedBox(height: PhoenixSpacing.lg),
          primaryAction!,
        ],
      ],
    );
  }
}
