import 'package:flutter/material.dart';

import '../../../services/sample_data_service.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import 'widgets/knowledge_dna_progress_card.dart';
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
    final profile = sampleData.knowledgeProfile;

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
              Text(
                'A beautiful snapshot of your growth, strengths, and focus areas.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              KnowledgeDNATopProgressCard(profile: profile),
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
                    title: 'Confidence',
                    value: '${(profile.confidence * 100).toInt()}%',
                    accentColor: AppColors.primary,
                  ),
                  KnowledgeDNAStatCard(
                    title: 'Retention',
                    value: '${(profile.retention * 100).toInt()}%',
                    accentColor: AppColors.success,
                  ),
                  KnowledgeDNAStatCard(
                    title: 'Consistency',
                    value: '${(profile.consistency * 100).toInt()}%',
                    accentColor: AppColors.warning,
                  ),
                  KnowledgeDNAStatCard(
                    title: 'Velocity',
                    value: '${(profile.learningVelocity * 100).toInt()}%',
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
                children: profile.strongAreas
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
                children: profile.weakAreas
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
                    Text('Career Focus', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      profile.careerGoal,
                      style: theme.textTheme.bodyLarge,
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
