/// A single history entry tracking a recommendation lifecycle.
///
/// Records when a recommendation was made, accepted, dismissed, or
/// completed so the engine can track engagement rates.
class RecommendationHistoryEntry {
  const RecommendationHistoryEntry({
    required this.recommendationId,
    required this.title,
    required this.categoryName,
    required this.ruleName,
    required this.recommendedAt,
    this.acceptedAt,
    this.dismissedAt,
    this.completedAt,
    this.accepted = false,
    this.dismissed = false,
    this.completed = false,
    this.ignored = false,
    this.completionTimeMinutes,
  });

  /// ID of the recommendation.
  final String recommendationId;

  /// Title of the recommendation.
  final String title;

  /// Category name.
  final String categoryName;

  /// Which rule generated it.
  final String ruleName;

  /// When recommended.
  final DateTime recommendedAt;

  /// When accepted.
  final DateTime? acceptedAt;

  /// When dismissed.
  final DateTime? dismissedAt;

  /// When completed.
  final DateTime? completedAt;

  /// Whether accepted.
  final bool accepted;

  /// Whether dismissed.
  final bool dismissed;

  /// Whether completed.
  final bool completed;

  /// Whether ignored (no action taken).
  final bool ignored;

  /// Minutes to complete.
  final int? completionTimeMinutes;

  /// Whether this entry is actionable (not dismissed/completed).
  bool get isActive => !dismissed && !completed && !ignored;

  /// Whether accepted.
  bool get isAccepted => accepted && acceptedAt != null;

  /// Whether completed.
  bool get isCompleted => completed && completedAt != null;

  @override
  String toString() =>
      'RecommendationHistoryEntry(title: $title, '
      'accepted: $accepted, completed: $completed)';
}
