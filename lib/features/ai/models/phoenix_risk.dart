/// Severity level for a detected risk.
enum RiskSeverity {
  /// Immediate attention required — likely blocking progress.
  high,

  /// Should be addressed soon — could become blocking.
  medium,

  /// Minor — worth monitoring but not urgent.
  low;

  /// Numeric value for sorting (higher = more severe).
  int get rank {
    switch (this) {
      case RiskSeverity.high:
        return 3;
      case RiskSeverity.medium:
        return 2;
      case RiskSeverity.low:
        return 1;
    }
  }
}

/// A cross-domain risk detected by [CrossFeatureReasoner].
///
/// Represents a pattern that could negatively impact the user's progress,
/// discovered by combining signals from multiple Phoenix services.
///
/// Immutable. No persistence — computed on demand.
class PhoenixRisk {
  const PhoenixRisk({
    required this.id,
    required this.title,
    required this.description,
    this.severity = RiskSeverity.low,
    this.confidence = 0.0,
  });

  /// Unique identifier.
  final String id;

  /// Short human-readable title (e.g. "Streak at Risk").
  final String title;

  /// Detailed explanation of the risk and its potential impact.
  final String description;

  /// How severe this risk is.
  final RiskSeverity severity;

  /// Confidence score (0.0–1.0) based on signal strength.
  final double confidence;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoenixRisk && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PhoenixRisk(id: $id, title: $title, severity: $severity)';
}
