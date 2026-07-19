import 'daily_history_entry.dart';

/// Historical record of daily briefs.
///
/// Maintained by [DailyBriefEngine] for tracking completion rates,
/// XP earned, and growth over time.
class DailyHistory {
  const DailyHistory({
    this.entries = const <DailyHistoryEntry>[],
  });

  final List<DailyHistoryEntry> entries;

  /// Most recent entry.
  DailyHistoryEntry? get latest =>
      entries.isNotEmpty ? entries.last : null;

  /// Average completion ratio across all entries.
  double get averageCompletionRatio {
    if (entries.isEmpty) return 0.0;
    final sum = entries.fold<double>(0.0, (s, e) => s + e.completionRatio);
    return sum / entries.length;
  }

  /// Total XP earned across all entries.
  int get totalXpEarned =>
      entries.fold<int>(0, (s, e) => s + e.xpEarned);

  /// Average daily XP.
  double get averageDailyXp =>
      entries.isNotEmpty ? totalXpEarned / entries.length : 0.0;

  /// Total days recorded.
  int get totalDays => entries.length;

  /// Entries for a specific week (by year + week number).
  List<DailyHistoryEntry> forWeek(int year, int week) =>
      entries.where((e) {
        final date = DateTime.parse(e.date);
        return date.year == year && _isoWeekNumber(date) == week;
      }).toList();

  int _isoWeekNumber(DateTime date) {
    final jan4 = DateTime(date.year, 1, 4);
    final daysSinceJan4 = date.difference(jan4).inDays;
    return ((daysSinceJan4 + (jan4.weekday - 1)) / 7).floor() + 1;
  }

  @override
  String toString() =>
      'DailyHistory(entries: ${entries.length}, '
      'avg completion: ${(averageCompletionRatio * 100).round()}%)';
}
