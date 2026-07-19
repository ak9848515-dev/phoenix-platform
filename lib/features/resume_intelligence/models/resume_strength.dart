/// A resume strength identified by the [ResumeIntelligenceEngine].
///
/// Each strength has a category, confidence score, and supporting evidence.
class ResumeStrength {
  const ResumeStrength({
    required this.name,
    this.category = 'General',
    this.confidence = 0.0,
    this.evidence = '',
  });

  /// Name of the strength (e.g. 'Flutter Development', 'Project Portfolio').
  final String name;

  /// Category grouping (e.g. 'Technical', 'Portfolio', 'Career').
  final String category;

  /// Confidence in this strength (0.0–1.0).
  final double confidence;

  /// Supporting evidence for why this is a strength.
  final String evidence;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumeStrength && other.name == name;

  @override
  int get hashCode => name.hashCode;
}
