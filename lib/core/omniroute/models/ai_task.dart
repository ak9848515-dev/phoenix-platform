import 'provider.dart';

/// A single AI processing task routed through OmniRoute.
///
/// Describes what the AI should do, under what constraints, and which
/// provider is preferred. OmniRoute uses the capability flags
/// ([requiresReasoning], [requiresCoding], [requiresVision],
/// [requiresSearch]) and [maxTokens] to select the optimal provider
/// when [preferredProvider] is not set.
///
/// No provider SDKs are integrated yet — this is the routing contract only.
class AITask {
  const AITask({
    required this.id,
    required this.taskType,
    required this.userPrompt,
    this.requiresReasoning = false,
    this.requiresCoding = false,
    this.requiresVision = false,
    this.requiresSearch = false,
    this.maxTokens = 4096,
    this.preferredProvider,
  });

  /// Unique identifier for this task.
  final String id;

  /// The type/domain of the task (e.g. "explain", "code", "analyze",
  /// "recommend", "reflect", "summarize").
  final String taskType;

  /// The user's input prompt.
  final String userPrompt;

  /// Whether this task requires advanced reasoning (e.g. chain-of-thought,
  /// complex analysis). Providers like Claude and o1 excel here.
  final bool requiresReasoning;

  /// Whether this task requires code generation or analysis.
  /// DeepSeek-Coder and GPT-4 are strong choices.
  final bool requiresCoding;

  /// Whether this task requires image understanding.
  /// GPT-4o and Gemini Pro Vision support vision inputs.
  final bool requiresVision;

  /// Whether this task requires web search or real-time information.
  /// Future: routes through provider with search grounding.
  final bool requiresSearch;

  /// Maximum output tokens for the response.
  final int maxTokens;

  /// Optional explicit provider preference. When set, OmniRoute will
  /// use this provider regardless of capability routing — unless the
  /// provider cannot handle the task (e.g. vision requested on a
  /// text-only model).
  final AIProvider? preferredProvider;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AITask && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AITask(id: $id, taskType: $taskType, '
        'preferredProvider: $preferredProvider)';
  }
}
