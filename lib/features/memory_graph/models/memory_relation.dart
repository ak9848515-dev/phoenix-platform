import 'dart:convert';

import 'relation_type.dart' show RelationType;

/// A directed relationship between two entities in the Memory Graph.
///
/// Immutable. Use [copyWith] to produce modified copies.
class MemoryRelation {
  const MemoryRelation({
    required this.id,
    required this.sourceEntityId,
    required this.targetEntityId,
    required this.type,
    this.strength = 1.0,
    this.label,
    this.metadata = const {},
    this.createdAt,
  });

  /// Unique identifier.
  final String id;

  /// ID of the source entity.
  final String sourceEntityId;

  /// ID of the target entity.
  final String targetEntityId;

  /// Type of relationship.
  final RelationType type;

  /// Strength of the relationship (0.0 - 1.0).
  final double strength;

  /// Optional display label override.
  final String? label;

  /// Extensible metadata.
  final Map<String, dynamic> metadata;

  /// When this relation was created.
  final DateTime? createdAt;

  MemoryRelation copyWith({
    String? id,
    String? sourceEntityId,
    String? targetEntityId,
    RelationType? type,
    double? strength,
    String? label,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    bool clearLabel = false,
  }) {
    return MemoryRelation(
      id: id ?? this.id,
      sourceEntityId: sourceEntityId ?? this.sourceEntityId,
      targetEntityId: targetEntityId ?? this.targetEntityId,
      type: type ?? this.type,
      strength: strength ?? this.strength,
      label: clearLabel ? null : (label ?? this.label),
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sourceEntityId': sourceEntityId,
      'targetEntityId': targetEntityId,
      'type': type.name,
      'strength': strength,
      'label': label,
      'metadata': metadata,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory MemoryRelation.fromMap(Map<String, dynamic> map) {
    return MemoryRelation(
      id: map['id'] as String,
      sourceEntityId: map['sourceEntityId'] as String? ?? '',
      targetEntityId: map['targetEntityId'] as String? ?? '',
      type: RelationType.fromString(map['type'] as String? ?? 'associated'),
      strength: (map['strength'] as num?)?.toDouble() ?? 1.0,
      label: map['label'] as String?,
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? {}),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
    );
  }

  String toJson() => json.encode(toMap());
  factory MemoryRelation.fromJson(String source) =>
      MemoryRelation.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MemoryRelation && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MemoryRelation($sourceEntityId --[$type]--> $targetEntityId)';
}
