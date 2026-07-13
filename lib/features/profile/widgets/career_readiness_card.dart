import 'package:flutter/material.dart';

import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_icons.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../core/design/widgets/phoenix_card.dart';
import '../../../core/design/widgets/phoenix_progress_bar.dart';
import '../../../core/design/widgets/phoenix_stat_tile.dart';

/// Displays the user's career readiness: interview readiness,
/// opportunity readiness, and a career recommendation.
///
/// Reads from [CareerService], [InterviewService], [RecommendationService].
/// Presentation-only — no business logic.
class CareerReadinessCard extends StatelessWidget {
  const CareerReadinessCard({
    super.key,
    required this.jobReadiness,
    required this.careerScore,
    required this.interviewReadiness,
    required this.estimatedWeeks,
    required this.nextGoal,
    this.opportunityReadiness,
    this.careerRecommendation,
    this.onViewCareer,
  });

  /// Job readiness label (e.g. "Building", "Nearly Ready").
  final String jobReadiness;

  /// Career score from 0.0 to 1.0.
  final double careerScore;

  /// Interview readiness from 0.0 to 1.0.
  final double interviewReadiness;

  /// Estimated weeks remaining.
  final int estimatedWeeks;

  /// The next recommended career goal.
  final String nextGoal;

  /// Opportunity match readiness score (0.0–1.0).
  final double? opportunityReadiness;

  /// Top career recommendation label.
  final String? careerRecommendation;

  /// Navigate to the career readiness screen.
  final VoidCallback? onViewCareer;

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 300),
      child: PhoenixCard(
        header: 'Career Readiness',
        action: onViewCareer != null
            ? TextButton(
                onPressed: onViewCareer,
                child: Text(
                  'Full Report',
                  style: PhoenixTypography.label.copyWith(
                    color: PhoenixColors.primary,
                  ),
                ),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Readiness Scores ───────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PhoenixStatTile(
                  icon: PhoenixIcons.career,
                  label: 'Career',
                  value: jobReadiness,
                  color: PhoenixColors.primary,
                ),
                _verticalDivider(),
                PhoenixStatTile(
                  icon: PhoenixIcons.interview,
                  label: 'Interview',
                  value: '${(interviewReadiness * 100).round()}%',
                  color: PhoenixColors.warning,
                ),
                _verticalDivider(),
                PhoenixStatTile(
                  icon: PhoenixIcons.time,
                  label: 'Timeline',
                  value: '$estimatedWeeks weeks',
                  color: PhoenixColors.textSecondary,
                ),
              ],
            ),
            SizedBox(height: PhoenixSpacing.lg),

            // ── Career Progress ────────────────────────────────────
            PhoenixProgressBar(
              value: careerScore,
              label: 'Career Readiness',
              showPercentage: true,
              minHeight: 6,
              animationDuration: const Duration(milliseconds: 800),
            ),
            // ── Opportunity Readiness ─────────────────────────────
            if (opportunityReadiness != null) ...[
              PhoenixProgressBar(
                value: opportunityReadiness!,
                label: 'Opportunity Readiness',
                showPercentage: true,
                minHeight: 6,
                progressColor: PhoenixColors.success,
                animationDuration: const Duration(milliseconds: 800),
              ),
              SizedBox(height: PhoenixSpacing.md),
            ],

            // ── Career Recommendation ──────────────────────────────
            if (careerRecommendation != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(PhoenixSpacing.md),
                decoration: BoxDecoration(
                  color: PhoenixColors.warningContainer(0.08),
                  borderRadius: BorderRadius.circular(PhoenixSpacing.sm),
                  border: Border.all(
                    color: PhoenixColors.warning.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      PhoenixIcons.lightbulb,
                      size: 18,
                      color: PhoenixColors.warning,
                    ),
                    SizedBox(width: PhoenixSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Career Recommendation',
                            style: PhoenixTypography.caption.copyWith(
                              color: PhoenixColors.warning,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            careerRecommendation!,
                            style: PhoenixTypography.label.copyWith(
                              color: PhoenixColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: PhoenixSpacing.md),
            ],

            // ── Next Goal ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(PhoenixSpacing.md),
              decoration: BoxDecoration(
                color: PhoenixColors.primaryContainer(0.08),
                borderRadius: BorderRadius.circular(PhoenixSpacing.sm),
                border: Border.all(
                  color: PhoenixColors.primary.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    PhoenixIcons.target,
                    size: 18,
                    color: PhoenixColors.primary,
                  ),
                  SizedBox(width: PhoenixSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next Goal',
                          style: PhoenixTypography.caption.copyWith(
                            color: PhoenixColors.textSecondary,
                          ),
                        ),
                        Text(
                          nextGoal,
                          style: PhoenixTypography.label.copyWith(
                            color: PhoenixColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 48,
      color: PhoenixColors.border,
    );
  }
}
