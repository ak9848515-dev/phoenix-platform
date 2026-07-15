import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/spacing.dart';

class MissionStatisticsCard extends StatelessWidget {
  const MissionStatisticsCard({
    super.key,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.completionPercentage,
    this.onTotalTasksTap,
    this.onCompletedTap,
    this.onPendingTap,
    this.onCompletionTap,
  });

  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final double completionPercentage;

  /// Called when the Total Tasks stat is tapped.
  final VoidCallback? onTotalTasksTap;

  /// Called when the Completed stat is tapped.
  final VoidCallback? onCompletedTap;

  /// Called when the Pending stat is tapped.
  final VoidCallback? onPendingTap;

  /// Called when the Completion stat is tapped.
  final VoidCallback? onCompletionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (completionPercentage * 100).round();

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mission Statistics', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _TappableStatTile(
                  onTap: onTotalTasksTap,
                  label: 'Total Tasks',
                  value: totalTasks.toString(),
                  icon: Icons.assignment_outlined,
                  color: theme.colorScheme.primary,
                  theme: theme,
                ),
              ),
              Expanded(
                child: _TappableStatTile(
                  onTap: onCompletedTap,
                  label: 'Completed',
                  value: completedTasks.toString(),
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
                child: _TappableStatTile(
                  onTap: onPendingTap,
                  label: 'Pending',
                  value: pendingTasks.toString(),
                  icon: Icons.hourglass_empty_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                  theme: theme,
                ),
              ),
              Expanded(
                child: _TappableStatTile(
                  onTap: onCompletionTap,
                  label: 'Completion',
                  value: '$percent%',
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

/// A tappable stat tile with icon, value, and label.
class _TappableStatTile extends StatelessWidget {
  const _TappableStatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.theme,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ThemeData theme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
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
        ),
      ),
    );
  }
}
