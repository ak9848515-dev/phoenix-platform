import 'package:flutter/material.dart';

import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../core/design/widgets/phoenix_badge.dart';
import '../../../core/design/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_bar.dart';

/// Displays the user's Knowledge DNA summary with top skills,
/// skill categories, learning progress, and strongest competencies.
///
/// Reads from [KnowledgeDNAService.buildAnalysis()].
/// Presentation-only — no business logic.
class KnowledgeSkillsCard extends StatelessWidget {
  const KnowledgeSkillsCard({
    super.key,
    required this.knowledgeScore,
    required this.confidenceScore,
    required this.retentionScore,
    required this.skillStrengths,
    required this.skillWeaknesses,
    required this.summary,
  });

  /// Overall knowledge score from 0.0 to 1.0.
  final double knowledgeScore;

  /// Confidence score from 0.0 to 1.0.
  final double confidenceScore;

  /// Retention score from 0.0 to 1.0.
  final double retentionScore;

  /// Top skill strengths.
  final List<String> skillStrengths;

  /// Areas needing improvement.
  final List<String> skillWeaknesses;

  /// Summary label text.
  final String summary;

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 150),
      child: PhoenixCard(
        header: 'Knowledge & Skills',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Core Scores ────────────────────────────────────────
            Row(
              children: [
                _ScoreChip(
                  label: 'Knowledge',
                  value: knowledgeScore,
                  color: PhoenixColors.primary,
                ),
                SizedBox(width: PhoenixSpacing.sm),
                _ScoreChip(
                  label: 'Confidence',
                  value: confidenceScore,
                  color: PhoenixColors.success,
                ),
                SizedBox(width: PhoenixSpacing.sm),
                _ScoreChip(
                  label: 'Retention',
                  value: retentionScore,
                  color: PhoenixColors.warning,
                ),
              ],
            ),
            SizedBox(height: PhoenixSpacing.lg),

            // ── Knowledge Progress ────────────────────────────────
            PhoenixProgressBar(
              value: knowledgeScore,
              label: 'Knowledge Readiness',
              showPercentage: true,
              minHeight: 6,
              animationDuration: const Duration(milliseconds: 800),
            ),
            SizedBox(height: PhoenixSpacing.lg),

            // ── Strengths ──────────────────────────────────────────
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
                children: skillStrengths.map((strength) {
                  return PhoenixBadge(
                    label: strength,
                    variant: BadgeVariant.success,
                    isSmall: true,
                  );
                }).toList(),
              ),
              SizedBox(height: PhoenixSpacing.md),
            ],

            // ── Areas to Improve ──────────────────────────────────
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
                children: skillWeaknesses.map((weakness) {
                  return PhoenixBadge(
                    label: weakness,
                    variant: BadgeVariant.neutral,
                    isSmall: true,
                  );
                }).toList(),
              ),
            ],

            if (skillStrengths.isEmpty && skillWeaknesses.isEmpty) ...[
              Text(
                summary,
                style: PhoenixTypography.bodySmall.copyWith(
                  color: PhoenixColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A compact circular score indicator.
class _ScoreChip extends StatelessWidget {
  const _ScoreChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: PhoenixSpacing.sm,
          horizontal: PhoenixSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(PhoenixSpacing.sm),
        ),
        child: Column(
          children: [
            Text(
              '$percent%',
              style: PhoenixTypography.label.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: PhoenixTypography.caption.copyWith(
                color: PhoenixColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
