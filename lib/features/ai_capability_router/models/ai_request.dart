import 'ai_capability.dart';
import 'ai_provider.dart';

/// A request to an AI capability.
///
/// Contains everything the router needs to determine the best provider
/// and execute the capability.
class AIRequest {
  const AIRequest({
    required this.capability,
    required this.prompt,
    this.context = const <String, dynamic>{},
    this.temperature = 0.7,
    this.maxTokens = 2048,
    this.attachments = const [],
    this.preferredProvider,
    this.metadata = const <String, dynamic>{},
  });

  /// The AI capability to invoke.
  final AICapability capability;

  /// The user's prompt or instruction.
  final String prompt;

  /// Additional context (identity, growth, mission data, etc.).
  final Map<String, dynamic> context;

  /// Creativity temperature (0.0–1.0).
  final double temperature;

  /// Maximum output tokens.
  final int maxTokens;

  /// Attachments (file paths, URLs, etc.).
  final List<String> attachments;

  /// Preferred provider override.
  final AIProvider? preferredProvider;

  /// Optional metadata for routing.
  final Map<String, dynamic> metadata;

  /// Whether an offline provider is preferred.
  bool get preferOffline =>
      metadata['preferOffline'] == true || metadata['offline'] == true;

  @override
  String toString() =>
      'AIRequest(capability: ${capability.name}, '
      'provider: ${preferredProvider?.name ?? "auto"}, '
      'prompt: "${prompt.length > 50 ? '${prompt.substring(0, 50)}...' : prompt}")';
}
