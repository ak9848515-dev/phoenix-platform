/// Priority level for a daily recommendation.
///
/// Used by [DailyBriefEngine] to rank actions the user should take.
enum RecommendationPriority {
  /// Must be done today — time-sensitive or blocking.
  critical,

  /// Should be done today — high value.
  high,

  /// Good to do today — positive impact.
  medium,

  /// Nice to do — optional, build momentum.
  low;

  /// Numeric value for sorting (higher = more urgent).
  int get rank {
    switch (this) {
      case RecommendationPriority.critical:
        return 4;
      case RecommendationPriority.high:
        return 3;
      case RecommendationPriority.medium:
        return 2;
      case RecommendationPriority.low:
        return 1;
    }
  }
}

/// Category of recommendation produced by [DailyBriefEngine].
enum RecommendationType {
  /// Learning path or lesson recommendation from [AcademyService].
  learning,

  /// Habit insight or action from [HabitService].
  habit,

  /// Decision follow-up from [DecisionIntelligenceService].
  decision,

  /// Timeline event or milestone reminder from [TimelineService].
  timeline,

  /// Knowledge graph insight from [KnowledgeService].
  knowledge,

  /// Memory graph exploration from [MemoryGraphService].
  graph;

  /// Human-readable label.
  String get label {
    switch (this) {
      case RecommendationType.learning:
        return 'Learning';
      case RecommendationType.habit:
        return 'Habit';
      case RecommendationType.decision:
        return 'Decision';
      case RecommendationType.timeline:
        return 'Timeline';
      case RecommendationType.knowledge:
        return 'Knowledge';
      case RecommendationType.graph:
        return 'Memory Graph';
    }
  }
}

/// A single recommendation with priority, urgency, and confidence scoring.
///
/// Produced by [DailyBriefEngine] from data in the six Phoenix platform
/// services. Immutable. No persistence.
class DailyRecommendation {
  const DailyRecommendation({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.priority = RecommendationPriority.medium,
    this.urgency = 0.0,
    this.confidence = 0.0,
    this.sourceService = '',
    this.metadata = const {},
  });

  /// Unique identifier within this brief generation.
  final String id;

  /// Category of recommendation.
  final RecommendationType type;

  /// Short action-oriented title.
  final String title;

  /// Optional detailed description or rationale.
  final String? description;

  /// Computed priority level.
  final RecommendationPriority priority;

  /// Urgency score (0.0 = not urgent, 1.0 = extremely urgent).
  ///
  /// Factors: time-sensitivity, blocking status, streak at risk, etc.
  final double urgency;

  /// Confidence score (0.0 = uncertain, 1.0 = highly confident).
  ///
  /// Factors: data completeness, recency, consistency across signals.
  final double confidence;

  /// Name of the source service that produced this recommendation.
  final String sourceService;

  /// Extensible metadata for the engine to pass additional context.
  final Map<String, dynamic> metadata;

  /// Combined priority score for ranking (urgency × confidence × priority rank).
  double get priorityScore =>
      urgency * confidence * priority.rank;

  /// Whether this recommendation is actionable right now.
  bool get isActionable => priority != RecommendationPriority.low;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecommendation && other.id == id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'description': description,
        'priority': priority.name,
        'urgency': urgency,
        'confidence': confidence,
        'sourceService': sourceService,
        'metadata': metadata,
        'priorityScore': priorityScore,
      };

  @override
  String toString() =>
      'DailyRecommendation(id: $id, type: $type, '
      'priority: $priority, urgency: $urgency)';
}
