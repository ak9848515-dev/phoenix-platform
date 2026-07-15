import '../models/conversation_context.dart' show ConversationContext;
import '../models/conversation_intent.dart' show ConversationIntent;

/// Pure computation engine for AI mentor conversations.
///
/// [ConversationEngine] provides:
/// - Intent detection from user messages
/// - Context tracking across conversation turns
/// - Follow-up suggestion generation
/// - Multi-turn conversation support
/// - Context window management
///
/// **Architecture Rules:**
/// - Pure computation — no persistence, no AI APIs
/// - No service access — all data injected via [ConversationContext]
/// - Deterministic — same input always produces same output
class ConversationEngine {
  const ConversationEngine();

  // ── Intent Detection ─────────────────────────────────────────────────

  /// Detects the user's intent from a message text.
  ///
  /// Uses keyword matching against known patterns for each intent.
  /// Returns [ConversationIntent.general] if no specific intent matches.
  (ConversationIntent, double) detectIntent(String message) {
    final lower = message.toLowerCase().trim();

    // Check each intent pattern group
    if (_matchesAny(lower, _greetingPatterns)) {
      return (ConversationIntent.greeting, 0.95);
    }
    if (_matchesAny(lower, _progressPatterns)) {
      return (ConversationIntent.progress, 0.85);
    }
    if (_matchesAny(lower, _recommendationPatterns)) {
      return (ConversationIntent.recommendation, 0.85);
    }
    if (_matchesAny(lower, _learningPatterns)) {
      return (ConversationIntent.learning, 0.85);
    }
    if (_matchesAny(lower, _habitPatterns)) {
      return (ConversationIntent.habit, 0.85);
    }
    if (_matchesAny(lower, _timelinePatterns)) {
      return (ConversationIntent.timeline, 0.80);
    }
    if (_matchesAny(lower, _knowledgePatterns)) {
      return (ConversationIntent.knowledge, 0.80);
    }
    if (_matchesAny(lower, _decisionPatterns)) {
      return (ConversationIntent.decision, 0.80);
    }
    if (_matchesAny(lower, _memoryPatterns)) {
      return (ConversationIntent.memory, 0.75);
    }
    if (_matchesAny(lower, _careerPatterns)) {
      return (ConversationIntent.career, 0.80);
    }
    if (_matchesAny(lower, _explanationPatterns)) {
      return (ConversationIntent.explanation, 0.90);
    }
    if (_matchesAny(lower, _insightPatterns)) {
      return (ConversationIntent.insight, 0.75);
    }
    if (_matchesAny(lower, _planningPatterns)) {
      return (ConversationIntent.planning, 0.70);
    }

    return (ConversationIntent.general, 0.40);
  }

  /// Detects intent with context awareness — considers the previous topic.
  (ConversationIntent, double) detectIntentWithContext(
    String message,
    ConversationIntent? previousTopic,
  ) {
    final (intent, confidence) = detectIntent(message);

    // If confidence is low and we have a previous topic, assume continuity
    if (confidence < 0.5 && previousTopic != null) {
      // Check if this message could be a follow-up to the previous topic
      if (_isFollowUp(message, previousTopic)) {
        return (previousTopic, 0.6);
      }
    }

    return (intent, confidence);
  }

  /// Whether the message looks like a follow-up to the given topic.
  bool _isFollowUp(String message, ConversationIntent topic) {
    final lower = message.toLowerCase().trim();
    final followUpMarkers = [
      'why',
      'how',
      'tell me more',
      'explain',
      'elaborate',
      'what about',
      'and',
      'also',
      'next',
      'continue',
    ];
    return followUpMarkers.any((m) => lower.startsWith(m) || lower.contains(m));
  }

  // ── Follow-up Generation ─────────────────────────────────────────────

  /// Generates context-aware follow-up suggestions based on the detected
  /// intent and current context.
  List<String> generateSuggestions(
    ConversationIntent intent,
    ConversationContext context,
  ) {
    switch (intent) {
      case ConversationIntent.greeting:
        return _greetingFollowUps(context);
      case ConversationIntent.progress:
        return _progressFollowUps(context);
      case ConversationIntent.recommendation:
        return _recommendationFollowUps(context);
      case ConversationIntent.learning:
        return _learningFollowUps(context);
      case ConversationIntent.habit:
        return _habitFollowUps(context);
      case ConversationIntent.timeline:
        return _timelineFollowUps(context);
      case ConversationIntent.knowledge:
        return _knowledgeFollowUps(context);
      case ConversationIntent.decision:
        return _decisionFollowUps(context);
      case ConversationIntent.memory:
        return _memoryFollowUps(context);
      case ConversationIntent.career:
        return _careerFollowUps(context);
      case ConversationIntent.explanation:
        return _explanationFollowUps(context);
      case ConversationIntent.insight:
        return _insightFollowUps(context);
      case ConversationIntent.planning:
        return _planningFollowUps(context);
      case ConversationIntent.general:
        return _generalFollowUps(context);
    }
  }

  /// Selects the top-N suggestions based on context relevance.
  List<String> topSuggestions(
    ConversationIntent intent,
    ConversationContext context, {
    int count = 3,
  }) {
    final all = generateSuggestions(intent, context);
    if (all.length <= count) return all;
    return all.take(count).toList();
  }

  // ── Context Helpers ─────────────────────────────────────────────────

  /// Whether the conversation should switch context based on a new message.
  bool shouldSwitchContext(
    ConversationIntent newIntent,
    ConversationIntent? currentTopic,
  ) {
    if (currentTopic == null) return true;
    if (newIntent == currentTopic) return false;
    // General intent doesn't switch context
    if (newIntent == ConversationIntent.general) return false;
    // Explanation intent doesn't switch context (it elaborates)
    if (newIntent == ConversationIntent.explanation) return false;
    return true;
  }

  // ── Intent Pattern Groups ────────────────────────────────────────────

  static const _greetingPatterns = [
    'hello', 'hi', 'hey', 'good morning', 'good afternoon',
    'good evening', 'yo', 'sup', 'howdy', 'welcome',
    'start', 'begin', 'help',
  ];

  static const _progressPatterns = [
    'how am i doing', 'how am i', 'my progress', 'progress',
    'stats', 'status', 'update', 'my stats', 'show progress',
    'how far', 'xp', 'level', 'score', 'my level',
  ];

  static const _recommendationPatterns = [
    'what should i do', 'recommend', 'suggestion', 'next step',
    'what to do', 'focus on', 'today\'s focus', 'my focus',
    'what\'s next', 'top priority', 'action item',
  ];

  static const _learningPatterns = [
    'learn', 'lesson', 'study', 'course', 'academy',
    'training', 'skill', 'path', 'module', 'resume lesson',
    'continue learning', 'start lesson',
  ];

  static const _habitPatterns = [
    'habit', 'streak', 'routine', 'daily habit',
    'habit summary', 'my habits', 'track habit',
    'consistency', 'habit progress',
  ];

  static const _timelinePatterns = [
    'timeline', 'events', 'what happened', 'activity',
    'history', 'recent', 'this week', 'today',
    'milestone', 'achievement', 'calendar',
  ];

  static const _knowledgePatterns = [
    'knowledge', 'knowledge graph', 'dna', 'skills',
    'my skills', 'strengths', 'weaknesses', 'gaps',
    'knowledge node', 'domain', 'expertise',
  ];

  static const _decisionPatterns = [
    'decision', 'outcome', 'follow up', 'pending decision',
    'decision history', 'my decisions', 'choices',
  ];

  static const _memoryPatterns = [
    'memory', 'remember', 'graph', 'entity', 'cluster',
    'connection', 'relationship', 'memory graph',
  ];

  static const _careerPatterns = [
    'career', 'job', 'interview', 'resume', 'portfolio',
    'job readiness', 'professional', 'work',
  ];

  static const _explanationPatterns = [
    'why', 'explain', 'reason', 'how come', 'what does this mean',
    'tell me why', 'elaborate', 'clarify', 'break down',
  ];

  static const _insightPatterns = [
    'insight', 'risk', 'opportunity', 'improve',
    'what should i improve', 'weakness', 'growth',
    'pattern', 'trend', 'analysis',
  ];

  static const _planningPatterns = [
    'plan', 'schedule', 'remind', 'set', 'create',
    'goals', 'target', 'objective',
  ];

  bool _matchesAny(String text, List<String> patterns) {
    return patterns.any((p) {
      var searchFrom = 0;
      while (true) {
        final index = text.indexOf(p, searchFrom);
        if (index == -1) return false;
        // Check word boundary before the match
        // This prevents short patterns like 'hi' matching inside 'this'
        if (index == 0 || !_isWordChar(text[index - 1])) {
          return true;
        }
        // Move search position forward to find next occurrence
        searchFrom = index + 1;
      }
    });
  }

  static bool _isWordChar(String ch) {
    final code = ch.codeUnitAt(0);
    return (code >= 97 && code <= 122) || // a-z
        (code >= 48 && code <= 57); // 0-9
  }

  // ── Follow-up Suggestion Templates ───────────────────────────────────

  List<String> _greetingFollowUps(ConversationContext context) {
    if (context.isNewUser) {
      return [
        'What can you help me with?',
        'Show me around the platform',
        'How do I get started?',
      ];
    }
    return [
      'What should I focus on today?',
      'How am I progressing?',
      'Any recommendations for me?',
    ];
  }

  List<String> _progressFollowUps(ConversationContext context) => [
    'What should I work on next?',
    'How can I improve my stats?',
    'Show me my recommendations',
  ];

  List<String> _recommendationFollowUps(ConversationContext context) => [
    'Why this recommendation?',
    'What are the risks?',
    'Any opportunities I should pursue?',
  ];

  List<String> _learningFollowUps(ConversationContext context) => [
    'What should I learn next?',
    'Any learning paths for me?',
    'How is my learning progress?',
  ];

  List<String> _habitFollowUps(ConversationContext context) => [
    'How do I improve my streak?',
    'Which habits need attention?',
    'Show my habit statistics',
  ];

  List<String> _timelineFollowUps(ConversationContext context) => [
    'What happened this week?',
    'Any upcoming milestones?',
    'Show my timeline',
  ];

  List<String> _knowledgeFollowUps(ConversationContext context) => [
    'What are my strongest skills?',
    'Where should I improve?',
    'Show my knowledge graph',
  ];

  List<String> _decisionFollowUps(ConversationContext context) => [
    'Which decisions need follow-up?',
    'How have my decisions been?',
    'Record a decision outcome',
  ];

  List<String> _memoryFollowUps(ConversationContext context) => [
    'What entities are in my graph?',
    'Any patterns in my connections?',
    'Show my memory graph',
  ];

  List<String> _careerFollowUps(ConversationContext context) => [
    'How job-ready am I?',
    'What skills should I build?',
    'Show my portfolio',
  ];

  List<String> _explanationFollowUps(ConversationContext context) => [
    'What evidence supports this?',
    'What is the confidence level?',
    'What happens if I do this?',
  ];

  List<String> _insightFollowUps(ConversationContext context) => [
    'What risks should I watch for?',
    'Any opportunities I\'m missing?',
    'How do I improve?',
  ];

  List<String> _planningFollowUps(ConversationContext context) => [
    'What should I schedule today?',
    'Set a learning goal',
    'Plan my week',
  ];

  List<String> _generalFollowUps(ConversationContext context) {
    if (context.isNewUser) {
      return [
        'How do I get started?',
        'What features are available?',
        'Show me around',
      ];
    }
    return [
      'How am I doing?',
      'What should I focus on?',
      'Any insights for me?',
    ];
  }

  // ── Response Template Builder ────────────────────────────────────────

  /// Builds a mentor response for the given intent and context.
  /// Returns typed fields: message, confidence, sourceServices, suggestions.
  ({
    String message,
    double confidence,
    List<String> sourceServices,
    List<String> suggestions,
  }) buildResponse(
    ConversationIntent intent,
    ConversationContext context,
  ) {
    switch (intent) {
      case ConversationIntent.greeting:
        return _greetingResponse(context);
      case ConversationIntent.progress:
        return _progressResponse(context);
      case ConversationIntent.recommendation:
        return _recommendationResponse(context);
      case ConversationIntent.learning:
        return _learningResponse(context);
      case ConversationIntent.habit:
        return _habitResponse(context);
      case ConversationIntent.timeline:
        return _timelineResponse(context);
      case ConversationIntent.knowledge:
        return _knowledgeResponse(context);
      case ConversationIntent.decision:
        return _decisionResponse(context);
      case ConversationIntent.memory:
        return _memoryResponse(context);
      case ConversationIntent.career:
        return _careerResponse(context);
      case ConversationIntent.explanation:
        return _explanationResponse(context);
      case ConversationIntent.insight:
        return _insightResponse(context);
      case ConversationIntent.planning:
        return _planningResponse(context);
      case ConversationIntent.general:
        return _generalResponse(context);
    }
  }

  // ── Response Templates ───────────────────────────────────────────────

  ({
    String message,
    double confidence,
    List<String> sourceServices,
    List<String> suggestions,
  }) _greetingResponse(ConversationContext context) {
    if (context.isNewUser) {
      return (
        message: 'Welcome to Phoenix! I\'m your AI mentor. I can help you track '
            'progress, recommend learning paths, manage habits, and discover '
            'insights about your growth. How would you like to get started?',
        confidence: 0.95,
        sourceServices: ['ConversationEngine'],
        suggestions: _greetingFollowUps(context),
      );
    }
    return (
      message: 'Welcome back! I\'ve been tracking your activity. You have '
          '${context.activeHabitCount} active habits'
          '${context.lessonInProgress ? ' and a lesson in progress' : ''}'
          '${context.pendingDecisions > 0 ? ', and ${context.pendingDecisions} decisions awaiting follow-up' : ''}. '
          'What would you like to explore today?',
      confidence: 0.9,
      sourceServices: ['ConversationEngine'],
      suggestions: _greetingFollowUps(context),
    );
  }

  ({
    String message,
    double confidence,
    List<String> sourceServices,
    List<String> suggestions,
  }) _progressResponse(ConversationContext context) {
    return (
      message: 'Here\'s your current snapshot:\n'
          '• ${context.activeHabitCount} active habit${context.activeHabitCount == 1 ? '' : 's'}\n'
          '• ${context.lessonInProgress ? 'A lesson in progress' : 'No active lessons'}\n'
          '• ${context.knowledgeNodes} knowledge node${context.knowledgeNodes == 1 ? '' : 's'}\n'
          '• ${context.todaysEvents} event${context.todaysEvents == 1 ? '' : 's'} today\n'
          '• ${context.pendingDecisions} pending decision follow-up${context.pendingDecisions == 1 ? '' : 's'}\n\n'
          'Keep building momentum — every action compounds!',
      confidence: 0.85,
      sourceServices: ['HabitService', 'AcademyService', 'TimelineService'],
      suggestions: _progressFollowUps(context),
    );
  }

  ({
    String message,
    double confidence,
    List<String> sourceServices,
    List<String> suggestions,
  }) _recommendationResponse(ConversationContext context) {
    if (context.recommendationCount == 0) {
      return (
        message: 'I don\'t have any specific recommendations right now. Continue '
            'with your current activities and I\'ll generate new suggestions based '
            'on your progress. You can also ask me about specific areas like '
            'learning, habits, or career.',
        confidence: 0.7,
        sourceServices: ['ConversationEngine'],
        suggestions: _recommendationFollowUps(context),
      );
    }
    return (
      message: 'You have ${context.recommendationCount} '
          'recommendation${context.recommendationCount == 1 ? '' : 's'} for today. '
          'Check your Intelligence Dashboard for details. Your top areas are: '
          '${context.lessonInProgress ? 'learning' : ''}'
          '${context.lessonInProgress && context.activeHabitCount > 0 ? ', ' : ''}'
          '${context.activeHabitCount > 0 ? 'habits' : ''}'
          '${context.pendingDecisions > 0 ? ', decisions' : ''}.',
      confidence: 0.8,
      sourceServices: ['DailyBriefEngine', 'ConversationEngine'],
      suggestions: _recommendationFollowUps(context),
    );
  }

  ({
    String message,
    double confidence,
    List<String> sourceServices,
    List<String> suggestions,
  }) _learningResponse(ConversationContext context) {
    if (context.lessonInProgress) {
      return (
        message: 'You have a lesson in progress! Continue where you left off to '
            'maintain momentum. Consistent daily learning builds stronger '
            'knowledge retention.',
        confidence: 0.85,
        sourceServices: ['AcademyService'],
        suggestions: _learningFollowUps(context),
      );
    }
    return (
      message: 'No active lessons right now. Starting a new lesson is a great way '
          'to build momentum. Check your Academy for available learning paths '
          'tailored to your goals.',
      confidence: 0.8,
      sourceServices: ['AcademyService'],
      suggestions: _learningFollowUps(context),
    );
  }

  ({
    String message,
    double confidence,
    List<String> sourceServices,
    List<String> suggestions,
  }) _habitResponse(ConversationContext context) {
    if (context.activeHabitCount == 0) {
      return (
        message: 'You don\'t have any active habits yet. Starting with one small '
            'daily habit is the most effective way to build consistency. '
            'Would you like to create one?',
        confidence: 0.85,
        sourceServices: ['HabitService'],
        suggestions: _habitFollowUps(context),
      );
    }
    return (
      message: 'You have ${context.activeHabitCount} active '
          'habit${context.activeHabitCount == 1 ? '' : 's'}. Consistency is key — '
          'even small daily actions compound into significant progress. '
          'Keep up the great work!',
      confidence: 0.85,
      sourceServices: ['HabitService'],
      suggestions: _habitFollowUps(context),
    );
  }

  ({
    String message,
    double confidence,
    List<String> sourceServices,
    List<String> suggestions,
  }) _timelineResponse(ConversationContext context) {
    return (
      message: 'Today you have ${context.todaysEvents} '
          'event${context.todaysEvents == 1 ? '' : 's'} on your timeline. '
          'Reviewing your activity regularly helps you stay aligned with your goals.',
      confidence: 0.8,
      sourceServices: ['TimelineService'],
      suggestions: _timelineFollowUps(context),
    );
  }

  ({
    String message,
    double confidence,
    List<String> sourceServices,
    List<String> suggestions,
  }) _knowledgeResponse(ConversationContext context) {
    if (context.knowledgeNodes == 0) {
      return (
        message: 'Your knowledge graph is empty. Complete missions and decisions '
            'to populate it — each new entry creates connections that reveal '
            'patterns in your learning journey.',
        confidence: 0.8,
        sourceServices: ['KnowledgeService'],
        suggestions: _knowledgeFollowUps(context),
      );
    }
    return (
      message: 'You have ${context.knowledgeNodes} knowledge '
          'node${context.knowledgeNodes == 1 ? '' : 's'} in your graph. Your '
          'knowledge network grows with every completed lesson and decision. '
          'Explore your Knowledge Dashboard for detailed insights.',
      confidence: 0.85,
      sourceServices: ['KnowledgeService'],
      suggestions: _knowledgeFollowUps(context),
    );
  }

  ({
    String message,
    double confidence,
    List<String> sourceServices,
    List<String> suggestions,
  }) _decisionResponse(ConversationContext context) {
    if (context.pendingDecisions == 0) {
      return (
        message: 'All your decisions have recorded outcomes. Great habit! '
            'Recording outcomes builds a valuable decision history that improves '
            'your future choices.',
        confidence: 0.8,
        sourceServices: ['DecisionIntelligenceService'],
        suggestions: _decisionFollowUps(context),
      );
    }
    return (
      message: 'You have ${context.pendingDecisions} '
          'decision${context.pendingDecisions == 1 ? '' : 's'} awaiting follow-up. '
          'Taking 2 minutes to record each outcome builds a valuable decision '
          'history that improves future choices.',
      confidence: 0.8,
      sourceServices: ['DecisionIntelligenceService'],
      suggestions: _decisionFollowUps(context),
    );
  }

  ({
    String message,
    double confidence,
    List<String> sourceServices,
    List<String> suggestions,
  }) _memoryResponse(ConversationContext context) {
    return (
      message: 'Your memory graph captures the connections between all your '
          'activities. Explore it to discover patterns and relationships in your '
          'personal growth journey.',
      confidence: 0.75,
      sourceServices: ['MemoryGraphService'],
      suggestions: _memoryFollowUps(context),
    );
  }

  ({
    String message,
    double confidence,
    List<String> sourceServices,
    List<String> suggestions,
  }) _careerResponse(ConversationContext context) {
    return (
      message: 'Building your career readiness takes consistent effort across '
          'learning, habits, and practical application. Check your Career Dashboard '
          'for your readiness score and recommended next steps.',
      confidence: 0.8,
      sourceServices: ['CareerService'],
      suggestions: _careerFollowUps(context),
    );
  }

  ({
    String message,
    double confidence,
    List<String> sourceServices,
    List<String> suggestions,
  }) _explanationResponse(ConversationContext context) {
    return (
      message: 'I can explain any recommendation in detail — the data sources, '
          'confidence levels, and cross-domain signals that informed it. What would '
          'you like me to explain?',
      confidence: 0.85,
      sourceServices: ['ExplanationEngine'],
      suggestions: _explanationFollowUps(context),
    );
  }

  ({
    String message,
    double confidence,
    List<String> sourceServices,
    List<String> suggestions,
  }) _insightResponse(ConversationContext context) {
    return (
      message: 'Analyzing your current state across all domains, I see '
          'opportunities for growth in your learning consistency and decision '
          'follow-through. Would you like specific insights on any area?',
      confidence: 0.75,
      sourceServices: ['CrossFeatureReasoner'],
      suggestions: _insightFollowUps(context),
    );
  }

  ({
    String message,
    double confidence,
    List<String> sourceServices,
    List<String> suggestions,
  }) _planningResponse(ConversationContext context) {
    return (
      message: 'Planning ahead is a great way to stay on track. Focus on your '
          'current priorities first, then explore what\'s coming next in your '
          'learning journey.',
      confidence: 0.7,
      sourceServices: ['ConversationEngine'],
      suggestions: _planningFollowUps(context),
    );
  }

  ({
    String message,
    double confidence,
    List<String> sourceServices,
    List<String> suggestions,
  }) _generalResponse(ConversationContext context) {
    if (context.isNewUser) {
      return (
        message: 'Welcome! I\'m your Phoenix AI mentor. I can help you with '
            'learning, habits, career planning, and personal growth. What would '
            'you like to explore?',
        confidence: 0.6,
        sourceServices: ['ConversationEngine'],
        suggestions: _generalFollowUps(context),
      );
    }
    return (
      message: 'I\'m here to help you grow! You can ask me about your progress, '
          'recommendations, learning, habits, timeline, knowledge, decisions, or '
          'career readiness. What interests you right now?',
      confidence: 0.6,
      sourceServices: ['ConversationEngine'],
      suggestions: _generalFollowUps(context),
    );
  }
}
