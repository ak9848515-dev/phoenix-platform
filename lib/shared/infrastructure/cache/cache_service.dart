import 'dart:async';
import 'dart:core';

import '../../../core/bootstrap.dart';
import '../logging/phoenix_logger.dart';

/// Per-domain cache statistics for diagnostics.
class CacheDomainStats {
  CacheDomainStats({
    this.hits = 0,
    this.misses = 0,
    this.entryCount = 0,
    this.adaptiveTtlSeconds,
    this.defaultTtlSeconds = 300,
  });

  int hits;
  int misses;
  int entryCount;
  int defaultTtlSeconds;
  int? adaptiveTtlSeconds;

  double get hitRate {
    final total = hits + misses;
    if (total == 0) return 1.0;
    return hits / total;
  }

  int get effectiveTtlSeconds =>
      adaptiveTtlSeconds ?? defaultTtlSeconds;

  Map<String, dynamic> toMap() => {
        'hits': hits,
        'misses': misses,
        'hitRate': hitRate.toStringAsFixed(3),
        'entryCount': entryCount,
        'defaultTtlSeconds': defaultTtlSeconds,
        'adaptiveTtlSeconds': adaptiveTtlSeconds,
        'effectiveTtlSeconds': effectiveTtlSeconds,
      };
}

/// Cache entry with TTL tracking.
class CacheEntry<T> {
  CacheEntry({
    required this.key,
    required this.data,
    required this.ttlSeconds,
  }) : _createdAt = DateTime.now();

  final String key;
  final T data;
  final int ttlSeconds;
  final DateTime _createdAt;

  /// Whether this cache entry has expired.
  bool get isExpired =>
      DateTime.now().difference(_createdAt).inSeconds > ttlSeconds;

  /// Age of this entry in seconds.
  int get ageSeconds =>
      DateTime.now().difference(_createdAt).inSeconds;
}

/// Cache domain for each intelligence engine.
enum CacheDomain {
  journey(300),    // 5 min
  portfolio(600),  // 10 min
  career(600),     // 10 min
  interview(300),  // 5 min
  opportunity(600),// 10 min
  knowledge(900),  // 15 min
  memory(900),     // 15 min
  review(600),     // 10 min
  notification(120),// 2 min
  identity(1200),  // 20 min
  sync(30),        // 30 sec
  academy(600),    // 10 min
  habits(300),     // 5 min
  progress(600),   // 10 min
  recommendations(300); // 5 min

  const CacheDomain(this.defaultTtlSeconds);
  final int defaultTtlSeconds;
}

/// Cache optimization service with TTL, invalidation, and refresh.
///
/// Provides:
/// - TTL-based expiration per domain
/// - Manual invalidation by domain or key
/// - Global flush
/// - Hit/miss tracking for diagnostics
/// - Memory-constrained LRU-like eviction
/// - Per-domain analytics with adaptive TTL
///
/// **Architecture:**
/// ```text
/// Any engine → CacheService.cache(key, data, domain)
/// Any consumer → CacheService.get<T>(key)
/// Engine on data change → CacheService.invalidate(domain)
/// ```
///
/// **Rules:**
/// - No business logic — caching only
/// - Thread-safe via synchronous operations (single isolate)
/// - Max 500 entries to bound memory usage
class CacheService {
  CacheService({this.maxEntries = 500, this.enableAdaptiveTtl = true, this.purgeIntervalSeconds = 300});

  final PhoenixLogger _logger = PhoenixLogger.shared;
  final int maxEntries;
  final bool enableAdaptiveTtl;

  /// How often to purge expired entries (default: 5 minutes).
  final int purgeIntervalSeconds;

  final Map<String, CacheEntry<dynamic>> _cache = {};
  Timer? _purgeTimer;
  int _hits = 0;
  int _misses = 0;
  final Map<CacheDomain, CacheDomainStats> _domainStats = {};
  final Map<String, List<int>> _engineExecutionTimes = {};
  int _evictedCount = 0;

  // ── Accessors ─────────────────────────────────────────────────────

  /// Cache hit count.
  int get hits => _hits;

  /// Cache miss count.
  int get misses => _misses;

  /// Total cache entries.
  int get size => _cache.length;

  /// Hit rate (0.0 – 1.0), or 1.0 if no lookups.
  double get hitRate {
    final total = _hits + _misses;
    if (total == 0) return 1.0;
    return _hits / total;
  }

  /// Whether the cache is empty.
  bool get isEmpty => _cache.isEmpty;

  /// All cached domain names.
  List<String> get keys => _cache.keys.toList();

  /// Number of expired entries currently in cache.
  int get expiredCount => _cache.values.where((e) => e.isExpired).length;

  /// Number of entries evicted due to capacity limits.
  int get evictedCount => _evictedCount;

  // ── Per-Domain Stats ──────────────────────────────────────────────

  /// Returns stats for a specific domain.
  CacheDomainStats statsFor(CacheDomain domain) =>
      _domainStats.putIfAbsent(domain, () => CacheDomainStats(
        defaultTtlSeconds: domain.defaultTtlSeconds,
      ));

  /// Returns all domain stats as a map keyed by domain name.
  Map<String, CacheDomainStats> get allDomainStats =>
      _domainStats.map((k, v) => MapEntry(k.name, v));

  /// Updates adaptive TTL based on hit rate.
  /// High hit rate → longer TTL. Low hit rate → shorter TTL.
  void _updateAdaptiveTtl(CacheDomain domain) {
    if (!enableAdaptiveTtl) return;

    final stats = statsFor(domain);
    final total = stats.hits + stats.misses;
    if (total < 10) return; // Not enough data yet

    final rate = stats.hitRate;
    if (rate >= 0.9) {
      // High hit rate — extend TTL by 50%
      stats.adaptiveTtlSeconds =
          (domain.defaultTtlSeconds * 1.5).round();
    } else if (rate >= 0.7) {
      // Moderate hit rate — keep default
      stats.adaptiveTtlSeconds = domain.defaultTtlSeconds;
    } else if (rate >= 0.4) {
      // Low hit rate — reduce TTL by 30%
      stats.adaptiveTtlSeconds =
          (domain.defaultTtlSeconds * 0.7).round();
    } else {
      // Very low hit rate — reduce TTL by 50%
      stats.adaptiveTtlSeconds =
          (domain.defaultTtlSeconds * 0.5).round();
    }

    _logger.debug(
      'Cache: adaptive TTL for ${domain.name} → ${stats.effectiveTtlSeconds}s '
      '(hit rate: ${(rate * 100).round()}%)',
      category: LogCategory.performance,
      source: 'CacheService',
    );
  }

  // ── Core Operations ──────────────────────────────────────────────

  /// Caches [data] under [key] with the given [domain]'s TTL.
  /// If [ttlSeconds] is provided, overrides the domain default.
  void cache<T>(String key, T data, CacheDomain domain, {int? ttlSeconds}) {
    // Evict oldest entry if at capacity
    if (_cache.length >= maxEntries) {
      _evictOldest();
    }

    final ttl = ttlSeconds ?? statsFor(domain).effectiveTtlSeconds;
    _cache[key] = CacheEntry<T>(
      key: key,
      data: data,
      ttlSeconds: ttl,
    );
    statsFor(domain).entryCount = _cache.length;
  }

  /// Retrieves cached data if available and not expired.
  /// Returns `null` if not found or expired (and removes expired entries).
  T? get<T>(String key, {CacheDomain? domain}) {
    final entry = _cache[key];
    if (entry == null) {
      _misses++;
      if (domain != null) statsFor(domain).misses++;
      return null;
    }

    if (entry.isExpired) {
      _cache.remove(key);
      _misses++;
      if (domain != null) statsFor(domain).misses++;
      return null;
    }

    _hits++;
    if (domain != null) {
      statsFor(domain).hits++;
      _updateAdaptiveTtl(domain);
    }
    return entry.data as T;
  }

  /// Returns cached data without removing expired entries.
  /// Useful for diagnostics to check what's in the cache.
  CacheEntry<T>? peek<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    return entry as CacheEntry<T>;
  }

  /// Invalidates all entries for a specific domain.
  void invalidate(CacheDomain domain) {
    final prefix = '${domain.name}:';
    _cache.removeWhere((key, _) => key.startsWith(prefix));
    _logger.info('Cache invalidated for ${domain.name}',
        category: LogCategory.performance, source: 'CacheService');
  }

  /// Invalidates a specific key.
  void invalidateKey(String key) {
    _cache.remove(key);
  }

  /// Starts the periodic purge timer and memory snapshot tracking.
  void startPeriodicPurge() {
    _purgeTimer?.cancel();
    _purgeTimer = Timer.periodic(
      Duration(seconds: purgeIntervalSeconds),
      (_) {
        purgeExpired();
        _recordMemorySnapshot();
      },
    );
  }

  /// Records a memory usage snapshot for diagnostics.
  /// Uses an estimate based on cache size and entry count.
  void _recordMemorySnapshot() {
    final diagnostics = AppBootstrap.maybeDiagnosticsService;
    if (diagnostics == null) return;
    // Estimate memory: ~2KB per entry average + overhead
    final estimatedMb = (_cache.length * 0.002).roundToDouble();
    diagnostics.recordMemorySnapshot(
      estimatedMb,
      label: 'CacheService: ${_cache.length} entries',
    );
  }

  /// Stops the periodic purge timer.
  void stopPeriodicPurge() {
    _purgeTimer?.cancel();
    _purgeTimer = null;
  }

  /// Clears the entire cache and stops periodic purge.
  void flush() {
    _cache.clear();
    _hits = 0;
    _misses = 0;
    _domainStats.clear();
    _evictedCount = 0;
    _purgeTimer?.cancel();
    _purgeTimer = null;
    _logger.info('Cache flushed',
        category: LogCategory.performance, source: 'CacheService');
  }

  /// Removes all expired entries.
  int purgeExpired() {
    final before = _cache.length;
    _cache.removeWhere((_, entry) => entry.isExpired);
    final removed = before - _cache.length;
    if (removed > 0) {
      _logger.debug('Cache: purged $removed expired entries',
          category: LogCategory.performance, source: 'CacheService');
    }
    return removed;
  }

  /// Records an engine execution duration for diagnostics.
  void recordEngineExecution(String engineName, int durationMs) {
    _engineExecutionTimes.putIfAbsent(engineName, () => []);
    final list = _engineExecutionTimes[engineName]!;
    list.add(durationMs);
    if (list.length > 100) {
      list.removeAt(0);
    }
  }

  /// Returns average engine execution times.
  Map<String, double> get engineExecutionAverages {
    return _engineExecutionTimes.map((k, v) {
      if (v.isEmpty) return MapEntry(k, 0.0);
      return MapEntry(k, v.reduce((a, b) => a + b) / v.length);
    });
  }

  // ── Diagnostics Summary ─────────────────────────────────────────

  /// Returns a comprehensive diagnostics summary for the cache.
  Map<String, dynamic> diagnosticsSummary() {
    final totalLookups = _hits + _misses;
    final perDomain = allDomainStats.map((k, v) => MapEntry(k, v.toMap()));

    return {
      'size': _cache.length,
      'maxEntries': maxEntries,
      'hits': _hits,
      'misses': _misses,
      'totalLookups': totalLookups,
      'hitRate': hitRate.toStringAsFixed(3),
      'expiredCount': expiredCount,
      'evictedCount': _evictedCount,
      'isEmpty': isEmpty,
      'perDomain': perDomain,
      'engineExecutionAverages': engineExecutionAverages,
    };
  }

  /// Serializes the diagnostics summary for HealthReport integration.
  List<Map<String, dynamic>> diagnosticEntries() {
    return [
      {
        'name': 'CacheSize',
        'passed': _cache.length < maxEntries,
        'message': '${_cache.length}/$maxEntries entries',
        'elapsedMs': 0,
      },
      {
        'name': 'CacheHitRate',
        'passed': hitRate > 0.5,
        'message': '${(hitRate * 100).round()}% hit rate',
        'elapsedMs': 0,
      },
      {
        'name': 'CacheExpiredCount',
        'passed': expiredCount < 50,
        'message': '$expiredCount expired entries',
        'elapsedMs': 0,
      },
    ];
  }

  /// Resets all engine execution time tracking.
  void resetEngineExecutionTimes() {
    _engineExecutionTimes.clear();
  }

  // ── Helpers ──────────────────────────────────────────────────────

  void _evictOldest() {
    if (_cache.isEmpty) return;
    final oldest = _cache.entries.reduce(
      (a, b) => a.value._createdAt.isBefore(b.value._createdAt) ? a : b,
    );
    _cache.remove(oldest.key);
    _evictedCount++;
  }

  /// Builds a namespaced cache key.
  static String buildKey(CacheDomain domain, String identifier) =>
      '${domain.name}:$identifier';
}
