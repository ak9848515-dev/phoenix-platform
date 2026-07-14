import 'package:flutter/material.dart';

import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_icons.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../core/design/widgets/phoenix_badge.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../recommendation/models/recommendation.dart';

/// Displays today's high-priority recommendation from the
/// Recommendation Service.
///
/// Only reads existing recommendations — no generation logic here.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onAction,
  });

  /// The recommendation to display.
  final Recommendation recommendation;

  /// Called when the user taps the action button.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final priorityBadge = _priorityBadge(recommendation.priority);
    final typeIcon = _typeIcon(recommendation.type);

    return PhoenixCard(
      header: "Today's Focus",
      action: priorityBadge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title & Type ─────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(PhoenixSpacing.sm),
                decoration: BoxDecoration(
                  color: PhoenixColors.primaryContainer(0.1),
                  borderRadius: BorderRadius.circular(PhoenixSpacing.sm),
                ),
                child: Icon(
                  typeIcon,
                  size: 20,
                  color: PhoenixColors.primary,
                ),
              ),
              SizedBox(width: PhoenixSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.title,
                      style: PhoenixTypography.h3.copyWith(
                        color: PhoenixColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: PhoenixSpacing.xs),
                    Text(
                      '${recommendation.estimatedDuration} min',
                      style: PhoenixTypography.caption.copyWith(
                        color: PhoenixColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: PhoenixSpacing.md),

          // ── Description ──────────────────────────────────────────
          Text(
            recommendation.description,
            style: PhoenixTypography.bodySmall.copyWith(
              color: PhoenixColors.textSecondary,
            ),
          ),
          SizedBox(height: PhoenixSpacing.md),

          // ── Reason ───────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(PhoenixSpacing.md),
            decoration: BoxDecoration(
              color: PhoenixColors.surfaceVariant,
              borderRadius: BorderRadius.circular(PhoenixSpacing.sm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  PhoenixIcons.lightbulb,
                  size: 16,
                  color: PhoenixColors.warning,
                ),
                SizedBox(width: PhoenixSpacing.sm),
                Expanded(
                  child: Text(
                    recommendation.reason,
                    style: PhoenixTypography.caption.copyWith(
                      color: PhoenixColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: PhoenixSpacing.lg),

          // ── Action Button ─────────────────────────────────────────
          if (onAction != null)
            PhoenixPrimaryButton(
              onPressed: onAction!,
              label: recommendation.actionLabel,
              fullWidth: true,
            ),
        ],
      ),
    );
  }

  Widget _priorityBadge(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.critical:
        return const PhoenixBadge(
          label: 'Critical',
          variant: BadgeVariant.error,
          isSmall: true,
        );
      case RecommendationPriority.high:
        return const PhoenixBadge(
          label: 'High Priority',
          variant: BadgeVariant.warning,
          isSmall: true,
        );
      case RecommendationPriority.medium:
        return const PhoenixBadge(
          label: 'Medium',
          variant: BadgeVariant.primary,
          isSmall: true,
        );
      case RecommendationPriority.low:
        return const PhoenixBadge(
          label: 'Optional',
          variant: BadgeVariant.neutral,
          isSmall: true,
        );
    }
  }

  IconData _typeIcon(RecommendationType type) {
    switch (type) {
      case RecommendationType.mission:
        return PhoenixIcons.mission;
      case RecommendationType.learning:
        return PhoenixIcons.lessons;
      case RecommendationType.practice:
        return PhoenixIcons.skills;
      case RecommendationType.project:
        return PhoenixIcons.launch;
      case RecommendationType.career:
        return PhoenixIcons.career;
      case RecommendationType.business:
        return PhoenixIcons.target;
      case RecommendationType.reflection:
        return PhoenixIcons.lightbulb;
      case RecommendationType.review:
        return PhoenixIcons.feedback;
    }
  }
}
