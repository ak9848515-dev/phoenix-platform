import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../services/knowledge_service.dart';
import '../widgets/knowledge_insight_card.dart';
import '../widgets/knowledge_node_card.dart';
import '../widgets/knowledge_recommendation_card.dart';
import 'knowledge_search_screen.dart';
import 'skills_map_screen.dart';

/// Knowledge Dashboard — main view for the Personal Knowledge Graph.
class KnowledgeDashboardScreen extends StatefulWidget {
  const KnowledgeDashboardScreen({super.key});

  @override
  State<KnowledgeDashboardScreen> createState() =>
      _KnowledgeDashboardScreenState();
}

class _KnowledgeDashboardScreenState extends State<KnowledgeDashboardScreen> {
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
      return const Center(child: CircularProgressIndicator());
    }

    final analytics = svc.analytics;
    final insights = svc.insights;
    final recommendations = svc.recommendations;
    final snapshot = svc.snapshot;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, svc, analytics),
          const SizedBox(height: AppSpacing.lg),
          _buildStatsRow(context, analytics),
          const SizedBox(height: AppSpacing.lg),
          if (recommendations.isNotEmpty) ...[
            _buildSectionTitle(
                context, 'Recommended Actions', Icons.north_east_rounded),
            const SizedBox(height: AppSpacing.sm),
            ...recommendations.take(3).map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: KnowledgeRecommendationCard(
                    recommendation: rec,
                  ),
                )),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (insights.isNotEmpty) ...[
            _buildSectionTitle(
                context, 'Knowledge Insights', Icons.lightbulb_rounded),
            const SizedBox(height: AppSpacing.sm),
            ...insights.take(4).map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: KnowledgeInsightCard(
                    insight: insight,
                  ),
                )),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (snapshot.nodes.isNotEmpty) ...[
            _buildSectionTitle(
                context, 'Recent Knowledge', Icons.history_rounded),
            const SizedBox(height: AppSpacing.sm),
            ...snapshot.nodes.take(5).map((node) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: KnowledgeNodeCard(node: node),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, KnowledgeService svc,
      Map<String, dynamic> analytics) {
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
              Icons.psychology_rounded,
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
                  'Personal Knowledge',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${analytics['nodeCount']} knowledge nodes, '
                  '${analytics['domainCoverage']} domains',
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
                builder: (_) => const KnowledgeSearchScreen(),
              ),
            ),
            tooltip: 'Search knowledge',
          ),
          IconButton(
            icon: const Icon(Icons.map_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SkillsMapScreen(),
              ),
            ),
            tooltip: 'Skills map',
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
      BuildContext context, Map<String, dynamic> analytics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: '${analytics['nodeCount']}',
                label: 'Knowledge',
                icon: Icons.psychology_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatTile(
                value: '${analytics['domainCoverage']}',
                label: 'Domains',
                icon: Icons.category_rounded,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatTile(
                value: '${analytics['edgeCount']}',
                label: 'Connections',
                icon: Icons.link_rounded,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: '${analytics['skillCount']}',
                label: 'Skills',
                icon: Icons.psychology_rounded,
                color: const Color(0xFF7C4DFF),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatTile(
                value: '${analytics['goalCount']}',
                label: 'Goals',
                icon: Icons.flag_rounded,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatTile(
                value: '${analytics['learningCount']}',
                label: 'Learning',
                icon: Icons.school_rounded,
                color: const Color(0xFF00BCD4),
              ),
            ),
          ],
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
