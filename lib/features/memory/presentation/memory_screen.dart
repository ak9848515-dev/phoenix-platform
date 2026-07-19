import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../../theme/spacing.dart';
import '../widgets/memory_header.dart';

/// Memory Screen — displays the user's long-term memories.
///
/// All data sourced from [MemoryEngine] snapshot. No SampleRepository.
class MemoryScreen extends StatelessWidget {
  const MemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final memoryEngine = AppBootstrap.maybeMemoryEngine;
    final snap = memoryEngine?.snapshot;

    final totalMemories = snap?.totalMemories ?? 0;
    final totalRelationships = snap?.totalRelationships ?? 0;
    final recentMemories = snap?.recentMemories ?? [];
    final importantMemories = snap?.importantMemories ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const MemoryHeader(),
          const SizedBox(height: AppSpacing.lg),
          _StatisticsCard(
            totalCount: totalMemories,
            relationshipCount: totalRelationships,
            pinnedCount: importantMemories.length,
          ),
          const SizedBox(height: AppSpacing.lg),
          _RecentMemoriesSection(
            memories: recentMemories.map((m) => _memorySummary(m)).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ImportantMemoriesSection(
            memories: importantMemories.map((m) => _memorySummary(m)).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          PhoenixPrimaryButton(
            onPressed: () => _onViewAllMemories(context),
            label: 'View All Memories',
            icon: Icons.memory_outlined,
            fullWidth: true,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  String _memorySummary(dynamic entry) {
    if (entry == null) return '';
    try {
      return entry.title ?? entry.toString();
    } catch (_) {
      return entry.toString();
    }
  }

  void _onViewAllMemories(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.timeline);
  }
}

class _StatisticsCard extends StatelessWidget {
  const _StatisticsCard({
    required this.totalCount,
    required this.relationshipCount,
    required this.pinnedCount,
  });

  final int totalCount;
  final int relationshipCount;
  final int pinnedCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(child: _statItem(theme, Icons.memory_outlined, '$totalCount', 'Total', theme.colorScheme.primary)),
            Expanded(child: _statItem(theme, Icons.link_rounded, '$relationshipCount', 'Relationships', theme.colorScheme.tertiary)),
            Expanded(child: _statItem(theme, Icons.push_pin_outlined, '$pinnedCount', 'Pinned', theme.colorScheme.error)),
          ],
        ),
      ),
    );
  }

  Widget _statItem(ThemeData theme, IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _RecentMemoriesSection extends StatelessWidget {
  const _RecentMemoriesSection({required this.memories});

  final List<String> memories;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (memories.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history_rounded, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('Recent Memories', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...memories.take(5).map((title) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 6, color: theme.colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ImportantMemoriesSection extends StatelessWidget {
  const _ImportantMemoriesSection({required this.memories});

  final List<String> memories;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (memories.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star_rounded, size: 20, color: theme.colorScheme.error),
                const SizedBox(width: AppSpacing.sm),
                Text('Important Memories', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...memories.take(5).map((title) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.push_pin, size: 14, color: theme.colorScheme.error),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
