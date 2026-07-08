import 'package:flutter/material.dart';

import '../../models/level.dart';
import '../../models/stage.dart';
import '../../services/sample_data_service.dart';
import '../../shared/widgets/phoenix_card.dart';
import '../../shared/widgets/phoenix_progress_indicator.dart';
import '../../shared/widgets/phoenix_section_header.dart';
import '../../theme/colors.dart';
import '../../theme/radius.dart';
import '../../theme/spacing.dart';

class AcademyScreen extends StatelessWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sampleData = const SampleDataService();
    final academy = sampleData.featuredAcademy;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Academy', style: theme.textTheme.titleLarge),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhoenixCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(academy.title, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      academy.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PhoenixProgressIndicator(value: 0.35),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PhoenixSectionHeader(title: 'Learning Path'),
              const SizedBox(height: AppSpacing.sm),
              ...academy.levels.map(
                (level) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _AcademyLevelTile(level: level),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AcademyLevelTile extends StatelessWidget {
  const _AcademyLevelTile({required this.level});

  final Level level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(level.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          ...level.stages.map(
            (stage) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _StageTile(stage: stage),
            ),
          ),
        ],
      ),
    );
  }
}

class _StageTile extends StatelessWidget {
  const _StageTile({required this.stage});

  final Stage stage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stage.title, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          ...stage.missions.map(
            (mission) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.radio_button_checked, size: 16, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      mission.title,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
