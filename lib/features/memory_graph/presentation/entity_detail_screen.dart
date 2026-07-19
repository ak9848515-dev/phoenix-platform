import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../shared/widgets/phoenix_loading_widget.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/memory_entity.dart';
import '../services/memory_graph_service.dart';
import '../widgets/entity_card.dart';
import '../widgets/related_items_panel.dart';
import 'memory_search_screen.dart';

/// Detail view for a single graph entity with its relationships.
class EntityDetailScreen extends StatefulWidget {
  const EntityDetailScreen({super.key, required this.entity});

  final MemoryEntity entity;

  @override
  State<EntityDetailScreen> createState() => _EntityDetailScreenState();
}

class _EntityDetailScreenState extends State<EntityDetailScreen> {
  MemoryGraphService? _service;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _service = AppBootstrap.maybeMemoryGraphService;
    _service?.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _service?.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final svc = _service;
    final entity = widget.entity;
    final theme = Theme.of(context);

    if (svc == null) {
      return Scaffold(
        appBar: AppBar(title: Text(entity.title)),
        body: const PhoenixLoadingWidget(
          icon: Icons.circle_rounded,
          title: 'Loading entity details...',
          subtitle: 'Preparing relationships and context.',
        ),
      );
    }

    final context_ = svc.buildContext(entity.id, depth: 1);
    final similar = svc.findSimilar(entity.id);
    final degree = svc.degreeCentrality(entity.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(entity.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search memory graph',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const MemorySearchScreen(),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Entity header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.circle_rounded,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entity.title,
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(entity.type.label,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant)),
                          if (entity.description != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(entity.description!,
                                style: theme.textTheme.bodySmall),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Info row
            Row(
              children: [
                _InfoChip(
                    label: '$degree connections',
                    icon: Icons.link_rounded),
                const SizedBox(width: AppSpacing.sm),
                _InfoChip(
                    label: entity.sourceEngine,
                    icon: Icons.source_rounded),
                if (entity.importance > 0.5) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _InfoChip(
                      label: '${(entity.importance * 100).round()}%',
                      icon: Icons.auto_awesome_rounded),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Related entities
            Text('Related',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            if (context_.relatedEntities.isEmpty)
              Text('No related entities.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant))
            else
              RelatedItemsPanel(
                memoryContext: context_,
                onEntityTap: (entity) => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EntityDetailScreen(entity: entity),
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.lg),

            // Similar entities
            if (similar.isNotEmpty) ...[
              Text('Similar',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.sm),
              ...similar.take(5).map((entity) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: EntityCard(
                  entity: entity,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EntityDetailScreen(entity: entity),
                    ),
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
