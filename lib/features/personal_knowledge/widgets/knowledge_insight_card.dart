import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/knowledge_insight.dart';

/// A card displaying a knowledge insight with type icon,
/// title, description, and relevance indicator.
class KnowledgeInsightCard extends StatelessWidget {
  const KnowledgeInsightCard({
    super.key,
    required this.insight,
    this.onTap,
  });

  final KnowledgeInsight insight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconData = _insightIcon(insight.type);
    final color = _insightColor(insight.type);

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
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, size: 18, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          insight.title,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (insight.actionable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ACTION',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (insight.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      insight.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: insight.relevance,
                      backgroundColor: color.withValues(alpha: 0.1),
                      color: color,
                      minHeight: 3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _insightIcon(KnowledgeInsightType type) {
    switch (type) {
      case KnowledgeInsightType.skillGap:
        return Icons.broken_image_rounded;
      case KnowledgeInsightType.strength:
        return Icons.auto_awesome_rounded;
      case KnowledgeInsightType.learningOpportunity:
        return Icons.lightbulb_rounded;
      case KnowledgeInsightType.goalConflict:
        return Icons.warning_amber_rounded;
      case KnowledgeInsightType.pattern:
        return Icons.timeline_rounded;
      case KnowledgeInsightType.coverage:
        return Icons.grid_view_rounded;
      case KnowledgeInsightType.cluster:
        return Icons.bubble_chart_rounded;
      case KnowledgeInsightType.recommendation:
        return Icons.thumb_up_rounded;
      case KnowledgeInsightType.custom:
        return Icons.extension_rounded;
    }
  }

  Color _insightColor(KnowledgeInsightType type) {
    switch (type) {
      case KnowledgeInsightType.skillGap:
        return AppColors.warning;
      case KnowledgeInsightType.strength:
        return AppColors.success;
      case KnowledgeInsightType.learningOpportunity:
        return AppColors.primary;
      case KnowledgeInsightType.goalConflict:
        return AppColors.error;
      case KnowledgeInsightType.pattern:
        return const Color(0xFF7C4DFF);
      case KnowledgeInsightType.coverage:
        return const Color(0xFF00BCD4);
      case KnowledgeInsightType.cluster:
        return const Color(0xFFFF6F00);
      case KnowledgeInsightType.recommendation:
        return AppColors.success;
      case KnowledgeInsightType.custom:
        return Colors.grey;
    }
  }
}
