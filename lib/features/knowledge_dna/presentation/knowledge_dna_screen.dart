import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';
import '../../../core/sample_repository.dart';
import '../../../theme/spacing.dart';
import '../knowledge_dna_service.dart';
import '../widgets/knowledge_actions_card.dart';
import '../widgets/knowledge_balance_card.dart';
import '../widgets/knowledge_dna_header.dart';
import '../widgets/knowledge_growth_card.dart';
import '../widgets/knowledge_strengths_card.dart';
import '../widgets/knowledge_summary_card.dart';

class KnowledgeDNAScreen extends StatelessWidget {
  const KnowledgeDNAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = const SampleRepository();
    final knowledgeService = KnowledgeDNAService(repository: repository);
    final analysis = knowledgeService.buildAnalysis();

    final strongestCategory = analysis.skillStrengths.isNotEmpty
        ? analysis.skillStrengths.first
        : 'Building';
    final weakestCategory = analysis.skillWeaknesses.isNotEmpty
        ? analysis.skillWeaknesses.first
        : 'Exploring';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KnowledgeDnaHeader(
            userName: 'Ava',
            dnaScore: analysis.knowledgeScore,
            learningProfile: analysis.summary,
          ),
          const SizedBox(height: AppSpacing.lg),
          KnowledgeSummaryCard(
            overallScore: analysis.knowledgeScore,
            strongestCategory: strongestCategory,
            weakestCategory: weakestCategory,
          ),
          const SizedBox(height: AppSpacing.lg),
          KnowledgeStrengthsCard(
            strengths: analysis.skillStrengths,
            confidenceScore: analysis.confidenceScore,
          ),
          const SizedBox(height: AppSpacing.lg),
          KnowledgeGrowthCard(
            weaknesses: analysis.skillWeaknesses,
            learningVelocity: analysis.learningVelocity,
          ),
          const SizedBox(height: AppSpacing.lg),
          KnowledgeBalanceCard(
            knowledgeScore: analysis.knowledgeScore,
            confidenceScore: analysis.confidenceScore,
            retentionScore: analysis.retentionScore,
            learningVelocity: analysis.learningVelocity,
          ),
          const SizedBox(height: AppSpacing.lg),
          _RecommendedFocusCard(
            missions: analysis.recommendedMissions,
            academies: analysis.recommendedAcademies,
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
}

/// Displays recommended missions and academies from the engine.
///
/// Each list item is tappable and navigates to the relevant screen:
/// - Missions → Mission Center
/// - Academies → Academy
class _RecommendedFocusCard extends StatelessWidget {
  const _RecommendedFocusCard({
    required this.missions,
    required this.academies,
  });

  final List<dynamic> missions;
  final List<String> academies;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasMissions = missions.isNotEmpty;
    final hasAcademies = academies.isNotEmpty;

    if (!hasMissions && !hasAcademies) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
                Text('Recommended Focus', style: theme.textTheme.titleMedium),
              ],
            ),
            if (hasMissions) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Missions',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...missions
                  .take(3)
                  .map(
                    (mission) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.missionCenter,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: Row(
                            children: [
                              Icon(
                                Icons.rocket_launch_outlined,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  mission.title,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
            ],
            if (hasAcademies) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Academies',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...academies
                  .take(3)
                  .map(
                    (academy) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.academy,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: Row(
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 16,
                                color: theme.colorScheme.tertiary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  academy,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
