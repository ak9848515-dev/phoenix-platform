/// A single daily brief history entry.
///
/// Records what was planned, completed, and earned on a given day.
class DailyHistoryEntry {
  const DailyHistoryEntry({
    required this.date,
    required this.todaysFocus,
    required this.totalTasks,
    required this.completedTasks,
    required this.xpEarned,
    required this.growthDelta,
    required this.completionRatio,
  });

  /// Date string (YYYY-MM-DD).
  final String date;

  /// That day's focus.
  final String todaysFocus;

  /// Total tasks planned.
  final int totalTasks;

  /// Tasks completed.
  final int completedTasks;

  /// XP earned.
  final int xpEarned;

  /// Growth change.
  final double growthDelta;

  /// Completion ratio (0.0–1.0).
  final double completionRatio;

  @override
  String toString() =>
      'DailyHistoryEntry(date: $date, $completedTasks/$totalTasks, '
      'xp: $xpEarned)';
}
