import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../shared/widgets/phoenix_loading_widget.dart';
import '../../../theme/spacing.dart';
import '../services/memory_graph_service.dart';
import '../widgets/entity_card.dart';
import '../widgets/graph_visualizer.dart';
import 'entity_detail_screen.dart';
import 'memory_search_screen.dart';

/// Graph Explorer — full-screen graph visualization with entity list.
class GraphExplorerScreen extends StatefulWidget {
  const GraphExplorerScreen({super.key});

  @override
  State<GraphExplorerScreen> createState() => _GraphExplorerScreenState();
}

class _GraphExplorerScreenState extends State<GraphExplorerScreen> {
  MemoryGraphService? _service;
  String? _selectedEntityId;

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
    if (svc == null) {
      return const Scaffold(
        body: PhoenixLoadingWidget(
          icon: Icons.hub_rounded,
          title: 'Loading graph explorer...',
          subtitle: 'Preparing visualization.',
        ),
      );
    }

    final graph = svc.graph;
    final selectedEntity =
        _selectedEntityId != null ? svc.getEntity(_selectedEntityId!) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Graph Explorer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const MemorySearchScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Graph visualization
          Expanded(
            flex: 3,
            child: GraphVisualizer(
              graph: graph,
              focalEntityId: _selectedEntityId,
              onEntityTap: (entity) {
                setState(() => _selectedEntityId = entity.id);
              },
            ),
          ),
          // Selected entity info
          if (selectedEntity != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: EntityCard(
                entity: selectedEntity,
                isSelected: true,
                relationCount: svc.degreeCentrality(selectedEntity.id),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        EntityDetailScreen(entity: selectedEntity),
                  ),
                ),
              ),
            ),
          // Entity list
          Expanded(
            flex: 2,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: graph.entities.length,
              itemBuilder: (context, index) {
                final entity = graph.entities[index];
                final isSelected = entity.id == _selectedEntityId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: EntityCard(
                    entity: entity,
                    isSelected: isSelected,
                    relationCount: svc.degreeCentrality(entity.id),
                    onTap: () {
                      setState(() => _selectedEntityId = entity.id);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
