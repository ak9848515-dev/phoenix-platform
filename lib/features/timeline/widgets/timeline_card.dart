import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/timeline_category.dart';
import '../models/timeline_event.dart';

/// A card displaying a single timeline event.
class TimelineCard extends StatelessWidget {
  const TimelineCard({
    super.key,
    required this.event,
    this.onTap,
  });

  final TimelineEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForCategory(event.category);

    return Semantics(
      label: '${event.title}, ${event.category.label}',
      hint: onTap != null ? 'Double-tap to view details' : null,
      button: onTap != null,
      enabled: onTap != null,
      child: InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: event.importance >= 2
                ? color.withValues(alpha: 0.3)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconForCategory(event.category),
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (event.importance >= 2)
                        Icon(Icons.auto_awesome_rounded,
                            size: 14, color: AppColors.warning),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    event.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text(
                        _formatTime(event.timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.category.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Color _colorForCategory(TimelineCategory category) {
    switch (category) {
      case TimelineCategory.learning:
        return AppColors.primary;
      case TimelineCategory.mission:
        return Colors.orange;
      case TimelineCategory.achievement:
        return AppColors.warning;
      case TimelineCategory.career:
        return const Color(0xFF7C3AED);
      case TimelineCategory.portfolio:
        return Colors.teal;
      case TimelineCategory.resume:
        return Colors.blue;
      case TimelineCategory.interview:
        return Colors.purple;
      case TimelineCategory.decision:
        return const Color(0xFF0891B2);
      case TimelineCategory.ai:
        return const Color(0xFFD97706);
      case TimelineCategory.voice:
        return Colors.indigo;
      case TimelineCategory.marketplace:
        return Colors.pink;
      case TimelineCategory.system:
        return Colors.grey;
      case TimelineCategory.custom:
        return Colors.amber;
    }
  }

  IconData _iconForCategory(TimelineCategory category) {
    switch (category) {
      case TimelineCategory.learning:
        return Icons.school_rounded;
      case TimelineCategory.mission:
        return Icons.rocket_launch_rounded;
      case TimelineCategory.achievement:
        return Icons.emoji_events_rounded;
      case TimelineCategory.career:
        return Icons.work_rounded;
      case TimelineCategory.portfolio:
        return Icons.folder_rounded;
      case TimelineCategory.resume:
        return Icons.description_rounded;
      case TimelineCategory.interview:
        return Icons.record_voice_over_rounded;
      case TimelineCategory.decision:
        return Icons.account_tree_rounded;
      case TimelineCategory.ai:
        return Icons.auto_awesome_rounded;
      case TimelineCategory.voice:
        return Icons.mic_rounded;
      case TimelineCategory.marketplace:
        return Icons.store_rounded;
      case TimelineCategory.system:
        return Icons.settings_rounded;
      case TimelineCategory.custom:
        return Icons.star_rounded;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
