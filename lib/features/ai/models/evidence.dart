/// A piece of evidence supporting a recommendation or insight.
///
/// Immutable. Used by [ExplanationEngine] to build explainable
/// recommendations. Each evidence item has a source domain and
/// human-readable statement.
class Evidence {
  const Evidence({
    required this.statement,
    this.source = '',
    this.relevance = 0.0,
  });

  /// Human-readable evidence statement (e.g. "You completed Widgets 101").
  final String statement;

  /// Source domain or service (e.g. "AcademyService", "HabitService").
  final String source;

  /// How relevant this evidence is to the conclusion (0.0–1.0).
  final double relevance;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Evidence && other.statement == statement;

  @override
  int get hashCode => statement.hashCode;

  @override
  String toString() =>
      'Evidence(statement: ${statement.length} chars, source: $source)';
}
