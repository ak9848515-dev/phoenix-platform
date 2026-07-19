import 'ai_capability.dart';
import 'ai_provider.dart';

/// Configuration for the AI Capability Router.
///
/// Defines the default capability-to-provider mappings,
/// fallback chains, and offline provider preferences.
class AIRouterConfig {
  const AIRouterConfig({
    this.defaultMappings = _kDefaultMappings,
    this.fallbackChain = _kDefaultFallbackChain,
    this.offlineProvider = AIProvider.ollama,
    this.fallbackProvider = AIProvider.openRouter,
    this.enableFallback = true,
  });

  /// Default mapping: capability -> primary provider.
  final Map<AICapability, AIProvider> defaultMappings;

  /// Ordered fallback chain (tried in order after primary fails).
  final List<AIProvider> fallbackChain;

  /// The preferred offline provider.
  final AIProvider offlineProvider;

  /// Global fallback when all providers fail.
  final AIProvider fallbackProvider;

  /// Whether fallback logic is enabled.
  final bool enableFallback;

  /// Creates a copy with overridden fields.
  AIRouterConfig copyWith({
    Map<AICapability, AIProvider>? defaultMappings,
    List<AIProvider>? fallbackChain,
    AIProvider? offlineProvider,
    AIProvider? fallbackProvider,
    bool? enableFallback,
  }) =>
      AIRouterConfig(
        defaultMappings: defaultMappings ?? this.defaultMappings,
        fallbackChain: fallbackChain ?? this.fallbackChain,
        offlineProvider: offlineProvider ?? this.offlineProvider,
        fallbackProvider: fallbackProvider ?? this.fallbackProvider,
        enableFallback: enableFallback ?? this.enableFallback,
      );

  /// Returns the primary provider for a given capability.
  AIProvider providerFor(AICapability capability) =>
      defaultMappings[capability] ?? fallbackProvider;

  /// Capability-to-provider routing optimized for:
  /// - **Reasoning** → Gemini (best analytical reasoning)
  /// - **Coding** → Claude (best code generation)
  /// - **Creative Writing** → OpenAI (best creative output)
  /// - **Offline** → Ollama (local execution)
  /// - **Research** → Gemini (broad knowledge)
  ///
  /// Gemini is the DEFAULT provider for most capabilities.
  static const Map<AICapability, AIProvider> _kDefaultMappings = {
    AICapability.coding: AIProvider.claude,
    AICapability.learning: AIProvider.gemini,
    AICapability.career: AIProvider.gemini,
    AICapability.resume: AIProvider.gemini,
    AICapability.interview: AIProvider.gemini,
    AICapability.research: AIProvider.gemini,
    AICapability.writing: AIProvider.openAI,
    AICapability.reasoning: AIProvider.gemini,
    AICapability.planning: AIProvider.gemini,
    AICapability.image: AIProvider.gemini,
    AICapability.vision: AIProvider.gemini,
    AICapability.speech: AIProvider.gemini,
    AICapability.translation: AIProvider.gemini,
    AICapability.summarization: AIProvider.gemini,
    AICapability.generalChat: AIProvider.gemini,
  };

  static const List<AIProvider> _kDefaultFallbackChain = [
    AIProvider.openRouter,
    AIProvider.ollama,
  ];

  @override
  String toString() =>
      'AIRouterConfig(mappings: ${defaultMappings.length}, '
      'fallbackChain: [${fallbackChain.map((p) => p.name).join(", ")}], '
      'offline: ${offlineProvider.name})';
}
