import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';

/// Displays a streak count with a fire icon and motivational label.
class StreakIndicator extends StatelessWidget {
  const StreakIndicator({
    super.key,
    this.streak = 0,
    this.longestStreak = 0,
    this.size = StreakSize.medium,
  });

  final int streak;
  final int longestStreak;
  final StreakSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = streak >= 1;
    final iconSize = size == StreakSize.small ? 20.0 : (size == StreakSize.large ? 40.0 : 28.0);
    final textStyle = size == StreakSize.small
        ? theme.textTheme.labelLarge
        : (size == StreakSize.large
            ? theme.textTheme.headlineMedium
            : theme.textTheme.titleLarge);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.local_fire_department_rounded : Icons.local_fire_department_outlined,
              size: iconSize,
              color: isActive ? AppColors.warning : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '$streak',
              style: textStyle?.copyWith(
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.warning : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          streak == 0
              ? 'No streak'
              : streak == 1
                  ? 'Day streak'
                  : 'Day streak',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (longestStreak > streak && longestStreak > 0) ...[
          const SizedBox(height: 2),
          Text(
            'Best: $longestStreak',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }
}

enum StreakSize { small, medium, large }
