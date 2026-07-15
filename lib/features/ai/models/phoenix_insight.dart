/// A cross-domain insight produced by [CrossFeatureReasoner].
///
/// Represents a meaningful pattern discovered by combining signals
/// from two or more Phoenix platform services.
///
/// Immutable. No persistence — computed on demand.
class PhoenixInsight {
  const PhoenixInsight({
    required this.id,
    required this.title,
    required this.description,
    this.confidence = 0.0,
    this.priority = 0.0,
    this.sourceDomains = const [],
  });

  /// Unique identifier.
  final String id;

  /// Short human-readable title (e.g. "Learning + Habit Synergy").
  final String title;

  /// Detailed explanation of the insight and its implication.
  final String description;

  /// Confidence score (0.0–1.0) based on signal strength and recency.
  final double confidence;

  /// Importance priority (0.0–1.0) for presentation ordering.
  final double priority;

  /// The domain/service names that produced this insight
  /// (e.g. ["AcademyService", "HabitService"]).
  final List<String> sourceDomains;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoenixInsight && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PhoenixInsight(id: $id, title: $title, confidence: $confidence)';
}
