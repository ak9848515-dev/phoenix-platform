import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_indicator.dart';

/// Displays overall readiness and best match scores.
class ReadinessMatchCard extends StatelessWidget {
  const ReadinessMatchCard({
    super.key,
    required this.overallReadiness,
    required this.bestMatchScore,
    required this.estimatedTimeline,
  });

  final double overallReadiness;
  final double bestMatchScore;
  final String estimatedTimeline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.speed_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Readiness & Match', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Readiness',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    PhoenixProgressIndicator(
                      value: overallReadiness,
                      minHeight: 8,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${(overallReadiness * 100).round()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Best Match',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    PhoenixProgressIndicator(
                      value: bestMatchScore,
                      minHeight: 8,
                      valueColor: Colors.green,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${(bestMatchScore * 100).round()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Estimated timeline: $estimatedTimeline',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
