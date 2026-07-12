import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/spacing.dart';
import '../models/journey_stage.dart';

class JourneyStatisticsCard extends StatelessWidget {
  const JourneyStatisticsCard({super.key, required this.stages});

  final List<JourneyStage> stages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalStages = stages.length;
    final completedStages = stages
        .where((s) => s.status == StageStatus.completed)
        .length;
    final inProgressStages = stages
        .where((s) => s.status == StageStatus.inProgress)
        .length;
    final lockedStages = stages
        .where((s) => s.status == StageStatus.locked)
        .length;
    final availableStages = stages
        .where((s) => s.status == StageStatus.available)
        .length;

    // Calculate average completion of in-progress stages
    final inProgressCompletion = inProgressStages > 0
        ? stages
                  .where((s) => s.status == StageStatus.inProgress)
                  .map((s) => s.completion)
                  .reduce((a, b) => a + b) /
              inProgressStages
        : 0.0;

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Journey Statistics', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Total Stages',
                  value: totalStages.toString(),
                  icon: Icons.flag_outlined,
                  color: theme.colorScheme.primary,
                  theme: theme,
                ),
              ),
              Expanded(
                child: _StatTile(
                  label: 'Completed',
                  value: completedStages.toString(),
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
                  label: 'In Progress',
                  value: inProgressStages.toString(),
                  icon: Icons.trending_up_outlined,
                  color: theme.colorScheme.primary,
                  theme: theme,
                ),
              ),
              Expanded(
                child: _StatTile(
                  label: 'Available',
                  value: availableStages.toString(),
                  icon: Icons.lock_open_outlined,
                  color: theme.colorScheme.secondary,
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
                  label: 'Locked',
                  value: lockedStages.toString(),
                  icon: Icons.lock_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                  theme: theme,
                ),
              ),
              Expanded(
                child: _StatTile(
                  label: 'Avg Progress',
                  value: '${(inProgressCompletion * 100).round()}%',
                  icon: Icons.pie_chart_outline,
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
