import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_loading_widget.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/knowledge_domain.dart';
import '../models/knowledge_node.dart';
import '../services/knowledge_service.dart';
import '../widgets/knowledge_edge_badge.dart';
import '../widgets/knowledge_node_card.dart';

/// Skills Map — visualizes skill relationships and proficiencies.
class SkillsMapScreen extends StatefulWidget {
  const SkillsMapScreen({super.key});

  @override
  State<SkillsMapScreen> createState() => _SkillsMapScreenState();
}

class _SkillsMapScreenState extends State<SkillsMapScreen> {
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
          icon: Icons.psychology_rounded,
          title: 'Loading your skills...',
          subtitle: 'Building proficiency distribution.',
        ),
      );
    }

    final skills = svc.snapshot.nodes
        .where((n) => n.domain == KnowledgeDomain.skills)
        .toList()
      ..sort((a, b) => b.proficiency.compareTo(a.proficiency));

    final edges = svc.snapshot.edges
        .where((e) =>
            skills.any((s) => s.id == e.sourceNodeId) ||
            skills.any((s) => s.id == e.targetNodeId))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skills Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => svc.rebuildGraph(),
            tooltip: 'Rebuild graph',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            PhoenixCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.psychology_rounded,
                        color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${skills.length} Skills Tracked',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          '${edges.length} semantic connections',
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
            // Proficiency distribution
            Text(
              'Proficiency Distribution',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildProficiencyDistribution(context, skills),
            const SizedBox(height: AppSpacing.lg),
            // Skills list
            Text(
              'All Skills',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...skills.map((skill) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: KnowledgeNodeCard(
                    node: skill,
                    onTap: () => _showSkillDetail(context, svc, skill),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildProficiencyDistribution(
      BuildContext context, List<KnowledgeNode> skills) {
    final high =
        skills.where((s) => s.proficiency >= 0.7).length;
    final medium =
        skills.where((s) => s.proficiency >= 0.4 && s.proficiency < 0.7).length;
    final low = skills
        .where((s) => s.proficiency > 0 && s.proficiency < 0.4)
        .length;
    final untracked = skills.where((s) => s.proficiency == 0).length;

    final total = skills.length;

    return Row(
      children: [
        _DistributionSegment(
          label: 'High',
          count: high,
          total: total,
          color: AppColors.success,
        ),
        const SizedBox(width: AppSpacing.sm),
        _DistributionSegment(
          label: 'Medium',
          count: medium,
          total: total,
          color: AppColors.warning,
        ),
        const SizedBox(width: AppSpacing.sm),
        _DistributionSegment(
          label: 'Low',
          count: low,
          total: total,
          color: AppColors.error,
        ),
        if (untracked > 0) ...[
          const SizedBox(width: AppSpacing.sm),
          _DistributionSegment(
            label: 'New',
            count: untracked,
            total: total,
            color: Colors.grey,
          ),
        ],
      ],
    );
  }

  void _showSkillDetail(
      BuildContext context, KnowledgeService svc, KnowledgeNode skill) {
    final edges = svc.snapshot.edges
        .where((e) => e.sourceNodeId == skill.id || e.targetNodeId == skill.id)
        .toList();

    final relatedIds = <String>{};
    for (final e in edges) {
      if (e.sourceNodeId == skill.id) relatedIds.add(e.targetNodeId);
      if (e.targetNodeId == skill.id) relatedIds.add(e.sourceNodeId);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ListView(
            controller: scrollController,
            children: [
              Text(skill.label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              if (skill.description != null) ...[
                const SizedBox(height: 4),
                Text(skill.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        )),
              ],
              const SizedBox(height: AppSpacing.md),
              // Proficiency
              Row(
                children: [
                  Text('Proficiency: ',
                      style: Theme.of(context).textTheme.labelLarge),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: skill.proficiency,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        color: AppColors.primary,
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${(skill.proficiency * 100).round()}%'),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Tags
              if (skill.tags.isNotEmpty) ...[
                Text('Tags',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: skill.tags.map((tag) => Chip(
                        label: Text(tag,
                            style: const TextStyle(fontSize: 11)),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      )).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              // Related edges
              if (edges.isNotEmpty) ...[
                Text('Connections',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                const SizedBox(height: 4),
                ...edges.map((edge) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              edge.sourceNodeId == skill.id
                                  ? edge.targetNodeId
                                  : edge.sourceNodeId,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          const SizedBox(width: 6),
                          KnowledgeEdgeBadge(edge: edge),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DistributionSegment extends StatelessWidget {
  const _DistributionSegment({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  final String label;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total) : 0.0;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
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
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: color.withValues(alpha: 0.1),
                color: color,
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
