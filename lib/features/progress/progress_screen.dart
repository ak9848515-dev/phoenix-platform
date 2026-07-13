import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../core/sample_repository.dart';
import '../../theme/spacing.dart';
import '../progress_engine/progress_service.dart';
import 'widgets/achievement_summary_card.dart';
import 'widgets/level_progress_card.dart';
import 'widgets/progress_actions_card.dart';
import 'widgets/progress_header.dart';
import 'widgets/streak_card.dart';
import 'widgets/weekly_activity_card.dart';
import 'widgets/xp_summary_card.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = const SampleRepository();
    final progressSummary = ProgressService(
      repository: repository,
    ).buildSummary();

    final currentLevel = progressSummary.level;
    final nextLevel = currentLevel + 1;
    final xpForCurrentLevel = (currentLevel - 1) * 250;
    final xpForNextLevel = currentLevel * 250;
    final xpInCurrentLevel = progressSummary.totalXp - xpForCurrentLevel;
    final xpNeededForNextLevel = xpForNextLevel - xpForCurrentLevel;
    final levelProgress = xpNeededForNextLevel > 0
        ? (xpInCurrentLevel / xpNeededForNextLevel).clamp(0.0, 1.0)
        : 1.0;

    const weeklyDays = [
      DayActivity(label: 'M', value: 120),
      DayActivity(label: 'T', value: 200),
      DayActivity(label: 'W', value: 80),
      DayActivity(label: 'T', value: 250),
      DayActivity(label: 'F', value: 150),
      DayActivity(label: 'S', value: 90),
      DayActivity(label: 'S', value: 60),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProgressHeader(
            currentLevel: currentLevel,
            totalXp: progressSummary.totalXp,
            welcomeMessage: 'Keep building momentum',
          ),
          const SizedBox(height: AppSpacing.lg),
          XpSummaryCard(
            currentXp: progressSummary.totalXp,
            xpToNextLevel: xpNeededForNextLevel,
            progressPercentage: levelProgress,
          ),
          const SizedBox(height: AppSpacing.lg),
          LevelProgressCard(
            currentLevel: currentLevel,
            nextLevel: nextLevel,
            progressPercentage: levelProgress,
          ),
          const SizedBox(height: AppSpacing.lg),
          StreakCard(
            currentStreak: progressSummary.streaks.daily,
            bestStreak: progressSummary.streaks.weekly,
            dailyStatus: progressSummary.streaks.daily > 0
                ? '${progressSummary.streaks.daily}-day streak active'
                : 'Start your streak today',
          ),
          const SizedBox(height: AppSpacing.lg),
          AchievementSummaryCard(
            totalAchievements: progressSummary.achievements.length,
            completedAchievements: progressSummary.achievements
                .where((a) => a.completed)
                .length,
            recentAchievements: progressSummary.achievements
                .where((a) => a.completed)
                .map((a) => a.title)
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          WeeklyActivityCard(days: weeklyDays),
          const SizedBox(height: AppSpacing.lg),
          ProgressActionsCard(
            onContinueMission: () =>
                Navigator.of(context).pushNamed(AppRoutes.missionCenter),
            onDashboard: () =>
                Navigator.of(context).pushNamed(AppRoutes.dashboard),
            onLearn: () => Navigator.of(context).pushNamed(AppRoutes.academy),
            onProfile: () => Navigator.of(context).pushNamed(AppRoutes.profile),
          ),
        ],
      ),
    );
  }
}
