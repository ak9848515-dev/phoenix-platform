/// Priority levels for the decision engine.
enum DecisionPriority {
  /// Critical priority — highest impact, most urgent.
  critical,

  /// High priority — significant impact.
  high,

  /// Medium priority — moderate impact.
  medium,

  /// Low priority — supplementary action.
  low,
}

/// The single highest-impact action the user should take next.
///
/// A Decision is produced by [DecisionService] after aggregating inputs from
/// every Phoenix module: Identity, Journey, Current Stage, Mission Progress,
/// Knowledge DNA, Progress, Memory, and Recommendations.
///
/// The [sourceModule] field tracks which upstream module provided the primary
/// signal, and [confidence] expresses how strongly the engine recommends this
/// action (0.0 = weakest, 1.0 = strongest).
class Decision {
  const Decision({
    required this.id,
    required this.title,
    required this.description,
    required this.reason,
    required this.priority,
    required this.estimatedDuration,
    required this.sourceModule,
    required this.confidence,
    this.actionLabel,
  });

  /// Unique identifier for this decision.
  final String id;

  /// Short title of the decided action.
  final String title;

  /// Detailed description of what the action involves.
  final String description;

  /// Explanation of *why* this is the highest-impact action right now.
  final String reason;

  /// Priority level indicating urgency and impact.
  final DecisionPriority priority;

  /// Estimated time in minutes to complete this action.
  final int estimatedDuration;

  /// The upstream module that provided the primary signal
  /// (e.g. "journey", "mission", "progress", "knowledge_dna", "memory",
  /// "recommendation").
  final String sourceModule;

  /// How strongly the engine recommends this action, from 0.0 to 1.0.
  ///
  /// A higher value means the engine is more confident this is the correct
  /// next step based on the aggregated inputs.
  final double confidence;

  /// Optional label for the call-to-action button (e.g. "Start", "Continue").
  final String? actionLabel;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Decision && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Decision(id: $id, title: $title, priority: $priority, '
        'sourceModule: $sourceModule, confidence: $confidence)';
  }
}
