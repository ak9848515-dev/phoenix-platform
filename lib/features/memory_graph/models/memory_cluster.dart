import 'dart:convert';

import 'entity_type.dart';
import 'memory_entity.dart';
import 'memory_relation.dart';

/// A cluster of related entities forming a meaningful group.
///
/// Immutable. Produced by [MemoryGraphEngine.detectClusters].
class MemoryCluster {
  const MemoryCluster({
    required this.id,
    required this.label,
    this.description,
    this.entities = const [],
    this.relations = const [],
    this.score = 0.0,
  });

  /// Unique identifier.
  final String id;

  /// Human-readable label (e.g. "Flutter Learning Path").
  final String label;

  /// Optional description.
  final String? description;

  /// Entities in this cluster.
  final List<MemoryEntity> entities;

  /// Relations connecting entities within this cluster.
  final List<MemoryRelation> relations;

  /// Relevance score (0.0 - 1.0).
  final double score;

  int get entityCount => entities.length;
  int get relationCount => relations.length;

  /// Dominant entity type in this cluster.
  EntityType? get dominantType {
    if (entities.isEmpty) return null;
    final counts = <EntityType, int>{};
    for (final e in entities) {
      counts[e.type] = (counts[e.type] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'description': description,
      'entities': entities.map((e) => e.toMap()).toList(),
      'relations': relations.map((r) => r.toMap()).toList(),
      'score': score,
    };
  }

  factory MemoryCluster.fromMap(Map<String, dynamic> map) {
    return MemoryCluster(
      id: map['id'] as String,
      label: map['label'] as String? ?? '',
      description: map['description'] as String?,
      entities: (map['entities'] as List?)
              ?.map((e) => MemoryEntity.fromMap(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      relations: (map['relations'] as List?)
              ?.map((r) => MemoryRelation.fromMap(
                  Map<String, dynamic>.from(r as Map)))
              .toList() ??
          [],
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());
  factory MemoryCluster.fromJson(String source) =>
      MemoryCluster.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MemoryCluster && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MemoryCluster(id: $id, label: $label, entities: $entityCount)';
}
