import 'ai_capability.dart';
import 'ai_provider.dart';

/// The result of executing an AI capability.
///
/// Contains the output, metadata about which provider served it,
/// and any errors that occurred.
class AIResponse {
  const AIResponse({
    required this.provider,
    required this.capability,
    required this.success,
    required this.output,
    this.latencyMs = 0,
    this.estimatedTokens = 0,
    this.fallbackUsed = false,
    this.error,
    this.metadata = const <String, dynamic>{},
  });

  /// The provider that executed this request.
  final AIProvider provider;

  /// The capability that was executed.
  final AICapability capability;

  /// Whether the request was successful.
  final bool success;

  /// The generated output text.
  final String output;

  /// Request latency in milliseconds.
  final int latencyMs;

  /// Estimated tokens used.
  final int estimatedTokens;

  /// Whether a fallback provider was used.
  final bool fallbackUsed;

  /// Error message if unsuccessful.
  final String? error;

  /// Additional response metadata.
  final Map<String, dynamic> metadata;

  /// Create a successful response.
  factory AIResponse.success({
    required AIProvider provider,
    required AICapability capability,
    required String output,
    int latencyMs = 0,
    int estimatedTokens = 0,
    bool fallbackUsed = false,
    Map<String, dynamic> metadata = const {},
  }) =>
      AIResponse(
        provider: provider,
        capability: capability,
        success: true,
        output: output,
        latencyMs: latencyMs,
        estimatedTokens: estimatedTokens,
        fallbackUsed: fallbackUsed,
        metadata: metadata,
      );

  /// Create an error response.
  factory AIResponse.error({
    required AIProvider provider,
    required AICapability capability,
    required String error,
    int latencyMs = 0,
    bool fallbackUsed = false,
  }) =>
      AIResponse(
        provider: provider,
        capability: capability,
        success: false,
        output: '',
        latencyMs: latencyMs,
        fallbackUsed: fallbackUsed,
        error: error,
      );

  @override
  String toString() =>
      'AIResponse(provider: ${provider.name}, '
      'success: $success, latency: ${latencyMs}ms, '
      'error: ${error ?? "none"})';
}
