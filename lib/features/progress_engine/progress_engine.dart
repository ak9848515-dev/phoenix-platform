import '../mission_engine/mission_engine.dart';

/// Immutable growth model used by the Progress Engine.
class ProgressEngine {
  const ProgressEngine({
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

class Streaks {
  const Streaks({
    required this.daily,
    required this.weekly,
    required this.monthly,
  });

  final int daily;
  final int weekly;
  final int monthly;
}

class AchievementProgress {
  const AchievementProgress({
    required this.id,
    required this.title,
    required this.progress,
    required this.completed,
  });

  final String id;
  final String title;
  final double progress;
  final bool completed;
}

class ProgressSnapshot {
  const ProgressSnapshot({
    required this.missions,
    required this.totalXp,
    required this.level,
    required this.completionPercentage,
    required this.streaks,
    required this.achievements,
    required this.summary,
  });

  final List<Mission> missions;
  final int totalXp;
  final int level;
  final double completionPercentage;
  final Streaks streaks;
  final List<AchievementProgress> achievements;
  final String summary;
}
