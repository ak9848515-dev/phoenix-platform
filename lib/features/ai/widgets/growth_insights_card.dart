import 'package:flutter/material.dart';

import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_icons.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../core/design/widgets/phoenix_badge.dart';
import '../../../core/design/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_bar.dart';

/// Displays growth insights across multiple dimensions.
///
/// Reads from existing services only — no business logic.
class GrowthInsightsCard extends StatelessWidget {
  const GrowthInsightsCard({
    super.key,
    required this.knowledgeScore,
    required this.skillStrengths,
    required this.skillWeaknesses,
    required this.portfolioScore,
    required this.resumeScore,
    required this.interviewReadiness,
    required this.careerScore,
    required this.jobReadiness,
  });

  final double knowledgeScore;
  final List<String> skillStrengths;
  final List<String> skillWeaknesses;
  final double portfolioScore;
  final double resumeScore;
  final double interviewReadiness;
  final double careerScore;
  final String jobReadiness;

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 200),
      child: PhoenixCard(
        header: 'Growth Insights',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Knowledge ─────────────────────────────────────────
            _InsightRow(
              icon: PhoenixIcons.knowledge,
              label: 'Knowledge DNA',
              value: knowledgeScore,
              color: PhoenixColors.primary,
            ),
            SizedBox(height: PhoenixSpacing.md),

            // ── Portfolio ─────────────────────────────────────────
            _InsightRow(
              icon: PhoenixIcons.profile,
              label: 'Portfolio',
              value: portfolioScore,
              color: PhoenixColors.primary,
            ),
            SizedBox(height: PhoenixSpacing.md),

            // ── Resume ────────────────────────────────────────────
            _InsightRow(
              icon: Icons.description_outlined,
              label: 'Resume',
              value: resumeScore,
              color: PhoenixColors.success,
            ),
            SizedBox(height: PhoenixSpacing.md),

            // ── Interview ─────────────────────────────────────────
            _InsightRow(
              icon: PhoenixIcons.interview,
              label: 'Interview Readiness',
              value: interviewReadiness,
              color: PhoenixColors.warning,
            ),
            SizedBox(height: PhoenixSpacing.md),

            // ── Career ────────────────────────────────────────────
            Row(
              children: [
                Icon(
                  PhoenixIcons.career,
                  size: 18,
                  color: PhoenixColors.career,
                ),
                SizedBox(width: PhoenixSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Career Readiness',
                            style: PhoenixTypography.caption.copyWith(
                              color: PhoenixColors.textSecondary,
                            ),
                          ),
                          PhoenixBadge(
                            label: jobReadiness,
                            variant: BadgeVariant.neutral,
                            isSmall: true,
                          ),
                        ],
                      ),
                      SizedBox(height: PhoenixSpacing.xs),
                      PhoenixProgressBar(
                        value: careerScore,
                        minHeight: 6,
                        progressColor: PhoenixColors.career,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: PhoenixSpacing.lg),

            // ── Strengths & Areas ─────────────────────────────────
            if (skillStrengths.isNotEmpty) ...[
              Text(
                'Strengths',
                style: PhoenixTypography.label.copyWith(
                  color: PhoenixColors.textSecondary,
                ),
              ),
              SizedBox(height: PhoenixSpacing.sm),
              Wrap(
                spacing: PhoenixSpacing.sm,
                runSpacing: PhoenixSpacing.sm,
                children: skillStrengths.map((s) {
                  return PhoenixBadge(
                    label: s,
                    variant: BadgeVariant.success,
                    isSmall: true,
                  );
                }).toList(),
              ),
            ],
            if (skillStrengths.isNotEmpty && skillWeaknesses.isNotEmpty)
              SizedBox(height: PhoenixSpacing.sm),
            if (skillWeaknesses.isNotEmpty) ...[
              Text(
                'Areas to Improve',
                style: PhoenixTypography.label.copyWith(
                  color: PhoenixColors.textSecondary,
                ),
              ),
              SizedBox(height: PhoenixSpacing.sm),
              Wrap(
                spacing: PhoenixSpacing.sm,
                runSpacing: PhoenixSpacing.sm,
                children: skillWeaknesses.map((w) {
                  return PhoenixBadge(
                    label: w,
                    variant: BadgeVariant.neutral,
                    isSmall: true,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        SizedBox(width: PhoenixSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: PhoenixTypography.caption.copyWith(
                      color: PhoenixColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${(value * 100).round()}%',
                    style: PhoenixTypography.caption.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: PhoenixSpacing.xs),
              PhoenixProgressBar(
                value: value,
                minHeight: 6,
                progressColor: color,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
