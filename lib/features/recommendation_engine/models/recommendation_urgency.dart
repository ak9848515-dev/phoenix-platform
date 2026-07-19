/// Urgency scoring for a recommendation — determines timing and priority.
///
/// Computed by [RecommendationRule] implementations and aggregated by
/// [RecommendationEngine] for ranking.
class RecommendationUrgency {
  const RecommendationUrgency({
    required this.score,
    this.reason = '',
    this.isTimeSensitive = false,
    this.isBlocking = false,
  });

  /// Urgency score (0.0–1.0). Higher = more urgent.
  final double score;

  /// Why this recommendation is urgent.
  final String reason;

  /// Whether time is a factor (e.g. streak expiring, deadline approaching).
  final bool isTimeSensitive;

  /// Whether this recommendation blocks other progress.
  final bool isBlocking;

  @override
  String toString() =>
      'RecommendationUrgency(score: ${(score * 100).round()}%, '
      'sensitive: $isTimeSensitive, blocking: $isBlocking)';
}
