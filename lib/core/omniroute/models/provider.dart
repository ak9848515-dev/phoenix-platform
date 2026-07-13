/// Supported AI providers in the OmniRoute routing layer.
///
/// OmniRoute selects a provider based on the [AITask] requirements and
/// the routing strategy. No provider SDKs are integrated yet; the enum
/// defines the set of supported providers for future integration.
///
/// See [ProviderStrategy] for the selection logic.
enum AIProvider {
  /// OpenAI models (GPT-4, GPT-4o, o1, etc.).
  openAI,

  /// Anthropic Claude models (Claude 3.5 Sonnet, Claude 3 Opus, etc.).
  claude,

  /// Google Gemini models (Gemini 1.5 Pro, Gemini 1.5 Flash, etc.).
  gemini,

  /// DeepSeek models (DeepSeek-V2, DeepSeek-Coder, etc.).
  deepSeek,

  /// Locally-hosted models (Ollama, LM Studio, etc.).
  local,
}
