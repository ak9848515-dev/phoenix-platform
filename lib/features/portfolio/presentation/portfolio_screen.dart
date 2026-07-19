import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/phoenix_empty_state.dart';
import '../../../shared/widgets/phoenix_error_state.dart';
import '../../../theme/spacing.dart';
import '../models/portfolio_skill.dart';
import '../widgets/achievements_card.dart';
import '../widgets/career_readiness_card.dart';
import '../widgets/featured_projects_card.dart';
import '../widgets/portfolio_actions_card.dart';
import '../widgets/portfolio_header.dart';
import '../widgets/portfolio_statistics_card.dart';
import '../widgets/skills_matrix_card.dart';
import '../widgets/technology_stack_card.dart';

/// The Living Portfolio screen showcases the user's skills, projects,
/// achievements, and career readiness.
///
/// All data sourced from [PortfolioEngine] snapshot. No SampleRepository.
///
/// Presentation only. StatelessWidget.
class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final portfolioEngine = AppBootstrap.maybePortfolioEngine;
    final snapshot = portfolioEngine?.snapshot;

    if (snapshot == null) {
      return PhoenixErrorState(
        category: PhoenixErrorCategory.data,
        title: 'Portfolio data unavailable',
        message: "We couldn't load your portfolio right now. "
            'Your existing data is safe and will be available shortly.',
        actionLabel: 'Try Again',
        onAction: () => Navigator.of(context).pushReplacementNamed(
          AppRoutes.portfolio,
        ),
      );
    }

    if (snapshot.portfolioScore == 0.0 && snapshot.strengthAreas.isEmpty) {
      return const PhoenixEmptyState(
        icon: Icons.folder_outlined,
        title: 'Portfolio is empty',
        message: 'Your portfolio showcases your projects, skills, and achievements. '
            'Start learning and building to populate your portfolio.',
        positiveMessage: 'Every expert was once a beginner',
        primaryAction: _StartBuildingButton(),
      );
    }

    // Build typed objects from snapshot data
    final skills = snapshot.strengthAreas.map((name) => PortfolioSkill(
          id: 'skill-${name.toLowerCase().replaceAll(' ', '_')}',
          name: name,
          proficiency: 0.85,
          category: 'General',
          isStrength: true,
        )).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PortfolioHeader(
            title: 'Portfolio',
            portfolioScore: snapshot.portfolioScore,
            careerReadiness: snapshot.careerReadiness,
          ),
          const SizedBox(height: AppSpacing.lg),
          PortfolioStatisticsCard(
            projectCount: snapshot.projectCount,
            achievementCount: snapshot.achievementCount,
            technologyCount: snapshot.technologyCount,
            skillCount: snapshot.skillCount,
            portfolioScore: snapshot.portfolioScore,
          ),
          const SizedBox(height: AppSpacing.lg),
          FeaturedProjectsCard(projects: const []),
          const SizedBox(height: AppSpacing.lg),
          SkillsMatrixCard(skills: skills),
          const SizedBox(height: AppSpacing.lg),
          TechnologyStackCard(
            technologies: snapshot.technologies,
          ),
          const SizedBox(height: AppSpacing.lg),
          AchievementsCard(achievements: const []),
          const SizedBox(height: AppSpacing.lg),
          CareerReadinessCard(
            careerScore: snapshot.portfolioScore,
            careerReadiness: snapshot.careerReadiness,
            strengthAreas: snapshot.strengthAreas,
            improvementAreas: snapshot.improvementAreas,
          ),
          const SizedBox(height: AppSpacing.lg),
          PortfolioActionsCard(
            onDashboard: () =>
                Navigator.of(context).pushNamed(AppRoutes.dashboard),
            onCareer: () => Navigator.of(context).pushNamed(AppRoutes.career),
            onJourney: () => Navigator.of(context).pushNamed(AppRoutes.journey),
            onProgress: () =>
                Navigator.of(context).pushNamed(AppRoutes.progress),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

/// Reusable start-building button for empty portfolio state.
class _StartBuildingButton extends StatelessWidget {
  const _StartBuildingButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.academy),
      icon: const Icon(Icons.build_rounded, size: 18),
      label: const Text('Start Building'),
    );
  }
}
