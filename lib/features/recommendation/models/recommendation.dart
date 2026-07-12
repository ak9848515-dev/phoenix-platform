/// Represents a single recommendation suggesting the user's next high-impact action.
///
/// Each recommendation includes a clear reason so the user understands
/// why Phoenix suggested it.
class Recommendation {
  const Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.estimatedDuration,
    required this.reason,
    this.relatedIdentity,
    this.relatedMission,
    this.relatedSkill,
    required this.actionLabel,
  });

  /// Unique identifier for this recommendation.
  final String id;

  /// Short title of the recommended action.
  final String title;

  /// Detailed description of the recommendation.
  final String description;

  /// The type of recommendation (e.g. Mission, Learning, Practice).
  final RecommendationType type;

  /// Priority level indicating urgency and impact.
  final RecommendationPriority priority;

  /// Estimated time in minutes to complete this action.
  final int estimatedDuration;

  /// Explanation of *why* this recommendation was made.
  final String reason;

  /// Optional identity this recommendation relates to.
  final String? relatedIdentity;

  /// Optional mission this recommendation relates to.
  final String? relatedMission;

  /// Optional skill this recommendation targets.
  final String? relatedSkill;

  /// Label for the call-to-action button (e.g. "Start", "Continue", "Review").
  final String actionLabel;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recommendation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Recommendation(id: $id, title: $title, type: $type, '
        'priority: $priority)';
  }
}

/// The possible types of recommendations.
enum RecommendationType {
  /// A mission to complete.
  mission,

  /// A learning module or course.
  learning,

  /// A practice or exercise.
  practice,

  /// A project to start or continue.
  project,

  /// A career-related action.
  career,

  /// A business-related action.
  business,

  /// A reflection or journaling activity.
  reflection,

  /// A review of past work or progress.
  review,
}

/// Priority levels for recommendations.
enum RecommendationPriority {
  /// Critical priority — highest impact.
  critical,

  /// High priority — significant impact.
  high,

  /// Medium priority — moderate impact.
  medium,

  /// Low priority — supplementary action.
  low,
}
