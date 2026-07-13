import 'package:flutter/material.dart';

import '../../../core/sample_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/spacing.dart';
import '../services/resume_service.dart';
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
/// All data is derived from existing Phoenix modules — no manual editing,
/// no AI, no persistence, no networking, no duplicate storage.
///
/// Presentation only. StatelessWidget.
class ResumeScreen extends StatelessWidget {
  const ResumeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = const SampleRepository();
    final resumeService = ResumeService(repository: repository);
    final resume = resumeService.buildResume();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResumeHeader(
            title: repository.selectedIdentity.title,
            resumeType: resume.resumeType,
            resumeScore: resume.resumeScore,
            careerReadiness: resume.careerReadiness,
          ),
          const SizedBox(height: AppSpacing.lg),
          ResumeStatisticsCard(
            projectCount: resume.projectCount,
            skillCount: resume.skillCount,
            achievementCount: resume.achievements.length,
            technologyCount: resume.technologyStack.length,
            resumeScore: resume.resumeScore,
          ),
          const SizedBox(height: AppSpacing.lg),
          ProfessionalSummaryCard(summary: resume.professionalSummary),
          const SizedBox(height: AppSpacing.lg),
          SkillsCard(skills: resume.skills),
          const SizedBox(height: AppSpacing.lg),
          ProjectsCard(projects: resume.projects),
          const SizedBox(height: AppSpacing.lg),
          AchievementsCard(achievements: resume.achievements),
          const SizedBox(height: AppSpacing.lg),
          CareerHighlightsCard(highlights: resume.careerHighlights),
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
