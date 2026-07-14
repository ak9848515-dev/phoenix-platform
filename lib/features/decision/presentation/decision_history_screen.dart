import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/decision_analysis.dart';

/// Decision history — past decisions with outcomes.
class DecisionHistoryScreen extends StatefulWidget {
  const DecisionHistoryScreen({super.key});

  @override
  State<DecisionHistoryScreen> createState() => _DecisionHistoryScreenState();
}

class _DecisionHistoryScreenState extends State<DecisionHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final svc = AppBootstrap.maybeDecisionService;
    final analyses = svc?.allAnalyses ?? [];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Decision History'),
      ),
      body: analyses.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_rounded,
                      size: 64, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: AppSpacing.md),
                  Text('No decisions yet',
                      style: theme.textTheme.titleMedium),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: analyses.length,
              itemBuilder: (context, index) {
                final analysis = analyses.reversed.toList()[index];
                return _buildDecisionCard(analysis, theme);
              },
            ),
    );
  }

  Widget _buildDecisionCard(DecisionAnalysis analysis, ThemeData theme) {
    final hasOutcome = analysis.outcome != null;
    final top = analysis.topRecommendation;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasOutcome
              ? AppColors.success.withValues(alpha: 0.3)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  analysis.decisionType.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                hasOutcome ? 'Completed' : 'In Progress',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: hasOutcome ? AppColors.success : AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            analysis.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (top != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Chosen: ${top.title}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (hasOutcome && analysis.outcome!.satisfaction != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.star_rounded,
                    size: 16, color: AppColors.warning),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Satisfaction: ${analysis.outcome!.satisfaction}/10',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
