import '../../core/repository.dart';
import '../../core/sample_repository.dart';
import '../mission_engine/mission_engine.dart';
import '../user_state/services/user_state_service.dart';
import 'achievement_engine.dart';
import 'level_calculator.dart';
import 'progress_engine.dart';
import 'progress_summary.dart';
import 'streak_calculator.dart';
import 'xp_calculator.dart';

/// Orchestrates progress metrics from mission completion data.
class ProgressService {
  ProgressService({Repository? repository, this._userStateService})
    : repository = repository ?? const SampleRepository();

  final Repository repository;
  final UserStateService? _userStateService;

  /// In-memory accumulator for XP earned through mission completions.
  /// Used when the Progress Engine completes a mission — this allows
  /// the Mission Engine to track rewards without a full persistence
  /// pipeline. Accumulated XP is added on top of the base sample XP.
  int _accumulatedXp = 0;

  /// Records XP earned from a mission completion.
  ///
  /// This is the ONLY entry point for modifying XP from outside
  /// the Progress Engine. Never update XP directly from widgets.
  /// Also updates UserStateService when available.
  void addXp(int amount) {
    _accumulatedXp += amount;
    _userStateService?.addXp(amount);
    _userStateService?.touch();
  }

  /// Returns the total accumulated XP including mission rewards.
  int get totalAccumulatedXp => _accumulatedXp;

  ProgressSummary buildSummary() {
    final missions = <Mission>[
      ...repository.dailyMissions,
      ...repository.weeklyMissions,
    ];
    final completedMissions = missions
        .where((mission) => mission.isCompleted)
        .toList();
    final baseXp = XPCalculator().calculate(
      completedMissions.map((mission) => mission.rewardXP).toList(),
    );
    final totalXp = baseXp + _accumulatedXp;
    final level = LevelCalculator().calculate(totalXp);
    final completionPercentage = missions.isEmpty
        ? 0.0
        : completedMissions.length / missions.length;
    final streaks = Streaks(
      daily: StreakCalculator().calculateDaily(
        repository.dailyMissions
            .map((mission) => mission.isCompleted)
            .toList(),
      ),
      weekly: StreakCalculator().calculateWeekly(
        repository.weeklyMissions
            .map((mission) => mission.isCompleted)
            .toList(),
      ),
      monthly: StreakCalculator().calculateMonthly(
        missions.map((mission) => mission.isCompleted).toList(),
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
