import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/memory_insight.dart';
import '../services/memory_graph_service.dart';
import '../widgets/entity_card.dart';
import '../widgets/entity_cluster_card.dart';
import '../widgets/graph_visualizer.dart';
import 'entity_detail_screen.dart';
import 'graph_explorer_screen.dart';
import 'memory_search_screen.dart';

/// Memory Graph Dashboard — main view for the graph.
class MemoryGraphDashboardScreen extends StatefulWidget {
  const MemoryGraphDashboardScreen({super.key});

  @override
  State<MemoryGraphDashboardScreen> createState() =>
      _MemoryGraphDashboardScreenState();
}

class _MemoryGraphDashboardScreenState
    extends State<MemoryGraphDashboardScreen> {
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
    if (svc == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final stats = svc.stats;
    final clusters = svc.detectClusters();
    final hubs = svc.findHubs(topN: 5);
    final insights = svc.insights();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, svc, stats),
          const SizedBox(height: AppSpacing.lg),
          _buildStatsRow(context, stats),
          const SizedBox(height: AppSpacing.lg),
          // Graph visual
          PhoenixCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Graph Explorer',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const GraphExplorerScreen(),
                        ),
                      ),
                      child: const Text('Explore'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 200,
                  child: GraphVisualizer(
                    graph: svc.graph,
                    onEntityTap: (entity) => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            EntityDetailScreen(entity: entity),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Clusters
          if (clusters.isNotEmpty) ...[
            _buildSectionTitle(context, 'Clusters', Icons.auto_awesome_rounded),
            const SizedBox(height: AppSpacing.sm),
            ...clusters.map((cluster) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: EntityClusterCard(
                cluster: cluster,
                onEntityTap: (entity) => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EntityDetailScreen(entity: entity),
                  ),
                ),
              ),
            )),
            const SizedBox(height: AppSpacing.lg),
          ],
          // Hubs
          if (hubs.isNotEmpty) ...[
            _buildSectionTitle(
                context, 'Most Connected', Icons.hub_rounded),
            const SizedBox(height: AppSpacing.sm),
            ...hubs.map((entity) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: EntityCard(
                entity: entity,
                relationCount: svc.degreeCentrality(entity.id),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EntityDetailScreen(entity: entity),
                  ),
                ),
              ),
            )),
            const SizedBox(height: AppSpacing.lg),
          ],
          // Insights
          if (insights.isNotEmpty) ...[
            _buildSectionTitle(
                context, 'Insights', Icons.lightbulb_rounded),
            const SizedBox(height: AppSpacing.sm),
            ...insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildInsightCard(context, insight),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, MemoryGraphService svc, Map<String, dynamic> stats) {
    final theme = Theme.of(context);
    return PhoenixCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.hub_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Memory Graph',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${stats['entityCount']} entities, ${stats['relationCount']} relations',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const MemorySearchScreen(),
              ),
            ),
            tooltip: 'Search',
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
      BuildContext context, Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            value: '${stats['entityCount']}',
            label: 'Entities',
            icon: Icons.circle_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            value: '${stats['relationCount']}',
            label: 'Relations',
            icon: Icons.link_rounded,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            value: '${((stats['density'] as double) * 100).round()}%',
            label: 'Density',
            icon: Icons.grid_view_rounded,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
      BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(BuildContext context, MemoryInsight insight) {
    final theme = Theme.of(context);
    return PhoenixCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lightbulb_rounded,
                size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (insight.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    insight.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
