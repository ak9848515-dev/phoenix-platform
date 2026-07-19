import '../models/growth_metrics.dart';

/// Abstract interface for a dimension-specific growth calculator.
///
/// Each [GrowthCalculator] implementation calculates a [GrowthMetrics]
/// for one [GrowthDimension] using existing platform services.
///
/// This abstraction allows future engines to replace individual calculators
/// without modifying the [GrowthIndexEngine].
abstract class GrowthCalculator {
  /// Calculates the current [GrowthMetrics] for this dimension.
  ///
  /// Returns default metrics (score 0.0, trend stable) if data is
  /// unavailable rather than throwing.
  GrowthMetrics calculate();

  /// Returns the previous [GrowthMetrics] if available, or `null`.
  ///
  /// Used by [GrowthIndexEngine] to compute trend direction.
  GrowthMetrics? get previousMetrics;
}
