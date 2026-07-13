import '../../context/models/phoenix_context.dart';
import '../builders/prompt_builder.dart';
import '../models/ai_response.dart';
import '../models/ai_task.dart';
import '../models/provider.dart';
import '../strategies/provider_strategy.dart';

/// Provider-agnostic AI routing layer for the Phoenix platform.
///
/// OmniRoute takes a [PhoenixContext] and an [AITask], selects the optimal
/// AI provider via the [ProviderStrategy], builds the prompt via
/// [PromptBuilder], and returns a mocked [AIResponse].
///
/// **Current state:** Foundation only. No provider SDKs are integrated.
/// The response is always mocked — no API calls, no networking, no SDKs.
///
/// **Future:** Each [AIProvider] will have a dedicated executor that calls
/// the actual provider API, handles rate limits, retries, and streaming.
class OmniRouteService {
  OmniRouteService({ProviderStrategy? strategy, PromptBuilder? promptBuilder})
    : _strategy = strategy ?? const DefaultProviderStrategy(),
      _promptBuilder = promptBuilder ?? const PromptBuilder();

  final ProviderStrategy _strategy;
  final PromptBuilder _promptBuilder;

  // ─────────────────────────────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────────────────────────────

  /// Routes the given [task] through OmniRoute and returns a response.
  ///
  /// Steps:
  /// 1. Select the optimal provider via [ProviderStrategy]
  /// 2. Build the system prompt from [PhoenixContext]
  /// 3. Return a mocked [AIResponse] (no real API calls yet)
  AIResponse route({required AITask task, required PhoenixContext context}) {
    final selection = _strategy.selectProvider(task);

    final systemPrompt = _promptBuilder.buildSystemPrompt(context, task);
    final userPrompt = _promptBuilder.buildUserPrompt(task);

    return _mockResponse(
      provider: selection.provider,
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Mock response (temporary — no provider SDKs integrated yet)
  // ─────────────────────────────────────────────────────────────────────

  /// Returns a mocked [AIResponse] simulating the selected provider.
  ///
  /// Replace this with real provider calls once SDKs are integrated.
  /// Each provider will have its own executor class.
  AIResponse _mockResponse({
    required AIProvider provider,
    required String systemPrompt,
    required String userPrompt,
  }) {
    final model = _mockModelName(provider);

    return AIResponse(
      provider: provider,
      model: model,
      content: _mockContent(systemPrompt, userPrompt, provider),
      tokens: _mockTokens(userPrompt),
      latency: _mockLatency(provider),
      costEstimate: _mockCost(provider),
      success: true,
    );
  }

  /// Returns a realistic model name for the given provider.
  String _mockModelName(AIProvider provider) {
    return switch (provider) {
      AIProvider.openAI => 'gpt-4o',
      AIProvider.claude => 'claude-3-5-sonnet',
      AIProvider.gemini => 'gemini-1.5-pro',
      AIProvider.deepSeek => 'deepseek-coder-v2',
      AIProvider.local => 'llama-3.1-8b',
    };
  }

  /// Returns a mocked response content.
  String _mockContent(
    String systemPrompt,
    String userPrompt,
    AIProvider provider,
  ) {
    return '[Mocked ${provider.name} response]\n\n'
        'System context prepared. '
        'User prompt received: "${userPrompt.length > 50 ? '${userPrompt.substring(0, 50)}...' : userPrompt}"\n\n'
        'This is a placeholder response. '
        'Provider SDK integration will replace this with real AI output.';
  }

  /// Returns a mocked token count.
  int _mockTokens(String userPrompt) =>
      (systemPromptEstimate +
      userPrompt.split(' ').length * 2 +
      estimatedOutputTokens);

  /// Estimated system prompt tokens (rough approximation).
  int get systemPromptEstimate => 400;

  /// Estimated output tokens (rough approximation).
  int get estimatedOutputTokens => 512;

  /// Returns a mocked latency in milliseconds.
  int _mockLatency(AIProvider provider) {
    return switch (provider) {
      AIProvider.openAI => 1200,
      AIProvider.claude => 1800,
      AIProvider.gemini => 900,
      AIProvider.deepSeek => 1500,
      AIProvider.local => 3000,
    };
  }

  /// Returns a mocked cost estimate in USD.
  double _mockCost(AIProvider provider) {
    return switch (provider) {
      AIProvider.openAI => 0.0035,
      AIProvider.claude => 0.0040,
      AIProvider.gemini => 0.0025,
      AIProvider.deepSeek => 0.0015,
      AIProvider.local => 0.0001,
    };
  }
}
