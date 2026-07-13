import 'package:flutter/material.dart';

import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_icons.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../core/design/widgets/phoenix_badge.dart';
import '../../../core/design/widgets/phoenix_card.dart';
import '../../../core/design/widgets/phoenix_primary_button.dart';
import '../../recommendation/models/recommendation.dart';

/// Displays the highest-priority recommendation with reason, expected
/// outcome, and an action button.
///
/// Consumes [RecommendationService] — no recommendation generation here.
class RecommendedActionCard extends StatelessWidget {
  const RecommendedActionCard({
    super.key,
    required this.recommendation,
    this.onAction,
  });

  /// The top recommendation to display.
  final Recommendation recommendation;

  /// Called when the action button is tapped.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final priorityBadge = _priorityBadge(recommendation.priority);

    return FadeAnimation(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 150),
      child: PhoenixCard(
        header: 'Recommended Next Action',
        action: priorityBadge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ─────────────────────────────────────────────
            Text(
              recommendation.title,
              style: PhoenixTypography.h3.copyWith(
                color: PhoenixColors.textPrimary,
              ),
            ),
            SizedBox(height: PhoenixSpacing.sm),

            // ── Description ───────────────────────────────────────
            Text(
              recommendation.description,
              style: PhoenixTypography.bodySmall.copyWith(
                color: PhoenixColors.textSecondary,
              ),
            ),
            SizedBox(height: PhoenixSpacing.md),

            // ── Reason + Outcome ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(PhoenixSpacing.md),
              decoration: BoxDecoration(
                color: PhoenixColors.primaryContainer(0.06),
                borderRadius: BorderRadius.circular(PhoenixSpacing.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhoenixIcons.lightbulb,
                        size: 14,
                        color: PhoenixColors.primary,
                      ),
                      SizedBox(width: PhoenixSpacing.sm),
                      Text(
                        'Why this matters',
                        style: PhoenixTypography.caption.copyWith(
                          color: PhoenixColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: PhoenixSpacing.xs),
                  Text(
                    recommendation.reason,
                    style: PhoenixTypography.caption.copyWith(
                      color: PhoenixColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: PhoenixSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        PhoenixIcons.time,
                        size: 14,
                        color: PhoenixColors.textSecondary,
                      ),
                      SizedBox(width: PhoenixSpacing.xs),
                      Text(
                        '${recommendation.estimatedDuration} min',
                        style: PhoenixTypography.caption.copyWith(
                          color: PhoenixColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: PhoenixSpacing.lg),

            // ── Action Button ────────────────────────────────────
            PhoenixPrimaryButton(
              onPressed: onAction ?? () {},
              label: recommendation.actionLabel,
              fullWidth: true,
            ),
          ],
        ),
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
}
