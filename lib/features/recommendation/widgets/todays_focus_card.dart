import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_indicator.dart';
import '../../../theme/spacing.dart';
import '../models/recommendation.dart';

/// Displays the single highest-priority recommendation as today's focus.
class TodaysFocusCard extends StatelessWidget {
  const TodaysFocusCard({super.key, required this.recommendation});

  /// The top-priority recommendation for today.
  final Recommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = _priorityColor(theme);

    return PhoenixCard(
      color: theme.colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.star_outlined,
                size: 20,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                "Today's Focus",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _priorityLabel(recommendation.priority),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: priorityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            recommendation.title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            recommendation.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(
                alpha: 0.8,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: theme.colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.7,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${recommendation.estimatedDuration} min',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Icon(
                _typeIcon(recommendation.type),
                size: 16,
                color: theme.colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.7,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _typeLabel(recommendation.type),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PhoenixProgressIndicator(
            value: _priorityProgress(recommendation.priority),
            minHeight: 4,
            valueColor: priorityColor,
            backgroundColor: priorityColor.withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(ThemeData theme) {
    switch (recommendation.priority) {
      case RecommendationPriority.critical:
        return Colors.red.shade400;
      case RecommendationPriority.high:
        return Colors.orange.shade400;
      case RecommendationPriority.medium:
        return theme.colorScheme.primary;
      case RecommendationPriority.low:
        return theme.colorScheme.secondary;
    }
  }

  double _priorityProgress(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.critical:
        return 1.0;
      case RecommendationPriority.high:
        return 0.75;
      case RecommendationPriority.medium:
        return 0.5;
      case RecommendationPriority.low:
        return 0.25;
    }
  }

  String _priorityLabel(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.critical:
        return 'Critical';
      case RecommendationPriority.high:
        return 'High';
      case RecommendationPriority.medium:
        return 'Medium';
      case RecommendationPriority.low:
        return 'Low';
    }
  }

  IconData _typeIcon(RecommendationType type) {
    switch (type) {
      case RecommendationType.mission:
        return Icons.rocket_launch_outlined;
      case RecommendationType.learning:
        return Icons.school_outlined;
      case RecommendationType.practice:
        return Icons.build_outlined;
      case RecommendationType.project:
        return Icons.folder_outlined;
      case RecommendationType.career:
        return Icons.work_outlined;
      case RecommendationType.business:
        return Icons.store_outlined;
      case RecommendationType.reflection:
        return Icons.auto_stories_outlined;
      case RecommendationType.review:
        return Icons.refresh_outlined;
    }
  }

  String _typeLabel(RecommendationType type) {
    switch (type) {
      case RecommendationType.mission:
        return 'Mission';
      case RecommendationType.learning:
        return 'Learning';
      case RecommendationType.practice:
        return 'Practice';
      case RecommendationType.project:
        return 'Project';
      case RecommendationType.career:
        return 'Career';
      case RecommendationType.business:
        return 'Business';
      case RecommendationType.reflection:
        return 'Reflection';
      case RecommendationType.review:
        return 'Review';
    }
  }
}
