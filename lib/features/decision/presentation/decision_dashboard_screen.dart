import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/decision_analysis.dart';
import 'decision_history_screen.dart';
import 'decision_wizard_screen.dart';

/// Decision Dashboard — overview of decision intelligence.
///
/// Shows:
/// - Total decisions analysed
/// - Recent decisions
/// - Quick actions (create new decision, view history)
/// - Top recommendation from latest analysis
class DecisionDashboardScreen extends StatefulWidget {
  const DecisionDashboardScreen({super.key});

  @override
  State<DecisionDashboardScreen> createState() =>
      _DecisionDashboardScreenState();
}

class _DecisionDashboardScreenState extends State<DecisionDashboardScreen> {
  List<DecisionAnalysis> _analyses = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  void _loadData() {
    final svc = AppBootstrap.maybeDecisionService;
    if (svc == null) return;
    setState(() {
      _analyses = svc.allAnalyses;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          const SizedBox(height: AppSpacing.lg),
          _buildStatsRow(theme),
          const SizedBox(height: AppSpacing.lg),
          _buildRecentDecisions(theme),
          const SizedBox(height: AppSpacing.lg),
          _buildQuickActions(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_tree_rounded,
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
                      'Decision Intelligence',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Make better decisions with data-driven analysis',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    final total = _analyses.length;
    final withOutcomes = _analyses.where((a) => a.outcome != null).length;
    final avgConfidence = _analyses.isEmpty
        ? 0.0
        : _analyses.fold(0.0, (sum, a) => sum + a.confidence) / total;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '$total',
            label: 'Analyses',
            icon: Icons.analytics_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            value: '$withOutcomes',
            label: 'Outcomes',
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            value: '${(avgConfidence * 100).round()}%',
            label: 'Avg Confidence',
            icon: Icons.trending_up_rounded,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentDecisions(ThemeData theme) {
    final recent = _analyses.reversed.take(5).toList();

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Decisions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_analyses.isNotEmpty)
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const DecisionHistoryScreen(),
                    ),
                  ),
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_rounded,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'No decisions yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...recent.map((analysis) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const DecisionHistoryScreen(),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _iconForType(analysis.decisionType),
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              analysis.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              analysis.decisionType.label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: analysis.outcome != null
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          analysis.outcome != null ? 'Done' : 'Open',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: analysis.outcome != null
                                ? AppColors.success
                                : AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PhoenixPrimaryButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const DecisionWizardScreen(),
              ),
            ),
            label: 'New Decision Analysis',
            icon: Icons.add_rounded,
            fullWidth: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          PhoenixPrimaryButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const DecisionHistoryScreen(),
              ),
            ),
            label: 'View Decision History',
            icon: Icons.history_rounded,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  IconData _iconForType(dynamic type) {
    return Icons.account_tree_rounded;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
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
