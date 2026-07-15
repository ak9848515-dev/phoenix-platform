import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_loading_widget.dart';
import '../../../shared/widgets/phoenix_empty_state.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/knowledge_domain.dart';
import '../models/knowledge_node.dart';
import '../services/knowledge_service.dart';
import '../widgets/knowledge_edge_badge.dart';
import '../widgets/knowledge_node_card.dart';

/// Goal Map — visualizes goal dependencies, progress, and priorities.
class GoalMapScreen extends StatefulWidget {
  const GoalMapScreen({super.key});

  @override
  State<GoalMapScreen> createState() => _GoalMapScreenState();
}

class _GoalMapScreenState extends State<GoalMapScreen> {
  KnowledgeService? _service;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _service = AppBootstrap.maybeKnowledgeService;
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
          icon: Icons.flag_rounded,
          title: 'Loading your goals...',
          subtitle: 'Preparing goal map and priorities.',
        ),
      );
    }

    final goals = svc.snapshot.nodes
        .where((n) => n.domain == KnowledgeDomain.goals)
        .toList()
      ..sort((a, b) => b.importance.compareTo(a.importance));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Map'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary
            PhoenixCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.flag_rounded,
                        color: AppColors.warning, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${goals.length} Goals',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${goals.where((g) => g.importance > 0.7).length} high priority',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Priority breakdown
            Row(
              children: [
                _PriorityTile(
                  label: 'High',
                  count: goals.where((g) => g.importance >= 0.7).length,
                  color: AppColors.error,
                ),
                const SizedBox(width: AppSpacing.sm),
                _PriorityTile(
                  label: 'Medium',
                  count: goals.where((g) => g.importance >= 0.4 && g.importance < 0.7).length,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.sm),
                _PriorityTile(
                  label: 'Low',
                  count: goals.where((g) => g.importance < 0.4).length,
                  color: AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            // Goals list
            Text(
              'All Goals',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (goals.isEmpty)
              const PhoenixEmptyState(
                icon: Icons.flag_rounded,
                title: 'No goals yet',
                message: 'Goals help you stay focused on what matters most.',
                positiveMessage: 'Every great achievement starts with a clear goal.',
              )
            else
              ...goals.map((goal) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: KnowledgeNodeCard(
                      node: goal,
                      onTap: () => _showGoalDependencies(context, svc, goal),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  void _showGoalDependencies(
      BuildContext context, KnowledgeService svc, KnowledgeNode goal) {
    final edges = svc.snapshot.edges
        .where((e) =>
            e.sourceNodeId == goal.id || e.targetNodeId == goal.id)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.7,
        minChildSize: 0.3,
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ListView(
            controller: scrollController,
            children: [
              Text(goal.label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text('Importance: ',
                      style: Theme.of(context).textTheme.labelLarge),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: goal.importance,
                        backgroundColor: AppColors.warning
                            .withValues(alpha: 0.1),
                        color: AppColors.warning,
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                      '${(goal.importance * 100).round()}%'),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (edges.isNotEmpty) ...[
                Text('Dependencies',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ...edges.map((edge) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              edge.sourceNodeId == goal.id
                                  ? edge.targetNodeId
                                  : edge.sourceNodeId,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                            ),
                          ),
                          const SizedBox(width: 6),
                          KnowledgeEdgeBadge(
                              edge: edge),
                        ],
                      ),
                    )),
              ],
              if (edges.isEmpty)
                Text(
                  'No dependencies mapped yet',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityTile extends StatelessWidget {
  const _PriorityTile({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
