import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_indicator.dart';
import '../../../theme/spacing.dart';
import '../models/memory_entry.dart';

/// Displays aggregate statistics about the user's memory entries.
class MemoryStatisticsCard extends StatelessWidget {
  const MemoryStatisticsCard({
    super.key,
    required this.entries,
  });

  /// All memory entries to compute statistics from.
  final List<MemoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalMemories = entries.length;
    final pinnedCount = entries.where((e) => e.isPinned).length;
    final categories = entries
        .map((e) => e.category)
        .toSet()
        .length;
    final avgImportance = entries.isEmpty
        ? 0.0
        : entries.fold(0.0, (sum, e) => sum + e.importance) / totalMemories;

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.analytics_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Statistics', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatItem(
                  label: 'Total',
                  value: '$totalMemories',
                  icon: Icons.menu_book_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Pinned',
                  value: '$pinnedCount',
                  icon: Icons.push_pin_outlined,
                  color: theme.colorScheme.secondary,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Categories',
                  value: '$categories',
                  icon: Icons.category_outlined,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Icon(
                Icons.trending_up_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Avg. Importance',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '${(avgImportance * 100).round()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          PhoenixProgressIndicator(
            value: avgImportance,
            minHeight: 6,
            valueColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

/// A single statistic item showing a label, value, and icon.
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(icon, size: 20, color: color),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}