import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_indicator.dart';
import '../../../theme/spacing.dart';

class MissionProgressCard extends StatelessWidget {
  const MissionProgressCard({
    super.key,
    required this.progressPercentage,
    required this.completedTasks,
    required this.remainingTasks,
  });

  final double progressPercentage;
  final int completedTasks;
  final int remainingTasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (progressPercentage * 100).round();

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mission Progress', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(
                label: 'Completed',
                value: completedTasks.toString(),
                color: theme.colorScheme.primary,
              ),
              _StatItem(
                label: 'Remaining',
                value: remainingTasks.toString(),
                color: theme.colorScheme.onSurfaceVariant,
              ),
              _StatItem(
                label: 'Progress',
                value: '$percent%',
                color: theme.colorScheme.tertiary,
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

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
