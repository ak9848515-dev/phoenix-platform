import 'decision_recommendation.dart';

/// Immutable snapshot of the current decision intelligence state.
///
/// This is the SINGLE SOURCE OF TRUTH for all recommendations in Phoenix.
/// Dashboard, Phoenix Assistant, and Daily Brief consume this snapshot.
///
/// Produced by [DecisionEngine.evaluate()].
class DecisionSnapshot {
  const DecisionSnapshot({
    this.top,
    this.recommendations = const [],
    this.history = const [],
    this.confidence = 0,
    this.totalRules = 0,
    this.activeRules = 0,
    this.generatedAt,
    this.contextVersion = 0,
  });

  /// The single top recommendation.
  final DecisionRecommendation? top;

  /// All ranked recommendations (top recommendations first).
  final List<DecisionRecommendation> recommendations;

  /// Previously shown recommendations (for continuity).
  final List<DecisionRecommendation> history;

  /// Overall confidence in the top recommendation (0–100).
  final int confidence;

  /// Total rules evaluated.
  final int totalRules;

  /// Rules that produced a recommendation.
  final int activeRules;

  /// When this snapshot was generated.
  final DateTime? generatedAt;

  /// Version of the context used.
  final int contextVersion;

  /// Whether any recommendations exist.
  bool get hasRecommendations => recommendations.isNotEmpty;

  /// Whether a clear top recommendation exists.
  bool get hasTopRecommendation => top != null;

  /// Top 3 recommendations for display in constrained layouts.
  List<DecisionRecommendation> get top3 =>
      recommendations.take(3).toList();

  /// Top 5 recommendations.
  List<DecisionRecommendation> get top5 =>
      recommendations.take(5).toList();

  /// Recommendations by type.
  List<DecisionRecommendation> byType(String typeName) =>
      recommendations.where((r) => r.type.displayName == typeName).toList();

  @override
  String toString() =>
      'DecisionSnapshot(top: ${top?.title ?? 'none'}, '
      'recommendations: ${recommendations.length}, '
      'confidence: $confidence)';
}
