import '../../services/sample_data_service.dart';
import '../mission_engine/mission_engine.dart';
import '../mission_engine/mission_service.dart';
import '../persistence/local_progress_repository.dart';
import '../persistence/progress_repository.dart';
import 'achievement_engine.dart';
import 'level_calculator.dart';
import 'progress_engine.dart';
import 'progress_summary.dart';
import 'streak_calculator.dart';
import 'xp_calculator.dart';

/// Orchestrates progress metrics from mission completion data.
class ProgressService {
  ProgressService({
    SampleDataService? seedSource,
    ProgressRepository? progressRepository,
  })  : seedSource = seedSource ?? const SampleDataService(),
        progressRepository = progressRepository ?? const LocalProgressRepository();

  final SampleDataService seedSource;
  final ProgressRepository progressRepository;

  MissionService get missionService => MissionService(seedSource: seedSource);

  ProgressSummary buildSummary() {
    final missions = <Mission>[...missionService.dailyMissions, ...missionService.weeklyMissions];
    return _buildSummaryFromMissions(missions);
  }

  Future<ProgressSummary> initialize() async {
    final missions = await missionService.restoreMissions();
    final summary = _buildSummaryFromMissions(missions);
    await saveSummary(summary);
    return summary;
  }

  Future<ProgressSummary> restoreSummary() async {
    final persistedProgress = await progressRepository.loadProgress();
    final defaultSummary = buildSummary();

    return ProgressSummary(
      totalXp: persistedProgress.totalXp,
      level: persistedProgress.currentLevel,
      completionPercentage: defaultSummary.completionPercentage,
      streaks: Streaks(
        daily: persistedProgress.dailyStreak,
        weekly: persistedProgress.weeklyStreak,
        monthly: defaultSummary.streaks.monthly,
      ),
      achievements: defaultSummary.achievements,
      summary: defaultSummary.summary,
    );
  }

  Future<void> saveSummary(ProgressSummary summary) {
    return progressRepository.saveProgressSummary(_toProgressEngine(summary));
  }

  ProgressSummary _buildSummaryFromMissions(List<Mission> missions) {
    final completedMissions = missions.where((mission) => mission.completed).toList();
    final totalXp = XPCalculator().calculate(completedMissions.map((mission) => mission.xpReward).toList());
    final level = LevelCalculator().calculate(totalXp);
    final completionPercentage = missions.isEmpty ? 0.0 : completedMissions.length / missions.length;
    final dailyMissionIds = missionService.dailyMissions.map((mission) => mission.id).toSet();
    final dailyMissions = missions
        .where((mission) => dailyMissionIds.contains(mission.id))
        .toList(growable: false);
    final weeklyMissions = missions
        .where((mission) => !dailyMissionIds.contains(mission.id))
        .toList(growable: false);
    final streaks = Streaks(
      daily: StreakCalculator().calculateDaily(dailyMissions.map((mission) => mission.completed).toList()),
      weekly: StreakCalculator().calculateWeekly(weeklyMissions.map((mission) => mission.completed).toList()),
      monthly: StreakCalculator().calculateMonthly(missions.map((mission) => mission.completed).toList()),
    );
    final achievements = AchievementEngine().calculate(completedMissions.length, missions.length);

    return ProgressSummary(
      totalXp: totalXp,
      level: level,
      completionPercentage: completionPercentage,
      streaks: streaks,
      achievements: achievements,
      summary: '$level • ${completedMissions.length}/${missions.length} missions complete',
    );
  }

  ProgressEngine _toProgressEngine(ProgressSummary summary) {
    return ProgressEngine(
      totalXp: summary.totalXp,
      level: summary.level,
      completionPercentage: summary.completionPercentage,
      streaks: summary.streaks,
      achievements: summary.achievements,
      summary: summary.summary,
    );
  }
}
