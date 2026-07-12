import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_indicator.dart';
import '../../../theme/spacing.dart';
import '../models/recommendation.dart';

/// Displays learning-type recommendations with progress indicators.
class RecommendedLearningCard extends StatelessWidget {
  const RecommendedLearningCard({super.key, required this.learningItems});

  /// Learning-type recommendations to display.
  final List<Recommendation> learningItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (learningItems.isEmpty) return const SizedBox.shrink();

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.school_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Recommended Learning', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...learningItems.map(
            (item) =>
                _LearningItem(item: item, isLast: learningItems.last == item),
          ),
        ],
      ),
    );
  }
}

/// A single learning recommendation item with a progress bar.
class _LearningItem extends StatelessWidget {
  const _LearningItem({required this.item, required this.isLast});

  final Recommendation item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  item.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                item.actionLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Icon(
                Icons.timer_outlined,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${item.estimatedDuration} min',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (item.relatedSkill != null) ...[
                const SizedBox(width: AppSpacing.md),
                Icon(
                  Icons.psychology_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    item.relatedSkill!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          PhoenixProgressIndicator(
            value: _progressValue(item.priority),
            minHeight: 4,
            valueColor: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          ),
        ],
      ),
    );
  }

  double _progressValue(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.critical:
        return 0.8;
      case RecommendationPriority.high:
        return 0.6;
      case RecommendationPriority.medium:
        return 0.4;
      case RecommendationPriority.low:
        return 0.2;
    }
  }
}
