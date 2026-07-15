/// A cross-domain opportunity detected by [CrossFeatureReasoner].
///
/// Represents a positive pattern or growth opportunity discovered by
/// combining signals from multiple Phoenix platform services.
///
/// Immutable. No persistence — computed on demand.
class PhoenixOpportunity {
  const PhoenixOpportunity({
    required this.id,
    required this.title,
    required this.description,
    this.estimatedImpact = 0.0,
    this.confidence = 0.0,
  });

  /// Unique identifier.
  final String id;

  /// Short human-readable title (e.g. "High-Impact Learning Window").
  final String title;

  /// Detailed explanation of the opportunity and its potential value.
  final String description;

  /// Estimated positive impact (0.0–1.0) if pursued.
  final double estimatedImpact;

  /// Confidence score (0.0–1.0) based on signal strength.
  final double confidence;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoenixOpportunity && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PhoenixOpportunity(id: $id, title: $title, '
      'impact: $estimatedImpact)';
}
