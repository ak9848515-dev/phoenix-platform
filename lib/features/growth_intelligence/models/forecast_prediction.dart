import 'forecast_confidence.dart';
import 'forecast_type.dart';

/// A single deterministic prediction for one [ForecastType].
///
/// Every prediction includes:
/// - [currentValue]: what the value is today
/// - [predictedValue]: what the value is expected to be
/// - [improvement]: expected delta (absolute or percentage depending on type)
/// - [confidence]: how reliable this prediction is
/// - [estimatedDate]: when the prediction is expected to materialize
/// - [assumptions]: what must remain true for this prediction
/// - [dependencies]: what must happen first
/// - [requiredActions]: what the user must do
/// - [riskFactors]: what could go wrong
class ForecastPrediction {
  const ForecastPrediction({
    required this.type,
    required this.timelineDays,
    required this.currentValue,
    required this.predictedValue,
    required this.improvement,
    required this.confidence,
    this.estimatedDate,
    this.assumptions = const [],
    this.dependencies = const [],
    this.requiredActions = const [],
    this.riskFactors = const [],
    this.label = '',
    this.unit = '',
  });

  /// Which type of forecast this is.
  final ForecastType type;

  /// Timeline in days (7, 30, 90, 180, 365).
  final int timelineDays;

  /// Current value of the metric.
  final double currentValue;

  /// Predicted value after [timelineDays].
  final double predictedValue;

  /// Expected improvement (absolute delta or percentage).
  final double improvement;

  /// Confidence score for this prediction.
  final ForecastConfidence confidence;

  /// Estimated date when the prediction is expected to materialize.
  final DateTime? estimatedDate;

  /// Conditions that must remain true for this prediction.
  final List<String> assumptions;

  /// Things that must happen before this prediction.
  final List<String> dependencies;

  /// Actions the user can take to improve this prediction.
  final List<String> requiredActions;

  /// Factors that could reduce the predicted outcome.
  final List<String> riskFactors;

  /// Optional human-readable label.
  final String label;

  /// Optional unit string (e.g. "XP", "levels", "%").
  final String unit;

  @override
  String toString() =>
      'ForecastPrediction(${type.displayName}: '
      '$currentValue → $predictedValue in ${timelineDays}d)';
}
