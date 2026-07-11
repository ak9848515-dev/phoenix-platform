import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_indicator.dart';
import '../../../theme/spacing.dart';

class CourseProgressCard extends StatelessWidget {
  const CourseProgressCard({
    super.key,
    required this.lessonsCompleted,
    required this.lessonsRemaining,
    required this.progressPercentage,
  });

  final int lessonsCompleted;
  final int lessonsRemaining;
  final double progressPercentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (progressPercentage * 100).round();

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Course Progress', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ProgressStat(
                value: lessonsCompleted.toString(),
                label: 'Completed',
                color: theme.colorScheme.primary,
                theme: theme,
              ),
              _ProgressStat(
                value: lessonsRemaining.toString(),
                label: 'Remaining',
                color: theme.colorScheme.onSurfaceVariant,
                theme: theme,
              ),
              _ProgressStat(
                value: '$percent%',
                label: 'Progress',
                color: theme.colorScheme.tertiary,
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PhoenixProgressIndicator(value: progressPercentage),
        ],
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({
    required this.value,
    required this.label,
    required this.color,
    required this.theme,
  });

  final String value;
  final String label;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
