import 'dart:convert';

import 'entity_type.dart' show EntityType;

/// A node in the Memory Graph.
///
/// Represents any entity tracked by Phoenix OS (person, skill, project,
/// habit, mission, lesson, decision, etc.).
///
/// Immutable. Use [copyWith] to produce modified copies.
class MemoryEntity {
  const MemoryEntity({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    required this.sourceEngine,
    this.sourceId,
    this.metadata = const {},
    this.importance = 0.0,
    this.createdAt,
  });

  /// Unique identifier in the graph (e.g. 'ent-mission-m1').
  final String id;

  /// Entity type.
  final EntityType type;

  /// Display title.
  final String title;

  /// Optional description.
  final String? description;

  /// The engine that owns this entity (e.g. 'mission_engine', 'academy').
  final String sourceEngine;

  /// The source entity's original ID.
  final String? sourceId;

  /// Extensible metadata key-value pairs.
  final Map<String, dynamic> metadata;

  /// Importance weight (0.0 - 1.0) for ranking.
  final double importance;

  /// When this entity was created in the graph.
  final DateTime? createdAt;

  MemoryEntity copyWith({
    String? id,
    EntityType? type,
    String? title,
    String? description,
    String? sourceEngine,
    String? sourceId,
    Map<String, dynamic>? metadata,
    double? importance,
    DateTime? createdAt,
    bool clearDescription = false,
    bool clearSourceId = false,
  }) {
    return MemoryEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      sourceEngine: sourceEngine ?? this.sourceEngine,
      sourceId: clearSourceId ? null : (sourceId ?? this.sourceId),
      metadata: metadata ?? this.metadata,
      importance: importance ?? this.importance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'sourceEngine': sourceEngine,
      'sourceId': sourceId,
      'metadata': metadata,
      'importance': importance,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory MemoryEntity.fromMap(Map<String, dynamic> map) {
    return MemoryEntity(
      id: map['id'] as String,
      type: EntityType.fromString(map['type'] as String? ?? 'custom'),
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      sourceEngine: map['sourceEngine'] as String? ?? '',
      sourceId: map['sourceId'] as String?,
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? {}),
      importance: (map['importance'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
    );
  }

  String toJson() => json.encode(toMap());
  factory MemoryEntity.fromJson(String source) =>
      MemoryEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MemoryEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MemoryEntity(id: $id, type: $type, title: $title)';
}
