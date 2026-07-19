import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/phoenix_empty_state.dart';
import '../../../shared/widgets/phoenix_error_state.dart';
import '../../../theme/spacing.dart';
import '../widgets/knowledge_actions_card.dart';
import '../widgets/knowledge_balance_card.dart';
import '../widgets/knowledge_dna_header.dart';
import '../widgets/knowledge_growth_card.dart';
import '../widgets/knowledge_strengths_card.dart';
import '../widgets/knowledge_summary_card.dart';

/// Knowledge DNA Screen — visualizes the user's knowledge profile.
///
/// All data sourced from [KnowledgeEngine] snapshot. No SampleRepository.
class KnowledgeDNAScreen extends StatelessWidget {
  const KnowledgeDNAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final knowledgeEngine = AppBootstrap.maybeKnowledgeEngine;
    final growthEngine = AppBootstrap.maybeGrowthEngine;

    if (knowledgeEngine == null) {
      return PhoenixErrorState(
        category: PhoenixErrorCategory.data,
        title: 'Knowledge data unavailable',
        message: "We couldn't load your knowledge map right now. "
            'Your learning progress is safe and will be available shortly.',
        actionLabel: 'Try Again',
        onAction: () => Navigator.of(context).pushReplacementNamed(
          AppRoutes.knowledgeDna,
        ),
      );
    }

    final analytics = knowledgeEngine.analytics;
    final insights = knowledgeEngine.insights;

    // Knowledge score from GrowthSnapshot (single source of truth)
    final knowledgeScore = growthEngine?.snapshot?.knowledge.score ?? 0.5;
    final nodeCount = analytics['nodeCount'] as int? ?? 0;
    final domainCoverage = analytics['domainCoverage'] as int? ?? 0;
    final totalDomains = analytics['totalDomains'] as int? ?? 5;

    if (nodeCount == 0 && domainCoverage == 0 && insights.isEmpty) {
      return const PhoenixEmptyState(
        icon: Icons.psychology_outlined,
        title: 'Knowledge map is empty',
        message: 'Your knowledge DNA maps what you know and where you can grow. '
            'Start learning to build your knowledge graph.',
        positiveMessage: 'Knowledge grows with every lesson',
        primaryAction: _StartExploringButton(),
      );
    }

    final displayScore = knowledgeScore;
    final summary =
        '${(displayScore * 100).round()}% knowledge readiness • '
        '$nodeCount nodes • $domainCoverage/$totalDomains domains';

    // Build strengths/weaknesses from analytics
    final topSkills =
        List<String>.from(analytics['topSkills'] as List? ?? []);
    final learningVelocity = _deriveLearningVelocity(analytics);

    final strengths = topSkills.isNotEmpty ? topSkills : <String>['Execution'];
    final weaknesses = analytics['topGoals'] is List
        ? List<String>.from((analytics['topGoals'] as List).take(3))
        : <String>['Explore new domains'];

    final strongestCategory = strengths.isNotEmpty ? strengths.first : 'Building';
    final weakestCategory = weaknesses.isNotEmpty ? weaknesses.first : 'Exploring';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KnowledgeDnaHeader(
            userName: 'Explorer',
            dnaScore: displayScore,
            learningProfile: summary,
          ),
          const SizedBox(height: AppSpacing.lg),
          KnowledgeSummaryCard(
            overallScore: displayScore,
            strongestCategory: strongestCategory,
            weakestCategory: weakestCategory,
          ),
          const SizedBox(height: AppSpacing.lg),
          KnowledgeStrengthsCard(
            strengths: strengths,
            confidenceScore: displayScore,
          ),
          const SizedBox(height: AppSpacing.lg),
          KnowledgeGrowthCard(
            weaknesses: weaknesses,
            learningVelocity: learningVelocity,
          ),
          const SizedBox(height: AppSpacing.lg),
          KnowledgeBalanceCard(
            knowledgeScore: displayScore,
            confidenceScore: displayScore,
            retentionScore: (displayScore * 0.9).clamp(0.0, 1.0),
            learningVelocity: learningVelocity,
          ),
          const SizedBox(height: AppSpacing.lg),
          _RecommendedFocusCard(
            skillCount: topSkills.length,
            insightCount: insights.length,
            nodeCount: nodeCount,
          ),
          const SizedBox(height: AppSpacing.lg),
          KnowledgeActionsCard(
            onDashboard: () =>
                Navigator.of(context).pushNamed(AppRoutes.dashboard),
            onMission: () =>
                Navigator.of(context).pushNamed(AppRoutes.missionCenter),
            onLearn: () => Navigator.of(context).pushNamed(AppRoutes.academy),
            onProgress: () =>
                Navigator.of(context).pushNamed(AppRoutes.progress),
          ),
        ],
      ),
    );
  }

  double _deriveLearningVelocity(Map<String, dynamic> analytics) {
    final recentCount = analytics['recentActivityCount'];
    if (recentCount is int && recentCount > 0) {
      return (recentCount / 30.0).clamp(0.0, 1.0);
    }
    final topSkills = analytics['topSkills'];
    if (topSkills is List && topSkills.isNotEmpty) {
      return 0.5;
    }
    return 0.3;
  }
}

/// Reusable start-exploring button for empty knowledge state.
class _StartExploringButton extends StatelessWidget {
  const _StartExploringButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.academy),
      icon: const Icon(Icons.explore_rounded, size: 18),
      label: const Text('Start Exploring'),
    );
  }
}

/// Displays recommended focus areas from the engine.
class _RecommendedFocusCard extends StatelessWidget {
  const _RecommendedFocusCard({
    required this.skillCount,
    required this.insightCount,
    required this.nodeCount,
  });

  final int skillCount;
  final int insightCount;
  final int nodeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return  Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(PhoenixSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('Knowledge Profile',
                    style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '$nodeCount knowledge nodes • $skillCount skills • $insightCount insights',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.academy),
                    icon: const Icon(Icons.school_outlined, size: 18),
                    label: const Text('Start Learning'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
