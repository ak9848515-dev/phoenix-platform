import 'package:flutter/material.dart';

import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_icons.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/widgets/phoenix_card.dart';
import '../../../core/design/widgets/phoenix_progress_bar.dart';
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
                PhoenixStatTile(
                  icon: PhoenixIcons.xp,
                  label: 'Total XP',
                  value: _formatXp(totalXp),
                  color: PhoenixColors.primary,
                ),
                _verticalDivider(),
                PhoenixStatTile(
                  icon: PhoenixIcons.level,
                  label: 'Level',
                  value: '$currentLevel',
                  color: PhoenixColors.primary,
                ),
                _verticalDivider(),
                PhoenixStatTile(
                  icon: PhoenixIcons.streak,
                  label: 'Streak',
                  value: '$currentStreak days',
                  color: PhoenixColors.warning,
                ),
              ],
            ),
            SizedBox(height: PhoenixSpacing.lg),

            // ── Mission Progress ──────────────────────────────────
            Row(
              children: [
                PhoenixStatTile(
                  icon: PhoenixIcons.mission,
                  label: 'Missions',
                  value: '$completedMissions / $totalMissions',
                  color: PhoenixColors.primary,
                  compact: true,
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
