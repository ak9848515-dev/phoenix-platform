/// Progress summary for a completed daily brief.
///
/// Tracks how the user performed against the day's plan.
class DailyProgress {
  const DailyProgress({
    required this.totalTasks,
    required this.completedTasks,
    required this.skippedTasks,
    required this.completionPercentage,
    required this.xpEarned,
    required this.growthDelta,
  });

  final int totalTasks;
  final int completedTasks;
  final int skippedTasks;
  final double completionPercentage;
  final int xpEarned;
  final double growthDelta;

  @override
  String toString() =>
      'DailyProgress($completedTasks/$totalTasks tasks, '
      '${(completionPercentage * 100).round()}%, $xpEarned XP)';
}
