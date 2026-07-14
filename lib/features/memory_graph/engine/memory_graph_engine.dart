import 'dart:collection' show Queue;
import 'dart:math' as math;

import '../models/entity_type.dart';
import '../models/memory_cluster.dart';
import '../models/memory_context.dart';
import '../models/memory_entity.dart';
import '../models/memory_graph.dart';
import '../models/memory_insight.dart';
import '../models/memory_relation.dart';
import '../models/relation_type.dart';

/// The core Memory Graph Engine.
///
/// Owns:
/// - Entity registration (adding/removing entities)
/// - Relationship management (creating/deleting relations)
/// - Graph traversal (BFS from any entity)
/// - Context discovery (subgraph around a focal entity)
/// - Similarity search (entities with shared traits)
/// - Memory clustering (dense subgraph detection)
/// - Graph analytics (statistics, density, centrality)
/// - Recall suggestions (entities to revisit)
///
/// **Never** owns business logic from Mission, Timeline, Habit,
/// Decision, AI, or UserState engines.
///
/// Pure Dart — no Flutter or service dependencies.
/// Integration happens in [MemoryGraphService].
class MemoryGraphEngine {
  const MemoryGraphEngine();

  // ── Entity Registration ──────────────────────────────────────────

  /// Registers entities into a graph, deduplicating by ID.
  MemoryGraph registerEntities(
    MemoryGraph graph,
    List<MemoryEntity> newEntities,
  ) {
    final entityMap = {for (final e in graph.entities) e.id: e};
    for (final entity in newEntities) {
      entityMap[entity.id] = entity;
    }
    return MemoryGraph(
      entities: entityMap.values.toList(),
      relations: graph.relations,
    );
  }

  /// Removes entities and their relations from the graph.
  MemoryGraph removeEntities(
    MemoryGraph graph,
    List<String> entityIds,
  ) {
    final idSet = entityIds.toSet();
    return MemoryGraph(
      entities: graph.entities.where((e) => !idSet.contains(e.id)).toList(),
      relations: graph.relations
          .where((r) =>
              !idSet.contains(r.sourceEntityId) &&
              !idSet.contains(r.targetEntityId))
          .toList(),
    );
  }

  /// Gets an entity by its source engine and source ID composite key.
  MemoryEntity? findEntityBySource(
    MemoryGraph graph,
    String sourceEngine,
    String sourceId,
  ) {
    try {
      return graph.entities.firstWhere(
        (e) => e.sourceEngine == sourceEngine && e.sourceId == sourceId,
      );
    } catch (_) {
      return null;
    }
  }

  // ── Relationship Management ──────────────────────────────────────

  /// Creates a relationship between two entities.
  MemoryGraph createRelation(
    MemoryGraph graph,
    MemoryRelation relation,
  ) {
    final existing = graph.relations.any((r) => r.id == relation.id);
    if (existing) return graph;

    final newRelations = List<MemoryRelation>.from(graph.relations)
      ..add(relation);
    return MemoryGraph(
      entities: graph.entities,
      relations: newRelations,
    );
  }

  /// Creates multiple relations at once.
  MemoryGraph createRelations(
    MemoryGraph graph,
    List<MemoryRelation> relations,
  ) {
    final existingIds = graph.relations.map((r) => r.id).toSet();
    final newRelations = List<MemoryRelation>.from(graph.relations);
    for (final rel in relations) {
      if (!existingIds.contains(rel.id)) {
        newRelations.add(rel);
      }
    }
    return MemoryGraph(
      entities: graph.entities,
      relations: newRelations,
    );
  }

  /// Removes a relation by ID.
  MemoryGraph removeRelation(MemoryGraph graph, String relationId) {
    return MemoryGraph(
      entities: graph.entities,
      relations:
          graph.relations.where((r) => r.id != relationId).toList(),
    );
  }

  /// Auto-discovers relations between entities that share the same
  /// source entity type or common metadata keys.
  List<MemoryRelation> discoverAutoRelations(MemoryGraph graph) {
    final autoRelations = <MemoryRelation>[];
    final entities = graph.entities;
    int relCounter = graph.relations.length;

    // Same source ID → strong association
    final bySourceId = <String, List<MemoryEntity>>{};
    for (final entity in entities) {
      if (entity.sourceId != null) {
        bySourceId.putIfAbsent(entity.sourceId!, () => []).add(entity);
      }
    }
    for (final group in bySourceId.values) {
      for (int i = 0; i < group.length; i++) {
        for (int j = i + 1; j < group.length; j++) {
          autoRelations.add(MemoryRelation(
            id: 'auto-src-${relCounter++}',
            sourceEntityId: group[i].id,
            targetEntityId: group[j].id,
            type: RelationType.associated,
            strength: 0.8,
            label: 'Shared source',
          ));
        }
      }
    }

    return autoRelations;
  }

  // ── Graph Traversal ──────────────────────────────────────────────

  /// BFS traversal from a starting entity.
  ///
  /// Returns entities reachable within [maxDepth] hops.
  List<MemoryEntity> bfsTraverse(
    MemoryGraph graph,
    String startEntityId, {
    int maxDepth = 3,
    Set<RelationType>? relationFilter,
  }) {
    final entityMap = {for (final e in graph.entities) e.id: e};
    if (!entityMap.containsKey(startEntityId)) return [];

    final visited = <String>{startEntityId};
    final result = <MemoryEntity>[];
    final queue = Queue<_QueueItem>()..add(_QueueItem(startEntityId, 0));

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (current.depth >= maxDepth) continue;

      final relations = graph.relationsForEntity(current.entityId);
      for (final rel in relations) {
        if (relationFilter != null && !relationFilter.contains(rel.type)) {
          continue;
        }

        final neighborId = rel.sourceEntityId == current.entityId
            ? rel.targetEntityId
            : rel.sourceEntityId;

        if (visited.add(neighborId)) {
          final entity = entityMap[neighborId];
          if (entity != null) {
            result.add(entity);
            queue.add(_QueueItem(neighborId, current.depth + 1));
          }
        }
      }
    }

    return result;
  }

  /// Finds the shortest path between two entities.
  List<MemoryEntity>? findShortestPath(
    MemoryGraph graph,
    String sourceId,
    String targetId,
  ) {
    if (sourceId == targetId) return [];

    final entityMap = {for (final e in graph.entities) e.id: e};
    if (!entityMap.containsKey(sourceId) ||
        !entityMap.containsKey(targetId)) {
      return null;
    }

    // BFS with path tracking
    final visited = <String>{sourceId};
    final parent = <String, String>{};
    final queue = Queue<String>()..add(sourceId);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (current == targetId) break;

      final relations = graph.relationsForEntity(current);
      for (final rel in relations) {
        final neighbor = rel.sourceEntityId == current
            ? rel.targetEntityId
            : rel.sourceEntityId;
        if (visited.add(neighbor)) {
          parent[neighbor] = current;
          queue.add(neighbor);
        }
      }
    }

    if (!parent.containsKey(targetId) && sourceId != targetId) return null;

    // Reconstruct path
    final path = <String>[];
    var current = targetId;
    while (current != sourceId) {
      path.add(current);
      current = parent[current]!;
    }
    path.add(sourceId);
    return path.reversed.map((id) => entityMap[id]!).toList();
  }

  // ── Context Discovery ────────────────────────────────────────────

  /// Builds a context subgraph around a focal entity.
  MemoryContext buildContext(
    MemoryGraph graph,
    String focalEntityId, {
    int depth = 1,
    Set<RelationType>? relationFilter,
  }) {
    final entity = graph.entityById(focalEntityId);
    if (entity == null) {
      return MemoryContext(
        focalEntity: MemoryEntity(
          id: focalEntityId,
          type: EntityType.custom,
          title: 'Unknown',
          sourceEngine: '',
        ),
      );
    }

    final related = bfsTraverse(graph, focalEntityId,
        maxDepth: depth, relationFilter: relationFilter);

    // Collect relevant relations
    final relatedIds = related.map((e) => e.id).toSet()..add(focalEntityId);
    final contextRelations = graph.relations
        .where((r) =>
            relatedIds.contains(r.sourceEntityId) &&
            relatedIds.contains(r.targetEntityId))
        .toList();

    return MemoryContext(
      focalEntity: entity,
      relatedEntities: related,
      relations: contextRelations,
      depth: depth,
    );
  }

  // ── Similarity Search ────────────────────────────────────────────

  /// Finds entities similar to a given entity based on shared type,
  /// source engine, and metadata keys.
  List<MemoryEntity> findSimilar(
    MemoryGraph graph,
    String entityId, {
    int maxResults = 10,
  }) {
    final entity = graph.entityById(entityId);
    if (entity == null) return [];

    final scored = <_ScoredEntity>[];

    for (final other in graph.entities) {
      if (other.id == entityId) continue;

      double score = 0.0;

      // Same type = strong signal
      if (other.type == entity.type) score += 0.4;
      // Same source engine = moderate signal
      if (other.sourceEngine == entity.sourceEngine) score += 0.2;
      // Shared metadata keys = weak signal
      final sharedKeys = entity.metadata.keys
          .where((k) => other.metadata.containsKey(k))
          .length;
      score += sharedKeys * 0.05;

      // Title overlap (simple word overlap)
      final entityWords =
          entity.title.toLowerCase().split(RegExp(r'\s+'));
      final otherWords =
          other.title.toLowerCase().split(RegExp(r'\s+'));
      final overlap = entityWords
          .where((w) => otherWords.contains(w))
          .length;
      if (entityWords.isNotEmpty) {
        score += (overlap / entityWords.length) * 0.2;
      }

      if (score > 0) {
        scored.add(_ScoredEntity(other, score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(maxResults).map((s) => s.entity).toList();
  }

  // ── Search ───────────────────────────────────────────────────────

  /// Searches entities by text query with relevance scoring.
  List<MemoryEntity> searchEntities(
    MemoryGraph graph,
    String query, {
    EntityType? typeFilter,
    int maxResults = 20,
  }) {
    if (query.trim().isEmpty) return [];

    final lower = query.toLowerCase();
    final terms = lower.split(RegExp(r'\s+'));

    var candidates = graph.entities;
    if (typeFilter != null) {
      candidates =
          candidates.where((e) => e.type == typeFilter).toList();
    }

    final scored = <_ScoredEntity>[];
    for (final entity in candidates) {
      double score = 0.0;
      final titleLower = entity.title.toLowerCase();
      final descLower = entity.description?.toLowerCase() ?? '';

      for (final term in terms) {
        if (titleLower.contains(term)) score += 0.5;
        if (descLower.contains(term)) score += 0.3;
        if (entity.sourceEngine.toLowerCase().contains(term)) {
          score += 0.2;
        }
      }

      if (score > 0) {
        scored.add(_ScoredEntity(entity, score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(maxResults).map((s) => s.entity).toList();
  }

  // ── Clustering ───────────────────────────────────────────────────

  /// Detects clusters (dense subgraphs) in the graph using
  /// a simple community detection approach.
  List<MemoryCluster> detectClusters(
    MemoryGraph graph, {
    int minClusterSize = 2,
  }) {
    if (graph.entities.isEmpty) return [];

    final clusters = <MemoryCluster>[];
    final assigned = <String>{};
    int clusterId = 0;

    for (final entity in graph.entities) {
      if (assigned.contains(entity.id)) continue;

      // Find all entities within 2 hops
      final clusterEntities =
          bfsTraverse(graph, entity.id, maxDepth: 2);
      clusterEntities.insert(0, entity);

      final clusterEntityIds =
          clusterEntities.map((e) => e.id).toSet();

      // Skip already-assigned
      final newIds =
          clusterEntityIds.difference(assigned).toList();
      if (newIds.length < minClusterSize) continue;

      // Collect relations within cluster
      final clusterRelations = graph.relations
          .where((r) =>
              clusterEntityIds.contains(r.sourceEntityId) &&
              clusterEntityIds.contains(r.targetEntityId))
          .toList();

      // Build label from dominant type
      final typeCounts = <EntityType, int>{};
      for (final e in clusterEntities) {
        typeCounts[e.type] = (typeCounts[e.type] ?? 0) + 1;
      }
      final dominant = typeCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      // Build label from titles
      final titles =
          clusterEntities.take(3).map((e) => e.title).join(', ');
      final labelSuffix = clusterEntities.length > 3 ? '...' : '';
      final label = '$dominant Cluster: $titles$labelSuffix';

      assigned.addAll(clusterEntityIds);
      clusters.add(MemoryCluster(
        id: 'cluster-${clusterId++}',
        label: label,
        entities:
            newIds.map((id) => graph.entityById(id)!).toList(),
        relations: clusterRelations,
        score: (clusterRelations.length /
                math.max(1, newIds.length))
            .clamp(0.0, 1.0),
      ));
    }

    return clusters;
  }

  // ── Graph Analytics ──────────────────────────────────────────────

  /// Computes graph density (0.0 - 1.0).
  double calculateDensity(MemoryGraph graph) {
    final n = graph.entityCount;
    if (n < 2) return 0.0;
    final maxEdges = n * (n - 1) / 2;
    return graph.relationCount / maxEdges;
  }

  /// Computes degree centrality for an entity (number of connections).
  int degreeCentrality(MemoryGraph graph, String entityId) {
    return graph.relationsForEntity(entityId).length;
  }

  /// Finds the most connected entities (hubs).
  List<MemoryEntity> findHubs(MemoryGraph graph, {int topN = 5}) {
    final scored = graph.entities
        .map((e) =>
            _ScoredEntity(e, graph.relationsForEntity(e.id).length.toDouble()))
        .toList();
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(topN).map((s) => s.entity).toList();
  }

  // ── Insights ─────────────────────────────────────────────────────

  /// Generates graph-based insights.
  List<MemoryInsight> generateInsights(MemoryGraph graph) {
    final insights = <MemoryInsight>[];

    // Most connected entity insight
    final hubs = findHubs(graph, topN: 1);
    if (hubs.isNotEmpty) {
      final hub = hubs.first;
      final degree = degreeCentrality(graph, hub.id);
      insights.add(MemoryInsight(
        id: 'insight-hub',
        title: 'Most Connected: ${hub.title}',
        description:
            '${hub.title} has $degree connections, making it the '
            'most central entity in your graph.',
        type: MemoryInsightType.pattern,
        entities: [hub],
        relevance: 0.8,
      ));
    }

    // Cluster insight
    final clusters = detectClusters(graph);
    if (clusters.length > 1) {
      final largest = clusters
          .reduce((a, b) => a.entityCount > b.entityCount ? a : b);
      insights.add(MemoryInsight(
        id: 'insight-largest-cluster',
        title: 'Largest Cluster: ${largest.label}',
        description:
            'Your largest memory cluster contains ${largest.entityCount} '
            'entities with ${largest.relationCount} connections.',
        type: MemoryInsightType.cluster,
        entities: largest.entities,
        relations: largest.relations,
        relevance: 0.7,
      ));
    }

    // Density insight
    final density = calculateDensity(graph);
    if (graph.entityCount > 5 && density < 0.1) {
      insights.add(MemoryInsight(
        id: 'insight-sparse',
        title: 'Sparse Graph',
        description:
            'Your graph has low density (${(density * 100).toStringAsFixed(1)}%). '
            'Try connecting more entities to discover hidden patterns.',
        type: MemoryInsightType.gap,
        relevance: 0.5,
      ));
    }

    return insights;
  }

  // ── Helpers ──────────────────────────────────────────────────────

  /// Generates a deterministic entity ID from source engine + source ID.
  String entityId(String sourceEngine, String sourceId) =>
      'ent-$sourceEngine-$sourceId';
}

/// Internal helper for BFS queue.
class _QueueItem {
  _QueueItem(this.entityId, this.depth);
  final String entityId;
  final int depth;
}

/// Internal helper for scored search results.
class _ScoredEntity {
  _ScoredEntity(this.entity, this.score);
  final MemoryEntity entity;
  final double score;
}
