import 'package:flutter/material.dart';
import '../../../theme/spacing.dart';
import '../../daily_brief/models/daily_priority.dart';
import '../../daily_brief/models/daily_task.dart';
import '../models/daily_journey_snapshot.dart';

/// Displays today's task timeline organized by time slot.
class DailyTimelineCard extends StatelessWidget {
  const DailyTimelineCard({super.key, required this.snapshot});

  final DailyJourneySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = snapshot.plan;

    if (plan.tasks.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text("Today's Timeline",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(
                  '${plan.completedCount}/${plan.total}',
                  style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (plan.morning.isNotEmpty) ...[
              _timeSlot(theme, 'Morning', plan.morning, Icons.wb_sunny_outlined),
              const SizedBox(height: AppSpacing.md),
            ],
            if (plan.afternoon.isNotEmpty) ...[
              _timeSlot(theme, 'Afternoon', plan.afternoon, Icons.wb_cloudy_outlined),
              const SizedBox(height: AppSpacing.md),
            ],
            if (plan.evening.isNotEmpty) ...[
              _timeSlot(theme, 'Evening', plan.evening, Icons.nightlight_outlined),
              const SizedBox(height: AppSpacing.md),
            ],
            if (plan.flexible.isNotEmpty)
              _timeSlot(theme, 'Flexible', plan.flexible, Icons.autorenew_rounded),
          ],
        ),
      ),
    );
  }

  Widget _timeSlot(ThemeData theme, String label, List<DailyTask> tasks, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(label,
                style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...tasks.map((task) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.priority == DailyPriority.high
                          ? Colors.orange
                          : task.priority == DailyPriority.medium
                              ? Colors.blue
                              : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(task.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            decoration: task.completed ? TextDecoration.lineThrough : null,
                            color: task.completed ? theme.colorScheme.onSurfaceVariant : null)),
                  ),
                  Text('${task.estimatedMinutes} min',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            )),
      ],
    );
  }
}
