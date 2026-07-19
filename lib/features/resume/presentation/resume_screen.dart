import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/spacing.dart';
import '../models/resume.dart';
import '../widgets/achievements_card.dart';
import '../widgets/career_highlights_card.dart';
import '../widgets/professional_summary_card.dart';
import '../widgets/projects_card.dart';
import '../widgets/resume_actions_card.dart';
import '../widgets/resume_header.dart';
import '../widgets/resume_statistics_card.dart';
import '../widgets/skills_card.dart';

/// The Living Resume screen automatically generates a resume from the
/// user's Living Portfolio and Career Profile.
///
/// All data is derived from existing Phoenix engine snapshots — no
/// SampleRepository, no manual editing, no AI.
///
/// Presentation only. StatelessWidget.
class ResumeScreen extends StatelessWidget {
  const ResumeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final identityEngine = AppBootstrap.maybeIdentityEngine;
    final identitySnap = identityEngine?.snapshot;
    final portfolioEngine = AppBootstrap.maybePortfolioEngine;
    final portfolioSnap = portfolioEngine?.snapshot;
    final careerEngine = AppBootstrap.maybeCareerEngine;
    final careerSnap = careerEngine?.snapshot;
    final resumeEngine = AppBootstrap.maybeResumeIntelligenceEngine;
    final resumeSnap = resumeEngine?.snapshot;

    final identityTitle = identitySnap?.currentIdentityTitle ?? 'Phoenix User';
    final careerReadiness = careerSnap?.jobReadiness ?? 'Starting Out';
    final resumeScore = resumeSnap?.overallScore ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResumeHeader(
            title: identityTitle,
            resumeType: ResumeType.fromIdentityTitle(identityTitle),
            resumeScore: resumeScore / 100.0,
            careerReadiness: careerReadiness,
          ),
          const SizedBox(height: AppSpacing.lg),
          ResumeStatisticsCard(
            projectCount: portfolioSnap?.projectCount ?? 0,
            skillCount: portfolioSnap?.skillCount ?? 0,
            achievementCount: portfolioSnap?.achievementCount ?? 0,
            technologyCount: portfolioSnap?.technologyCount ?? 0,
            resumeScore: resumeScore / 100.0,
          ),
          const SizedBox(height: AppSpacing.lg),
          ProfessionalSummaryCard(summary: 'Professional $identityTitle with career readiness: $careerReadiness'),
          const SizedBox(height: AppSpacing.lg),
          SkillsCard(skills: []),
          const SizedBox(height: AppSpacing.lg),
          ProjectsCard(projects: []),
          const SizedBox(height: AppSpacing.lg),
          AchievementsCard(achievements: []),
          const SizedBox(height: AppSpacing.lg),
          CareerHighlightsCard(highlights: [
            if (careerSnap != null) ...[
              'Career score: ${(careerSnap.careerScore * 100).round()}%',
              'Readiness: $careerReadiness',
              if (careerSnap.strengths.isNotEmpty)
                'Strengths: ${careerSnap.strengths.join(", ")}',
            ],
          ]),
          const SizedBox(height: AppSpacing.lg),
          ResumeActionsCard(
            onDashboard: () =>
                Navigator.of(context).pushNamed(AppRoutes.dashboard),
            onPortfolio: () =>
                Navigator.of(context).pushNamed(AppRoutes.portfolio),
            onCareer: () => Navigator.of(context).pushNamed(AppRoutes.career),
            onProgress: () =>
                Navigator.of(context).pushNamed(AppRoutes.progress),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
