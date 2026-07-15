import 'package:flutter/material.dart';

import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_icons.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_bar.dart';
import '../../../core/design/widgets/phoenix_stat_tile.dart';

/// Displays a growth summary with XP, Level, Streak, completed missions,
/// and overall progress.
///
/// Reads from [ProgressService.buildSummary()] and [MissionService].
/// Presentation-only — no calculations.
class GrowthSummaryCard extends StatelessWidget {
  const GrowthSummaryCard({
    super.key,
    required this.totalXp,
    required this.currentLevel,
    required this.currentStreak,
    required this.completedMissions,
    required this.totalMissions,
    required this.overallProgress,
    this.onXpTap,
    this.onLevelTap,
    this.onStreakTap,
    this.onMissionsTap,
  });

  /// Total XP earned.
  final int totalXp;

  /// Current level number.
  final int currentLevel;

  /// Current daily streak.
  final int currentStreak;

  /// Number of completed missions.
  final int completedMissions;

  /// Total number of missions.
  final int totalMissions;

  /// Overall progress as a value between 0.0 and 1.0.
  final double overallProgress;

  /// Called when the XP stat tile is tapped.
  final VoidCallback? onXpTap;

  /// Called when the Level stat tile is tapped.
  final VoidCallback? onLevelTap;

  /// Called when the Streak stat tile is tapped.
  final VoidCallback? onStreakTap;

  /// Called when the Missions stat tile is tapped.
  final VoidCallback? onMissionsTap;

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 100),
      child: PhoenixCard(
        header: 'Growth Summary',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stats Row ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TappableStatTile(
                  onTap: onXpTap,
                  child: PhoenixStatTile(
                    icon: PhoenixIcons.xp,
                    label: 'Total XP',
                    value: _formatXp(totalXp),
                    color: PhoenixColors.primary,
                  ),
                ),
                _verticalDivider(),
                _TappableStatTile(
                  onTap: onLevelTap,
                  child: PhoenixStatTile(
                    icon: PhoenixIcons.level,
                    label: 'Level',
                    value: '$currentLevel',
                    color: PhoenixColors.primary,
                  ),
                ),
                _verticalDivider(),
                _TappableStatTile(
                  onTap: onStreakTap,
                  child: PhoenixStatTile(
                    icon: PhoenixIcons.streak,
                    label: 'Streak',
                    value: '$currentStreak days',
                    color: PhoenixColors.warning,
                  ),
                ),
              ],
            ),
            SizedBox(height: PhoenixSpacing.lg),

            // ── Mission Progress ──────────────────────────────────
            Row(
              children: [
                _TappableStatTile(
                  onTap: onMissionsTap,
                  child: PhoenixStatTile(
                    icon: PhoenixIcons.mission,
                    label: 'Missions',
                    value: '$completedMissions / $totalMissions',
                    color: PhoenixColors.primary,
                    compact: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: PhoenixSpacing.md),

            // ── Overall Progress Bar ──────────────────────────────
            PhoenixProgressBar(
              value: overallProgress,
              label: 'Overall Progress',
              showPercentage: true,
              minHeight: 6,
              progressColor: PhoenixColors.primary,
              animationDuration: const Duration(milliseconds: 800),
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

  String _formatXp(int xp) {
    if (xp >= 1000) {
      return '${(xp / 1000).toStringAsFixed(1)}k';
    }
    return xp.toString();
  }
}

/// Wraps a stat tile in an [InkWell] to make it interactive.
class _TappableStatTile extends StatelessWidget {
  const _TappableStatTile({
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: child,
      ),
    );
  }
}
