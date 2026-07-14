import 'dart:convert';

import 'memory_entity.dart';
import 'memory_relation.dart';

/// A subgraph of the Memory Graph centered around a focal entity.
///
/// Immutable. Produced by [MemoryGraphEngine.buildContext].
class MemoryContext {
  const MemoryContext({
    required this.focalEntity,
    this.relatedEntities = const [],
    this.relations = const [],
    this.depth = 1,
  });

  /// The focal entity this context is centered on.
  final MemoryEntity focalEntity;

  /// Entities directly related to the focal entity.
  final List<MemoryEntity> relatedEntities;

  /// Relations connecting these entities.
  final List<MemoryRelation> relations;

  /// Maximum traversal depth used to build this context.
  final int depth;

  int get totalEntities => relatedEntities.length + 1;
  int get totalRelations => relations.length;

  /// Connected entities grouped by relation type.
  Map<String, List<MemoryEntity>> get groupedByRelation {
    final groups = <String, List<MemoryEntity>>{};
    for (final rel in relations) {
      final key = rel.type.label;
      if (rel.sourceEntityId == focalEntity.id) {
        final target = relatedEntities.cast<MemoryEntity?>().firstWhere(
            (e) => e?.id == rel.targetEntityId,
            orElse: () => null);
        if (target != null) {
          groups.putIfAbsent(key, () => []).add(target);
        }
      } else if (rel.targetEntityId == focalEntity.id) {
        final source = relatedEntities.cast<MemoryEntity?>().firstWhere(
            (e) => e?.id == rel.sourceEntityId,
            orElse: () => null);
        if (source != null) {
          groups.putIfAbsent(key, () => []).add(source);
        }
      }
    }
    return groups;
  }

  Map<String, dynamic> toMap() {
    return {
      'focalEntity': focalEntity.toMap(),
      'relatedEntities': relatedEntities.map((e) => e.toMap()).toList(),
      'relations': relations.map((r) => r.toMap()).toList(),
      'depth': depth,
    };
  }

  factory MemoryContext.fromMap(Map<String, dynamic> map) {
    return MemoryContext(
      focalEntity: MemoryEntity.fromMap(
          Map<String, dynamic>.from(map['focalEntity'] as Map)),
      relatedEntities: (map['relatedEntities'] as List?)
              ?.map((e) => MemoryEntity.fromMap(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      relations: (map['relations'] as List?)
              ?.map((r) => MemoryRelation.fromMap(
                  Map<String, dynamic>.from(r as Map)))
              .toList() ??
          [],
      depth: map['depth'] as int? ?? 1,
    );
  }

  String toJson() => json.encode(toMap());
  factory MemoryContext.fromJson(String source) =>
      MemoryContext.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryContext && other.focalEntity == focalEntity;

  @override
  int get hashCode => focalEntity.hashCode;

  @override
  String toString() =>
      'MemoryContext(focal: ${focalEntity.title}, '
      'related: ${relatedEntities.length})';
}
