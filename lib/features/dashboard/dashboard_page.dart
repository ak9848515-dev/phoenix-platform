import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../core/sample_repository.dart';
import '../../theme/spacing.dart';
import '../knowledge_dna/knowledge_dna_service.dart';
import '../mission_engine/mission_service.dart';
import '../progress_engine/progress_service.dart';
import 'widgets/continue_learning_card.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/knowledge_dna_summary_card.dart';
import 'widgets/progress_summary_card.dart';
import 'widgets/quick_actions_card.dart';
import 'widgets/today_mission_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = const SampleRepository();
    final missionService = MissionService(repository: repository);
    final missionProgress = missionService.buildProgress();
    final progressSummary = ProgressService(
      repository: repository,
    ).buildSummary();
    final knowledgeDNA = KnowledgeDNAService(
      repository: repository,
    ).buildAnalysis();
    final knowledgeProfile = repository.knowledgeProfile;
    final featuredMission = missionProgress.featuredMission;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardHeader(
            greeting: 'Good morning',
            userName: 'Ava',
            welcomeMessage: 'Ready for today\'s growth journey?',
          ),
          const SizedBox(height: AppSpacing.lg),
          TodayMissionCard(
            missionTitle: featuredMission.title,
            missionDescription: featuredMission.description,
            progress: missionProgress.completionPercentage,
            status: missionProgress.pendingCount > 0
                ? 'In Progress'
                : 'Complete',
          ),
          const SizedBox(height: AppSpacing.lg),
          ContinueLearningCard(
            courseTitle: 'Leadership Lab',
            lessonTitle: 'Foundation • Mindset',
            onContinue: () =>
                Navigator.of(context).pushNamed(AppRoutes.academy),
          ),
          const SizedBox(height: AppSpacing.lg),
          ProgressSummaryCard(
            totalXp: progressSummary.totalXp,
            currentLevel: progressSummary.level,
            currentStreak: progressSummary.streaks.daily,
          ),
          const SizedBox(height: AppSpacing.lg),
          KnowledgeDNASummaryCard(
            topStrengths:
                '${knowledgeProfile.strongAreas.firstOrNull ?? "Building"} & ${knowledgeProfile.strongAreas.length > 1 ? knowledgeProfile.strongAreas[1] : "Growing"}',
            knowledgeBalance: knowledgeDNA.knowledgeScore,
            strongAreas: knowledgeProfile.strongAreas,
          ),
          const SizedBox(height: AppSpacing.lg),
          QuickActionsCard(
            onMission: () =>
                Navigator.of(context).pushNamed(AppRoutes.missionCenter),
            onLearn: () => Navigator.of(context).pushNamed(AppRoutes.academy),
            onProgress: () =>
                Navigator.of(context).pushNamed(AppRoutes.dashboard),
            onProfile: () => Navigator.of(context).pushNamed(AppRoutes.profile),
          ),
        ],
      ),
    );
  }
}
