import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/spacing.dart';
import '../models/journey_stage.dart';

class JourneyTimelineCard extends StatelessWidget {
  const JourneyTimelineCard({super.key, required this.stages});

  final List<JourneyStage> stages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Journey Timeline', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...List.generate(stages.length, (index) {
            final stage = stages[index];
            final isLast = index == stages.length - 1;

            return _TimelineStage(stage: stage, isLast: isLast, theme: theme);
          }),
        ],
      ),
    );
  }
}

class _TimelineStage extends StatelessWidget {
  const _TimelineStage({
    required this.stage,
    required this.isLast,
    required this.theme,
  });

  final JourneyStage stage;
  final bool isLast;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final (Color nodeColor, IconData nodeIcon) = switch (stage.status) {
      StageStatus.completed => (theme.colorScheme.tertiary, Icons.check),
      StageStatus.inProgress => (theme.colorScheme.primary, Icons.circle),
      StageStatus.available => (
        theme.colorScheme.outline,
        Icons.circle_outlined,
      ),
      StageStatus.locked => (
        theme.colorScheme.onSurfaceVariant,
        Icons.lock_outlined,
      ),
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline node and connector
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: stage.status == StageStatus.completed
                        ? nodeColor
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: nodeColor,
                      width: stage.status == StageStatus.inProgress ? 3 : 2,
                    ),
                  ),
                  child: stage.status == StageStatus.completed
                      ? Icon(
                          Icons.check,
                          size: 14,
                          color: theme.colorScheme.onTertiary,
                        )
                      : Icon(nodeIcon, size: 12, color: nodeColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Stage content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  stage.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: stage.status == StageStatus.locked
                        ? theme.colorScheme.onSurfaceVariant
                        : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    if (stage.status == StageStatus.inProgress) ...[
                      _StatusChip(
                        label: '${(stage.completion * 100).round()}%',
                        color: theme.colorScheme.primary,
                        theme: theme,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    if (stage.status == StageStatus.completed) ...[
                      _StatusChip(
                        label: 'Done',
                        color: theme.colorScheme.tertiary,
                        theme: theme,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    if (stage.estimatedDuration != null)
                      Text(
                        '${stage.estimatedDuration} days',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${stage.missions.length} missions',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.theme,
  });

  final String label;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
