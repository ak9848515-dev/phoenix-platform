import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../core/cloud/firestore_sync_adapter.dart';
import '../../../features/adaptive_learning/engine/adaptive_learning_engine.dart';
import '../../../features/ai/provider_config/models/provider_config.dart';
import '../../../features/ai/provider_config/services/health_monitor.dart';
import '../../../features/ai/provider_config/services/provider_config_service.dart';
import '../../../features/ai_capability_router/router/ai_capability_router.dart';
import '../../../features/ai_context/engine/ai_context_engine.dart';
import '../../../features/ai_gateway/services/ai_response_gateway.dart';
import '../../../features/ai_prompt/services/prompt_builder_service.dart';
import '../../../features/career/engine/career_engine.dart';
import '../../../features/continue_journey/engine/continue_journey_engine.dart';
import '../../../features/daily_brief/engine/daily_brief_engine.dart';
import '../../../features/decision_intelligence/engine/decision_engine.dart';
import '../../../features/decision_intelligence/orchestrator/decision_intelligence_orchestrator.dart';
import '../../../features/growth_index/engine/growth_index_engine.dart';
import '../../../features/growth_intelligence/engine/growth_intelligence_engine.dart';
import '../../../features/identity/engine/identity_engine.dart';
import '../../../features/interview/intelligence/engine/interview_intelligence_engine.dart';
import '../../../features/opportunity/intelligence/engine/opportunity_intelligence_engine.dart';
import '../../../features/memory_engine/engine/memory_engine.dart';
import '../../../features/mission_intelligence/engine/mission_intelligence_engine.dart';
import '../../../features/notification_center/engine/notification_engine.dart';
import '../../../features/personal_knowledge/engine/knowledge_engine.dart';
import '../../../features/portfolio/engine/portfolio_engine.dart';
import '../../../features/progress_engine/achievement_engine.dart';
import '../../../features/recommendation_engine/engine/recommendation_engine.dart';
import '../../../features/resume_intelligence/engine/resume_intelligence_engine.dart';
import '../../../features/settings/engine/settings_engine.dart';
import '../../../features/review_engine/engine/review_engine.dart';
import '../../infrastructure/cache/cache_service.dart';
import '../firebase/firebase_service.dart';
import '../logging/phoenix_logger.dart';

/// Result of a single health check.
class HealthCheck {
  const HealthCheck({
    required this.name,
    required this.passed,
    this.message = '',
    this.elapsedMs = 0,
    this.detail,
  });

  final String name;
  final bool passed;
  final String message;
  final int elapsedMs;
  final String? detail;

  Map<String, dynamic> toMap() => {
        'name': name,
        'passed': passed,
        'message': message,
        'elapsedMs': elapsedMs,
        'detail': detail,
      };
}

/// Complete health report for the application.
class HealthReport {
  const HealthReport({
    required this.healthy,
    required this.checks,
    this.totalElapsedMs = 0,
    this.timestamp,
  });

  /// Whether all checks passed.
  final bool healthy;

  /// Individual health check results.
  final List<HealthCheck> checks;

  /// Total elapsed time for all checks.
  final int totalElapsedMs;

  /// When the report was generated.
  final DateTime? timestamp;

  /// Checks that failed.
  List<HealthCheck> get failures => checks.where((c) => !c.passed).toList();

  /// Number of passed checks.
  int get passedCount => checks.where((c) => c.passed).length;

  /// Number of failed checks.
  int get failedCount => checks.where((c) => !c.passed).length;

  /// Summary string.
  String get summary =>
      'Health: ${healthy ? "PASSED" : "FAILED"} '
      '($passedCount/${checks.length} checks passed, ${totalElapsedMs}ms)';

  /// Serializes the report to a map for export.
  Map<String, dynamic> toMap() => {
        'healthy': healthy,
        'passedCount': passedCount,
        'failedCount': failedCount,
        'totalChecks': checks.length,
        'totalElapsedMs': totalElapsedMs,
        'timestamp': timestamp?.toIso8601String(),
        'checks': checks.map((c) => c.toMap()).toList(),
      };
}

/// Application diagnostics service.
///
/// Performs health checks on all registered engines, services, and
/// infrastructure. Supports export for diagnostics reporting.
class DiagnosticsService {
  final PhoenixLogger _logger = PhoenixLogger.shared;

  IdentityEngine? _identityEngine;
  GrowthIndexEngine? _growthEngine;
  MissionIntelligenceEngine? _missionEngine;
  RecommendationEngine? _recommendationEngine;
  DailyBriefEngine? _dailyBriefEngine;
  ContinueJourneyEngine? _continueJourneyEngine;
  MemoryEngine? _memoryEngine;
  AICapabilityRouter? _aiRouter;

  // ── Domain Engines ────────────────────────────────────────────
  CareerEngine? _careerEngine;
  PortfolioEngine? _portfolioEngine;
  KnowledgeEngine? _knowledgeEngine;
  AchievementEngine? _achievementEngine;

  // ── Settings & AI Infrastructure ───────────────────────────────
  SettingsEngine? _settingsEngine;
  ProviderConfigurationService? _providerConfigService;
  HealthMonitor? _healthMonitor;

  // ── Intelligence Engines ──────────────────────────────────────
  InterviewIntelligenceEngine? _interviewEngine;
  OpportunityIntelligenceEngine? _opportunityEngine;
  ResumeIntelligenceEngine? _resumeEngine;
  GrowthIntelligenceEngine? _growthIntelligenceEngine;
  AdaptiveLearningEngine? _adaptiveLearningEngine;

  // ── Decision Intelligence ─────────────────────────────────────
  DecisionEngine? _decisionEngine;
  DecisionIntelligenceOrchestrator? _decisionOrchestrator;

  // ── Notification & Review ─────────────────────────────────────
  NotificationEngine? _notificationEngine;
  ReviewEngine? _reviewEngine;

  // ── AI Pipeline ───────────────────────────────────────────────
  AIContextEngine? _aiContextEngine;
  PromptBuilderService? _promptBuilderService;
  AIResponseGateway? _aiResponseGateway;

  // ── Cache ─────────────────────────────────────────────────────
  CacheService? _cacheService;

  // ── AI Diagnostics Tracking ───────────────────────────────────
  int _aiTotalRequests = 0;
  int _aiSuccessfulRequests = 0;
  int _aiFailedRequests = 0;
  int _aiRetries = 0;
  int _aiFallbacksUsed = 0;
  final List<int> _aiLatencyHistory = [];
  final Map<String, int> _aiRequestCountByProvider = {};
  final Map<String, int> _aiRequestCountByCapability = {};
  DateTime? _lastAiRequestAt;

  /// Records an AI request for diagnostics tracking.
  void recordAiRequest({
    required String providerName,
    required String capabilityName,
    required bool success,
    int latencyMs = 0,
    int retries = 0,
    bool fallbackUsed = false,
    String? promptTemplate,
    int? promptSize,
    int? contextSize,
    int? estimatedTokens,
    int? responseSize,
  }) {
    _aiTotalRequests++;
    _lastAiRequestAt = DateTime.now();
    _aiRequestCountByProvider[providerName] =
        (_aiRequestCountByProvider[providerName] ?? 0) + 1;
    _aiRequestCountByCapability[capabilityName] =
        (_aiRequestCountByCapability[capabilityName] ?? 0) + 1;
    _aiRetries += retries;
    if (fallbackUsed) _aiFallbacksUsed++;
    if (success) {
      _aiSuccessfulRequests++;
    } else {
      _aiFailedRequests++;
    }
    if (latencyMs > 0) {
      _aiLatencyHistory.add(latencyMs);
      if (_aiLatencyHistory.length > 100) {
        _aiLatencyHistory.removeAt(0);
      }
    }
    _logger.info('AI request recorded: $providerName/$capabilityName '
        '(${success ? "success" : "failure"}, ${latencyMs}ms, '
        'retries: $retries, fallback: $fallbackUsed)',
        category: LogCategory.diagnostics, source: 'DiagnosticsService');
  }

  /// AI diagnostics summary for the diagnostics screen.
  Map<String, dynamic> get aiDiagnosticsSummary {
    final avgLatency = _aiLatencyHistory.isEmpty
        ? 0.0
        : _aiLatencyHistory.reduce((a, b) => a + b) / _aiLatencyHistory.length;
    final successRate = _aiTotalRequests > 0
        ? (_aiSuccessfulRequests / _aiTotalRequests * 100)
        : 100.0;
    return {
      'totalRequests': _aiTotalRequests,
      'successful': _aiSuccessfulRequests,
      'failed': _aiFailedRequests,
      'successRate': '${successRate.toStringAsFixed(1)}%',
      'totalRetries': _aiRetries,
      'fallbacksUsed': _aiFallbacksUsed,
      'avgLatencyMs': avgLatency.round(),
      'lastRequestAt': _lastAiRequestAt?.toIso8601String(),
      'requestsByProvider': Map.from(_aiRequestCountByProvider),
      'requestsByCapability': Map.from(_aiRequestCountByCapability),
      'providerCount': _aiRequestCountByProvider.length,
      'capabilityCount': _aiRequestCountByCapability.length,
    };
  }

  /// Resets all AI diagnostics tracking data.
  void resetAiDiagnostics() {
    _aiTotalRequests = 0;
    _aiSuccessfulRequests = 0;
    _aiFailedRequests = 0;
    _aiRetries = 0;
    _aiFallbacksUsed = 0;
    _aiLatencyHistory.clear();
    _aiRequestCountByProvider.clear();
    _aiRequestCountByCapability.clear();
    _lastAiRequestAt = null;
  }

  // ── Lifecycle ─────────────────────────────────────────────────
  AppLifecycleState? _lastLifecycleState;

  // ── Sync Adapter ──────────────────────────────────────────────
  FirestoreSyncAdapter? _syncAdapter;

  // ── Performance Tracking ──────────────────────────────────────

  /// Tracks frame rendering times for diagnostics.
  final List<int> _frameTimes = [];
  int _totalFrames = 0;
  int _jankyFrames = 0; // frames > 16ms

  /// Tracks engine execution durations (engineName -> list of ms).
  final Map<String, List<int>> _engineExecutionTimes = {};

  /// Tracks widget rebuild counts (widgetName -> count).
  final Map<String, int> _widgetRebuildCounts = {};

  /// Memory usage snapshots (timestamp -> MB).
  final List<Map<String, dynamic>> _memorySnapshots = [];

  /// Firestore operation latency tracking.
  final List<int> _firestoreReadLatency = [];
  final List<int> _firestoreWriteLatency = [];

  /// Sync operation duration tracking.
  final List<int> _syncDurations = [];

  // ── Startup Timing ────────────────────────────────────────
  int? _coldStartMs;
  int? _warmStartMs;

  void registerEngines({
    IdentityEngine? identityEngine,
    GrowthIndexEngine? growthEngine,
    MissionIntelligenceEngine? missionEngine,
    RecommendationEngine? recommendationEngine,
    DailyBriefEngine? dailyBriefEngine,
    ContinueJourneyEngine? continueJourneyEngine,
    MemoryEngine? memoryEngine,
    AICapabilityRouter? aiRouter,
    CareerEngine? careerEngine,
    PortfolioEngine? portfolioEngine,
    KnowledgeEngine? knowledgeEngine,
    AchievementEngine? achievementEngine,
    SettingsEngine? settingsEngine,
    ProviderConfigurationService? providerConfigService,
    HealthMonitor? healthMonitor,
    InterviewIntelligenceEngine? interviewEngine,
    OpportunityIntelligenceEngine? opportunityEngine,
    ReviewEngine? reviewEngine,
    FirestoreSyncAdapter? syncAdapter,
    NotificationEngine? notificationEngine,
    DecisionEngine? decisionEngine,
    DecisionIntelligenceOrchestrator? decisionOrchestrator,
    GrowthIntelligenceEngine? growthIntelligenceEngine,
    AdaptiveLearningEngine? adaptiveLearningEngine,
    ResumeIntelligenceEngine? resumeEngine,
    AIContextEngine? aiContextEngine,
    PromptBuilderService? promptBuilderService,
    AIResponseGateway? aiResponseGateway,
    CacheService? cacheService,
  }) {
    _identityEngine = identityEngine;
    _growthEngine = growthEngine;
    _missionEngine = missionEngine;
    _recommendationEngine = recommendationEngine;
    _dailyBriefEngine = dailyBriefEngine;
    _continueJourneyEngine = continueJourneyEngine;
    _memoryEngine = memoryEngine;
    _aiRouter = aiRouter;
    _careerEngine = careerEngine;
    _portfolioEngine = portfolioEngine;
    _knowledgeEngine = knowledgeEngine;
    _achievementEngine = achievementEngine;
    _settingsEngine = settingsEngine;
    _providerConfigService = providerConfigService;
    _healthMonitor = healthMonitor;
    _interviewEngine = interviewEngine;
    _opportunityEngine = opportunityEngine;
    _reviewEngine = reviewEngine;
    _syncAdapter = syncAdapter;
    _notificationEngine = notificationEngine;
    _decisionEngine = decisionEngine;
    _decisionOrchestrator = decisionOrchestrator;
    _growthIntelligenceEngine = growthIntelligenceEngine;
    _adaptiveLearningEngine = adaptiveLearningEngine;
    _resumeEngine = resumeEngine;
    _aiContextEngine = aiContextEngine;
    _promptBuilderService = promptBuilderService;
    _aiResponseGateway = aiResponseGateway;
    _cacheService = cacheService;
  }

  /// Runs all health checks and returns a report.
  Future<HealthReport> runHealthCheck() async {
    final start = DateTime.now();
    final checks = <HealthCheck>[];

    // ── Core Intelligence Engines ─────────────────────────────────
    checks.addAll([
      _checkEngine('IdentityEngine', _identityEngine?.isInitialized ?? false),
      _checkEngine('GrowthIndexEngine', _growthEngine?.isInitialized ?? false),
      _checkEngine('MissionIntelligenceEngine',
          _missionEngine?.isInitialized ?? false),
      _checkEngine(
          'RecommendationEngine', _recommendationEngine?.isInitialized ?? false),
      _checkEngine(
          'DailyBriefEngine', _dailyBriefEngine?.isInitialized ?? false),
      _checkEngine('ContinueJourneyEngine',
          _continueJourneyEngine?.isInitialized ?? false),
    ]);

    // ── Domain Engines (PHX-069.5) ────────────────────────────────
    checks.addAll([
      _checkEngine('CareerEngine', _careerEngine?.isInitialized ?? false),
      _checkEngine('PortfolioEngine', _portfolioEngine?.isInitialized ?? false),
      _checkEngine('KnowledgeEngine', _knowledgeEngine?.isInitialized ?? false),
      _checkEngine(
          'AchievementEngine', _achievementEngine?.isInitialized ?? false),
    ]);

    // ── Interview Intelligence Engine ────────────────────────────
    checks.add(
      _checkEngine('InterviewIntelligenceEngine', _interviewEngine?.isInitialized ?? false),
    );

    // ── Opportunity Intelligence Engine ──────────────────────────
    checks.add(
      _checkEngine('OpportunityIntelligenceEngine', _opportunityEngine?.isInitialized ?? false),
    );

    // ── Resume Intelligence Engine ──────────────────────────────
    checks.add(
      _checkEngine('ResumeIntelligenceEngine', _resumeEngine?.isInitialized ?? false),
    );

    // ── Growth Intelligence Engine ──────────────────────────────
    checks.add(
      _checkEngine('GrowthIntelligenceEngine', _growthIntelligenceEngine?.isInitialized ?? false),
    );

    // ── Adaptive Learning Engine ─────────────────────────────────
    checks.add(
      _checkEngine('AdaptiveLearningEngine', _adaptiveLearningEngine?.isInitialized ?? false),
    );

    // ── Review Engine ─────────────────────────────────────────────
    checks.add(
      _checkEngine('ReviewEngine', _reviewEngine?.isInitialized ?? false),
    );

    // ── Notification Engine ──────────────────────────────────────
    checks.add(
      _checkEngine('NotificationEngine', _notificationEngine?.isInitialized ?? false),
    );

    // ── Decision Intelligence Engine ─────────────────────────────
    checks.addAll([
      _checkEngine('DecisionEngine', _decisionEngine?.isInitialized ?? false),
      _checkEngine('DecisionIntelligenceOrchestrator', _decisionOrchestrator?.isInitialized ?? false),
    ]);

    // ── AI Pipeline Infrastructure ───────────────────────────────
    checks.addAll([
      _checkEngine('AIContextEngine', _aiContextEngine?.isInitialized ?? false),
      _checkEngine('PromptBuilderService', _promptBuilderService != null),
      _checkEngine('AIResponseGateway', _aiResponseGateway != null),
      _checkEngine('CacheService', _cacheService != null),
    ]);

    // ── Memory & AI Infrastructure ────────────────────────────────
    checks.addAll([
      _checkEngine('MemoryEngine', _memoryEngine?.isInitialized ?? false),
      _checkEngine('AICapabilityRouter', _aiRouter != null),
      _checkEngine('SettingsEngine', _settingsEngine?.isInitialized ?? false),
    ]);

    // ── AI Provider Health ────────────────────────────────────────
    if (_providerConfigService != null) {
      try {
        final configs = await _providerConfigService!.loadAll();
        for (final config in configs) {
          final health = _healthMonitor?.getHealth(config.providerId) ??
              ProviderHealthStatus.unknown;
          checks.add(HealthCheck(
            name: 'Provider:${config.providerId}',
            passed: health.isOperational,
            message: health.displayName,
            detail: config.enabled
                ? 'Enabled, default=${config.isDefault}'
                : 'Disabled',
          ));
        }
      } catch (e) {
        checks.add(HealthCheck(
          name: 'ProviderConfig',
          passed: false,
          message: 'Failed to load configs',
          detail: e.toString(),
        ));
      }
    }

    // ── AI Providers Health Monitor Status ────────────────────────
    if (_healthMonitor != null) {
      final allHealth = _healthMonitor!.allHealth;
      for (final entry in allHealth.entries) {
        checks.add(HealthCheck(
          name: 'Health:${entry.key}',
          passed: entry.value.isOperational,
          message: entry.value.displayName,
        ));
      }
    }

    // ── Settings Engine ──────────────────────────────────────────
    if (_settingsEngine != null) {
      checks.add(HealthCheck(
        name: 'SettingsPersistence',
        passed: _settingsEngine!.isInitialized,
        message: _settingsEngine!.isInitialized ? 'Initialized' : 'Not initialized',
        detail: _settingsEngine!.isInitialized
            ? 'Dirty=${_settingsEngine!.isDirty}'
            : null,
      ));
    }

    // ── Startup Performance ────────────────────────────────────────
    // Read timing from AppBootstrap static fields (set by main.dart)
    final startupMs = AppBootstrap.startupMs;
    final bootstrapMs = AppBootstrap.bootstrapMs;
    final firebaseMs = AppBootstrap.firebaseMs;
    if (startupMs != null) {
      final isHealthy = startupMs < 10000;
      checks.add(HealthCheck(
        name: 'StartupTime',
        passed: isHealthy,
        message: isHealthy ? 'Fast' : 'Slow',
        detail: 'Total: ${startupMs}ms, Bootstrap: ${bootstrapMs ?? 0}ms, Firebase: ${firebaseMs ?? 0}ms',
      ));
    }

    // ── Authentication Health ───────────────────────────────────────
    final auth = FirebaseService.auth;
    if (auth != null) {
      final currentUser = auth.currentUser;
      checks.add(HealthCheck(
        name: 'AuthStatus',
        passed: currentUser != null,
        message: currentUser != null ? 'Authenticated' : 'Not authenticated',
        detail: currentUser != null
            ? 'UID: ${currentUser.uid.substring(0, 8)}...'
            : 'No active session',
      ));
    }

    // ── App Lifecycle ────────────────────────────────────────────────
    if (_lastLifecycleState != null) {
      checks.add(HealthCheck(
        name: 'LifecycleState',
        passed: _lastLifecycleState == AppLifecycleState.resumed,
        message: _lastLifecycleState!.name,
      ));
    }

    // ── Firebase Health Checks ────────────────────────────────────
    final firebaseHealth = FirebaseService.checkHealth();
    for (final result in firebaseHealth) {
      checks.add(HealthCheck(
        name: 'Firebase:${result.service}',
        passed: result.isHealthy,
        message: result.message.isNotEmpty
            ? result.message
            : result.status.displayName,
      ));
    }

    // ── Sync & Firestore Health ──────────────────────────────────
    if (_syncAdapter != null) {
      checks.addAll([
        HealthCheck(
          name: 'FirestoreSyncStatus',
          passed: _syncAdapter!.isFirestoreAvailable,
          message: _syncAdapter!.statusLabel,
          detail: 'Last sync: ${_syncAdapter!.lastSyncLabel}, '
              'Offline queue: ${_syncAdapter!.offlineQueueSize}, '
              'Dirty domains: ${_syncAdapter!.dirtyDomains.length}',
        ),
        HealthCheck(
          name: 'FirestoreSyncQueue',
          passed: _syncAdapter!.offlineQueueSize < 10,
          message: _syncAdapter!.offlineQueueSize == 0
              ? 'Empty queue'
              : '${_syncAdapter!.offlineQueueSize} pending',
        ),
        HealthCheck(
          name: 'FirestoreDirtyDomains',
          passed: !_syncAdapter!.hasDirtyData,
          message: _syncAdapter!.hasDirtyData
              ? '${_syncAdapter!.dirtyDomains.length} dirty domains'
              : 'All domains clean',
        ),
      ]);
    }

    // ── Firestore Health (from FirebaseService) ────────────────────
    final firestoreResult = FirebaseService.checkHealth()
        .where((h) => h.service == 'Cloud Firestore')
        .firstOrNull;
    if (firestoreResult != null) {
      checks.add(HealthCheck(
        name: 'FirestoreConnection',
        passed: firestoreResult.isHealthy,
        message: firestoreResult.isHealthy ? 'Connected' : 'Disconnected',
        detail: firestoreResult.isHealthy
            ? 'Persistence enabled'
            : 'Cannot reach Firestore',
      ));
    }

    // ── Snapshot Availability ──────────────────────────────────────
    checks.addAll([
      _checkSnapshot('IdentitySnapshot', _identityEngine?.snapshot),
      _checkSnapshot('GrowthSnapshot', _growthEngine?.snapshot),
      _checkSnapshot('MissionSnapshot', _missionEngine?.snapshot),
      _checkSnapshot('RecommendationSnapshot',
          _recommendationEngine?.snapshot),
      _checkSnapshot('DailyBriefSnapshot', _dailyBriefEngine?.snapshot),
      _checkSnapshot('JourneySnapshot', _continueJourneyEngine?.snapshot),
      _checkSnapshot('MemorySnapshot', _memoryEngine?.snapshot),
      _checkSnapshot('CareerSnapshot', _careerEngine?.snapshot),
      _checkSnapshot('PortfolioSnapshot', _portfolioEngine?.snapshot),
      _checkSnapshot('KnowledgeSnapshot', _knowledgeEngine?.snapshot),
      _checkSnapshot('AchievementSnapshot', _achievementEngine?.snapshot),
      _checkSnapshot('InterviewSnapshot', _interviewEngine?.snapshot),
      _checkSnapshot('OpportunitySnapshot', _opportunityEngine?.snapshot),
      _checkSnapshot('ResumeSnapshot', _resumeEngine?.snapshot),
      _checkSnapshot('ReviewSnapshot', _reviewEngine?.snapshot),
      _checkSnapshot('NotificationSnapshot', _notificationEngine?.notifications),
      _checkSnapshot('DecisionSnapshot', _decisionEngine?.snapshot),
      _checkSnapshot('OrchestratorSnapshot', _decisionOrchestrator?.snapshot),
    ]);

    final elapsed = DateTime.now().difference(start).inMilliseconds;
    final healthy = checks.every((c) => c.passed);

    _logger.info('Health check completed',
        category: LogCategory.diagnostics,
        elapsedMs: elapsed,
        metadata: {
          'passed': healthy
              ? checks.length
              : '${checks.length - checks.where((c) => !c.passed).length}/${checks.length}'
        });

    return HealthReport(
      healthy: healthy,
      checks: checks,
      totalElapsedMs: elapsed,
      timestamp: DateTime.now(),
    );
  }

  /// Sets the last known app lifecycle state.
  /// Called by the AppLifecycleHandler in main.dart.
  // ── Frame Time Tracking ────────────────────────────────────

  /// Records a frame rendering time for diagnostics.
  void recordFrameTime(int elapsedMs) {
    _frameTimes.add(elapsedMs);
    _totalFrames++;
    if (elapsedMs > 16) _jankyFrames++;
    if (_frameTimes.length > 1000) _frameTimes.removeAt(0);
  }

  /// Average frame time in ms.
  double get averageFrameMs {
    if (_frameTimes.isEmpty) return 0.0;
    return _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
  }

  /// Jank rate (frames > 16ms as fraction of total).
  double get jankRate =>
      _totalFrames > 0 ? _jankyFrames / _totalFrames : 0.0;

  // ── Engine Execution Tracking ───────────────────────────────

  /// Records an engine execution duration.
  void recordEngineExecution(String engineName, int durationMs) {
    _engineExecutionTimes.putIfAbsent(engineName, () => []);
    final list = _engineExecutionTimes[engineName]!;
    list.add(durationMs);
    if (list.length > 100) list.removeAt(0);
  }

  /// Average engine execution times by engine name.
  Map<String, double> get engineExecutionAverages {
    return _engineExecutionTimes.map((k, v) {
      if (v.isEmpty) return MapEntry(k, 0.0);
      return MapEntry(k, v.reduce((a, b) => a + b) / v.length);
    });
  }

  /// Total engine execution count.
  int get engineExecutionCount =>
      _engineExecutionTimes.values.fold(0, (s, l) => s + l.length);

  // ── Widget Rebuild Tracking ─────────────────────────────────

  /// Records a widget rebuild.
  void recordWidgetRebuild(String widgetName) {
    _widgetRebuildCounts[widgetName] =
        (_widgetRebuildCounts[widgetName] ?? 0) + 1;
  }

  /// Widget rebuild counts.
  Map<String, int> get widgetRebuildCounts =>
      Map.unmodifiable(_widgetRebuildCounts);

  /// Total widget rebuilds.
  int get totalWidgetRebuilds =>
      _widgetRebuildCounts.values.fold(0, (s, c) => s + c);

  // ── Memory Tracking ────────────────────────────────────────

  /// Records a memory usage snapshot.
  void recordMemorySnapshot(double usedMb, {String label = ''}) {
    _memorySnapshots.add({
      'timestamp': DateTime.now().toIso8601String(),
      'usedMb': usedMb,
      'label': label,
    });
    if (_memorySnapshots.length > 100) _memorySnapshots.removeAt(0);
  }

  /// Memory usage history.
  List<Map<String, dynamic>> get memorySnapshots =>
      List.unmodifiable(_memorySnapshots);

  // ── Firestore Latency Tracking ──────────────────────────────

  /// Records a Firestore read latency.
  void recordFirestoreRead(int latencyMs) {
    _firestoreReadLatency.add(latencyMs);
    if (_firestoreReadLatency.length > 100) _firestoreReadLatency.removeAt(0);
  }

  /// Records a Firestore write latency.
  void recordFirestoreWrite(int latencyMs) {
    _firestoreWriteLatency.add(latencyMs);
    if (_firestoreWriteLatency.length > 100) _firestoreWriteLatency.removeAt(0);
  }

  /// Average Firestore read latency.
  double get averageFirestoreReadMs {
    if (_firestoreReadLatency.isEmpty) return 0.0;
    return _firestoreReadLatency.reduce((a, b) => a + b) /
        _firestoreReadLatency.length;
  }

  /// Average Firestore write latency.
  double get averageFirestoreWriteMs {
    if (_firestoreWriteLatency.isEmpty) return 0.0;
    return _firestoreWriteLatency.reduce((a, b) => a + b) /
        _firestoreWriteLatency.length;
  }

  // ── Sync Duration Tracking ─────────────────────────────────

  /// Records a sync operation duration.
  void recordSyncDuration(int durationMs) {
    _syncDurations.add(durationMs);
    if (_syncDurations.length > 100) _syncDurations.removeAt(0);
  }

  /// Average sync duration.
  double get averageSyncDurationMs {
    if (_syncDurations.isEmpty) return 0.0;
    return _syncDurations.reduce((a, b) => a + b) / _syncDurations.length;
  }

  // ── Startup Timing ─────────────────────────────────────────

  /// Sets the cold start time (full app initialization).
  void setColdStartMs(int ms) => _coldStartMs = ms;

  /// Sets the warm start time (resume from background).
  void setWarmStartMs(int ms) => _warmStartMs = ms;

  /// Cold start time in ms.
  int? get coldStartMs => _coldStartMs;

  /// Warm start time in ms.
  int? get warmStartMs => _warmStartMs;

  /// Returns a comprehensive performance summary.
  Map<String, dynamic> get performanceSummary {
    return {
      'startup': {
        'coldStartMs': _coldStartMs,
        'warmStartMs': _warmStartMs,
        'totalStartupMs': AppBootstrap.startupMs,
        'bootstrapMs': AppBootstrap.bootstrapMs,
        'firebaseMs': AppBootstrap.firebaseMs,
      },
      'frameTime': {
        'averageMs': averageFrameMs.toStringAsFixed(1),
        'totalFrames': _totalFrames,
        'jankyFrames': _jankyFrames,
        'jankRate': jankRate.toStringAsFixed(3),
      },
      'engineExecution': {
        'totalExecutions': engineExecutionCount,
        'averages': engineExecutionAverages.map(
          (k, v) => MapEntry(k, '${v.toStringAsFixed(1)}ms'),
        ),
      },
      'widgetRebuilds': {
        'total': totalWidgetRebuilds,
        'byWidget': Map.from(_widgetRebuildCounts),
      },
      'firestore': {
        'averageReadMs': averageFirestoreReadMs.toStringAsFixed(1),
        'averageWriteMs': averageFirestoreWriteMs.toStringAsFixed(1),
        'readCount': _firestoreReadLatency.length,
        'writeCount': _firestoreWriteLatency.length,
      },
      'sync': {
        'averageDurationMs': averageSyncDurationMs.toStringAsFixed(1),
        'totalSyncs': _syncDurations.length,
      },
      'memory': {
        'snapshotCount': _memorySnapshots.length,
        'latestMb': _memorySnapshots.isNotEmpty
            ? _memorySnapshots.last['usedMb']
            : null,
      },
      'ai': aiDiagnosticsSummary,
      'cache': _cacheService?.diagnosticsSummary() ?? {},
    };
  }

  /// Resets all performance tracking data.
  void resetPerformanceTracking() {
    _frameTimes.clear();
    _totalFrames = 0;
    _jankyFrames = 0;
    _engineExecutionTimes.clear();
    _widgetRebuildCounts.clear();
    _memorySnapshots.clear();
    _firestoreReadLatency.clear();
    _firestoreWriteLatency.clear();
    _syncDurations.clear();
    _coldStartMs = null;
    _warmStartMs = null;
  }

  void setLifecycleState(AppLifecycleState state) {
    _lastLifecycleState = state;
  }

  /// Returns a JSON-exportable diagnostics summary.
  Future<Map<String, dynamic>> exportDiagnostics() async {
    final report = await runHealthCheck();
    final settings = _settingsEngine?.snapshot;
    return {
      'app': {
        'version': settings?.settings.version.appVersion ?? '1.0.0',
        'buildNumber': settings?.settings.version.buildNumber ?? '1',
        'platform': 'Flutter',
      },
      'health': report.toMap(),
      'firebase': FirebaseService.exportHealth(),
      'performance': performanceSummary,
      'cache': _cacheService?.diagnosticsSummary() ?? {},
      'ai': aiDiagnosticsSummary,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  HealthCheck _checkEngine(String name, bool initialized) {
    return HealthCheck(
      name: name,
      passed: initialized,
      message: initialized ? 'Initialized' : 'Not initialized',
    );
  }

  HealthCheck _checkSnapshot(String name, dynamic snapshot) {
    return HealthCheck(
      name: '${name}Available',
      passed: snapshot != null,
      message: snapshot != null ? 'Available' : 'Not available',
    );
  }
}
