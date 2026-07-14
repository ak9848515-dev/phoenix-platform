import 'package:flutter/material.dart';

import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_icons.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_bar.dart';
import '../../../core/design/widgets/phoenix_stat_tile.dart';

/// Displays a comprehensive guidance summary built from all existing
/// platform services.
///
/// Presentation-only — no business logic.
class TodaysGuidanceCard extends StatelessWidget {
  const TodaysGuidanceCard({
    super.key,
    required this.missionSummary,
    required this.missionCompletion,
    required this.level,
    required this.totalXp,
    required this.streak,
    required this.overallProgress,
    required this.portfolioScore,
    required this.resumeScore,
    required this.careerScore,
    required this.jobReadiness,
  });

  final String missionSummary;
  final double missionCompletion;
  final int level;
  final int totalXp;
  final int streak;
  final double overallProgress;
  final double portfolioScore;
  final double resumeScore;
  final double careerScore;
  final String jobReadiness;

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 100),
      child: PhoenixCard(
        header: "Today's Guidance",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Key Stats ─────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PhoenixStatTile(
                  icon: PhoenixIcons.xp,
                  label: 'XP',
                  value: _formatXp(totalXp),
                  color: PhoenixColors.primary,
                ),
                _divider(),
                PhoenixStatTile(
                  icon: PhoenixIcons.level,
                  label: 'Level',
                  value: '$level',
                  color: PhoenixColors.primary,
                ),
                _divider(),
                PhoenixStatTile(
                  icon: PhoenixIcons.streak,
                  label: 'Streak',
                  value: '$streak days',
                  color: PhoenixColors.warning,
                ),
              ],
            ),
            SizedBox(height: PhoenixSpacing.md),

            // ── Mission Summary ───────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(PhoenixSpacing.md),
              decoration: BoxDecoration(
                color: PhoenixColors.surfaceVariant,
                borderRadius: BorderRadius.circular(PhoenixSpacing.sm),
              ),
              child: Row(
                children: [
                  Icon(
                    PhoenixIcons.mission,
                    size: 16,
                    color: PhoenixColors.primary,
                  ),
                  SizedBox(width: PhoenixSpacing.sm),
                  Expanded(
                    child: Text(
                      missionSummary,
                      style: PhoenixTypography.bodySmall.copyWith(
                        color: PhoenixColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: PhoenixSpacing.md),

            // ── Progress Bars ─────────────────────────────────────
            PhoenixProgressBar(
              value: overallProgress,
              label: 'Overall Progress',
              showPercentage: true,
              minHeight: 6,
            ),
            SizedBox(height: PhoenixSpacing.sm),
            PhoenixProgressBar(
              value: missionCompletion,
              label: 'Mission Completion',
              showPercentage: true,
              minHeight: 6,
              progressColor: PhoenixColors.success,
            ),
            SizedBox(height: PhoenixSpacing.md),

            // ── Readiness Row ─────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _ReadinessChip(
                    label: 'Portfolio',
                    score: portfolioScore,
                    color: PhoenixColors.primary,
                  ),
                ),
                SizedBox(width: PhoenixSpacing.sm),
                Expanded(
                  child: _ReadinessChip(
                    label: 'Resume',
                    score: resumeScore,
                    color: PhoenixColors.success,
                  ),
                ),
                SizedBox(width: PhoenixSpacing.sm),
                Expanded(
                  child: _ReadinessChip(
                    label: 'Career',
                    score: careerScore,
                    color: PhoenixColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 36, color: PhoenixColors.border);
  }

  String _formatXp(int xp) {
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k';
    return xp.toString();
  }
}

class _ReadinessChip extends StatelessWidget {
  const _ReadinessChip({
    required this.label,
    required this.score,
    required this.color,
  });

  final String label;
  final double score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percent = (score * 100).round();
    return Container(
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
          Text(
            label,
            style: PhoenixTypography.caption.copyWith(
              color: PhoenixColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
