/// All AI providers supported by Phoenix.
///
/// Phoenix never talks directly to any provider.
/// Everything goes through the [AICapabilityRouter].
///
/// Adapters are mock implementations only — no real API calls.
enum AIProvider {
  gemini('Gemini', true, true),
  deepseek('DeepSeek', true, true),
  openAI('OpenAI', true, false),
  claude('Claude', true, false),
  ollama('Ollama', true, true),
  openRouter('OpenRouter', true, true);

  const AIProvider(
    this.displayName,
    this.isAvailable,
    this.supportsOffline,
  );

  /// Human-readable provider name.
  final String displayName;

  /// Whether this provider is currently available for use.
  final bool isAvailable;

  /// Whether this provider supports offline operation.
  final bool supportsOffline;
}
