import 'dart:convert';

/// A semantic edge connecting two knowledge nodes.
///
/// Unlike [MemoryRelation] which tracks entity relationships,
/// [KnowledgeEdge] captures semantic meaning — how skills relate,
/// what goals depend on what, how learning connects to growth.
class KnowledgeEdge {
  const KnowledgeEdge({
    required this.id,
    required this.sourceNodeId,
    required this.targetNodeId,
    required this.type,
    this.strength = 0.5,
    this.label,
    this.metadata = const {},
    this.createdAt,
  });

  /// Unique identifier.
  final String id;

  /// Source knowledge node ID.
  final String sourceNodeId;

  /// Target knowledge node ID.
  final String targetNodeId;

  /// Semantic relationship type.
  final KnowledgeEdgeType type;

  /// Connection strength (0.0 - 1.0).
  final double strength;

  /// Optional human-readable label.
  final String? label;

  /// Additional metadata.
  final Map<String, dynamic> metadata;

  /// When this edge was created.
  final DateTime? createdAt;

  KnowledgeEdge copyWith({
    String? id,
    String? sourceNodeId,
    String? targetNodeId,
    KnowledgeEdgeType? type,
    double? strength,
    String? label,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return KnowledgeEdge(
      id: id ?? this.id,
      sourceNodeId: sourceNodeId ?? this.sourceNodeId,
      targetNodeId: targetNodeId ?? this.targetNodeId,
      type: type ?? this.type,
      strength: strength ?? this.strength,
      label: label ?? this.label,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sourceNodeId': sourceNodeId,
      'targetNodeId': targetNodeId,
      'type': type.name,
      'strength': strength,
      'label': label,
      'metadata': metadata,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory KnowledgeEdge.fromMap(Map<String, dynamic> map) {
    return KnowledgeEdge(
      id: map['id'] as String,
      sourceNodeId: map['sourceNodeId'] as String,
      targetNodeId: map['targetNodeId'] as String,
      type: KnowledgeEdgeType.fromString(map['type'] as String? ?? 'relatedTo'),
      strength: (map['strength'] as num?)?.toDouble() ?? 0.5,
      label: map['label'] as String?,
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? {}),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }

  String toJson() => json.encode(toMap());
  factory KnowledgeEdge.fromJson(String source) =>
      KnowledgeEdge.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is KnowledgeEdge && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'KnowledgeEdge($sourceNodeId --[$type]--> $targetNodeId)';
}

/// Types of semantic relationships between knowledge nodes.
enum KnowledgeEdgeType {
  requires_('Requires', true),
  buildsToward('Builds Toward', true),
  strengthens('Strengthens', true),
  weakens('Weakens', true),
  relatedTo('Related To', false),
  similarTo('Similar To', false),
  prerequisite('Prerequisite', true),
  outcome('Outcome', true),
  alternative('Alternative', false),
  partOf('Part Of', true),
  recommended('Recommended', true),
  custom('Custom', false);

  const KnowledgeEdgeType(this.label, this.isDirectional);

  final String label;
  final bool isDirectional;

  static KnowledgeEdgeType fromString(String value) {
    return KnowledgeEdgeType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => KnowledgeEdgeType.custom,
    );
  }
}
