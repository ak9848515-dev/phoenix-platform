import 'journey_history_entry.dart';
import 'journey_resume_point.dart';

/// Historical record of journey activities.
///
/// Maintained by [ContinueJourneyEngine] for tracking started, paused,
/// completed, and cancelled activities over time.
class JourneyHistory {
  const JourneyHistory({
    this.entries = const <JourneyHistoryEntry>[],
  });

  final List<JourneyHistoryEntry> entries;

  /// Most recent entry.
  JourneyHistoryEntry? get latest =>
      entries.isNotEmpty ? entries.last : null;

  /// Entries currently in progress.
  List<JourneyHistoryEntry> get inProgress =>
      entries.where((e) => e.isInProgress).toList();

  /// Completed entries.
  List<JourneyHistoryEntry> get completed =>
      entries.where((e) => e.isCompleted).toList();

  /// Cancelled entries.
  List<JourneyHistoryEntry> get cancelled =>
      entries.where((e) => e.isCancelled).toList();

  /// Total entries.
  int get totalEntries => entries.length;

  /// Completion rate (0.0–1.0).
  double get completionRate {
    final completed = this.completed.length;
    final total = completed + cancelled.length;
    return total > 0 ? completed / total : 0.0;
  }

  /// Total XP earned from all activities.
  int get totalXpEarned =>
      entries.fold<int>(0, (s, e) => s + e.xpEarned);

  /// Total resume count across all entries.
  int get totalResumeCount =>
      entries.fold<int>(0, (s, e) => s + e.resumeCount);

  /// Average minutes spent per completed activity.
  double get averageMinutesPerCompletion {
    final completed = this.completed;
    if (completed.isEmpty) return 0.0;
    final totalMinutes =
        completed.fold<int>(0, (s, e) => s + e.totalMinutesSpent);
    return totalMinutes / completed.length;
  }

  /// Entries for a specific activity type.
  List<JourneyHistoryEntry> forType(JourneyResumePoint type) =>
      entries.where((e) => e.activityType == type).toList();

  @override
  String toString() =>
      'JourneyHistory(entries: ${entries.length}, '
      'completed: ${completed.length}, '
      'rate: ${(completionRate * 100).round()}%)';
}
