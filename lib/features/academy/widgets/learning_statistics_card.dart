import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/spacing.dart';

class LearningStatisticsCard extends StatelessWidget {
  const LearningStatisticsCard({
    super.key,
    required this.totalLessons,
    required this.completedLessons,
    required this.remainingLessons,
    required this.estimatedStudyTime,
  });

  final int totalLessons;
  final int completedLessons;
  final int remainingLessons;
  final String estimatedStudyTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Learning Statistics', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Total Lessons',
                  value: totalLessons.toString(),
                  icon: Icons.menu_book_outlined,
                  color: theme.colorScheme.primary,
                  theme: theme,
                ),
              ),
              Expanded(
                child: _StatTile(
                  label: 'Completed',
                  value: completedLessons.toString(),
                  icon: Icons.check_circle_outline,
                  color: theme.colorScheme.tertiary,
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Remaining',
                  value: remainingLessons.toString(),
                  icon: Icons.hourglass_empty_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                  theme: theme,
                ),
              ),
              Expanded(
                child: _StatTile(
                  label: 'Est. Study Time',
                  value: estimatedStudyTime,
                  icon: Icons.schedule_outlined,
                  color: theme.colorScheme.secondary,
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.theme,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
