import 'evidence.dart' show Evidence;

/// A step-by-step reasoning chain explaining why a recommendation
/// was made.
///
/// Immutable. Produced by [ExplanationEngine]. Each step connects
/// evidence to a conclusion, forming a traceable path from data
/// to recommendation.
class ReasonChain {
  const ReasonChain({
    required this.conclusion,
    this.evidence = const [],
    this.steps = const [],
    this.confidence = 0.0,
  });

  /// The final conclusion or recommendation being explained.
  final String conclusion;

  /// All evidence items supporting this reasoning chain.
  final List<Evidence> evidence;

  /// Step-by-step reasoning steps (human-readable).
  ///
  /// Example: ["You completed Widgets 101", "Knowledge graph shows gap in State Management", "Career goal requires Flutter"]
  final List<String> steps;

  /// Overall confidence in this reasoning chain (0.0–1.0).
  final double confidence;

  /// Whether the reasoning has sufficient evidence.
  bool get hasEvidence => evidence.length >= 2;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasonChain && other.conclusion == conclusion;

  @override
  int get hashCode => conclusion.hashCode;

  @override
  String toString() =>
      'ReasonChain(conclusion: ${conclusion.length} chars, '
      'evidence: ${evidence.length}, steps: ${steps.length})';
}
