import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../ai/services/ai_mentor_service.dart';
import '../../user_state/services/user_state_service.dart';
import '../../../core/storage_service.dart';
import '../engine/memory_graph_engine.dart';
import '../models/entity_type.dart';
import '../models/memory_cluster.dart';
import '../models/memory_context.dart';
import '../models/memory_entity.dart';
import '../models/memory_graph.dart';
import '../models/memory_insight.dart';
import '../models/memory_relation.dart';
/// Public API for the Memory Graph Engine.
///
/// [MemoryGraphService] is the ONLY entry point for graph functionality.
/// Screens and widgets never interact with [MemoryGraphEngine] directly.
///
/// Responsibilities:
/// - Entity and relationship management
/// - Graph traversal, context discovery, search
/// - Clustering and analytics
/// - AI-enhanced insight explanations
/// - Persistence through [UserStateService]
///
/// **Architecture Rules:**
/// - NEVER own Mission, Timeline, Habit, Decision, AI, or UserState logic
/// - [MemoryGraphEngine] owns graph intelligence — never duplicated
/// - AI integration uses [AIMentorService] only
class MemoryGraphService extends ChangeNotifier {
  MemoryGraphService({
    required this._userStateService,
    required this._aiMentorService,
    MemoryGraphEngine? engine,
    StorageService? storageService,
  }) : _engine = engine ?? const MemoryGraphEngine(),
       _storage = storageService;

  final UserStateService _userStateService;
  final AIMentorService _aiMentorService;
  final MemoryGraphEngine _engine;
  final StorageService? _storage;
  bool _initialized = false;

  // ── Graph Access ─────────────────────────────────────────────────

  /// The current memory graph, loaded from UserState.
  MemoryGraph get graph {
    final data = _userStateService.currentState.memoryGraphData;
    if (data == null || data.isEmpty) {
      return const MemoryGraph();
    }
    return MemoryGraph.fromMap(data);
  }

  /// Persists the graph to both UserState and StorageService.
  Future<void> _saveGraph(MemoryGraph g) async {
    await _userStateService.update(
      (s) => s.copyWith(memoryGraphData: g.toMap()),
    );
    await _persistToStorage(g);
    notifyListeners();
  }

  // ── Entity Operations ────────────────────────────────────────────

  /// Registers entities from any platform engine.
  Future<void> registerEntities(List<MemoryEntity> entities) async {
    final g = graph;
    final updated = _engine.registerEntities(g, entities);
    await _saveGraph(updated);
  }

  /// Registers a single entity.
  Future<void> registerEntity(MemoryEntity entity) async {
    await registerEntities([entity]);
  }

  /// Removes entities by ID.
  Future<void> removeEntities(List<String> entityIds) async {
    final g = graph;
    final updated = _engine.removeEntities(g, entityIds);
    await _saveGraph(updated);
  }

  /// Gets an entity by ID.
  MemoryEntity? getEntity(String id) => graph.entityById(id);

  /// Gets all entities.
  List<MemoryEntity> get allEntities => graph.entities;

  /// Gets entities by type.
  List<MemoryEntity> entitiesByType(EntityType type) =>
      graph.entitiesByType(type);

  // ── Relation Operations ──────────────────────────────────────────

  /// Creates a relationship between two entities.
  Future<void> createRelation(MemoryRelation relation) async {
    final g = graph;
    final updated = _engine.createRelation(g, relation);
    await _saveGraph(updated);
  }

  /// Removes a relation.
  Future<void> removeRelation(String relationId) async {
    final g = graph;
    final updated = _engine.removeRelation(g, relationId);
    await _saveGraph(updated);
  }

  /// Gets relations for an entity.
  List<MemoryRelation> relationsForEntity(String entityId) =>
      graph.relationsForEntity(entityId);

  // ── Auto-Discovery ───────────────────────────────────────────────

  /// Discovers auto-relations from shared source IDs.
  Future<void> discoverAutoRelations() async {
    final g = graph;
    final autoRelations = _engine.discoverAutoRelations(g);
    if (autoRelations.isNotEmpty) {
      final updated = _engine.createRelations(g, autoRelations);
      await _saveGraph(updated);
    }
  }

  // ── Traversal & Context ──────────────────────────────────────────

  /// BFS traversal from an entity.
  List<MemoryEntity> traverse(String entityId, {int maxDepth = 3}) =>
      _engine.bfsTraverse(graph, entityId, maxDepth: maxDepth);

  /// Builds a context around a focal entity.
  MemoryContext buildContext(String entityId, {int depth = 1}) =>
      _engine.buildContext(graph, entityId, depth: depth);

  /// Finds shortest path between two entities.
  List<MemoryEntity>? findShortestPath(String sourceId, String targetId) =>
      _engine.findShortestPath(graph, sourceId, targetId);

  // ── Search ───────────────────────────────────────────────────────

  /// Text search across all entities.
  List<MemoryEntity> search(String query, {EntityType? typeFilter}) =>
      _engine.searchEntities(graph, query, typeFilter: typeFilter);

  /// Similarity search.
  List<MemoryEntity> findSimilar(String entityId) =>
      _engine.findSimilar(graph, entityId);

  // ── Clustering ───────────────────────────────────────────────────

  /// Detects clusters in the graph.
  List<MemoryCluster> detectClusters() => _engine.detectClusters(graph);

  // ── Analytics ────────────────────────────────────────────────────

  /// Graph density.
  double get density => _engine.calculateDensity(graph);

  /// Most connected entities.
  List<MemoryEntity> findHubs({int topN = 5}) =>
      _engine.findHubs(graph, topN: topN);

  /// Degree centrality for an entity.
  int degreeCentrality(String entityId) =>
      _engine.degreeCentrality(graph, entityId);

  /// Graph statistics.
  Map<String, dynamic> get stats {
    final g = graph;
    return {
      'entityCount': g.entityCount,
      'relationCount': g.relationCount,
      'density': density,
      'entityTypes': g.entityTypeCounts,
      'relationTypes': g.relationTypeCounts,
    };
  }

  // ── Insights ─────────────────────────────────────────────────────

  /// Generates graph-based insights.
  List<MemoryInsight> insights() => _engine.generateInsights(graph);

  /// AI-enhanced explanation for an insight.
  Future<String> explainInsight(MemoryInsight insight) async {
    final entityTitles =
        insight.entities.take(3).map((e) => e.title).join(', ');
    final response = await _aiMentorService.chat(
      'I have a Memory Graph insight: "${insight.title}" - '
      '${insight.description ?? ""} '
      'Related entities: $entityTitles. '
      'Give me a brief explanation of why this connection matters.',
    );
    return response.content;
  }

  // ── Persistence ───────────────────────────────────────────────────

  /// Initializes the service by loading persisted graph data from storage.
  ///
  /// If UserState is empty but storage has data (e.g. after a cold start),
  /// loads the graph from storage into UserState. If storage is also empty
  /// (first launch), UserState remains empty and [seedFromPlatform] will
  /// populate it.
  ///
  /// Handles upgrade from v1 where UserState was the sole persistence layer:
  /// if UserState has data but storage is empty, writes to storage so
  /// subsequent launches can read from storage.
  Future<void> initFromStorage() async {
    if (_initialized) return;
    _initialized = true;

    final storage = _storage;
    if (storage == null) return;

    final currentState = _userStateService.currentState;
    final raw = storage.readMemoryGraph();

    if (raw != null && currentState.memoryGraphData == null) {
      // Storage has data, UserState is empty — load from storage
      try {
        final decoded = Map<String, dynamic>.from(
            json.decode(raw) as Map<String, dynamic>);
        await _userStateService.update(
          (s) => s.copyWith(memoryGraphData: decoded),
        );
      } catch (e) {
        debugPrint('MemoryGraphService: failed to load from storage: $e');
      }
    } else if (raw == null && currentState.memoryGraphData != null) {
      // UserState has data but storage is empty — upgrade from v1
      await _persistToStorage(graph);
    }
  }

  /// Persists the current graph to storage.
  Future<void> _persistToStorage(MemoryGraph g) async {
    final storage = _storage;
    if (storage == null) return;
    try {
      await storage.saveMemoryGraph(json.encode(g.toMap()));
    } catch (e) {
      debugPrint('MemoryGraphService: failed to persist graph: $e');
    }
  }

  // ── Platform Integration ─────────────────────────────────────────

  /// Seeds the graph with entities from all platform engines.
  /// Called once during bootstrap.
  Future<void> seedFromPlatform() async {
    final state = _userStateService.currentState;
    final entities = <MemoryEntity>[];

    // Missions
    for (final mission in state.missions) {
      entities.add(MemoryEntity(
        id: _engine.entityId('mission', mission.id),
        type: EntityType.mission,
        title: mission.title,
        description: mission.description,
        sourceEngine: 'mission_engine',
        sourceId: mission.id,
        importance: mission.isCompleted ? 0.8 : 0.4,
        createdAt: mission.completedDate ?? mission.createdDate,
      ));
    }

    // Decisions
    for (final decision in state.decisionHistory) {
      entities.add(MemoryEntity(
        id: _engine.entityId('decision', decision.id),
        type: EntityType.decision,
        title: decision.title,
        description: 'Decision with ${decision.options.length} options',
        sourceEngine: 'decision',
        sourceId: decision.id,
        importance: decision.confidence,
        createdAt: decision.createdAt,
      ));
    }

    // Habits
    for (final habit in state.habits) {
      entities.add(MemoryEntity(
        id: _engine.entityId('habit', habit.id),
        type: EntityType.habit,
        title: habit.title,
        description: habit.description,
        sourceEngine: 'habit',
        sourceId: habit.id,
        importance: habit.isActive ? 0.6 : 0.2,
        createdAt: habit.createdAt,
      ));
    }

    // Portfolio
    final portfolio = state.portfolio;
    if (portfolio != null) {
      entities.add(MemoryEntity(
        id: _engine.entityId('portfolio', 'main'),
        type: EntityType.portfolio,
        title: 'Portfolio (${portfolio.careerReadiness})',
        sourceEngine: 'portfolio',
        sourceId: 'main',
        importance: 0.7,
      ));
    }

    // Resume
    final resume = state.resume;
    if (resume != null) {
      entities.add(MemoryEntity(
        id: _engine.entityId('resume', 'main'),
        type: EntityType.resume,
        title: 'Resume (${resume.professionalSummary})',
        sourceEngine: 'resume',
        sourceId: 'main',
        importance: 0.7,
      ));
    }

    if (entities.isNotEmpty) {
      await registerEntities(entities);
      await discoverAutoRelations();
    }
  }

  // ── Diagnostics ──────────────────────────────────────────────────

  Map<String, dynamic> diagnostics() {
    return {
      'entityCount': graph.entityCount,
      'relationCount': graph.relationCount,
      'clusterCount': detectClusters().length,
    };
  }
}
