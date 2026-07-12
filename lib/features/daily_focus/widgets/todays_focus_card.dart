import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../../theme/spacing.dart';

class TodaysFocusCard extends StatelessWidget {
  const TodaysFocusCard({
    super.key,
    required this.title,
    required this.description,
    required this.estimatedDuration,
    required this.actionLabel,
    this.priority,
    this.onStart,
  });

  final String title;
  final String description;
  final int estimatedDuration;
  final String actionLabel;
  final String? priority;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color accentColor = switch (priority?.toLowerCase()) {
      'critical' => theme.colorScheme.error,
      'high' => theme.colorScheme.tertiary,
      _ => theme.colorScheme.primary,
    };

    return PhoenixCard(
      color: accentColor.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.bolt_outlined, size: 24, color: accentColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Focus",
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$estimatedDuration min',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Icon(Icons.trending_up_outlined, size: 16, color: accentColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                priority ?? 'High impact',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (onStart != null) ...[
            const SizedBox(height: AppSpacing.lg),
            PhoenixPrimaryButton(
              onPressed: onStart!,
              label: actionLabel,
              icon: Icons.play_arrow_outlined,
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
  }
}
