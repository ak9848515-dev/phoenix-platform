import 'package:flutter/material.dart';

import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_icons.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../core/design/widgets/phoenix_stat_tile.dart';

/// Displays a summary of the user's key progress metrics: XP, Level,
/// and Streak.
///
/// Reads from [ProgressService] — no calculation logic here.
class ProgressSummaryCard extends StatelessWidget {
  const ProgressSummaryCard({
    super.key,
    required this.totalXp,
    required this.currentLevel,
    required this.currentStreak,
    this.onXpTap,
    this.onLevelTap,
    this.onStreakTap,
  });

  /// Total XP earned.
  final int totalXp;

  /// Current level.
  final int currentLevel;

  /// Current daily streak count.
  final int currentStreak;

  /// Called when the XP stat is tapped.
  final VoidCallback? onXpTap;

  /// Called when the Level stat is tapped.
  final VoidCallback? onLevelTap;

  /// Called when the Streak stat is tapped.
  final VoidCallback? onStreakTap;

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 100),
      child: PhoenixCard(
        header: 'Progress Summary',
        child: Row(
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

/// Wraps a stat tile in a tappable [InkWell] if [onTap] is provided.
class _TappableStatTile extends StatelessWidget {
  const _TappableStatTile({
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'View progress details',
      button: onTap != null,
      enabled: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: child,
        ),
      ),
    );
  }
}
