/// An unlock milestone that the user can expect to reach.
///
/// Predicts when the user will unlock the next:
/// - Level
/// - Badge / Achievement
/// - Career milestone
/// - Skill unlock
/// - Project unlock
/// - Interview stage
class ForecastMilestone {
  const ForecastMilestone({
    required this.title,
    required this.description,
    required this.predictedDate,
    required this.confidence,
    this.prerequisites = const [],
    this.daysRemaining,
    this.iconName,
  });

  /// Human-readable milestone title.
  final String title;

  /// Description of what the milestone means.
  final String description;

  /// Predicted date when this milestone will be reached.
  final DateTime predictedDate;

  /// How confident the prediction is (0-100).
  final int confidence;

  /// Prerequisites that must be met first.
  final List<String> prerequisites;

  /// Estimated days remaining until the milestone.
  final int? daysRemaining;

  /// Optional icon name for UI display.
  final String? iconName;

  /// Whether the milestone is within the current planning horizon (90 days).
  bool get isNearTerm => daysRemaining != null && daysRemaining! <= 90;

  /// Whether the milestone is far-term (more than 180 days).
  bool get isFarTerm => daysRemaining != null && daysRemaining! > 180;

  @override
  String toString() =>
      'ForecastMilestone($title: ~${daysRemaining ?? "?"} days)';
}
