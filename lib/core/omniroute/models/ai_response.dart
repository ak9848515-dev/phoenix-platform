import 'provider.dart';

/// The result of processing an [AITask] through OmniRoute.
///
/// Contains the generated content, metadata about which provider and model
/// were used, token usage, latency, and a cost estimate. The [success] flag
/// indicates whether the task completed without error.
///
/// Currently all responses are mocked — no provider SDKs are integrated.
class AIResponse {
  const AIResponse({
    required this.provider,
    required this.model,
    required this.content,
    required this.tokens,
    required this.latency,
    required this.costEstimate,
    required this.success,
  });

  /// The provider that processed the task.
  final AIProvider provider;

  /// The specific model name (e.g. "gpt-4o", "claude-3-5-sonnet",
  /// "gemini-1.5-pro", "deepseek-coder").
  final String model;

  /// The generated response text.
  final String content;

  /// Total token usage (input + output) for the request.
  final int tokens;

  /// Response latency in milliseconds.
  final int latency;

  /// Estimated cost in USD for this request.
  final double costEstimate;

  /// Whether the task completed successfully.
  final bool success;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIResponse &&
        other.provider == provider &&
        other.model == model &&
        other.content == content &&
        other.tokens == tokens &&
        other.latency == latency &&
        other.costEstimate == costEstimate &&
        other.success == success;
  }

  @override
  int get hashCode => Object.hash(
    provider,
    model,
    content,
    tokens,
    latency,
    costEstimate,
    success,
  );

  @override
  String toString() {
    return 'AIResponse(provider: $provider, model: $model, '
        'tokens: $tokens, latency: ${latency}ms, '
        'cost: \$${costEstimate.toStringAsFixed(6)}, '
        'success: $success)';
  }
}
