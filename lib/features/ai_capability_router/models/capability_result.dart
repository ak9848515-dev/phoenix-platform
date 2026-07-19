import 'ai_capability.dart';
import 'ai_provider.dart';
import 'ai_response.dart';

/// The result of routing and executing a capability.
///
/// Wraps the [AIResponse] with routing metadata.
class CapabilityResult {
  const CapabilityResult({
    required this.capability,
    required this.response,
    required this.route,
    this.attemptedProviders = const [],
    this.totalLatencyMs = 0,
  });

  /// The capability that was executed.
  final AICapability capability;

  /// The AI response.
  final AIResponse response;

  /// The route that was used.
  final AIProvider route;

  /// All providers that were attempted (in order).
  final List<AIProvider> attemptedProviders;

  /// Total latency including fallback attempts.
  final int totalLatencyMs;

  /// Whether the request succeeded.
  bool get isSuccess => response.success;

  /// Whether fallback was required.
  bool get fallbackUsed => attemptedProviders.length > 1;

  /// Number of failed attempts before success.
  int get fallbackCount => attemptedProviders.length - 1;

  @override
  String toString() =>
      'CapabilityResult(capability: ${capability.name}, '
      'success: ${response.success}, '
      'route: ${route.name}, '
      'attempts: ${attemptedProviders.length})';
}
