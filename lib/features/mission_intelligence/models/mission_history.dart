import 'mission_history_entry.dart';

/// Historical record of all mission recommendations.
///
/// Maintained by [MissionIntelligenceEngine] for tracking acceptance rates,
/// completion rates, and average completion times.
class MissionHistory {
  const MissionHistory({
    this.entries = const <MissionHistoryEntry>[],
  });

  /// All history entries.
  final List<MissionHistoryEntry> entries;

  /// Total recommendations made.
  int get totalRecommended => entries.length;

  /// Total accepted missions.
  int get totalAccepted => entries.where((e) => e.isAccepted).length;

  /// Total rejected missions.
  int get totalRejected => entries.where((e) => e.rejected).length;

  /// Total completed missions.
  int get totalCompleted => entries.where((e) => e.isCompleted).length;

  /// Acceptance rate (0.0–1.0).
  double get acceptanceRate =>
      totalRecommended > 0 ? totalAccepted / totalRecommended : 0.0;

  /// Completion rate for accepted missions (0.0–1.0).
  double get completionRate =>
      totalAccepted > 0 ? totalCompleted / totalAccepted : 0.0;

  /// Average completion time in minutes for completed missions.
  double get averageCompletionTimeMinutes {
    final times = entries
        .where((e) => e.completionTimeMinutes != null)
        .map((e) => e.completionTimeMinutes!)
        .toList();
    if (times.isEmpty) return 0.0;
    return times.reduce((a, b) => a + b) / times.length;
  }

  /// Returns entries for a specific rule.
  List<MissionHistoryEntry> forRule(String ruleName) =>
      entries.where((e) => e.ruleName == ruleName).toList();

  /// Returns completed entries sorted by completion time (most recent first).
  List<MissionHistoryEntry> get recentCompleted {
    final completed = entries.where((e) => e.isCompleted).toList();
    completed.sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
    return completed;
  }

  @override
  String toString() =>
      'MissionHistory(recommended: $totalRecommended, '
      'accepted: $totalAccepted, completed: $totalCompleted, '
      'rate: ${(completionRate * 100).round()}%)';
}
