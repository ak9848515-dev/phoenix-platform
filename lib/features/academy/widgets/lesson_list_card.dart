import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/spacing.dart';

class LessonListCard extends StatelessWidget {
  const LessonListCard({super.key, required this.lessons});

  final List<LessonListItem> lessons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lesson List', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          if (lessons.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'No lessons available.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...lessons.map(
              (lesson) => _LessonRow(lesson: lesson, theme: theme),
            ),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.lesson, required this.theme});

  final LessonListItem lesson;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color iconColor;
    final Color textColor;
    final String statusLabel;

    switch (lesson.status) {
      case LessonStatus.completed:
        icon = Icons.check_circle;
        iconColor = theme.colorScheme.primary;
        textColor = theme.colorScheme.onSurfaceVariant;
        statusLabel = 'Done';
      case LessonStatus.current:
        icon = Icons.play_circle_filled;
        iconColor = theme.colorScheme.tertiary;
        textColor = theme.colorScheme.onSurface;
        statusLabel = 'Current';
      case LessonStatus.locked:
        icon = Icons.lock_outline;
        iconColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
        textColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
        statusLabel = 'Locked';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                if (lesson.subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    lesson.subtitle!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: lesson.status == LessonStatus.completed
                  ? theme.colorScheme.primaryContainer
                  : lesson.status == LessonStatus.current
                  ? theme.colorScheme.tertiaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: lesson.status == LessonStatus.completed
                    ? theme.colorScheme.onPrimaryContainer
                    : lesson.status == LessonStatus.current
                    ? theme.colorScheme.onTertiaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum LessonStatus { completed, current, locked }

class LessonListItem {
  const LessonListItem({
    required this.title,
    required this.status,
    this.subtitle,
  });

  final String title;
  final LessonStatus status;
  final String? subtitle;
}
