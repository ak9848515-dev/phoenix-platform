import '../../core/repository.dart';
import '../../core/sample_repository.dart';
import '../mission_engine/mission_engine.dart';
import '../mission_engine/mission_service.dart';
import 'achievement_engine.dart';
import 'level_calculator.dart';
import 'progress_engine.dart';
import 'progress_summary.dart';
import 'streak_calculator.dart';
import 'xp_calculator.dart';

/// Orchestrates progress metrics from mission completion data.
class ProgressService {
  ProgressService({Repository? repository})
    : repository = repository ?? const SampleRepository();

  final Repository repository;

  MissionService get missionService => MissionService(repository: repository);

  ProgressSummary buildSummary() {
    final missions = <Mission>[
      ...missionService.dailyMissions,
      ...missionService.weeklyMissions,
    ];
    final completedMissions = missions
        .where((mission) => mission.completed)
        .toList();
    final totalXp = XPCalculator().calculate(
      completedMissions.map((mission) => mission.xpReward).toList(),
    );
    final level = LevelCalculator().calculate(totalXp);
    final completionPercentage = missions.isEmpty
        ? 0.0
        : completedMissions.length / missions.length;
    final streaks = Streaks(
      daily: StreakCalculator().calculateDaily(
        missionService.dailyMissions
            .map((mission) => mission.completed)
            .toList(),
      ),
      weekly: StreakCalculator().calculateWeekly(
        missionService.weeklyMissions
            .map((mission) => mission.completed)
            .toList(),
      ),
      monthly: StreakCalculator().calculateMonthly(
        missions.map((mission) => mission.completed).toList(),
      ),
    );
    final achievements = AchievementEngine().calculate(
      completedMissions.length,
      missions.length,
    );

    // Incorporate Journey completion into the progress summary,
    // connecting Progress to Journey.
    final journey = repository.journey;
    final journeyPercent = (journey.completion * 100).round();
    final combinedSummary =
        '$level • ${completedMissions.length}/${missions.length} missions • '
        'Journey $journeyPercent%';

    return ProgressSummary(
      totalXp: totalXp,
      level: level,
      completionPercentage: completionPercentage,
      streaks: streaks,
      achievements: achievements,
      summary: combinedSummary,
    );
  }
}
