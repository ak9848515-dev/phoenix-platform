import 'package:flutter/foundation.dart';

import '../../../shared/infrastructure/ai_content/ingest_package.dart';
import '../../../shared/infrastructure/ai_content/metadata.dart';
import '../../../shared/infrastructure/cache/cache_service.dart';
import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../repository/career_repository_interface.dart';
import '../services/career_service.dart';
import 'career_snapshot.dart';

/// Single source of truth for career readiness data.
///
/// [CareerEngine] wraps [CareerService] and produces an immutable
/// [CareerSnapshot] consumed by CareerScreen, Dashboard, Progress,
/// and AI recommendations.
///
/// **Architecture:**
/// ```
/// CareerService → CareerEngine → CareerSnapshot → Widgets
/// ```
///
/// **Rules:**
/// - No AI logic
/// - No mission/learning logic
/// - Widgets read [CareerSnapshot] only
class CareerEngine extends ChangeNotifier {
  CareerEngine({
    required this.repository,
    required this._careerService,
    this._cacheService,
  });

  final CareerRepositoryInterface repository;
  final CareerService _careerService;
  final CacheService? _cacheService;
  static const String _cacheKey = 'career:snapshot';

  final PhoenixLogger _logger = PhoenixLogger.shared;

  CareerSnapshot? _cachedSnapshot;
  bool _isInitialized = false;

  /// AI-generated interview prep and coaching entries.
  final List<AIInterviewEntry> _aiInterviewEntries = [];
  final List<AICareerCoachingEntry> _aiCoachingEntries = [];

  // ── Accessors ─────────────────────────────────────────────────────

  /// The current career snapshot (may be cached).
  CareerSnapshot? get snapshot => _cachedSnapshot;

  /// Whether the engine has been initialized.
  bool get isInitialized => _isInitialized;

  /// All AI-generated interview preparation entries.
  List<AIInterviewEntry> get aiInterviewEntries =>
      List.unmodifiable(_aiInterviewEntries);

  /// All AI-generated career coaching entries.
  List<AICareerCoachingEntry> get aiCoachingEntries =>
      List.unmodifiable(_aiCoachingEntries);

  /// Whether any AI-generated career content exists.
  bool get hasAIGeneratedContent =>
      _aiInterviewEntries.isNotEmpty || _aiCoachingEntries.isNotEmpty;

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Initializes by loading cached data and building a fresh snapshot.
  Future<void> init() async {
    _cachedSnapshot = _cacheService?.get<CareerSnapshot>(_cacheKey);
    _cachedSnapshot ??= await repository.loadCachedSnapshot();
    final fresh = _buildSnapshot();
    if (_cachedSnapshot == null ||
        (fresh.careerScore - _cachedSnapshot!.careerScore).abs() > 0.01) {
      _cachedSnapshot = fresh;
      _cacheService?.cache(_cacheKey, fresh, CacheDomain.career);
      await repository.cacheSnapshot(fresh);
    }
    _isInitialized = true;
    _logger.info('CareerEngine initialized',
        category: LogCategory.engine, source: 'CareerEngine');
    notifyListeners();
  }

  /// Refreshes the snapshot from CareerService and persists it.
  Future<void> refresh() async {
    _cachedSnapshot = _buildSnapshot();
    _cacheService?.cache(_cacheKey, _cachedSnapshot!, CacheDomain.career);
    await repository.cacheSnapshot(_cachedSnapshot!);
    _logger.info('CareerEngine refreshed',
        category: LogCategory.engine, source: 'CareerEngine');
    notifyListeners();
  }

  /// Resets all cached career data.
  Future<void> reset() async {
    _cachedSnapshot = null;
    _isInitialized = false;
    _cacheService?.invalidate(CacheDomain.career);
    await repository.clear();
    _logger.info('CareerEngine reset',
        category: LogCategory.engine, source: 'CareerEngine');
    notifyListeners();
  }

  // ── Snapshot Builder ──────────────────────────────────────────────

  CareerSnapshot _buildSnapshot() {
    final profile = _careerService.buildProfile();

    return CareerSnapshot(
      careerScore: profile.careerScore,
      jobReadiness: profile.jobReadiness,
      strengths: profile.strengths,
      skillGaps: profile.skillGaps,
      nextGoal: profile.nextGoal,
      estimatedWeeks: profile.estimatedWeeks,
      portfolioProgress: profile.portfolioProgress,
      resumeProgress: profile.resumeProgress,
      interviewReadiness: profile.interviewReadiness,
      applicationCount: 0,
      offerCount: 0,
      careerTimeline: [
        if (profile.jobReadiness != 'Starting Out')
          'Career readiness: ${profile.jobReadiness}',
      ],
      lastUpdated: DateTime.now(),
    );
  }

  // ── AI Ingestion ──────────────────────────────────────────────────

  /// Ingests AI-generated career content (interview prep or coaching).
  ///
  /// Supports package types 'interview' and 'career_coaching'.
  void ingest(IngestPackage pkg) {
    switch (pkg.type) {
      case 'interview':
        _ingestInterview(pkg);
      case 'career_coaching':
        _ingestCoaching(pkg);
      default:
        _logger.warning('CareerEngine: unknown ingest type ${pkg.type}',
            category: LogCategory.engine, source: 'CareerEngine');
    }
  }

  /// Merges AI content with an existing entry by content hash.
  void merge(String id, IngestPackage pkg) {
    if (pkg.type == 'interview') {
      final idx = _aiInterviewEntries.indexWhere((e) => e.id == id);
      if (idx != -1) {
        _aiInterviewEntries[idx] = AIInterviewEntry(
          id: id,
          data: pkg.content,
          metadata: pkg.metadata,
        );
      }
    } else if (pkg.type == 'career_coaching') {
      final idx = _aiCoachingEntries.indexWhere((e) => e.id == id);
      if (idx != -1) {
        _aiCoachingEntries[idx] = AICareerCoachingEntry(
          id: id,
          data: pkg.content,
          metadata: pkg.metadata,
        );
      }
    }
  }

  /// Replaces AI content entirely by ID.
  void replace(String id, IngestPackage pkg) {
    merge(id, pkg);
  }

  /// Removes all AI-generated career content.
  void clearGenerated() {
    _aiInterviewEntries.clear();
    _aiCoachingEntries.clear();
    _logger.info('CareerEngine: cleared all AI-generated content',
        category: LogCategory.engine, source: 'CareerEngine');
  }

  /// Rolls back AI-generated content by content hash.
  void rollback(String contentHash) {
    _aiInterviewEntries.removeWhere((e) => e.metadata.contentHash == contentHash);
    _aiCoachingEntries.removeWhere((e) => e.metadata.contentHash == contentHash);
    _logger.info('CareerEngine: rolled back $contentHash',
        category: LogCategory.engine, source: 'CareerEngine');
  }

  /// Stub for future schema migration support.
  void migration(int fromVersion, int toVersion) {
    _logger.info('CareerEngine: migration $fromVersion→$toVersion (no-op)',
        category: LogCategory.engine, source: 'CareerEngine');
  }

  /// Validates an ingest package fits the career schema.
  /// Returns null if valid, or an error message if invalid.
  String? validate(IngestPackage pkg) {
    if (pkg.type == 'interview') {
      final questions = pkg.content['questions'] as List<dynamic>?;
      if (questions == null || questions.isEmpty) {
        return 'Interview must have at least one question';
      }
    } else if (pkg.type == 'career_coaching') {
      final advice = pkg.content['advice'] as String?;
      if (advice == null || advice.isEmpty) return 'Coaching advice is required';
    } else {
      return 'Expected type "interview" or "career_coaching", got "${pkg.type}"';
    }
    return null;
  }

  void _ingestInterview(IngestPackage pkg) {
    if (_aiInterviewEntries.any((e) => e.metadata.contentHash == pkg.contentHash)) {
      _logger.info('CareerEngine: duplicate interview ingest skipped',
          category: LogCategory.engine, source: 'CareerEngine');
      return;
    }
    _aiInterviewEntries.add(AIInterviewEntry(
      id: pkg.content['id'] as String? ?? '',
      data: pkg.content,
      metadata: pkg.metadata,
    ));
    _logger.info('CareerEngine: ingested interview prep',
        category: LogCategory.engine, source: 'CareerEngine');
  }

  void _ingestCoaching(IngestPackage pkg) {
    if (_aiCoachingEntries.any((e) => e.metadata.contentHash == pkg.contentHash)) {
      _logger.info('CareerEngine: duplicate coaching ingest skipped',
          category: LogCategory.engine, source: 'CareerEngine');
      return;
    }
    _aiCoachingEntries.add(AICareerCoachingEntry(
      id: pkg.content['id'] as String? ?? '',
      data: pkg.content,
      metadata: pkg.metadata,
    ));
    _logger.info('CareerEngine: ingested career coaching',
        category: LogCategory.engine, source: 'CareerEngine');
  }
}

/// Internal entry for AI-generated interview preparation.
class AIInterviewEntry {
  const AIInterviewEntry({
    required this.id,
    required this.data,
    required this.metadata,
  });

  final String id;
  final Map<String, dynamic> data;
  final AIContentMetadata metadata;
}

/// Internal entry for AI-generated career coaching.
class AICareerCoachingEntry {
  const AICareerCoachingEntry({
    required this.id,
    required this.data,
    required this.metadata,
  });

  final String id;
  final Map<String, dynamic> data;
  final AIContentMetadata metadata;
}
