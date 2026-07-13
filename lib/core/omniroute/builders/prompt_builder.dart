import '../../context/models/phoenix_context.dart';
import '../models/ai_task.dart';

/// Builds structured prompts for AI providers from [PhoenixContext] data.
///
/// The builder wraps the user's raw prompt with Phoenix system context —
/// identity, journey, progress, knowledge DNA, etc. — so that the AI model
/// receives the full user picture without needing to fetch it separately.
///
/// Currently this is a foundation; future iterations may add provider-
/// specific formatting, token budgeting, and context window management.
class PromptBuilder {
  const PromptBuilder();

  /// Builds a complete system prompt for the given [context] and [task].
  ///
  /// Returns the assembled prompt string ready for submission to the
  /// selected AI provider. For now this is a mocked representation;
  /// provider-specific formatting will be added in later sprints.
  String buildSystemPrompt(PhoenixContext context, AITask task) {
    final identity = context.selectedIdentity;
    final journey = context.journey;
    final stage = context.currentStage;
    final progress = context.progress;
    final knowledge = context.knowledgeDNA;

    return '''
You are an AI mentor for Phoenix, a Personal Growth Operating System.

## User Profile
- Identity: ${identity.title}
- Journey: ${journey.title} (${(journey.completion * 100).round()}% complete)
- Current Stage: ${stage.title} (${(stage.completion * 100).round()}% complete)
- Level: ${progress.level} • XP: ${progress.totalXp}
- Daily Streak: ${progress.streaks.daily} days

## Knowledge DNA
- Knowledge Score: ${(knowledge.knowledgeScore * 100).round()}%
- Confidence: ${(knowledge.confidenceScore * 100).round()}%
- Strengths: ${knowledge.skillStrengths.join(', ')}
- Areas to Improve: ${knowledge.skillWeaknesses.join(', ')}

## Task
Type: ${task.taskType}
User Request: ${task.userPrompt}

## Guidelines
- Be encouraging and specific to the user's progress.
- Reference their identity and journey context when relevant.
- Keep responses actionable and concise.
- Focus on helping them become who they want to become.
''';
  }

  /// Builds a minimal user prompt wrapping the raw input.
  ///
  /// For now this passes through the user prompt as-is. Future sprints
  /// may add task-type-specific prompting (e.g. chain-of-thought
  /// instructions for reasoning tasks, code format requirements for
  /// coding tasks).
  String buildUserPrompt(AITask task) {
    return task.userPrompt;
  }
}
