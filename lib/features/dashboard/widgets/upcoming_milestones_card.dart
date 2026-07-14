import 'package:flutter/material.dart';

import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_icons.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_bar.dart';
import '../../../core/design/widgets/phoenix_stat_tile.dart';
import '../../progress_engine/progress_engine.dart';

/// Displays upcoming achievement milestones from the Progress Engine.
///
/// Only reads existing [AchievementProgress] data — no calculation here.
class UpcomingMilestonesCard extends StatelessWidget {
  const UpcomingMilestonesCard({
    super.key,
    required this.achievements,
    required this.completedCount,
    required this.totalCount,
    this.onViewAll,
  });

  /// List of achievement progress items.
  final List<AchievementProgress> achievements;

  /// Number of completed missions.
  final int completedCount;

  /// Total number of missions.
  final int totalCount;

  /// Called when the user taps to view all milestones.
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final completedAchievements = achievements.where((a) => a.completed).length;
    final totalAchievements = achievements.length;

    return PhoenixCard(
      header: 'Upcoming Milestones',
      action: onViewAll != null
          ? TextButton(
              onPressed: onViewAll,
              child: Text(
                'View All',
                style: PhoenixTypography.label.copyWith(
                  color: PhoenixColors.primary,
                ),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary Stats Row ─────────────────────────────────────
          Row(
            children: [
              PhoenixStatTile(
                icon: PhoenixIcons.achievement,
                label: 'Unlocked',
                value: '$completedAchievements',
                color: PhoenixColors.gold,
                compact: true,
              ),
              SizedBox(width: PhoenixSpacing.xl),
              PhoenixStatTile(
                icon: PhoenixIcons.target,
                label: 'Total',
                value: '$totalAchievements',
                color: PhoenixColors.textSecondary,
                compact: true,
              ),
            ],
          ),
          SizedBox(height: PhoenixSpacing.lg),

          // ── Mission Progress ──────────────────────────────────────
          PhoenixProgressBar(
            value: totalCount > 0 ? completedCount / totalCount : 0,
            label: 'Mission Progress',
            showPercentage: true,
            minHeight: 6,
          ),
          SizedBox(height: PhoenixSpacing.lg),

          // ── Achievement List ──────────────────────────────────────
          if (achievements.isEmpty)
            Text(
              'Complete missions to unlock achievements.',
              style: PhoenixTypography.caption.copyWith(
                color: PhoenixColors.textDisabled,
              ),
            )
          else
            ...achievements.map((achievement) => _buildAchievementRow(
                  achievement,
                )),
        ],
      ),
    );
  }

  Widget _buildAchievementRow(AchievementProgress achievement) {
    final isCompleted = achievement.completed;

    return Padding(
      padding: EdgeInsets.only(bottom: PhoenixSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(PhoenixSpacing.xs),
            decoration: BoxDecoration(
              color: isCompleted
                  ? PhoenixColors.goldContainer(0.1)
                  : PhoenixColors.surfaceVariant,
              borderRadius: BorderRadius.circular(PhoenixSpacing.sm),
            ),
            child: Icon(
              isCompleted ? PhoenixIcons.trophy : PhoenixIcons.starBorder,
              size: 18,
              color: isCompleted ? PhoenixColors.gold : PhoenixColors.textDisabled,
            ),
          ),
          SizedBox(width: PhoenixSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: PhoenixTypography.label.copyWith(
                    color: isCompleted
                        ? PhoenixColors.textPrimary
                        : PhoenixColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: PhoenixSpacing.xs),
                PhoenixProgressBar(
                  value: achievement.progress,
                  minHeight: 4,
                  progressColor: isCompleted
                      ? PhoenixColors.gold
                      : PhoenixColors.primary,
                  backgroundColor: PhoenixColors.surfaceVariant,
                ),
              ],
            ),
          ),
          SizedBox(width: PhoenixSpacing.sm),
          Icon(
            isCompleted
                ? PhoenixIcons.checkCircle
                : PhoenixIcons.achievement,
            size: 18,
            color: isCompleted
                ? PhoenixColors.success
                : PhoenixColors.textDisabled,
          ),
        ],
      ),
    );
  }
}
