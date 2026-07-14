import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/knowledge_recommendation.dart';

/// A card displaying a knowledge recommendation with
/// type icon, priority indicator, and action prompt.
class KnowledgeRecommendationCard extends StatelessWidget {
  const KnowledgeRecommendationCard({
    super.key,
    required this.recommendation,
    this.onTap,
  });

  final KnowledgeRecommendation recommendation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = _priorityColor(recommendation.priority);
    final iconData = _typeIcon(recommendation.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant
                .withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, size: 18, color: priorityColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          recommendation.priority.name.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: priorityColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          recommendation.type.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recommendation.title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (recommendation.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      recommendation.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _priorityColor(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.high:
        return AppColors.error;
      case RecommendationPriority.medium:
        return AppColors.warning;
      case RecommendationPriority.low:
        return AppColors.success;
    }
  }

  IconData _typeIcon(KnowledgeRecommendationType type) {
    switch (type) {
      case KnowledgeRecommendationType.skillGap:
        return Icons.broken_image_rounded;
      case KnowledgeRecommendationType.nextAction:
        return Icons.north_east_rounded;
      case KnowledgeRecommendationType.learningPath:
        return Icons.route_rounded;
      case KnowledgeRecommendationType.careerMove:
        return Icons.trending_up_rounded;
      case KnowledgeRecommendationType.projectIdea:
        return Icons.lightbulb_rounded;
      case KnowledgeRecommendationType.mentorship:
        return Icons.group_rounded;
      case KnowledgeRecommendationType.resource:
        return Icons.book_rounded;
      case KnowledgeRecommendationType.milestone:
        return Icons.emoji_events_rounded;
      case KnowledgeRecommendationType.custom:
        return Icons.extension_rounded;
    }
  }
}
