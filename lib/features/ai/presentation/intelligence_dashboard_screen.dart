import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_empty_state.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../engine/cross_feature_reasoner.dart' show CrossFeatureResult;
import '../models/phoenix_daily_brief.dart' show PhoenixDailyBrief;
import '../services/phoenix_ai_service.dart' show PhoenixAIService;

/// Intelligence Dashboard — the central hub for the Phoenix Intelligence Layer.
class IntelligenceDashboardScreen extends StatelessWidget {
  const IntelligenceDashboardScreen({
    super.key,
    required this.phoenixAI,
  });

  final PhoenixAIService phoenixAI;

  @override
  Widget build(BuildContext context) {
    final brief = phoenixAI.generateBrief();
    final crossResult = phoenixAI.analyzeCrossFeature();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intelligence Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _TodayBriefCard(brief: brief),
          const SizedBox(height: AppSpacing.md),
          _RecommendationsCard(brief: brief),
          const SizedBox(height: AppSpacing.md),
          _InsightsCard(crossResult: crossResult),
          const SizedBox(height: AppSpacing.md),
          _RisksCard(crossResult: crossResult),
          const SizedBox(height: AppSpacing.md),
          _OpportunitiesCard(crossResult: crossResult),
          const SizedBox(height: AppSpacing.md),
          _ProgressCard(brief: brief, crossResult: crossResult),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ── Section Cards ──────────────────────────────────────────────────────

class _TodayBriefCard extends StatelessWidget {
  const _TodayBriefCard({required this.brief});
  final PhoenixDailyBrief brief;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.today, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text("Today's Brief",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                const Spacer(),
                _ConfidenceBadge(confidence: brief.confidenceScore),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Divider(height: 1),
            ),
            Text(brief.todaysFocus, style: theme.textTheme.bodyLarge),
            if (brief.overallDailySummary.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(brief.overallDailySummary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecommendationsCard extends StatelessWidget {
  const _RecommendationsCard({required this.brief});
  final PhoenixDailyBrief brief;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recs = brief.recommendations;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    color: AppColors.warning, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text('Top Recommendations',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                const Spacer(),
                Text('${recs.length} total',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Divider(height: 1),
            ),
            if (recs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: InlineEmptyState(
                  icon: Icons.lightbulb_outline,
                  title: 'No recommendations yet',
                  message: 'Recommendations appear as you complete missions '
                      'and build your journey.',
                  positiveMessage: 'Every completed mission unlocks new insights.',
                ),
              )
            else
              ...recs.take(5).map((rec) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PriorityDot(rec.priority.name),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(rec.title,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  )),
                              if (rec.description != null &&
                                  rec.description!.isNotEmpty)
                                Text(rec.description!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant,
                                    )),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text('${(rec.confidence * 100).round()}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            )),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _InsightsCard extends StatelessWidget {
  const _InsightsCard({required this.crossResult});
  final CrossFeatureResult crossResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insights = crossResult.insights;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology_outlined,
                    color: AppColors.info, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text('Cross-Domain Insights',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                const Spacer(),
                Text('${insights.length} found',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Divider(height: 1),
            ),
            if (insights.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: InlineEmptyState(
                  icon: Icons.psychology_outlined,
                  title: 'No insights yet',
                  message: 'Cross-domain insights emerge as you engage across '
                      'missions, habits, and knowledge.',
                  positiveMessage: 'The more you use Phoenix, the more it connects the dots.',
                ),
              )
            else
              ...insights.map((i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(i.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            )),
                        if (i.description.isNotEmpty)
                          Text(i.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              )),
                        const SizedBox(height: AppSpacing.xs),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: i.confidence,
                            backgroundColor: theme
                                .colorScheme.surfaceContainerHighest,
                            color: AppColors.primary,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _RisksCard extends StatelessWidget {
  const _RisksCard({required this.crossResult});
  final CrossFeatureResult crossResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final risks = crossResult.risks;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: AppColors.error, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text('Risks',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                const Spacer(),
                Text('${risks.length} detected',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Divider(height: 1),
            ),
            if (risks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text('No risks detected. Good momentum!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              )
            else
              ...risks.map((r) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SeverityBadge(r.severity.name),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.title,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  )),
                              Text(r.description,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _OpportunitiesCard extends StatelessWidget {
  const _OpportunitiesCard({required this.crossResult});
  final CrossFeatureResult crossResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opportunities = crossResult.opportunities;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_outlined,
                    color: AppColors.success, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text('Opportunities',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                const Spacer(),
                Text('${opportunities.length} found',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Divider(height: 1),
            ),
            if (opportunities.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: InlineEmptyState(
                  icon: Icons.auto_awesome_outlined,
                  title: 'No opportunities yet',
                  message: 'New opportunities will surface as your skills and '
                      'portfolio grow.',
                  positiveMessage: 'Every new skill opens a door.',
                ),
              )
            else
              ...opportunities.map((o) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            )),
                        if (o.description.isNotEmpty)
                          Text(o.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              )),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard(
      {required this.brief, required this.crossResult});
  final PhoenixDailyBrief brief;
  final CrossFeatureResult crossResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up_rounded,
                    color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text('Overall Progress',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Divider(height: 1),
            ),
            Text(brief.overallDailySummary,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                )),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatChip(
                    icon: Icons.insights_outlined,
                    label: 'Insights',
                    value: '${crossResult.insights.length}'),
                _StatChip(
                    icon: Icons.warning_amber_rounded,
                    label: 'Risks',
                    value: '${crossResult.risks.length}'),
                _StatChip(
                    icon: Icons.auto_awesome_outlined,
                    label: 'Opportunities',
                    value: '${crossResult.opportunities.length}'),
                _StatChip(
                    icon: Icons.lightbulb_outline,
                    label: 'Recs',
                    value: '${brief.recommendations.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared Widgets ─────────────────────────────────────────────────────

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.confidence});
  final double confidence;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (confidence * 100).round();
    final color = pct >= 70
        ? AppColors.success
        : pct >= 40
            ? AppColors.warning
            : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$pct%',
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          )),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  const _PriorityDot(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (label) {
      'critical' => AppColors.error,
      'high' => AppColors.warning,
      'medium' => AppColors.info,
      _ => theme.colorScheme.onSurfaceVariant,
    };
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (color, text) = switch (label) {
      'high' => (AppColors.error, 'HIGH'),
      'medium' => (AppColors.warning, 'MED'),
      _ => (theme.colorScheme.onSurfaceVariant, 'LOW'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          )),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            )),
        Text(label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            )),
      ],
    );
  }
}
