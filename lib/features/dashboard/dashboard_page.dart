import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/sample_data_service.dart';
import '../../theme/spacing.dart';
import '../knowledge_dna/knowledge_dna_service.dart';
import '../mission_engine/mission_service.dart';
import '../progress_engine/progress_service.dart';
import 'widgets/knowledge_dna_card.dart';
import 'widgets/mission_summary_card.dart';
import 'widgets/progress_card.dart';
import 'widgets/quick_actions_card.dart';
import 'widgets/streak_card.dart';
import 'widgets/welcome_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sampleData = const SampleDataService();
    final missionProgress = MissionService(seedSource: sampleData).buildProgress();
    final progressSummary = ProgressService(seedSource: sampleData).buildSummary();
    final knowledgeDNA = KnowledgeDNAService(seedSource: sampleData).buildAnalysis();
    final knowledgeProfile = sampleData.knowledgeProfile;
    final missionsAvailable = missionProgress.dailyMissions.length + missionProgress.weeklyMissions.length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Dashboard', style: theme.textTheme.titleLarge),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WelcomeCard(
                greeting: 'Good morning, Ava',
                currentLevel: progressSummary.level,
                totalXp: progressSummary.totalXp,
              ),
              const SizedBox(height: AppSpacing.lg),
              MissionSummaryCard(
                missionsAvailable: missionsAvailable,
                missionsCompleted: missionProgress.completedCount,
                completionPercentage: missionProgress.completionPercentage,
              ),
              const SizedBox(height: AppSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  final useTwoColumns = constraints.maxWidth >= 720;

                  if (!useTwoColumns) {
                    return Column(
                      children: [
                        ProgressCard(
                          currentLevel: progressSummary.level,
                          totalXp: progressSummary.totalXp,
                          overallProgress: progressSummary.completionPercentage,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        StreakCard(
                          dailyStreak: progressSummary.streaks.daily,
                          weeklyStreak: progressSummary.streaks.weekly,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        KnowledgeDNACard(
                          confidence: knowledgeDNA.confidenceScore,
                          retention: knowledgeDNA.retentionScore,
                          consistency: knowledgeProfile.consistency,
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ProgressCard(
                          currentLevel: progressSummary.level,
                          totalXp: progressSummary.totalXp,
                          overallProgress: progressSummary.completionPercentage,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: StreakCard(
                          dailyStreak: progressSummary.streaks.daily,
                          weeklyStreak: progressSummary.streaks.weekly,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: KnowledgeDNACard(
                          confidence: knowledgeDNA.confidenceScore,
                          retention: knowledgeDNA.retentionScore,
                          consistency: knowledgeProfile.consistency,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              QuickActionsCard(
                onContinueLearning: () => Navigator.of(context).pushNamed(AppRoutes.academy),
                onViewAcademy: () => Navigator.of(context).pushNamed(AppRoutes.academy),
                onViewMissions: () => Navigator.of(context).pushNamed(AppRoutes.missionCenter),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
