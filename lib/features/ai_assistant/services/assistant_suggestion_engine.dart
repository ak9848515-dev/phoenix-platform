import '../../ai_context/models/ai_context_snapshot.dart';
import '../models/assistant_response.dart';

/// Generates context-aware navigation suggestions from an [AIContextSnapshot].
///
/// Pure logic — no side effects, no state, no dependencies.
/// Used by [PhoenixAssistantService] to enrich every response.
class AssistantSuggestionEngine {
  const AssistantSuggestionEngine();

  /// Builds relevant suggestions based on the user's current context.
  ///
  /// Always includes top-level navigation, then adds context-specific
  /// suggestions based on active missions, weak skills, and career state.
  List<AssistantSuggestion> buildSuggestions(AIContextSnapshot context) {
    final suggestions = <AssistantSuggestion>[
      // Always-present base suggestions
      const AssistantSuggestion(
        label: 'View Missions',
        route: '/',
        icon: 'rocket_launch',
        description: 'See your active missions',
      ),
      const AssistantSuggestion(
        label: 'Continue Learning',
        route: '/academy',
        icon: 'school',
        description: 'Resume your learning journey',
      ),
    ];

    // Context-specific: active mission
    if (context.mission.currentMission.isNotEmpty) {
      suggestions.add(
        AssistantSuggestion(
          label: 'Resume: ${_truncate(context.mission.currentMission, 30)}',
          route: '/',
          icon: 'play_circle',
          description: context.mission.reason.isNotEmpty
              ? context.mission.reason
              : 'Continue your current mission',
        ),
      );
    }

    // Context-specific: weak skills
    if (context.knowledge.weakSkills.isNotEmpty) {
      final topWeak = context.knowledge.weakSkills.first;
      suggestions.add(
        AssistantSuggestion(
          label: 'Improve: $topWeak',
          route: '/academy',
          icon: 'trending_up',
          description:
              '$topWeak is your weakest area — focus here to grow fastest',
        ),
      );
    }

    // Context-specific: career
    if (context.career.careerReadiness.isNotEmpty) {
      suggestions.add(
        AssistantSuggestion(
          label: 'Career: ${_truncate(context.career.targetRole, 25)}',
          route: '/career',
          icon: 'work',
          description: 'Career readiness: ${context.career.careerReadiness}',
        ),
      );
    }

    // Context-specific: interview readiness
    if (context.career.interviewReadiness < 0.5) {
      suggestions.add(
        const AssistantSuggestion(
          label: 'Practice Interviews',
          route: '/interview',
          icon: 'record_voice_over',
          description: 'Improve your interview readiness',
        ),
      );
    }

    // Context-specific: portfolio
    if (context.portfolio.projectCount < 3) {
      suggestions.add(
        const AssistantSuggestion(
          label: 'Build Portfolio',
          route: '/portfolio',
          icon: 'folder_open',
          description: 'Add projects to strengthen your portfolio',
        ),
      );
    }

    // Context-specific: knowledge DNA
    if (context.knowledge.nodeCount > 0) {
      suggestions.add(
        const AssistantSuggestion(
          label: 'Knowledge Graph',
          route: '/knowledge-dna',
          icon: 'hub',
          description: 'Explore your knowledge connections',
        ),
      );
    }

    return suggestions;
  }

  /// Returns a short greeting suggestion set for new conversations.
  List<AssistantSuggestion> greetingSuggestions(AIContextSnapshot context) {
    final base = <AssistantSuggestion>[
      const AssistantSuggestion(
        label: 'How am I doing?',
        route: '',
        description: 'Get a quick progress overview',
      ),
      const AssistantSuggestion(
        label: 'What should I do next?',
        route: '',
        description: 'Get your top recommendation',
      ),
    ];

    if (context.knowledge.weakSkills.isNotEmpty) {
      base.add(
        AssistantSuggestion(
          label: 'How do I improve ${context.knowledge.weakSkills.first}?',
          route: '',
          description: 'Get learning advice for your weakest area',
        ),
      );
    }

    if (context.career.careerReadiness.isNotEmpty) {
      base.add(
        const AssistantSuggestion(
          label: 'Is my career on track?',
          route: '',
          description: 'Career readiness assessment',
        ),
      );
    }

    return base;
  }

  /// Detects the most likely response type from a user message.
  AssistantResponseType detectIntent(String userMessage) {
    final lower = userMessage.toLowerCase().trim();

    if (_matchesAny(lower, [
      'hello', 'hi', 'hey', 'greeting', 'good morning', 'good afternoon',
      'good evening', 'start', 'help',
    ])) {
      return AssistantResponseType.greeting;
    }

    if (_matchesAny(lower, [
      'progress', 'how am i', 'status', 'stats', 'xp', 'level', 'score',
      'how is my',
    ])) {
      return AssistantResponseType.progress;
    }

    if (_matchesAny(lower, [
      'mission', 'task', 'what should i do', 'what do i do', 'next mission',
      'active mission',
    ])) {
      return AssistantResponseType.mission;
    }

    if (_matchesAny(lower, [
      'skill', 'learn', 'knowledge', 'study', 'lesson', 'course', 'teach',
      'improve my', 'how to',
    ])) {
      return AssistantResponseType.learning;
    }

    if (_matchesAny(lower, [
      'career', 'job', 'resume', 'interview', 'role', 'position',
      'employer', 'hire',
    ])) {
      return AssistantResponseType.career;
    }

    if (_matchesAny(lower, [
      'portfolio', 'project', 'showcase', 'work', 'github', 'repo',
    ])) {
      return AssistantResponseType.portfolio;
    }

    if (_matchesAny(lower, [
      'recommend', 'suggest', 'next', 'focus', 'priority', 'what is important',
      'should i',
    ])) {
      return AssistantResponseType.recommendation;
    }

    if (_matchesAny(lower, [
      'why', 'how does', 'explain', 'insight', 'analyze', 'what does this mean',
    ])) {
      return AssistantResponseType.insight;
    }

    return AssistantResponseType.general;
  }

  bool _matchesAny(String text, List<String> keywords) =>
      keywords.any((kw) => text.contains(kw));

  String _truncate(String s, int maxLen) =>
      s.length <= maxLen ? s : '${s.substring(0, maxLen - 3)}...';
}
