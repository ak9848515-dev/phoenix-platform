import 'package:flutter/foundation.dart';

import '../../../shared/infrastructure/ai_content/ingest_package.dart';
import '../../../shared/infrastructure/cache/cache_service.dart';
import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../identity/engine/identity_engine.dart';
import '../../growth_index/engine/growth_index_engine.dart';
import '../../mission_intelligence/engine/mission_intelligence_engine.dart';
import '../models/memory_category.dart';
import '../models/memory_entry.dart';
import '../models/memory_graph.dart';
import '../models/memory_importance.dart';
import '../models/memory_index.dart';
import '../models/memory_relationship.dart';
import '../models/memory_search_result.dart';
import '../models/memory_snapshot.dart';
import '../repository/memory_repository_interface.dart';

/// The Phoenix Long-Term Memory Engine.
///
/// Stores and retrieves durable user knowledge: important facts, decisions,
/// achievements, preferences, and learning progress.
///
/// **NOT** a chat history. This is structured, categorised, and searchable
/// long-term memory.
///
/// **Architecture Rules:**
/// - No LLM, no embeddings, no vector database
/// - No cloud sync
/// - Deterministic keyword/tag/category search only
/// - Offline-first with SharedPreferences persistence
class MemoryEngine extends ChangeNotifier {
  MemoryEngine({
    required this.repository,
    required this._identityEngine,
    required this._growthEngine,
    required this._missionEngine,
    this._cacheService,
  });

  final MemoryRepositoryInterface repository;
  final IdentityEngine _identityEngine;
  final GrowthIndexEngine _growthEngine;
  final MissionIntelligenceEngine _missionEngine;
  final CacheService? _cacheService;
  static const String _cacheKey = 'memory:snapshot';

  final PhoenixLogger _logger = PhoenixLogger.shared;
  List<MemoryEntry> _entries = [];
  List<MemoryRelationship> _relationships = [];
  MemoryIndex _index = const MemoryIndex();
  MemorySnapshot? _cachedSnapshot;
  bool _isInitialized = false;
  bool _isBuilding = false;

  // ── Accessors ─────────────────────────────────────────────────────

  MemorySnapshot? get snapshot => _cachedSnapshot;
  List<MemoryEntry> get entries => List.unmodifiable(_entries);
  List<MemoryRelationship> get relationships =>
      List.unmodifiable(_relationships);
  MemoryGraph get graph => MemoryGraph(
        entries: {for (final e in _entries) e.id: e},
        relationships: _relationships,
      );
  MemoryIndex get index => _index;
  bool get isInitialized => _isInitialized;

  // ── Lifecycle ─────────────────────────────────────────────────────

  Future<void> init() async {
    _entries = await repository.loadAllEntries();
    _relationships = await repository.loadAllRelationships();
    _index = await repository.loadIndex();
    _cachedSnapshot = _cacheService?.get<MemorySnapshot>(_cacheKey);
    _cachedSnapshot ??= await repository.loadCachedSnapshot();

    if (_cachedSnapshot == null) {
      _cachedSnapshot = _buildSnapshot();
      _cacheService?.cache(_cacheKey, _cachedSnapshot!, CacheDomain.memory);
      await repository.cacheSnapshot(_cachedSnapshot!);
    }
    _isInitialized = true;

    _identityEngine.addListener(_onEngineChanged);
    _growthEngine.addListener(_onEngineChanged);
    _missionEngine.addListener(_onEngineChanged);

    _logger.info('MemoryEngine initialized with ${_entries.length} entries',
        category: LogCategory.engine, source: 'MemoryEngine');
    notifyListeners();
  }

  Future<void> rebuild() async {
    _cachedSnapshot = _buildSnapshot();
    if (_cachedSnapshot != null) {
      _cacheService?.cache(_cacheKey, _cachedSnapshot!, CacheDomain.memory);
      await repository.cacheSnapshot(_cachedSnapshot!);
    }
    _logger.info('MemoryEngine rebuilt with ${_entries.length} entries',
        category: LogCategory.engine, source: 'MemoryEngine');
    notifyListeners();
  }

  // ── Memory CRUD ───────────────────────────────────────────────────

  /// Adds a new memory entry.
  Future<void> addEntry(MemoryEntry entry) async {
    _entries.add(entry);
    _rebuildIndex();
    await repository.saveAllEntries(_entries);
    await repository.saveIndex(_index);
    _logger.info('Memory entry added: ${entry.title}',
        category: LogCategory.engine, source: 'MemoryEngine');
    await rebuild();
  }

  /// Updates an existing memory entry.
  Future<void> updateEntry(String id, MemoryEntry updated) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index == -1) return;
    _entries[index] = updated.copyWith(updated: DateTime.now());
    _rebuildIndex();
    await repository.saveAllEntries(_entries);
    await repository.saveIndex(_index);
    await rebuild();
  }

  /// Removes a memory entry by ID.
  Future<void> removeEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    _relationships.removeWhere((r) => r.sourceId == id || r.targetId == id);
    _rebuildIndex();
    await repository.saveAllEntries(_entries);
    await repository.saveAllRelationships(_relationships);
    await repository.saveIndex(_index);
    _logger.info('Memory entry removed: $id',
        category: LogCategory.engine, source: 'MemoryEngine');
    await rebuild();
  }

  /// Archives a memory entry (hides from normal view).
  Future<void> archiveEntry(String id) async {
    final idx = _entries.indexWhere((e) => e.id == id);
    if (idx == -1) {
      _logger.warning('Memory archive failed: entry $id not found',
          category: LogCategory.engine, source: 'MemoryEngine');
      return;
    }
    _entries[idx] = _entries[idx].copyWith(archived: true, updated: DateTime.now());
    _rebuildIndex();
    await repository.saveAllEntries(_entries);
    await repository.saveIndex(_index);
    _logger.info('Memory entry archived: $id',
        category: LogCategory.engine, source: 'MemoryEngine');
    await rebuild();
  }

  /// Toggles the favorite status of a memory.
  Future<void> toggleFavorite(String id) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index == -1) return;
    _entries[index] = _entries[index].copyWith(
      favorite: !_entries[index].favorite,
      updated: DateTime.now(),
    );
    await repository.saveAllEntries(_entries);
    await rebuild();
  }

  // ── AI Ingestion ──────────────────────────────────────────────────

  /// Ingests AI-generated content as a memory entry.
  ///
  /// Supports package types: 'reflection', 'goal', 'history'.
  /// Content is stored as a [MemoryEntry] tagged with the AI metadata.
  Future<void> ingest(IngestPackage pkg) async {
    if (pkg.type == 'reflection' ||
        pkg.type == 'goal' ||
        pkg.type == 'history') {
      // Duplicate detection by content hash stored as a tag
      if (_entries.any((e) =>
          e.tags.contains('ai-hash:${pkg.contentHash}'))) {
        _logger.info('MemoryEngine: duplicate ingest skipped',
            category: LogCategory.engine, source: 'MemoryEngine');
        return;
      }

      final data = pkg.content;
      final entry = MemoryEntry(
        id: 'ai-${pkg.type}-${pkg.contentHash.substring(0, 12)}',
        title: data['title'] as String? ?? 'AI-generated ${pkg.type}',
        content: data['content'] as String? ?? data.toString(),
        category: _mapPackageTypeToCategory(pkg.type),
        tags: [
          'ai-generated',
          'source:${pkg.metadata.provider}',
          'ai-hash:${pkg.contentHash}',
          pkg.type,
        ],
        importance: MemoryImportance.medium,
        source: 'ai:${pkg.metadata.provider}',
        confidence: pkg.metadata.confidenceScore,
        created: pkg.metadata.generatedAt,
        updated: DateTime.now(),
      );

      await addEntry(entry);
      _logger.info('MemoryEngine: ingested ${pkg.type}',
          category: LogCategory.engine, source: 'MemoryEngine');
    } else {
      _logger.warning('MemoryEngine: unknown ingest type ${pkg.type}',
          category: LogCategory.engine, source: 'MemoryEngine');
    }
  }

  /// Merges AI content with an existing memory entry by ID.
  Future<void> merge(String id, IngestPackage pkg) async {
    final existing = getEntry(id);
    if (existing == null) {
      await ingest(pkg);
      return;
    }
    final data = pkg.content;
    final updated = existing.copyWith(
      title: data['title'] as String? ?? existing.title,
      content: data['content'] as String? ?? existing.content,
      tags: [
        ...existing.tags,
        'source:${pkg.metadata.provider}',
        'ai-hash:${pkg.contentHash}',
      ],
      updated: DateTime.now(),
    );
    await updateEntry(id, updated);
  }

  /// Replaces AI content by content hash — removes matching entry first.
  Future<void> replace(String id, IngestPackage pkg) async {
    await removeEntry(id);
    await ingest(pkg);
  }

  /// Removes all AI-generated memory entries.
  Future<void> clearGenerated() async {
    final aiIds = _entries
        .where((e) => e.tags.contains('ai-generated'))
        .map((e) => e.id)
        .toList();
    for (final id in aiIds) {
      await removeEntry(id);
    }
    _logger.info('MemoryEngine: cleared all AI-generated entries',
        category: LogCategory.engine, source: 'MemoryEngine');
  }

  /// Rolls back AI-generated content by content hash.
  Future<void> rollback(String contentHash) async {
    final ids = _entries
        .where((e) => e.tags.contains('ai-hash:$contentHash'))
        .map((e) => e.id)
        .toList();
    for (final id in ids) {
      await removeEntry(id);
    }
    _logger.info('MemoryEngine: rolled back $contentHash',
        category: LogCategory.engine, source: 'MemoryEngine');
  }

  /// Stub for future schema migration support.
  /// Engines with persistent AI content will implement migration logic here.
  void migration(int fromVersion, int toVersion) {
    _logger.info('MemoryEngine: migration from $fromVersion to $toVersion (no-op)',
        category: LogCategory.engine, source: 'MemoryEngine');
  }

  /// Validates an ingest package fits the memory schema.
  /// Returns null if valid, or an error message if invalid.
  String? validate(IngestPackage pkg) {
    if (!['reflection', 'goal', 'history'].contains(pkg.type)) {
      return 'Expected type "reflection", "goal", or "history", got "${pkg.type}"';
    }
    final title = pkg.content['title'] as String?;
    if (title == null || title.isEmpty) return 'Title is required';
    return null;
  }

  MemoryCategory _mapPackageTypeToCategory(String type) {
    switch (type) {
      case 'reflection':
        return MemoryCategory.goals;
      case 'goal':
        return MemoryCategory.goals;
      case 'history':
        return MemoryCategory.milestones;
      default:
        return MemoryCategory.custom;
    }
  }

  /// Clears all memories.
  Future<void> clear() async {
    _entries = [];
    _relationships = [];
    _index = const MemoryIndex();
    _cachedSnapshot = null;
    _isInitialized = false;
    _cacheService?.invalidate(CacheDomain.memory);
    await repository.clear();
    _logger.info('MemoryEngine cleared',
        category: LogCategory.engine, source: 'MemoryEngine');
    notifyListeners();
  }

  // ── Relationships ─────────────────────────────────────────────────

  /// Adds a relationship between two memories.
  Future<void> addRelationship(MemoryRelationship relationship) async {
    _relationships.add(relationship);
    await repository.saveAllRelationships(_relationships);
    await rebuild();
  }

  /// Removes a relationship.
  Future<void> removeRelationship(
      String sourceId, String targetId, String type) async {
    _relationships.removeWhere(
        (r) => r.sourceId == sourceId && r.targetId == targetId && r.type == type);
    await repository.saveAllRelationships(_relationships);
    await rebuild();
  }

  // ── Search ────────────────────────────────────────────────────────

  /// Searches memories by keyword in title and content.
  List<MemorySearchResult> searchKeywords(String query) {
    final lower = query.toLowerCase();
    final results = <MemorySearchResult>[];

    for (final entry in _entries) {
      if (entry.archived) continue;
      double relevance = 0.0;
      String context = '';

      // Title match (highest relevance)
      if (entry.title.toLowerCase().contains(lower)) {
        relevance += 0.5;
        context = entry.title;
      }

      // Content match
      if (entry.content.toLowerCase().contains(lower)) {
        relevance += 0.3;
        if (context.isEmpty) context = entry.content;
      }

      // Tag match
      if (entry.tags.any((t) => t.toLowerCase().contains(lower))) {
        relevance += 0.2;
      }

      if (relevance > 0) {
        results.add(MemorySearchResult(
          entry: entry,
          relevance: relevance.clamp(0.0, 1.0),
          matchContext: context,
        ));
      }
    }

    results.sort((a, b) => b.relevance.compareTo(a.relevance));
    return results;
  }

  /// Returns memories in a specific category.
  List<MemoryEntry> searchCategory(MemoryCategory category) =>
      _entries.where((e) => e.category == category && !e.archived).toList();

  /// Returns memories with a specific tag.
  List<MemoryEntry> searchTag(String tag) =>
      _entries.where((e) => e.tags.contains(tag) && !e.archived).toList();

  /// Returns related memories for a given entry.
  List<MemoryEntry> relatedMemories(String id) {
    final graph = this.graph;
    return graph.relatedEntries(id).where((e) => !e.archived).toList();
  }

  /// Returns the most recent memories.
  List<MemoryEntry> recentMemories({int limit = 10}) {
    final sorted = List<MemoryEntry>.from(_entries.where((e) => !e.archived));
    sorted.sort((a, b) {
      final aTime = a.updated ?? a.created ?? DateTime(2000);
      final bTime = b.updated ?? b.created ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });
    return sorted.take(limit).toList();
  }

  /// Returns memories sorted by importance.
  List<MemoryEntry> importantMemories({int limit = 10}) {
    final sorted = List<MemoryEntry>.from(_entries.where((e) => !e.archived));
    sorted.sort((a, b) => b.importance.weight.compareTo(a.importance.weight));
    return sorted.take(limit).toList();
  }

  /// Returns favorited memories.
  List<MemoryEntry> favoriteMemories() =>
      _entries.where((e) => e.favorite && !e.archived).toList();

  /// Returns a single memory by ID.
  MemoryEntry? getEntry(String id) {
    final index = _entries.indexWhere((e) => e.id == id);
    return index >= 0 ? _entries[index] : null;
  }

  // ── Snapshot Builder ──────────────────────────────────────────────

  MemorySnapshot _buildSnapshot() {
    final recent = recentMemories();
    final important = importantMemories();
    final achievements =
        _entries.where((e) => e.category == MemoryCategory.achievements && !e.archived).toList();
    final goals =
        _entries.where((e) => e.category == MemoryCategory.goals && !e.archived).toList();
    final learning =
        _entries.where((e) => e.category == MemoryCategory.learning && !e.archived).toList();

    return MemorySnapshot(
      recentMemories: recent,
      importantMemories: important,
      activeGoals: goals,
      recentAchievements: achievements,
      pendingKnowledge: learning,
      totalMemories: _entries.length,
      totalRelationships: _relationships.length,
      lastUpdated: DateTime.now(),
      graph: graph,
    );
  }

  // ── Indexing ──────────────────────────────────────────────────────

  void _rebuildIndex() {
    final keywordIdx = <String, List<String>>{};
    final tagIdx = <String, List<String>>{};
    final catIdx = <String, List<String>>{};

    for (final entry in _entries) {
      if (entry.archived) continue;

      // Index title words
      for (final word in entry.title.toLowerCase().split(RegExp(r'\s+'))) {
        if (word.length >= 2) {
          keywordIdx.putIfAbsent(word, () => []).add(entry.id);
        }
      }

      // Index content words
      for (final word in entry.content.toLowerCase().split(RegExp(r'\s+'))) {
        if (word.length >= 3) {
          keywordIdx.putIfAbsent(word, () => []).add(entry.id);
        }
      }

      // Index tags
      for (final tag in entry.tags) {
        tagIdx.putIfAbsent(tag.toLowerCase(), () => []).add(entry.id);
      }

      // Index category
      catIdx.putIfAbsent(entry.category.name.toLowerCase(), () => []).add(entry.id);
    }

    _index = MemoryIndex(
      keywordIndex: keywordIdx,
      tagIndex: tagIdx,
      categoryIndex: catIdx,
    );
  }

  // ── AI Context (Prioritized) ─────────────────────────────────────

  /// Returns a prioritized context map for AI consumption.
  ///
  /// Prioritizes:
  /// - Recent activity (last 3 entries)
  /// - Current goals (activeGoals from snapshot)
  /// - Current learning (pendingKnowledge)
  /// - Current projects (tagged 'project')
  /// - Career aspirations (tagged 'career')
  /// - Interview history (tagged 'interview')
  /// - Resume weaknesses (tagged 'weakness')
  /// - Portfolio gaps (tagged 'gap')
  ///
  /// Excludes:
  /// - Duplicate memories (same content hash tag)
  /// - Archived memories
  /// - Outdated memories (>30 days without update)
  /// - Low-value memories (importance: low)
  Map<String, dynamic> prioritizedAiContext() {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final seenHashes = <String>{};

    // Collect relevant entries, deduplicating by tags that look like hashes
    List<MemoryEntry> collectByTag(String tag) {
      return _entries
          .where((e) =>
              !e.archived &&
              e.tags.any((t) => t.contains(tag)) &&
              (e.updated ?? e.created ?? DateTime(2000)).isAfter(cutoff) &&
              e.importance != MemoryImportance.low &&
              seenHashes.add(e.id))
          .toList();
    }

    final recent = recentMemories(limit: 3);
    for (final e in recent) {
      seenHashes.add(e.id);
    }

    final goals = collectByTag('goal');
    final learning = collectByTag('learning');
    final projects = collectByTag('project');
    final career = collectByTag('career');
    final interviews = collectByTag('interview');
    final weaknesses = collectByTag('weakness');
    final gaps = collectByTag('gap');

    return {
      'recentActivity': recent
          .map((e) => '${e.title}: ${e.content.length > 100 ? "${e.content.substring(0, 100)}..." : e.content}')
          .join('\n'),
      'activeGoals': goals.map((e) => e.title).join(', '),
      'learningInProgress': learning.map((e) => e.title).join(', '),
      'currentProjects': projects.map((e) => e.title).join(', '),
      'careerAspirations': career.map((e) => e.title).join(', '),
      'interviewHistory': interviews.map((e) => '${e.title}: ${e.content.length > 80 ? "${e.content.substring(0, 80)}..." : e.content}').join('\n'),
      'resumeWeaknesses': weaknesses.map((e) => e.title).join(', '),
      'portfolioGaps': gaps.map((e) => e.title).join(', '),
    };
  }

  /// Returns a summary of memory statistics for diagnostics.
  Map<String, dynamic> diagnosticsSummary() {
    return {
      'totalEntries': _entries.length,
      'totalRelationships': _relationships.length,
      'archivedCount': _entries.where((e) => e.archived).length,
      'favoriteCount': _entries.where((e) => e.favorite).length,
      'categoryCounts': {
        for (final cat in MemoryCategory.values)
          cat.name: _entries.where((e) => e.category == cat && !e.archived).length,
      },
      'recentCount': recentMemories().length,
      'importantCount': importantMemories().length,
      'isInitialized': _isInitialized,
    };
  }

  // ── Observer ──────────────────────────────────────────────────────

  Future<void> _onEngineChanged() async {
    if (!_isInitialized || _isBuilding) return;
    _isBuilding = true;
    _logger.debug('MemoryEngine rebuilding from observer event',
        category: LogCategory.observer, source: 'MemoryEngine');
    await rebuild();
    _isBuilding = false;
  }

  @override
  void dispose() {
    _identityEngine.removeListener(_onEngineChanged);
    _growthEngine.removeListener(_onEngineChanged);
    _missionEngine.removeListener(_onEngineChanged);
    super.dispose();
  }
}
