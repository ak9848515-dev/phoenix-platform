import 'progress_engine.dart';

/// Calculates achievement progress from mission completion.
class AchievementEngine {
  const AchievementEngine();

  List<AchievementProgress> calculate(int completedCount, int totalCount) {
    final completionRatio = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return <AchievementProgress>[
      AchievementProgress(
        id: 'first-win',
        title: 'First Win',
        progress: completionRatio.clamp(0.0, 1.0),
        completed: completedCount >= 1,
      ),
      AchievementProgress(
        id: 'consistency',
        title: 'Consistency',
        progress: (completionRatio * 2).clamp(0.0, 1.0),
        completed: completedCount >= 3,
      ),
    ];
  }
}
