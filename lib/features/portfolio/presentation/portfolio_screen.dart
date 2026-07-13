import 'package:flutter/material.dart';

import '../../../core/sample_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/spacing.dart';
import '../services/portfolio_service.dart';
import '../widgets/achievements_card.dart';
import '../widgets/career_readiness_card.dart';
import '../widgets/featured_projects_card.dart';
import '../widgets/portfolio_actions_card.dart';
import '../widgets/portfolio_header.dart';
import '../widgets/portfolio_statistics_card.dart';
import '../widgets/skills_matrix_card.dart';
import '../widgets/technology_stack_card.dart';

/// The Living Portfolio screen automatically showcases the user's skills,
/// projects, achievements, and career readiness.
///
/// All data is derived from existing Phoenix modules — no manual editing,
/// no AI, no persistence, no networking, no duplicate business logic.
///
/// Presentation only. StatelessWidget.
class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = const SampleRepository();
    final portfolioService = PortfolioService(repository: repository);
    final portfolio = portfolioService.buildPortfolio();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PortfolioHeader(
            title: repository.selectedIdentity.title,
            portfolioScore: portfolio.portfolioScore,
            careerReadiness: portfolio.careerReadiness,
          ),
          const SizedBox(height: AppSpacing.lg),
          PortfolioStatisticsCard(
            projectCount: portfolio.projectCount,
            achievementCount: portfolio.achievementCount,
            technologyCount: portfolio.technologyCount,
            skillCount: portfolio.skills.length,
            portfolioScore: portfolio.portfolioScore,
          ),
          const SizedBox(height: AppSpacing.lg),
          FeaturedProjectsCard(projects: portfolio.featuredProjects),
          const SizedBox(height: AppSpacing.lg),
          SkillsMatrixCard(skills: portfolio.skills),
          const SizedBox(height: AppSpacing.lg),
          TechnologyStackCard(technologies: portfolio.technologies),
          const SizedBox(height: AppSpacing.lg),
          AchievementsCard(achievements: portfolio.achievements),
          const SizedBox(height: AppSpacing.lg),
          CareerReadinessCard(
            careerScore: portfolio.portfolioScore,
            careerReadiness: portfolio.careerReadiness,
            strengthAreas: portfolio.strengthAreas,
            improvementAreas: portfolio.improvementAreas,
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
