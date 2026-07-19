import '../../../../shared/infrastructure/logging/phoenix_logger.dart';

/// Result of a connection test to an AI provider.
///
/// Contains structured information about provider reachability,
/// latency, authentication status, and any error that occurred.
class ConnectionTestResult {
  const ConnectionTestResult({
    required this.providerId,
    required this.reachable,
    this.latencyMs = 0,
    this.authenticated = false,
    this.errorReason,
  });

  /// The provider that was tested.
  final String providerId;

  /// Whether the provider was reachable.
  final bool reachable;

  /// Response latency in milliseconds (0 if unreachable).
  final int latencyMs;

  /// Whether the stored API key was accepted.
  final bool authenticated;

  /// Human-readable error reason if the test failed.
  final String? errorReason;

  /// Whether the connection test passed.
  bool get isSuccess => reachable && authenticated;

  /// Creates a successful test result.
  factory ConnectionTestResult.success({
    required String providerId,
    int latencyMs = 0,
  }) =>
      ConnectionTestResult(
        providerId: providerId,
        reachable: true,
        latencyMs: latencyMs,
        authenticated: true,
      );

  /// Creates a failure result with an optional reason.
  factory ConnectionTestResult.failure({
    required String providerId,
    bool reachable = false,
    bool authenticated = false,
    String? errorReason,
  }) =>
      ConnectionTestResult(
        providerId: providerId,
        reachable: reachable,
        authenticated: authenticated,
        errorReason: errorReason,
      );

  @override
  String toString() =>
      'ConnectionTestResult(providerId: $providerId, '
      'success: $isSuccess, reachable: $reachable, '
      'latency: ${latencyMs}ms, auth: $authenticated, '
      'error: ${errorReason ?? "none"})';
}

/// Service for testing connectivity to AI providers.
///
/// Simulates connection tests using the mock adapter infrastructure.
/// When real adapters are implemented, this will make actual API
/// calls to verify provider availability.
///
/// No UI. No side effects beyond logging.
class ConnectionTestService {
  ConnectionTestService();

  final PhoenixLogger _logger = PhoenixLogger.shared;

  /// Tests connectivity to a provider.
  ///
  /// [providerId] should match an [AIProvider] enum name.
  /// [apiKey] is optional; if provided, authentication is also checked.
  ///
  /// Currently returns a simulated successful result since all
  /// adapters are mock implementations. When real adapters are
  /// wired in, this will make a lightweight health-check call.
  Future<ConnectionTestResult> testConnection({
    required String providerId,
    String? apiKey,
  }) async {
    _logger.info('Testing connection to: $providerId',
        category: LogCategory.diagnostics,
        source: 'ConnectionTestService');

    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 100));

    // For providers requiring API keys, check if one is provided
    final requiresKey = _providersRequiringKey.contains(providerId);
    if (requiresKey && (apiKey == null || apiKey.isEmpty)) {
      _logger.warning('Connection test failed for $providerId: no API key',
          category: LogCategory.diagnostics,
          source: 'ConnectionTestService');
      return ConnectionTestResult.failure(
        providerId: providerId,
        reachable: false,
        authenticated: false,
        errorReason: 'No API key configured',
      );
    }

    final result = ConnectionTestResult.success(
      providerId: providerId,
      latencyMs: 100,
    );

    _logger.info('Connection test succeeded for $providerId',
        category: LogCategory.diagnostics,
        source: 'ConnectionTestService');
    return result;
  }

  /// Tests connectivity to multiple providers in parallel.
  Future<List<ConnectionTestResult>> testAll(
    List<String> providerIds, {
    Map<String, String?> apiKeys = const {},
  }) async {
    final futures = providerIds.map((id) => testConnection(
          providerId: id,
          apiKey: apiKeys[id],
        ));
    return Future.wait(futures);
  }

  /// Providers that require an API key to operate.
  static const List<String> _providersRequiringKey = [
    'openAI',
    'claude',
    'gemini',
    'deepseek',
    'openRouter',
  ];

  /// Whether a provider requires an API key.
  static bool requiresApiKey(String providerId) =>
      _providersRequiringKey.contains(providerId);
}
