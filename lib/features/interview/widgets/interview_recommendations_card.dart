import 'package:flutter/material.dart';

import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../intelligence/models/interview_enums.dart';
import '../intelligence/models/interview_recommendation.dart';

/// Displays intelligent interview preparation recommendations.
class InterviewRecommendationsCard extends StatelessWidget {
  const InterviewRecommendationsCard({
    super.key,
    required this.recommendations,
    required this.onAction,
  });

  final List<InterviewRecommendation> recommendations;
  final void Function(InterviewRecommendation rec) onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: PhoenixRadius.xlRadius,
        border: Border.all(
          color: PhoenixColors.primary.withAlpha(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PhoenixColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 20,
                  color: PhoenixColors.primary,
                ),
              ),
              const SizedBox(width: PhoenixSpacing.sm),
              Text(
                'Recommendations',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${recommendations.length} items',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: PhoenixSpacing.md),
          ...recommendations.take(5).map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: PhoenixSpacing.sm),
            child: _RecommendationTile(
              recommendation: rec,
              theme: theme,
              onTap: () => onAction(rec),
            ),
          )),
        ],
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({
    required this.recommendation,
    required this.theme,
    required this.onTap,
  });

  final InterviewRecommendation recommendation;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final actionColor = _actionColor(recommendation.actionType);
    final impactPct = (recommendation.impact * 100).round();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(PhoenixSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withAlpha(50),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: actionColor.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _actionIcon(recommendation.actionType),
                size: 16,
                color: actionColor,
              ),
            ),
            const SizedBox(width: PhoenixSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    recommendation.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recommendation.estimatedMinutes} min',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: PhoenixSpacing.md),
                      Icon(
                        Icons.trending_up_rounded,
                        size: 12,
                        color: PhoenixColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+$impactPct% impact',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: PhoenixColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Color _actionColor(InterviewActionType type) {
    switch (type) {
      case InterviewActionType.practice:
      case InterviewActionType.retryPractice:
        return PhoenixColors.primary;
      case InterviewActionType.study:
      case InterviewActionType.learnSkill:
        return PhoenixColors.info;
      case InterviewActionType.reviewResume:
        return PhoenixColors.success;
      case InterviewActionType.improvePortfolio:
        return PhoenixColors.warning;
      case InterviewActionType.completeMission:
        return PhoenixColors.success;
      case InterviewActionType.takeAssessment:
        return PhoenixColors.info;
      case InterviewActionType.watchTutorial:
        return PhoenixColors.warning;
      case InterviewActionType.readArticle:
        return PhoenixColors.textSecondary;
    }
  }

  IconData _actionIcon(InterviewActionType type) {
    switch (type) {
      case InterviewActionType.practice:
      case InterviewActionType.retryPractice:
        return Icons.mic_outlined;
      case InterviewActionType.study:
        return Icons.menu_book_outlined;
      case InterviewActionType.learnSkill:
        return Icons.psychology_outlined;
      case InterviewActionType.reviewResume:
        return Icons.description_outlined;
      case InterviewActionType.improvePortfolio:
        return Icons.folder_outlined;
      case InterviewActionType.completeMission:
        return Icons.rocket_launch_outlined;
      case InterviewActionType.takeAssessment:
        return Icons.quiz_outlined;
      case InterviewActionType.watchTutorial:
        return Icons.ondemand_video_outlined;
      case InterviewActionType.readArticle:
        return Icons.article_outlined;
    }
  }
}
