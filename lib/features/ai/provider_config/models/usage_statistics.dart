/// Usage statistics for an AI provider.
///
/// Tracks cumulative usage data used by [HealthMonitor] and
/// [ProviderConfigurationService] for cost awareness and
/// performance monitoring.
///
/// Immutable. Use [copyWith] to produce modified instances.
class UsageStatistics {
  const UsageStatistics({
    this.totalRequests = 0,
    this.totalTokens = 0,
    this.estimatedCost = 0.0,
    this.averageResponseTimeMs = 0.0,
    this.totalFailures = 0,
    this.lastUsed,
  });

  /// Total number of requests made to this provider.
  final int totalRequests;

  /// Total tokens consumed (input + output).
  final int totalTokens;

  /// Estimated total cost in USD.
  final double estimatedCost;

  /// Average response time in milliseconds.
  final double averageResponseTimeMs;

  /// Total number of failed requests.
  final int totalFailures;

  /// Timestamp of the last request.
  final DateTime? lastUsed;

  /// Creates a copy with the given fields replaced.
  UsageStatistics copyWith({
    int? totalRequests,
    int? totalTokens,
    double? estimatedCost,
    double? averageResponseTimeMs,
    int? totalFailures,
    DateTime? lastUsed,
  }) =>
      UsageStatistics(
        totalRequests: totalRequests ?? this.totalRequests,
        totalTokens: totalTokens ?? this.totalTokens,
        estimatedCost: estimatedCost ?? this.estimatedCost,
        averageResponseTimeMs:
            averageResponseTimeMs ?? this.averageResponseTimeMs,
        totalFailures: totalFailures ?? this.totalFailures,
        lastUsed: lastUsed ?? this.lastUsed,
      );

  /// Records a new request with the given latency and token count.
  ///
  /// Returns a new [UsageStatistics] with updated averages.
  UsageStatistics recordRequest({
    required int latencyMs,
    required int tokens,
    double cost = 0.0,
    bool isFailure = false,
  }) {
    final newTotalRequests = totalRequests + 1;
    final newTotalFailures = totalFailures + (isFailure ? 1 : 0);
    final newTotalTokens = totalTokens + tokens;
    final newEstimatedCost = estimatedCost + cost;

    // Running average
    final newAvgLatency = totalRequests > 0
        ? ((averageResponseTimeMs * totalRequests) + latencyMs) /
            newTotalRequests
        : latencyMs.toDouble();

    return UsageStatistics(
      totalRequests: newTotalRequests,
      totalTokens: newTotalTokens,
      estimatedCost: newEstimatedCost,
      averageResponseTimeMs: newAvgLatency,
      totalFailures: newTotalFailures,
      lastUsed: DateTime.now(),
    );
  }

  /// Success rate as a value between 0.0 and 1.0.
  double get successRate =>
      totalRequests > 0
          ? (totalRequests - totalFailures) / totalRequests
          : 1.0;

  /// Average tokens per request.
  double get avgTokensPerRequest =>
      totalRequests > 0 ? totalTokens / totalRequests : 0.0;

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toMap() => {
        'totalRequests': totalRequests,
        'totalTokens': totalTokens,
        'estimatedCost': estimatedCost,
        'averageResponseTimeMs': averageResponseTimeMs,
        'totalFailures': totalFailures,
        'lastUsed': lastUsed?.toIso8601String(),
      };

  /// Deserializes from a JSON-compatible map.
  factory UsageStatistics.fromMap(Map<String, dynamic> map) =>
      UsageStatistics(
        totalRequests: map['totalRequests'] as int? ?? 0,
        totalTokens: map['totalTokens'] as int? ?? 0,
        estimatedCost: (map['estimatedCost'] as num?)?.toDouble() ?? 0.0,
        averageResponseTimeMs:
            (map['averageResponseTimeMs'] as num?)?.toDouble() ?? 0.0,
        totalFailures: map['totalFailures'] as int? ?? 0,
        lastUsed: map['lastUsed'] != null
            ? DateTime.parse(map['lastUsed'] as String)
            : null,
      );

  @override
  String toString() =>
      'UsageStatistics(requests: $totalRequests, '
      'tokens: $totalTokens, cost: \$${estimatedCost.toStringAsFixed(4)}, '
      'failures: $totalFailures, successRate: ${(successRate * 100).round()}%)';
}
