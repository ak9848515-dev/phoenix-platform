import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/spacing.dart';
import '../models/memory_entry.dart';

/// Displays a list of the most recent memory entries.
class RecentMemoriesCard extends StatelessWidget {
  const RecentMemoriesCard({
    super.key,
    required this.memories,
  });

  /// The recent memory entries to display.
  final List<MemoryEntry> memories;

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
                Icons.history_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Recent Memories', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...memories.map(
            (memory) => _RecentMemoryItem(
              memory: memory,
              isLast: memories.last == memory,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single recent memory item row.
class _RecentMemoryItem extends StatelessWidget {
  const _RecentMemoryItem({
    required this.memory,
    required this.isLast,
  });

  final MemoryEntry memory;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _iconColor(theme).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                _categoryIcon(memory.category),
                size: 20,
                color: _iconColor(theme),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  memory.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  memory.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (memory.isPinned)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: Icon(
                Icons.push_pin_outlined,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  IconData _categoryIcon(MemoryCategory category) {
    switch (category) {
      case MemoryCategory.learning:
        return Icons.school_outlined;
      case MemoryCategory.mission:
        return Icons.rocket_launch_outlined;
      case MemoryCategory.achievement:
        return Icons.emoji_events_outlined;
      case MemoryCategory.decision:
        return Icons.lightbulb_outlined;
      case MemoryCategory.reflection:
        return Icons.auto_stories_outlined;
      case MemoryCategory.project:
        return Icons.folder_outlined;
      case MemoryCategory.career:
        return Icons.work_outlined;
      case MemoryCategory.business:
        return Icons.store_outlined;
    }
  }

  Color _iconColor(ThemeData theme) {
    return theme.colorScheme.primary;
  }
}