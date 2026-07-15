import 'package:flutter/material.dart';

import '../../theme/spacing.dart';

/// A meaningful empty state display for the Phoenix Platform.
///
/// Every empty state includes:
/// 1. Friendly illustration icon
/// 2. Clear explanation of why this area is empty
/// 3. Positive message to motivate the user
/// 4. Primary action CTA
/// 5. Optional secondary action CTA
///
/// An empty screen should never feel like a dead end.
class PhoenixEmptyState extends StatelessWidget {
  const PhoenixEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.positiveMessage,
    this.primaryAction,
    this.secondaryAction,
  });

  /// The icon representing this empty area.
  final IconData icon;

  /// Short title explaining the empty state.
  final String title;

  /// Detailed explanation of why this area is empty.
  final String message;

  /// Optional positive/encouraging message (e.g. "Your journey starts here").
  final String? positiveMessage;

  /// Primary call-to-action widget (e.g. a button to start/fill the area).
  final Widget? primaryAction;

  /// Optional secondary call-to-action widget (e.g. "Learn More" button).
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Friendly illustration (decorative)
            Semantics(
              excludeSemantics: true,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer
                      .withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 2. Clear title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            // 3. Explanation
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            // 4. Positive message
            if (positiveMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                positiveMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // 5. Primary action
            if (primaryAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              primaryAction!,
            ],

            // 6. Secondary action
            if (secondaryAction != null) ...[
              const SizedBox(height: AppSpacing.sm),
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
class InlineEmptyState extends StatelessWidget {
  const InlineEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.positiveMessage,
    this.primaryAction,
    this.secondaryAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? positiveMessage;
  final Widget? primaryAction;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Semantics(
          excludeSemantics: true,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer
                  .withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          message,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        if (positiveMessage != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            positiveMessage!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (primaryAction != null) ...[
          const SizedBox(height: AppSpacing.md),
          primaryAction!,
        ],
      ],
    );
  }
}
