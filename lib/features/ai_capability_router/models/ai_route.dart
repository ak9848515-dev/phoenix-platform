import 'ai_capability.dart';
import 'ai_provider.dart';

/// A resolved route from capability to provider.
///
/// Produced by [AICapabilityRouter] during routing.
class AIRoute {
  const AIRoute({
    required this.capability,
    required this.provider,
    this.fallbackProvider,
    this.confidence = 1.0,
    this.reason = '',
  });

  /// The capability to execute.
  final AICapability capability;

  /// The primary provider selected.
  final AIProvider provider;

  /// Optional fallback provider if primary is unavailable.
  final AIProvider? fallbackProvider;

  /// Confidence in this route (0.0–1.0).
  final double confidence;

  /// Human-readable reason for this route selection.
  final String reason;

  /// Whether a fallback is configured.
  bool get hasFallback => fallbackProvider != null;

  @override
  String toString() =>
      'AIRoute(capability: ${capability.name} -> '
      '${provider.name}${hasFallback ? ' (fallback: ${fallbackProvider!.name})' : ''}, '
      'confidence: $confidence)';
}
