import 'package:flutter/foundation.dart';

import '../../../shared/infrastructure/ai_content/ingest_package.dart';
import '../../../shared/infrastructure/ai_content/metadata.dart';
import '../../../shared/infrastructure/cache/cache_service.dart';
import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../repository/portfolio_repository_interface.dart';
import '../services/portfolio_service.dart';
import 'portfolio_snapshot.dart';

/// Single source of truth for portfolio data.
///
/// [PortfolioEngine] wraps [PortfolioService] and produces an immutable
/// [PortfolioSnapshot] consumed by PortfolioScreen, Dashboard, Progress,
/// and AI recommendations.
///
/// **Architecture:**
/// ```
/// PortfolioService → PortfolioEngine → PortfolioSnapshot → Widgets
/// ```
///
/// **Rules:**
/// - No AI logic
/// - No business logic duplication
/// - Widgets read [PortfolioSnapshot] only
class PortfolioEngine extends ChangeNotifier {
  PortfolioEngine({
    required this.repository,
    required this._portfolioService,
    this._cacheService,
  });

  final PortfolioRepositoryInterface repository;
  final PortfolioService _portfolioService;
  final CacheService? _cacheService;
  static const String _cacheKey = 'portfolio:snapshot';

  final PhoenixLogger _logger = PhoenixLogger.shared;

  PortfolioSnapshot? _cachedSnapshot;
  bool _isInitialized = false;

  /// AI-generated projects kept separate from user-created ones.
  final List<AIProjectEntry> _aiProjects = [];

  // ── Accessors ─────────────────────────────────────────────────────

  /// The current portfolio snapshot (may be cached).
  PortfolioSnapshot? get snapshot => _cachedSnapshot;

  /// Whether the engine has been initialized.
  bool get isInitialized => _isInitialized;

  /// All AI-generated projects currently stored.
  List<AIProjectEntry> get aiProjects => List.unmodifiable(_aiProjects);

  /// Whether any AI-generated projects exist.
  bool get hasAIGeneratedProjects => _aiProjects.isNotEmpty;

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Initializes by loading cached data and building a fresh snapshot.
  Future<void> init() async {
    _cachedSnapshot = _cacheService?.get<PortfolioSnapshot>(_cacheKey);
    _cachedSnapshot ??= await repository.loadCachedSnapshot();
    final fresh = _buildSnapshot();
    if (_cachedSnapshot == null ||
        (fresh.portfolioScore - _cachedSnapshot!.portfolioScore).abs() >
            0.01) {
      _cachedSnapshot = fresh;
      _cacheService?.cache(_cacheKey, fresh, CacheDomain.portfolio);
      await repository.cacheSnapshot(fresh);
    }
    _isInitialized = true;
    _logger.info('PortfolioEngine initialized',
        category: LogCategory.engine, source: 'PortfolioEngine');
    notifyListeners();
  }

  /// Refreshes the snapshot from PortfolioService and persists it.
  Future<void> refresh() async {
    _cachedSnapshot = _buildSnapshot();
    _cacheService?.cache(_cacheKey, _cachedSnapshot!, CacheDomain.portfolio);
    await repository.cacheSnapshot(_cachedSnapshot!);
    _logger.info('PortfolioEngine refreshed',
        category: LogCategory.engine, source: 'PortfolioEngine');
    notifyListeners();
  }

  /// Resets all cached portfolio data.
  Future<void> reset() async {
    _cachedSnapshot = null;
    _isInitialized = false;
    _cacheService?.invalidate(CacheDomain.portfolio);
    await repository.clear();
    _logger.info('PortfolioEngine reset',
        category: LogCategory.engine, source: 'PortfolioEngine');
    notifyListeners();
  }

  // ── Snapshot Builder ──────────────────────────────────────────────

  PortfolioSnapshot _buildSnapshot() {
    final portfolio = _portfolioService.buildPortfolio();

    return PortfolioSnapshot(
      portfolioScore: portfolio.portfolioScore,
      projectCount: portfolio.projectCount,
      skillCount: portfolio.skills.length,
      technologyCount: portfolio.technologyCount,
      achievementCount: portfolio.achievementCount,
      careerReadiness: portfolio.careerReadiness,
      strengthAreas: portfolio.strengthAreas,
      improvementAreas: portfolio.improvementAreas,
      technologies: portfolio.technologies,
      lastUpdated: DateTime.now(),
    );
  }

  // ── AI Ingestion ──────────────────────────────────────────────────

  /// Ingests an AI-generated project into the engine.
  void ingest(IngestPackage pkg) {
    if (pkg.type != 'project') return;

    // Duplicate detection by content hash
    if (_aiProjects.any((e) => e.metadata.contentHash == pkg.contentHash)) {
      _logger.info('PortfolioEngine: duplicate project ingest skipped',
          category: LogCategory.engine, source: 'PortfolioEngine');
      return;
    }

    final data = pkg.content;
    _aiProjects.add(AIProjectEntry(
      id: data['id'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      estimatedHours: data['estimatedHours'] as int? ?? 0,
      technologies: (data['technologies'] as List<dynamic>?)?.cast<String>() ?? [],
      metadata: pkg.metadata,
    ));
    _logger.info('PortfolioEngine: ingested project ${data['title']}',
        category: LogCategory.engine, source: 'PortfolioEngine');
  }

  /// Merges AI project with an existing entry by ID.
  void merge(String id, IngestPackage pkg) {
    if (pkg.type != 'project') return;
    final idx = _aiProjects.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final data = pkg.content;
    _aiProjects[idx] = AIProjectEntry(
      id: id,
      title: data['title'] as String? ?? _aiProjects[idx].title,
      description: data['description'] as String? ?? _aiProjects[idx].description,
      estimatedHours: data['estimatedHours'] as int? ?? _aiProjects[idx].estimatedHours,
      technologies: (data['technologies'] as List<dynamic>?)?.cast<String>() ??
          _aiProjects[idx].technologies,
      metadata: pkg.metadata,
    );
  }

  /// Replaces an AI project entirely by ID.
  void replace(String id, IngestPackage pkg) {
    merge(id, pkg);
  }

  /// Removes all AI-generated projects from this engine.
  void clearGenerated() {
    _aiProjects.clear();
    _logger.info('PortfolioEngine: cleared all AI-generated projects',
        category: LogCategory.engine, source: 'PortfolioEngine');
  }

  /// Rolls back AI-generated content by content hash.
  void rollback(String contentHash) {
    _aiProjects.removeWhere((e) => e.metadata.contentHash == contentHash);
    _logger.info('PortfolioEngine: rolled back $contentHash',
        category: LogCategory.engine, source: 'PortfolioEngine');
  }

  /// Stub for future schema migration support.
  void migration(int fromVersion, int toVersion) {
    _logger.info('PortfolioEngine: migration $fromVersion→$toVersion (no-op)',
        category: LogCategory.engine, source: 'PortfolioEngine');
  }

  /// Validates an ingest package fits the project schema.
  /// Returns null if valid, or an error message if invalid.
  String? validate(IngestPackage pkg) {
    if (pkg.type != 'project') return 'Expected type "project", got "${pkg.type}"';
    final title = pkg.content['title'] as String?;
    if (title == null || title.isEmpty) return 'Project title is required';
    return null;
  }
}

/// An AI-generated project entry in the portfolio engine.
class AIProjectEntry {
  const AIProjectEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedHours,
    required this.technologies,
    required this.metadata,
  });

  final String id;
  final String title;
  final String description;
  final int estimatedHours;
  final List<String> technologies;
  final AIContentMetadata metadata;
}
