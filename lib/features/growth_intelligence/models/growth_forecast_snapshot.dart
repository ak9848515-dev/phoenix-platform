import 'forecast_milestone.dart';
import 'forecast_prediction.dart';

/// Immutable snapshot of the user's predicted growth trajectory.
///
/// Produced by [GrowthIntelligenceEngine]. All consumers read this
/// snapshot instead of computing forecasts themselves.
///
/// **Contains:**
/// - [forecasts]: list of all deterministic predictions by timeline
/// - [milestones]: predicted unlock milestones
/// - [topOpportunities]: highest-growth forecasts
/// - [topRisks]: lowest-confidence or declining forecasts
/// - [whatIfScenarios]: deterministic simulations
/// - [confidence]: overall forecast reliability
class GrowthForecastSnapshot {
  const GrowthForecastSnapshot({
    required this.forecasts,
    required this.milestones,
    required this.topOpportunities,
    required this.topRisks,
    required this.overallConfidence,
    required this.generatedAt,
    this.whatIfScenarios = const {},
    this.history = const [],
  });

  /// All predictions across all timelines (7, 30, 90, 180, 365 days).
  final List<ForecastPrediction> forecasts;

  /// Predicted unlock milestones.
  final List<ForecastMilestone> milestones;

  /// Top 3 highest-impact opportunities.
  final List<ForecastPrediction> topOpportunities;

  /// Top 3 risk factors (declining or low-confidence forecasts).
  final List<ForecastPrediction> topRisks;

  /// Overall forecast confidence (0-100).
  final int overallConfidence;

  /// When this snapshot was generated.
  final DateTime generatedAt;

  /// What-if scenarios mapped by scenario name.
  final Map<String, List<ForecastPrediction>> whatIfScenarios;

  /// Previous forecast snapshots for trend comparison.
  final List<GrowthForecastSnapshot> history;

  /// Whether the snapshot has any predictions.
  bool get hasData => forecasts.isNotEmpty;

  /// Whether the snapshot represents insufficient data.
  bool get isInsufficient => forecasts.isEmpty;

  /// Short summary for dashboard display.
  String get summary {
    final top = topOpportunities.isNotEmpty
        ? topOpportunities.first
        : null;
    if (top == null) return 'Insufficient data for forecasts';
    return '${top.type.displayName}: ${top.currentValue} → ${top.predictedValue} '
        '(${top.timelineDays}d, ${top.confidence.overall}% confidence)';
  }

  @override
  String toString() =>
      'GrowthForecastSnapshot('
      'forecasts: ${forecasts.length}, '
      'milestones: ${milestones.length}, '
      'confidence: $overallConfidence%)';
}
