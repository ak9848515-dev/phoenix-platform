import 'package:flutter/foundation.dart';

import '../../../shared/infrastructure/ai_content/ingest_package.dart';
import '../../../shared/infrastructure/ai_content/metadata.dart';
import '../../../shared/infrastructure/cache/cache_service.dart';
import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../models/knowledge_snapshot.dart';
import '../services/knowledge_service.dart';

/// Knowledge Engine — the single source of truth for knowledge state.
///
/// Wraps [KnowledgeService] to produce an immutable [KnowledgeSnapshot]
/// consumed by KnowledgeDNAScreen, Progress, AI Mentor, and Dashboard.
///
/// **Architecture:**
/// ```
/// PersonalKnowledgeEngine → KnowledgeService → KnowledgeEngine → KnowledgeSnapshot → Widgets
/// ```
///
/// **Rules:**
/// - No duplication of logic from [KnowledgeService]
/// - Widgets read [snapshot] only
class KnowledgeEngine extends ChangeNotifier {
  KnowledgeEngine({
    required this._knowledgeService,
    this._cacheService,
  });

  final KnowledgeService _knowledgeService;
  final CacheService? _cacheService;
  static const String _cacheKey = 'knowledge:snapshot';
  final PhoenixLogger _logger = PhoenixLogger.shared;

  bool _isInitialized = false;

  /// AI-generated lessons kept for separate tracking.
  final List<AILessonEntry> _aiLessons = [];
  final List<AIRevisionEntry> _aiRevisions = [];

  // ── Accessors ─────────────────────────────────────────────────────

  /// The current knowledge snapshot from [KnowledgeService].
  KnowledgeSnapshot get snapshot => _knowledgeService.snapshot;

  /// Analytics from the knowledge engine.
  Map<String, dynamic> get analytics => _knowledgeService.analytics;

  /// Whether the engine has been initialized.
  bool get isInitialized => _isInitialized;

  /// Insights generated from the knowledge state.
  List<dynamic> get insights => _knowledgeService.insights;

  /// Recommendations generated from the knowledge state.
  List<dynamic> get recommendations => _knowledgeService.recommendations;

  /// All AI-generated lessons currently stored.
  List<AILessonEntry> get aiLessons => List.unmodifiable(_aiLessons);

  /// All AI-generated revision materials currently stored.
  List<AIRevisionEntry> get aiRevisions => List.unmodifiable(_aiRevisions);

  /// Whether any AI-generated content exists.
  bool get hasAIGeneratedContent => _aiLessons.isNotEmpty || _aiRevisions.isNotEmpty;

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Initializes the engine. [KnowledgeService] is already initialized
  /// during bootstrap, so this simply marks readiness.
  Future<void> init() async {
    _isInitialized = true;
    _cacheService?.cache(_cacheKey, snapshot, CacheDomain.knowledge);
    _logger.info('KnowledgeEngine initialized',
        category: LogCategory.engine, source: 'KnowledgeEngine');
    notifyListeners();
  }

  /// Triggers a full rebuild of the knowledge graph.
  Future<void> refresh() async {
    await _knowledgeService.rebuildGraph();
    _cacheService?.cache(_cacheKey, snapshot, CacheDomain.knowledge);
    _logger.info('KnowledgeEngine refreshed',
        category: LogCategory.engine, source: 'KnowledgeEngine');
    notifyListeners();
  }

  /// Seeds knowledge from all platform engines.
  Future<void> seedFromPlatform() async {
    await _knowledgeService.seedFromPlatform();
    _logger.info('KnowledgeEngine seeded from platform',
        category: LogCategory.engine, source: 'KnowledgeEngine');
    notifyListeners();
  }

  // ── Knowledge Operations ─────────────────────────────────────────

  /// Builds the current knowledge context.
  dynamic buildContext() => _knowledgeService.buildContext();

  /// Searches knowledge nodes by query.
  List<dynamic> search(String query, {dynamic domainFilter}) =>
      _knowledgeService.search(query, domainFilter: domainFilter);

  // ── AI Ingestion ──────────────────────────────────────────────────

  /// Ingests AI-generated knowledge content (lessons or revision).
  ///
  /// Supports package types 'lesson' and 'revision'.
  void ingest(IngestPackage pkg) {
    switch (pkg.type) {
      case 'lesson':
        _ingestLesson(pkg);
      case 'revision':
        _ingestRevision(pkg);
      default:
        _logger.warning('KnowledgeEngine: unknown ingest type ${pkg.type}',
            category: LogCategory.engine, source: 'KnowledgeEngine');
    }
  }

  /// Merges AI content with an existing entry by content hash.
  void merge(String id, IngestPackage pkg) {
    if (pkg.type == 'lesson') {
      final idx = _aiLessons.indexWhere((e) => e.id == id);
      if (idx != -1) {
        final data = pkg.content;
        _aiLessons[idx] = AILessonEntry(
          id: id,
          title: data['title'] as String? ?? _aiLessons[idx].title,
          summary: data['summary'] as String? ?? _aiLessons[idx].summary,
          metadata: pkg.metadata,
        );
      }
    } else if (pkg.type == 'revision') {
      final idx = _aiRevisions.indexWhere((e) => e.id == id);
      if (idx != -1) {
        final data = pkg.content;
        _aiRevisions[idx] = AIRevisionEntry(
          id: id,
          keyPoints: (data['keyPoints'] as List<dynamic>?)
                  ?.cast<String>() ??
              _aiRevisions[idx].keyPoints,
          flashCardCount: _aiRevisions[idx].flashCardCount,
          metadata: pkg.metadata,
        );
      }
    }
  }

  /// Replaces AI content by ID — removes old entry first, then ingests.
  void replace(String id, IngestPackage pkg) {
    _aiLessons.removeWhere((e) => e.id == id);
    _aiRevisions.removeWhere((e) => e.id == id);
    ingest(pkg);
  }

  /// Removes all AI-generated knowledge content.
  void clearGenerated() {
    _aiLessons.clear();
    _aiRevisions.clear();
    _logger.info('KnowledgeEngine: cleared all AI-generated content',
        category: LogCategory.engine, source: 'KnowledgeEngine');
  }

  /// Rolls back AI-generated content by content hash.
  void rollback(String contentHash) {
    _aiLessons.removeWhere((e) => e.metadata.contentHash == contentHash);
    _aiRevisions.removeWhere((e) => e.metadata.contentHash == contentHash);
    _logger.info('KnowledgeEngine: rolled back $contentHash',
        category: LogCategory.engine, source: 'KnowledgeEngine');
  }

  /// Stub for future schema migration support.
  void migration(int fromVersion, int toVersion) {
    _logger.info('KnowledgeEngine: migration $fromVersion→$toVersion (no-op)',
        category: LogCategory.engine, source: 'KnowledgeEngine');
  }

  /// Validates an ingest package fits the knowledge schema.
  /// Returns null if valid, or an error message if invalid.
  String? validate(IngestPackage pkg) {
    if (pkg.type == 'lesson') {
      final title = pkg.content['title'] as String?;
      if (title == null || title.isEmpty) return 'Lesson title is required';
    } else if (pkg.type == 'revision') {
      // Revision can have only key points or only flashcards
      final keyPoints = pkg.content['keyPoints'] as List<dynamic>?;
      final flashcards = pkg.content['flashCards'] as List<dynamic>?;
      if ((keyPoints == null || keyPoints.isEmpty) &&
          (flashcards == null || flashcards.isEmpty)) {
        return 'Revision must have key points or flash cards';
      }
    } else {
      return 'Expected type "lesson" or "revision", got "${pkg.type}"';
    }
    return null;
  }

  void _ingestLesson(IngestPackage pkg) {
    if (_aiLessons.any((e) => e.metadata.contentHash == pkg.contentHash)) {
      _logger.info('KnowledgeEngine: duplicate lesson skipped',
          category: LogCategory.engine, source: 'KnowledgeEngine');
      return;
    }

    final data = pkg.content;
    _aiLessons.add(AILessonEntry(
      id: data['id'] as String? ?? '',
      title: data['title'] as String? ?? '',
      summary: data['summary'] as String? ?? '',
      metadata: pkg.metadata,
    ));
    _logger.info('KnowledgeEngine: ingested lesson',
        category: LogCategory.engine, source: 'KnowledgeEngine');
  }

  void _ingestRevision(IngestPackage pkg) {
    if (_aiRevisions.any((e) => e.metadata.contentHash == pkg.contentHash)) {
      _logger.info('KnowledgeEngine: duplicate revision skipped',
          category: LogCategory.engine, source: 'KnowledgeEngine');
      return;
    }

    final data = pkg.content;
    final keyPoints = (data['keyPoints'] as List<dynamic>?)?.cast<String>() ?? [];
    final flashcards = (data['flashCards'] as List<dynamic>?) ?? [];

    _aiRevisions.add(AIRevisionEntry(
      id: data['id'] as String? ?? '',
      keyPoints: keyPoints,
      flashCardCount: flashcards.length,
      metadata: pkg.metadata,
    ));
    _logger.info('KnowledgeEngine: ingested revision',
        category: LogCategory.engine, source: 'KnowledgeEngine');
  }
}

/// Internal entry for an AI-generated lesson.
class AILessonEntry {
  const AILessonEntry({
    required this.id,
    required this.title,
    required this.summary,
    required this.metadata,
  });

  final String id;
  final String title;
  final String summary;
  final AIContentMetadata metadata;
}

/// Internal entry for AI-generated revision materials.
class AIRevisionEntry {
  const AIRevisionEntry({
    required this.id,
    required this.keyPoints,
    required this.flashCardCount,
    required this.metadata,
  });

  final String id;
  final List<String> keyPoints;
  final int flashCardCount;
  final AIContentMetadata metadata;
}
