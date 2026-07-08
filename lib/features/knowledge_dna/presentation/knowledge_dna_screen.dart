import 'package:flutter/material.dart';

import '../../../services/sample_data_service.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../knowledge_dna_service.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import 'widgets/knowledge_dna_stat_card.dart';

/// Presentation-only screen for the Knowledge DNA experience.
///
/// It uses placeholder data and reusable widgets to showcase the visual
/// structure of the feature without introducing navigation or logic.
class KnowledgeDNAScreen extends StatelessWidget {
  const KnowledgeDNAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sampleData = const SampleDataService();
    final knowledgeService = KnowledgeDNAService(seedSource: sampleData);
    final analysis = knowledgeService.buildAnalysis();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Knowledge DNA', style: theme.textTheme.titleLarge),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your learning profile',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              PhoenixCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Knowledge DNA', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      analysis.summary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Confidence ${((analysis.confidenceScore) * 100).toInt()}% • Retention ${((analysis.retentionScore) * 100).toInt()}%',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'A beautiful snapshot of your growth, strengths, and focus areas.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PhoenixCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Learning intelligence', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Knowledge ${((analysis.knowledgeScore) * 100).toInt()}%'),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Velocity ${((analysis.learningVelocity) * 100).toInt()}%'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.1,
                children: [
                  KnowledgeDNAStatCard(
                    title: 'Knowledge',
                    value: '${(analysis.knowledgeScore * 100).toInt()}%',
                    accentColor: AppColors.primary,
                  ),
                  KnowledgeDNAStatCard(
                    title: 'Confidence',
                    value: '${(analysis.confidenceScore * 100).toInt()}%',
                    accentColor: AppColors.success,
                  ),
                  KnowledgeDNAStatCard(
                    title: 'Retention',
                    value: '${(analysis.retentionScore * 100).toInt()}%',
                    accentColor: AppColors.warning,
                  ),
                  KnowledgeDNAStatCard(
                    title: 'Velocity',
                    value: '${(analysis.learningVelocity * 100).toInt()}%',
                    accentColor: AppColors.secondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Highlights', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: analysis.skillStrengths
                    .map(
                      (area) => Chip(
                        label: Text(area),
                        backgroundColor: AppColors.success.withValues(alpha: 0.14),
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Growth Areas', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: analysis.skillWeaknesses
                    .map(
                      (area) => Chip(
                        label: Text(area),
                        backgroundColor: AppColors.warning.withValues(alpha: 0.14),
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              PhoenixCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recommended focus', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    ...analysis.recommendedMissions.map(
                      (mission) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text('- ${mission.title}', style: theme.textTheme.bodyMedium),
                      ),
                    ),
                    ...analysis.recommendedAcademies.map(
                      (academy) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text('- $academy', style: theme.textTheme.bodyMedium),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
