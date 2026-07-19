import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../core/design/theme/phoenix_spacing.dart';

class MissionTasksCard extends StatelessWidget {
  const MissionTasksCard({super.key, required this.tasks});

  final List<MissionTaskItem> tasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mission Tasks', style: theme.textTheme.titleMedium),
          const SizedBox(height: PhoenixSpacing.md),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: PhoenixSpacing.md),
              child: Text(
                'No tasks available.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...tasks.map((task) => _TaskRow(task: task, theme: theme)),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.theme});

  final MissionTaskItem task;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PhoenixSpacing.sm),
      child: Row(
        children: [
          Icon(
            task.completed ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 22,
            color: task.completed
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: PhoenixSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : null,
                    color: task.completed
                        ? theme.colorScheme.onSurfaceVariant
                        : null,
                  ),
                ),
                if (task.subtitle != null) ...[
                  const SizedBox(height: PhoenixSpacing.xs),
                  Text(
                    task.subtitle!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: PhoenixSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PhoenixSpacing.sm,
              vertical: PhoenixSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: task.completed
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              task.completed ? 'Done' : 'Pending',
              style: theme.textTheme.labelSmall?.copyWith(
                color: task.completed
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MissionTaskItem {
  const MissionTaskItem({
    required this.title,
    required this.completed,
    this.subtitle,
    this.isAlternative = false,
  });

  final String title;
  final bool completed;
  final String? subtitle;

  /// Whether this task is an alternative recommendation.
  final bool isAlternative;
}
