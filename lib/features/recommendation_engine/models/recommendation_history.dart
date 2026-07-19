import 'recommendation_history_entry.dart';

/// Historical record of recommendation engagement.
///
/// Maintained by [RecommendationEngine] for tracking acceptance rates,
/// dismissal rates, and average completion times.
class RecommendationHistory {
  const RecommendationHistory({
    this.entries = const <RecommendationHistoryEntry>[],
  });

  /// All history entries.
  final List<RecommendationHistoryEntry> entries;

  /// Total recommendations made.
  int get totalRecommended => entries.length;

  /// Total accepted.
  int get totalAccepted => entries.where((e) => e.isAccepted).length;

  /// Total dismissed.
  int get totalDismissed => entries.where((e) => e.dismissed).length;

  /// Total completed.
  int get totalCompleted => entries.where((e) => e.isCompleted).length;

  /// Acceptance rate (0.0–1.0).
  double get acceptanceRate =>
      totalRecommended > 0 ? totalAccepted / totalRecommended : 0.0;

  /// Dismissal rate (0.0–1.0).
  double get dismissRate =>
      totalRecommended > 0 ? totalDismissed / totalRecommended : 0.0;

  /// Completion rate for accepted recommendations (0.0–1.0).
  double get completionRate =>
      totalAccepted > 0 ? totalCompleted / totalAccepted : 0.0;

  /// Average completion time in minutes.
  double get averageCompletionTimeMinutes {
    final times = entries
        .where((e) => e.completionTimeMinutes != null)
        .map((e) => e.completionTimeMinutes!)
        .toList();
    if (times.isEmpty) return 0.0;
    return times.reduce((a, b) => a + b) / times.length;
  }

  /// Returns entries for a specific rule.
  List<RecommendationHistoryEntry> forRule(String ruleName) =>
      entries.where((e) => e.ruleName == ruleName).toList();

  @override
  String toString() =>
      'RecommendationHistory(recommended: $totalRecommended, '
      'accepted: $totalAccepted, completed: $totalCompleted, '
      'rate: ${(completionRate * 100).round()}%)';
}
