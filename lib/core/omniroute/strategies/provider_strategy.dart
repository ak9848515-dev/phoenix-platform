import '../models/ai_task.dart';
import '../models/provider.dart';

/// Strategy for selecting an [AIProvider] based on [AITask] requirements.
///
/// Each implementation encapsulates a routing policy. The default
/// [DefaultProviderStrategy] uses capability flags ([requiresReasoning],
/// [requiresCoding], [requiresVision]) to select the best provider,
/// falling back to a sensible default.
///
/// No provider SDKs are integrated yet — this is the routing contract only.
abstract class ProviderStrategy {
  /// Selects the most appropriate [AIProvider] for the given [task].
  ///
  /// Returns the selected provider and a human-readable reason for the
  /// selection.
  ({AIProvider provider, String reason}) selectProvider(AITask task);
}

/// Default provider selection strategy.
///
/// Routing rules:
/// - Vision tasks → Gemini (strong multimodal capabilities)
/// - Coding tasks → DeepSeek (optimised for code)
/// - Reasoning tasks → Claude (best chain-of-thought)
/// - Search tasks → OpenAI (GPT-4 with browsing)
/// - Default → OpenAI (general-purpose)
///
/// When [task.preferredProvider] is set and capable, it is respected.
class DefaultProviderStrategy implements ProviderStrategy {
  const DefaultProviderStrategy();

  @override
  ({AIProvider provider, String reason}) selectProvider(AITask task) {
    // If the user has a preferred provider, use it directly.
    if (task.preferredProvider != null) {
      return (
        provider: task.preferredProvider!,
        reason: 'User-preferred provider: ${task.preferredProvider!.name}',
      );
    }

    // Capability-based routing.
    if (task.requiresVision) {
      return (
        provider: AIProvider.gemini,
        reason:
            'Vision task: Gemini selected for strong multimodal capabilities',
      );
    }

    if (task.requiresCoding) {
      return (
        provider: AIProvider.deepSeek,
        reason: 'Coding task: DeepSeek selected for code-optimised model',
      );
    }

    if (task.requiresReasoning) {
      return (
        provider: AIProvider.claude,
        reason: 'Reasoning task: Claude selected for advanced chain-of-thought',
      );
    }

    if (task.requiresSearch) {
      return (
        provider: AIProvider.openAI,
        reason: 'Search task: OpenAI selected for web-browsing capability',
      );
    }

    // Default fallback.
    return (
      provider: AIProvider.openAI,
      reason: 'General task: OpenAI selected as default provider',
    );
  }
}
