import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/sample_data_service.dart';
import '../../theme/spacing.dart';
import '../mission_engine/mission_service.dart';
import 'widgets/mission_actions_card.dart';
import 'widgets/mission_header.dart';
import 'widgets/mission_progress_card.dart';
import 'widgets/mission_statistics_card.dart';
import 'widgets/mission_tasks_card.dart';

class MissionCenterScreen extends StatelessWidget {
  const MissionCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sampleData = const SampleDataService();
    final missionService = MissionService(seedSource: sampleData);
    final missionProgress = missionService.buildProgress();
    final featuredMission = missionProgress.featuredMission;
    final allMissions = [
      ...missionProgress.dailyMissions,
      ...missionProgress.weeklyMissions,
    ];

    final taskItems = allMissions
        .map(
          (m) => MissionTaskItem(
            title: m.title,
            completed: m.completed,
            subtitle: m.description,
          ),
        )
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MissionHeader(
            title: featuredMission.title,
            description: featuredMission.description,
            statusLabel: missionProgress.pendingCount > 0
                ? 'In Progress'
                : 'Complete',
            priority: featuredMission.priority,
          ),
          const SizedBox(height: AppSpacing.lg),
          MissionProgressCard(
            progressPercentage: missionProgress.completionPercentage,
            completedTasks: missionProgress.completedCount,
            remainingTasks: missionProgress.pendingCount,
          ),
          const SizedBox(height: AppSpacing.lg),
          MissionTasksCard(tasks: taskItems),
          const SizedBox(height: AppSpacing.lg),
          MissionStatisticsCard(
            totalTasks: allMissions.length,
            completedTasks: missionProgress.completedCount,
            pendingTasks: missionProgress.pendingCount,
            completionPercentage: missionProgress.completionPercentage,
          ),
          const SizedBox(height: AppSpacing.lg),
          MissionActionsCard(
            onContinueMission: () =>
                Navigator.of(context).pushNamed(AppRoutes.academy),
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
