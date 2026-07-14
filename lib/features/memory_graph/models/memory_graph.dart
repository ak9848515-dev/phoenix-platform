import 'dart:collection';
import 'dart:convert';

import 'entity_type.dart';
import 'memory_entity.dart';
import 'memory_relation.dart';
import 'relation_type.dart';

/// The complete Memory Graph — all entities and their relationships.
///
/// Immutable. The [adjacencyIndex] provides O(1) lookups for
/// graph traversal. It is computed on construction.
class MemoryGraph {
  const MemoryGraph({
    this.entities = const [],
    this.relations = const [],
  }) : _adjacencyIndex = null;

  MemoryGraph.withIndex({
    this.entities = const [],
    this.relations = const [],
    Map<String, List<MemoryRelation>>? adjacencyIndex,
  }) : _adjacencyIndex = adjacencyIndex ?? const {};

  /// All entities in the graph.
  final List<MemoryEntity> entities;

  /// All relations in the graph.
  final List<MemoryRelation> relations;

  /// Adjacency index: entityId → outgoing relations.
  /// Built lazily on first access.
  final Map<String, List<MemoryRelation>>? _adjacencyIndex;

  /// Adjacency index for O(1) traversal lookups.
  Map<String, List<MemoryRelation>> get adjacencyIndex {
    if (_adjacencyIndex != null) return _adjacencyIndex;
    return _buildAdjacencyIndex();
  }

  Map<String, List<MemoryRelation>> _buildAdjacencyIndex() {
    final index = <String, List<MemoryRelation>>{};
    for (final rel in relations) {
      index.putIfAbsent(rel.sourceEntityId, () => []).add(rel);
      // Also index by target for reverse traversal
      index.putIfAbsent(rel.targetEntityId, () => []).add(rel);
    }
    return index;
  }

  /// Gets relations for a specific entity (both outgoing and incoming).
  List<MemoryRelation> relationsForEntity(String entityId) {
    return adjacencyIndex[entityId] ?? [];
  }

  /// Gets entities connected to a given entity.
  List<MemoryEntity> connectedEntities(String entityId) {
    final connected = <MemoryEntity>{};
    final entityMap = {for (final e in entities) e.id: e};
    final rels = relationsForEntity(entityId);

    for (final rel in rels) {
      if (rel.sourceEntityId == entityId) {
        final target = entityMap[rel.targetEntityId];
        if (target != null) connected.add(target);
      }
      if (rel.targetEntityId == entityId) {
        final source = entityMap[rel.sourceEntityId];
        if (source != null) connected.add(source);
      }
    }
    return connected.toList();
  }

  /// Gets an entity by ID.
  MemoryEntity? entityById(String id) {
    try {
      return entities.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Gets relations of a specific type.
  List<MemoryRelation> relationsByType(RelationType type) {
    return relations.where((r) => r.type == type).toList();
  }

  /// Gets entities of a specific type.
  List<MemoryEntity> entitiesByType(EntityType type) {
    return entities.where((e) => e.type == type).toList();
  }

  // ── Stats ───────────────────────────────────────────────────────

  int get entityCount => entities.length;
  int get relationCount => relations.length;

  Map<String, int> get entityTypeCounts {
    final counts = <String, int>{};
    for (final e in entities) {
      counts[e.type.name] = (counts[e.type.name] ?? 0) + 1;
    }
    return SplayTreeMap<String, int>.from(counts);
  }

  Map<String, int> get relationTypeCounts {
    final counts = <String, int>{};
    for (final r in relations) {
      counts[r.type.name] = (counts[r.type.name] ?? 0) + 1;
    }
    return SplayTreeMap<String, int>.from(counts);
  }

  /// Finds entities by text search (title + description).
  List<MemoryEntity> search(String query) {
    if (query.trim().isEmpty) return entities;
    final lower = query.toLowerCase();
    return entities.where((e) {
      return e.title.toLowerCase().contains(lower) ||
          (e.description?.toLowerCase().contains(lower) ?? false);
    }).toList();
  }

  // ── Serialization ───────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'entities': entities.map((e) => e.toMap()).toList(),
      'relations': relations.map((r) => r.toMap()).toList(),
    };
  }

  factory MemoryGraph.fromMap(Map<String, dynamic> map) {
    return MemoryGraph(
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
    );
  }

  String toJson() => json.encode(toMap());
  factory MemoryGraph.fromJson(String source) =>
      MemoryGraph.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryGraph &&
          other.entityCount == entityCount &&
          other.relationCount == relationCount;

  @override
  int get hashCode => Object.hash(entityCount, relationCount);

  @override
  String toString() =>
      'MemoryGraph(entities: $entityCount, relations: $relationCount)';
}
