import 'package:flutter/material.dart';

import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_icons.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../shared/widgets/phoenix_card.dart';

/// A single growth metric item with percentage, trend indicator, and navigation.
class _GrowthItem extends StatelessWidget {
  const _GrowthItem({
    required this.icon,
    required this.label,
    required this.percentage,
    required this.trend,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final int percentage;
  final _TrendDirection trend;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final trendIcon = trend == _TrendDirection.improving
        ? Icons.trending_up_rounded
        : trend == _TrendDirection.declining
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;
    final trendColor = trend == _TrendDirection.improving
        ? PhoenixColors.success
        : trend == _TrendDirection.declining
            ? PhoenixColors.error
            : PhoenixColors.textSecondary;
    final trendLabel = trend == _TrendDirection.improving
        ? 'Improving'
        : trend == _TrendDirection.declining
            ? 'Declining'
            : 'Stable';

    return Semantics(
      label: '$label: $percentage% - $trendLabel',
      button: onTap != null,
      enabled: onTap != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(PhoenixSpacing.md),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 16, color: color),
                    ),
                    const Spacer(),
                    Icon(trendIcon, size: 16, color: trendColor),
                  ],
                ),
                const SizedBox(height: PhoenixSpacing.sm),
                Text(
                  '$percentage%',
                  style: PhoenixTypography.h3.copyWith(
                    color: PhoenixColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: PhoenixTypography.caption.copyWith(
                    color: PhoenixColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(trendIcon, size: 10, color: trendColor),
                    const SizedBox(width: 4),
                    Text(
                      trendLabel,
                      style: PhoenixTypography.caption.copyWith(
                        color: trendColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _TrendDirection { improving, stable, declining }

_TrendDirection _computeTrend(double score) {
  if (score >= 0.6) return _TrendDirection.improving;
  if (score >= 0.3) return _TrendDirection.stable;
  return _TrendDirection.declining;
}

/// Growth Snapshot card for the Phoenix Command Center.
class GrowthSnapshotCard extends StatelessWidget {
  const GrowthSnapshotCard({
    super.key,
    required this.knowledgeScore,
    required this.careerScore,
    required this.portfolioScore,
    required this.interviewReadiness,
    required this.habitCompletionRate,
    this.onKnowledgeTap,
    this.onCareerTap,
    this.onProjectsTap,
    this.onInterviewTap,
    this.onHabitsTap,
  });

  final double knowledgeScore;
  final double careerScore;
  final double portfolioScore;
  final double interviewReadiness;
  final double habitCompletionRate;
  final VoidCallback? onKnowledgeTap;
  final VoidCallback? onCareerTap;
  final VoidCallback? onProjectsTap;
  final VoidCallback? onInterviewTap;
  final VoidCallback? onHabitsTap;

  @override
  Widget build(BuildContext context) {
    return PhoenixCard(
      header: 'Growth Snapshot',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _GrowthItem(
                  icon: PhoenixIcons.knowledge,
                  label: 'Knowledge',
                  percentage: (knowledgeScore * 100).round(),
                  trend: _computeTrend(knowledgeScore),
                  color: PhoenixColors.primary,
                  onTap: onKnowledgeTap,
                ),
              ),
              const SizedBox(width: PhoenixSpacing.sm),
              Expanded(
                child: _GrowthItem(
                  icon: PhoenixIcons.career,
                  label: 'Career',
                  percentage: (careerScore * 100).round(),
                  trend: _computeTrend(careerScore),
                  color: PhoenixColors.warning,
                  onTap: onCareerTap,
                ),
              ),
              const SizedBox(width: PhoenixSpacing.sm),
              Expanded(
                child: _GrowthItem(
                  icon: PhoenixIcons.launch,
                  label: 'Projects',
                  percentage: (portfolioScore * 100).round(),
                  trend: _computeTrend(portfolioScore),
                  color: PhoenixColors.primary,
                  onTap: onProjectsTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: PhoenixSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _GrowthItem(
                  icon: PhoenixIcons.interview,
                  label: 'Interview',
                  percentage: (interviewReadiness * 100).round(),
                  trend: _computeTrend(interviewReadiness),
                  color: PhoenixColors.warning,
                  onTap: onInterviewTap,
                ),
              ),
              const SizedBox(width: PhoenixSpacing.sm),
              Expanded(
                child: _GrowthItem(
                  icon: PhoenixIcons.streak,
                  label: 'Habits',
                  percentage: (habitCompletionRate * 100).round(),
                  trend: _computeTrend(habitCompletionRate),
                  color: PhoenixColors.success,
                  onTap: onHabitsTap,
                ),
              ),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ],
      ),
    );
  }
}
