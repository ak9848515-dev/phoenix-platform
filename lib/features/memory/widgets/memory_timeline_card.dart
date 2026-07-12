import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/spacing.dart';
import '../models/memory_entry.dart';

/// Displays a vertical timeline of memory entries.
class MemoryTimelineCard extends StatelessWidget {
  const MemoryTimelineCard({
    super.key,
    required this.entries,
  });

  /// The timeline entries to display, ordered newest first.
  final List<MemoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.timeline_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Timeline', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...entries.map(
            (entry) => _TimelineEntry(
              entry: entry,
              isLast: entries.last == entry,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single entry in the timeline with a connecting line.
class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.entry,
    required this.isLast,
  });

  final MemoryEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _categoryColor(theme, entry.category);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Timeline connector
          SizedBox(
            width: 24,
            child: Column(
              children: <Widget>[
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: categoryColor.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    entry.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    entry.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: <Widget>[
                      _CategoryLabel(
                        label: _categoryLabel(entry.category),
                        color: categoryColor,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _formatTimestamp(entry.timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(ThemeData theme, MemoryCategory category) {
    switch (category) {
      case MemoryCategory.learning:
        return theme.colorScheme.primary;
      case MemoryCategory.mission:
        return theme.colorScheme.tertiary;
      case MemoryCategory.achievement:
        return Colors.amber.shade600;
      case MemoryCategory.decision:
        return theme.colorScheme.secondary;
      case MemoryCategory.reflection:
        return Colors.purple.shade400;
      case MemoryCategory.project:
        return Colors.blue.shade400;
      case MemoryCategory.career:
        return Colors.teal.shade400;
      case MemoryCategory.business:
        return Colors.orange.shade400;
    }
  }

  String _categoryLabel(MemoryCategory category) {
    switch (category) {
      case MemoryCategory.learning:
        return 'Learning';
      case MemoryCategory.mission:
        return 'Mission';
      case MemoryCategory.achievement:
        return 'Achievement';
      case MemoryCategory.decision:
        return 'Decision';
      case MemoryCategory.reflection:
        return 'Reflection';
      case MemoryCategory.project:
        return 'Project';
      case MemoryCategory.career:
        return 'Career';
      case MemoryCategory.business:
        return 'Business';
    }
  }

  String _formatTimestamp(int milliseconds) {
    final date =
        DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// A small coloured label for the memory category.
class _CategoryLabel extends StatelessWidget {
  const _CategoryLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}