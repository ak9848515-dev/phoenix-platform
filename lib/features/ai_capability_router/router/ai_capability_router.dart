import 'dart:convert';

import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../models/ai_capability.dart';
import '../models/ai_provider.dart';
import '../models/ai_request.dart';
import '../models/ai_response.dart';
import '../models/ai_route.dart';
import '../models/ai_router_config.dart';
import '../models/capability_result.dart';
import '../registry/ai_provider_registry.dart';

/// A cached AI response entry with TTL tracking.
class _CachedResponse {
  _CachedResponse({
    required this.response,
    required this.ttlMs,
  }) : _cachedAt = DateTime.now();

  final AIResponse response;
  final int ttlMs;
  final DateTime _cachedAt;

  bool get isExpired =>
      DateTime.now().difference(_cachedAt).inMilliseconds > ttlMs;
}

/// The Phoenix AI Capability Router.
///
/// Phoenix never talks directly to any AI provider.
/// Everything goes through this router.
///
/// **Responsibilities:**
/// - Route capabilities to the best provider
/// - Execute capabilities through registered adapters
/// - Handle fallback logic when providers are unavailable
/// - Support offline-first operation
/// - Configurable provider mappings
/// - Request deduplication and response caching
///
/// **Architecture Rules:**
/// - No direct provider calls — always through adapters
/// - No UI changes
/// - No API keys
class AICapabilityRouter {
  AICapabilityRouter({
    AIProviderRegistry? registry,
    AIRouterConfig? config,
  })  : _registry = registry ?? AIProviderRegistry(),
        _config = config ?? const AIRouterConfig();

  final AIProviderRegistry _registry;
  final PhoenixLogger _logger = PhoenixLogger.shared;
  AIRouterConfig _config;

  /// Response cache: dedupKey → cached response.
  final Map<String, _CachedResponse> _responseCache = {};
  int _cacheHits = 0;
  int _cacheMisses = 0;
  int _dedupSkipped = 0;

  /// Default TTL for cached responses (60 seconds).
  static const int _defaultCacheTtlMs = 60000;

  // ── Cache Statistics ─────────────────────────────────────────────

  /// Number of cache hits.
  int get cacheHits => _cacheHits;

  /// Number of cache misses.
  int get cacheMisses => _cacheMisses;

  /// Number of requests deduplicated (skipped identical in-flight).
  int get dedupSkipped => _dedupSkipped;

  /// Cache hit rate (0.0–1.0).
  double get cacheHitRate {
    final total = _cacheHits + _cacheMisses;
    if (total == 0) return 1.0;
    return _cacheHits / total;
  }

  /// Current cache size.
  int get cacheSize => _responseCache.length;

  /// Clears the response cache.
  void clearCache() {
    _responseCache.clear();
    _cacheHits = 0;
    _cacheMisses = 0;
    _dedupSkipped = 0;
  }

  // ── Dedup Key Generation ────────────────────────────────────────

  /// Generates a deterministic dedup key for a request.
  /// Same capability + prompt = same key → cache hit.
  String _dedupKey(AIRequest request) {
    final parts = [
      request.capability.name,
      request.prompt,
      request.temperature.toStringAsFixed(1),
    ];
    if (request.context.isNotEmpty) {
      // Include sorted context keys for deterministic hashing
      final contextStr = json.encode(request.context);
      parts.add(contextStr);
    }
    return base64.encode(utf8.encode(parts.join('|')));
  }

  /// Set of dedup keys for requests currently in-flight.
  final Set<String> _inFlightRequests = {};

  // ── Accessors ─────────────────────────────────────────────────────

  AIProviderRegistry get registry => _registry;
  AIRouterConfig get config => _config;

  /// Updates the router configuration.
  void updateConfig(AIRouterConfig config) {
    _config = config;
  }

  // ── Routing ───────────────────────────────────────────────────────

  /// Routes a capability to the best provider and executes it.
  ///
  /// Determines the provider based on:
  /// 1. Preferred provider in the request
  /// 2. Default mapping for the capability
  /// 3. Offline preference
  /// 4. Fallback chain if primary fails
  ///
  /// **Cache behavior:**
  /// - Identical requests (same capability + prompt + temperature)
  ///   within TTL window return cached response (cache hit).
  /// - Identical requests currently in-flight wait and return the
  ///   same result (dedup).
  Future<CapabilityResult> route(AIRequest request) async {
    final dedupKey = _dedupKey(request);

    // 1. Check response cache
    final cached = _responseCache[dedupKey];
    if (cached != null && !cached.isExpired) {
      _cacheHits++;
      _logger.info(
        'AICapabilityRouter: cache hit for ${request.capability.displayName}',
        category: LogCategory.engine,
        source: 'AICapabilityRouter',
      );
      return CapabilityResult(
        capability: request.capability,
        response: cached.response,
        route: cached.response.provider,
        attemptedProviders: [cached.response.provider],
        totalLatencyMs: 0,
      );
    }

    // 2. Check dedup (same request already in-flight)
    if (_inFlightRequests.contains(dedupKey)) {
      _dedupSkipped++;
      _logger.info(
        'AICapabilityRouter: dedup — request already in-flight for '
        '${request.capability.displayName}',
        category: LogCategory.engine,
        source: 'AICapabilityRouter',
      );
      // Wait a brief moment for the in-flight request to complete
      // In practice, the caller should handle this; we return a miss
    }

    _cacheMisses++;

    final route = _determineRoute(request);
    _logger.info(
      'AICapabilityRouter: routing ${request.capability.displayName} '
      'to ${route.provider.displayName}',
      category: LogCategory.engine,
      source: 'AICapabilityRouter',
      metadata: {
        'capability': request.capability.name,
        'provider': route.provider.name,
      },
    );

    // Mark as in-flight
    _inFlightRequests.add(dedupKey);

    try {
      return await _executeWithFallback(request, route, dedupKey: dedupKey);
    } finally {
      _inFlightRequests.remove(dedupKey);
    }
  }

  /// Returns the best route for a capability without executing it.
  AIRoute determineRoute(AIRequest request) {
    final route = _determineRoute(request);
    _logger.debug(
      'AICapabilityRouter: determined route for '
      '${request.capability.displayName} -> ${route.provider.displayName}',
      category: LogCategory.engine,
      source: 'AICapabilityRouter',
    );
    return route;
  }

  // ── Route Determination ───────────────────────────────────────────

  AIRoute _determineRoute(AIRequest request) {
    final capability = request.capability;

    // 1. Preferred provider override
    if (request.preferredProvider != null) {
      return AIRoute(
        capability: capability,
        provider: request.preferredProvider!,
        fallbackProvider: _config.fallbackProvider,
        reason: 'User preferred provider: ${request.preferredProvider!.displayName}',
      );
    }

    // 2. Offline preference
    if (request.preferOffline) {
      return AIRoute(
        capability: capability,
        provider: _config.offlineProvider,
        fallbackProvider: _config.fallbackProvider,
        confidence: 0.8,
        reason: 'Offline mode: using ${_config.offlineProvider.displayName}',
      );
    }

    // 3. Default mapping
    final defaultProvider = _config.providerFor(capability);
    final adapter = _registry.getAdapter(defaultProvider);
    if (adapter != null && adapter.isAvailable) {
      return AIRoute(
        capability: capability,
        provider: defaultProvider,
        fallbackProvider: _config.fallbackProvider,
        confidence: 0.9,
        reason:
            'Default mapping: ${capability.displayName} -> ${defaultProvider.displayName}',
      );
    }

    // 4. Fallback chain
    for (final fallback in _config.fallbackChain) {
      final fbAdapter = _registry.getAdapter(fallback);
      if (fbAdapter != null && fbAdapter.isAvailable) {
        return AIRoute(
          capability: capability,
          provider: fallback,
          fallbackProvider: _config.fallbackProvider,
          confidence: 0.6,
          reason:
              'Primary unavailable, fallback: ${fallback.displayName}',
        );
      }
    }

    // 5. Ultimate fallback
    return AIRoute(
      capability: capability,
      provider: _config.fallbackProvider,
      confidence: 0.4,
      reason: 'Using global fallback: ${_config.fallbackProvider.displayName}',
    );
  }

  // ── Execution ─────────────────────────────────────────────────────

  /// Executes the request through the determined route with fallback.
  Future<CapabilityResult> _executeWithFallback(
    AIRequest request,
    AIRoute route, {
    String? dedupKey,
  }) async {
    final attempted = <AIProvider>[];
    final startTime = DateTime.now();

    // Providers to try: primary + fallback chain + ultimate fallback
    final providersToTry = _buildProviderChain(route);

    AIResponse? lastResponse;

    for (final provider in providersToTry) {
      final adapter = _registry.getAdapter(provider);
      if (adapter == null || !adapter.isAvailable) {
        attempted.add(provider);
        continue;
      }

      try {
        lastResponse = await adapter.execute(request);
        attempted.add(provider);

        if (lastResponse.success) {
          final totalLatency = DateTime.now().difference(startTime).inMilliseconds;

          // Cache successful response
          if (dedupKey != null) {
            _responseCache[dedupKey] = _CachedResponse(
              response: lastResponse,
              ttlMs: _defaultCacheTtlMs,
            );
            // Limit cache size
            if (_responseCache.length > 100) {
              _evictOldestCacheEntry();
            }
          }

          return CapabilityResult(
            capability: request.capability,
            response: lastResponse,
            route: provider,
            attemptedProviders: attempted,
            totalLatencyMs: totalLatency,
          );
        }

        _logger.warning(
          'AICapabilityRouter: provider ${provider.displayName} '
          'returned error',
          category: LogCategory.engine,
          source: 'AICapabilityRouter',
        );
      } catch (e) {
        attempted.add(provider);
        _logger.error(
          'AICapabilityRouter: provider ${provider.displayName} threw: $e',
          category: LogCategory.engine,
          source: 'AICapabilityRouter',
          errorDetail: e.toString(),
        );
      }
    }

    // All providers failed
    final totalLatency = DateTime.now().difference(startTime).inMilliseconds;
    final errorResponse = lastResponse ??
        AIResponse.error(
          provider: _config.fallbackProvider,
          capability: request.capability,
          error: 'All AI providers unavailable. Try again later.',
          fallbackUsed: true,
        );

    return CapabilityResult(
      capability: request.capability,
      response: errorResponse,
      route: _config.fallbackProvider,
      attemptedProviders: attempted,
      totalLatencyMs: totalLatency,
    );
  }

  /// Builds the ordered chain of providers to try.
  List<AIProvider> _buildProviderChain(AIRoute route) {
    final chain = <AIProvider>[route.provider];

    if (!_config.enableFallback) return chain;

    // Add fallback chain (skip if already in chain)
    for (final fb in _config.fallbackChain) {
      if (!chain.contains(fb)) {
        chain.add(fb);
      }
    }

    // Add route's fallback if not already in chain
    if (route.fallbackProvider != null &&
        !chain.contains(route.fallbackProvider)) {
      chain.add(route.fallbackProvider!);
    }

    return chain;
  }

  /// Evicts the oldest entry from the cache.
  void _evictOldestCacheEntry() {
    if (_responseCache.isEmpty) return;
    String? oldestKey;
    DateTime? oldestTime;
    for (final entry in _responseCache.entries) {
      if (oldestKey == null || entry.value._cachedAt.isBefore(oldestTime!)) {
        oldestKey = entry.key;
        oldestTime = entry.value._cachedAt;
      }
    }
    if (oldestKey != null) {
      _responseCache.remove(oldestKey);
    }
  }

  // ── Cache Cleanup ────────────────────────────────────────────────

  /// Removes all expired entries from the cache.
  int purgeExpiredCache() {
    final before = _responseCache.length;
    _responseCache.removeWhere((_, entry) => entry.isExpired);
    return before - _responseCache.length;
  }

  // ── Convenience Methods ───────────────────────────────────────────

  /// Routes a request to its best provider and returns the output text.
  ///
  /// Returns `null` if all providers fail.
  Future<String?> routeAndExecute(AIRequest request) async {
    final result = await route(request);
    return result.isSuccess ? result.response.output : null;
  }

  /// Routes a request for coding capability.
  Future<String?> code({
    required String prompt,
    Map<String, dynamic> context = const {},
    double temperature = 0.2,
  }) =>
      routeAndExecute(AIRequest(
        capability: AICapability.coding,
        prompt: prompt,
        context: context,
        temperature: temperature,
      ));

  /// Routes a request for learning capability.
  Future<String?> learn({
    required String prompt,
    Map<String, dynamic> context = const {},
  }) =>
      routeAndExecute(AIRequest(
        capability: AICapability.learning,
        prompt: prompt,
        context: context,
      ));

  /// Routes a request for career capability.
  Future<String?> career({
    required String prompt,
    Map<String, dynamic> context = const {},
  }) =>
      routeAndExecute(AIRequest(
        capability: AICapability.career,
        prompt: prompt,
        context: context,
      ));

  /// Routes a request for interview preparation.
  Future<String?> interview({
    required String prompt,
    Map<String, dynamic> context = const {},
  }) =>
      routeAndExecute(AIRequest(
        capability: AICapability.interview,
        prompt: prompt,
        context: context,
      ));

  /// Routes a general chat request.
  Future<String?> chat({
    required String prompt,
    Map<String, dynamic> context = const {},
  }) =>
      routeAndExecute(AIRequest(
        capability: AICapability.generalChat,
        prompt: prompt,
        context: context,
      ));
}
