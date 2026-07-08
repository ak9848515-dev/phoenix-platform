import 'progress_engine.dart';

/// Immutable dashboard summary for Progress Engine UI.
class ProgressSummary {
  const ProgressSummary({
    required this.totalXp,
    required this.level,
    required this.completionPercentage,
    required this.streaks,
    required this.achievements,
    required this.summary,
  });

  final int totalXp;
  final int level;
  final double completionPercentage;
  final Streaks streaks;
  final List<AchievementProgress> achievements;
  final String summary;
}
