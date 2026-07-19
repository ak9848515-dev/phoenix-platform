/// A directed relationship between two memory entries.
///
/// Forms the edges of the memory graph.
/// Supports: prerequisite, related, derived, supports, contradicts.
class MemoryRelationship {
  const MemoryRelationship({
    required this.sourceId,
    required this.targetId,
    this.type = 'related',
    this.weight = 1.0,
    this.description = '',
  });

  /// The source memory ID.
  final String sourceId;

  /// The target memory ID.
  final String targetId;

  /// Relationship type (e.g. 'prerequisite', 'related', 'derived', 'supports', 'contradicts').
  final String type;

  /// Strength of the relationship (0.0–1.0).
  final double weight;

  /// Optional description of the relationship.
  final String description;

  /// Create a copy with updated fields.
  MemoryRelationship copyWith({
    String? sourceId,
    String? targetId,
    String? type,
    double? weight,
    String? description,
  }) =>
      MemoryRelationship(
        sourceId: sourceId ?? this.sourceId,
        targetId: targetId ?? this.targetId,
        type: type ?? this.type,
        weight: weight ?? this.weight,
        description: description ?? this.description,
      );

  @override
  String toString() =>
      'MemoryRelationship($sourceId --[$type]--> $targetId)';
}
