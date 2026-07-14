import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/storage_service.dart';
import '../../ai/services/ai_mentor_service.dart';
import '../../user_state/services/user_state_service.dart';
import '../engine/personal_knowledge_engine.dart';
import '../models/knowledge_context.dart';
import '../models/knowledge_domain.dart';
import '../models/knowledge_insight.dart';
import '../models/knowledge_node.dart';
import '../models/knowledge_recommendation.dart';
import '../models/knowledge_snapshot.dart';

/// Public API for the Personal Knowledge Engine.
///
/// [KnowledgeService] is the ONLY entry point for knowledge functionality.
/// Screens and widgets never interact with [PersonalKnowledgeEngine] directly.
///
/// Responsibilities:
/// - Semantic knowledge indexing
/// - Context generation for AI
/// - Cross-domain reasoning
/// - Recommendations and insights
/// - Persistence through [UserStateService]
///
/// **Architecture Rules:**
/// - NEVER own Memory Graph, Timeline, Habit, Mission, Decision, AI, or UserState logic
/// - [PersonalKnowledgeEngine] owns semantic intelligence — never duplicated
/// - Integrations read from other services — never write
class KnowledgeService extends ChangeNotifier {
  KnowledgeService({
    required this._userStateService,
    required this._aiMentorService,
    PersonalKnowledgeEngine? engine,
    /// Optional [StorageService] for explicit persistence of knowledge
    /// snapshot data. When provided, snapshot writes are mirrored to storage.
    StorageService? storageService,
  })  : _engine = engine ?? const PersonalKnowledgeEngine(),
        _storage = storageService;

  final UserStateService _userStateService;
  final AIMentorService _aiMentorService;
  final PersonalKnowledgeEngine _engine;
  final StorageService? _storage;

  /// Whether persisted data has been loaded into UserState.
  bool _initialized = false;

  /// Loads persisted knowledge snapshot from storage into UserState.
  ///
  /// Called once during bootstrap. Merges stored snapshot into the
  /// current user state so that existing persisted data is available
  /// before any service reads occur. Also handles upgrade from v1
  /// where UserState was the sole persistence layer.
  Future<void> initFromStorage() async {
    if (_initialized) return;
    _initialized = true;

    final storage = _storage;
    if (storage == null) return;

    final raw = storage.readKnowledgeSnapshot();
    if (raw != null) {
      try {
        final map = json.decode(raw) as Map<String, dynamic>;
        // Only seed if user has no knowledge snapshot yet
        if (_userStateService.currentState.knowledgeSnapshot == null &&
            map.isNotEmpty) {
          await _userStateService.update(
              (s) => s.copyWith(knowledgeSnapshot: map));
        }
      } catch (e) {
        debugPrint(
            'KnowledgeService: failed to parse persisted snapshot: $e');
      }
    }

    // If UserState has data but storage is empty, persist to storage
    // (handles upgrade from v1 where snapshot was only in UserState)
    final currentState = _userStateService.currentState;
    if (raw == null &&
        currentState.knowledgeSnapshot != null &&
        currentState.knowledgeSnapshot!.isNotEmpty) {
      await _persistToStorage();
    }
  }

  /// Persists current knowledge snapshot to storage.
  Future<void> _persistToStorage() async {
    final storage = _storage;
    if (storage == null) return;
    try {
      final state = _userStateService.currentState;
      if (state.knowledgeSnapshot != null) {
        await storage.saveKnowledgeSnapshot(
          json.encode(state.knowledgeSnapshot),
        );
      }
    } catch (e) {
      debugPrint('KnowledgeService: failed to persist snapshot: $e');
    }
  }

  // ── Snapshot Access ───────────────────────────────────────────────

  /// Loads the current knowledge snapshot from UserState.
  KnowledgeSnapshot get snapshot {
    final data = _userStateService.currentState.knowledgeSnapshot;
    if (data == null || data.isEmpty) {
      return const KnowledgeSnapshot();
    }
    return KnowledgeSnapshot.fromMap(data);
  }

  /// Persists the current snapshot.
  Future<void> _saveSnapshot(KnowledgeSnapshot s) async {
    await _userStateService.update(
      (state) => state.copyWith(knowledgeSnapshot: s.toMap()),
    );
    await _persistToStorage();
    notifyListeners();
  }

  // ── Semantic Indexing ─────────────────────────────────────────────

  /// Indexes new knowledge nodes into the semantic index.
  Future<void> indexNodes(List<KnowledgeNode> nodes) async {
    final s = snapshot;
    final updated = _engine.indexNodes(s, nodes);

    // Build edges from the indexed nodes
    final edges = _engine.buildKnowledgeGraph(updated);
    await _saveSnapshot(updated.copyWith(edges: edges));
  }

  /// Indexes a single knowledge node.
  Future<void> indexNode(KnowledgeNode node) async {
    await indexNodes([node]);
  }

  /// Rebuilds the full knowledge graph (edges) from current nodes.
  Future<void> rebuildGraph() async {
    final s = snapshot;
    final edges = _engine.buildKnowledgeGraph(s);
    await _saveSnapshot(s.copyWith(edges: edges));
  }

  // ── Context Generation ────────────────────────────────────────────

  /// Builds the current knowledge context for AI consumption.
  KnowledgeContext buildContext() => _engine.buildContext(snapshot);

  /// Generates the AI context string and persists it.
  Future<KnowledgeContext> generateContext() async {
    final ctx = buildContext();
    final s = snapshot;
    await _saveSnapshot(s.copyWith(context: ctx));
    return ctx;
  }

  /// Gets the last generated context (or generates a fresh one).
  Future<KnowledgeContext> getOrGenerateContext() async {
    final s = snapshot;
    if (s.context != null) return s.context!;
    return generateContext();
  }

  /// Returns the context as a structured AI prompt string.
  Future<String> getContextPrompt() async {
    final ctx = await getOrGenerateContext();
    return ctx.toPromptString();
  }

  // ── AI Integration ────────────────────────────────────────────────

  /// Uses AI to explain a knowledge insight.
  Future<String> explainInsight(KnowledgeInsight insight) async {
    final response = await _aiMentorService.chat(
      'I have a Knowledge Insight: "${insight.title}" - '
      '${insight.description ?? ""} '
      'What does this mean for my personal growth?',
    );
    return response.content;
  }

  /// Uses AI to generate a personalized learning recommendation.
  Future<String> aiRecommendation() async {
    final ctx = await getOrGenerateContext();
    final response = await _aiMentorService.chat(
      'Based on this user knowledge context, suggest one specific actionable '
      'recommendation for their personal growth:\n\n${ctx.toPromptString()}',
    );
    return response.content;
  }

  // ── Search ────────────────────────────────────────────────────────

  /// Searches across all indexed knowledge.
  List<KnowledgeNode> search(
    String query, {
    KnowledgeDomain? domainFilter,
  }) =>
      _engine.search(snapshot, query, domainFilter: domainFilter);

  /// Finds nodes similar to a given node.
  List<KnowledgeNode> findSimilar(String nodeId) =>
      _engine.findSimilar(snapshot, nodeId);

  // ── Recommendations ───────────────────────────────────────────────

  /// Generates personalized recommendations.
  List<KnowledgeRecommendation> get recommendations =>
      _engine.generateRecommendations(snapshot);

  // ── Insights ──────────────────────────────────────────────────────

  /// Generates knowledge insights.
  List<KnowledgeInsight> get insights =>
      _engine.generateInsights(snapshot);

  // ── Analytics ─────────────────────────────────────────────────────

  /// Returns comprehensive analytics.
  Map<String, dynamic> get analytics => _engine.analyze(snapshot);

  // ── Platform Integration ──────────────────────────────────────────

  /// Seeds the knowledge graph from all platform engines.
  /// Called once during bootstrap (and periodically after).
  Future<void> seedFromPlatform() async {
    final nodes = <KnowledgeNode>[];
    final state = _userStateService.currentState;

    // Missions → goals domain
    for (final mission in state.missions) {
      nodes.add(KnowledgeNode(
        id: 'km-${mission.id}',
        domain: KnowledgeDomain.missions,
        label: mission.title,
        description: mission.description,
        proficiency: mission.isCompleted ? 1.0 : 0.3,
        importance: 0.7,
        sourceEngine: 'mission_engine',
        sourceId: mission.id,
        createdAt: mission.createdDate,
        updatedAt: mission.completedDate,
      ));
    }

    // Habits → habits domain
    for (final habit in state.habits) {
      nodes.add(KnowledgeNode(
        id: 'kh-${habit.id}',
        domain: KnowledgeDomain.habits,
        label: habit.title,
        description: habit.description,
        proficiency: habit.isActive ? 0.6 : 0.2,
        importance: habit.isActive ? 0.7 : 0.2,
        sourceEngine: 'habit',
        sourceId: habit.id,
        createdAt: habit.createdAt,
      ));
    }

    // Decisions → decisions domain
    for (final decision in state.decisionHistory) {
      nodes.add(KnowledgeNode(
        id: 'kd-${decision.id}',
        domain: KnowledgeDomain.decisions,
        label: decision.title,
        proficiency: decision.confidence,
        importance: decision.confidence,
        sourceEngine: 'decision',
        sourceId: decision.id,
        createdAt: decision.createdAt,
      ));
    }

    // Portfolio → portfolio domain
    final portfolio = state.portfolio;
    if (portfolio != null) {
      nodes.add(KnowledgeNode(
        id: 'kp-portfolio',
        domain: KnowledgeDomain.portfolio,
        label: 'Portfolio (${portfolio.careerReadiness})',
        importance: 0.8,
        proficiency: portfolio.portfolioScore,
        sourceEngine: 'portfolio',
        createdAt: DateTime.now(),
      ));
    }

    // Resume → resume domain
    final resume = state.resume;
    if (resume != null) {
      nodes.add(KnowledgeNode(
        id: 'kp-resume',
        domain: KnowledgeDomain.resume,
        label: 'Resume',
        importance: 0.8,
        sourceEngine: 'resume',
        createdAt: DateTime.now(),
      ));
    }

    // Knowledge DNA → skills domain
    final dna = state.knowledgeDNA;
    if (dna != null) {
      for (final skill in dna.strongAreas) {
        nodes.add(KnowledgeNode(
          id: 'kdna-strong-$skill',
          domain: KnowledgeDomain.skills,
          label: skill,
          proficiency: 0.8,
          importance: 0.9,
          tags: [skill.toLowerCase()],
          sourceEngine: 'knowledge_dna',
          createdAt: DateTime.now(),
        ));
      }
      for (final weak in dna.weakAreas) {
        nodes.add(KnowledgeNode(
          id: 'kdna-weak-$weak',
          domain: KnowledgeDomain.skills,
          label: weak,
          proficiency: 0.2,
          importance: 0.7,
          tags: [weak.toLowerCase()],
          sourceEngine: 'knowledge_dna',
          createdAt: DateTime.now(),
        ));
      }
    }

    if (nodes.isNotEmpty) {
      await indexNodes(nodes);
      await rebuildGraph();
    }
  }

  // ── Snapshot Management ───────────────────────────────────────────

  /// Creates a point-in-time knowledge snapshot.
  Future<void> takeSnapshot() async {
    await generateContext();
    final s = snapshot;
    await _saveSnapshot(s.copyWith(lastSnapshotAt: DateTime.now()));
  }

  // ── Diagnostics ───────────────────────────────────────────────────

  Map<String, dynamic> diagnostics() {
    final a = analytics;
    return {
      'nodeCount': a['nodeCount'],
      'edgeCount': a['edgeCount'],
      'domainCoverage': a['domainCoverage'],
      'insights': insights.length,
      'recommendations': recommendations.length,
    };
  }
}
