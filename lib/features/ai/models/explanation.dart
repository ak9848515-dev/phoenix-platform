import 'daily_recommendation.dart' show DailyRecommendation;
import 'reason_chain.dart' show ReasonChain;

/// A complete explanation for a recommendation.
///
/// Ties together the recommendation, its reasoning chain, supporting
/// evidence, and metadata. Immutable. Produced by [ExplanationEngine].
class Explanation {
  const Explanation({
    required this.recommendation,
    required this.reasonChain,
    this.title = '',
    this.description = '',
    this.confidence = 0.0,
    this.priority = 0.0,
    this.sourceDomains = const [],
  });

  /// The recommendation being explained.
  final DailyRecommendation recommendation;

  /// Step-by-step reasoning chain.
  final ReasonChain reasonChain;

  /// Short title for the explanation.
  final String title;

  /// Detailed description.
  final String description;

  /// Overall confidence (0.0–1.0).
  final double confidence;

  /// Priority (0.0–1.0).
  final double priority;

  /// Source domains that contributed to the explanation.
  final List<String> sourceDomains;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Explanation && other.title == title;

  @override
  int get hashCode => title.hashCode;

  @override
  String toString() =>
      'Explanation(title: $title, confidence: $confidence, '
      'sources: ${sourceDomains.length})';
}
