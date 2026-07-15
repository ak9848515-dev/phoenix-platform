import 'package:flutter/foundation.dart';

import '../../../features/academy/services/academy_service.dart';
import '../../../features/habit/services/habit_service.dart';
import '../../../features/timeline/services/timeline_service.dart';
import '../../../features/personal_knowledge/services/knowledge_service.dart';
import '../../../features/decision/services/decision_intelligence_service.dart';
import '../../../features/memory_graph/services/memory_graph_service.dart';
import '../engine/conversation_engine.dart' show ConversationEngine;
import '../engine/cross_feature_reasoner.dart' show CrossFeatureReasoner;
import '../engine/daily_brief_engine.dart' show DailyBriefEngine;
import '../engine/explanation_engine.dart' show ExplanationEngine;
import '../models/conversation_context.dart' show ConversationContext;
import '../models/conversation_intent.dart' show ConversationIntent;
import '../models/conversation_message.dart'
    show ConversationMessage, MessageRole;
import '../models/conversation_session.dart'
    show ConversationSession, SessionState;
import '../models/explanation.dart' show Explanation;

/// Orchestrates conversational AI mentor interactions.
///
/// [ConversationService] is an orchestration layer that:
/// 1. Receives user messages
/// 2. Detects intent via [ConversationEngine]
/// 3. Gathers context from all six platform services
/// 4. Routes through existing intelligence (DailyBriefEngine, CrossFeatureReasoner, etc.)
/// 5. Returns structured conversation responses
///
/// **Architecture Rules:**
/// - No duplicated reasoning — all computation delegated to engines
/// - No persistence — conversation history stored ephemerally
/// - No AI APIs — deterministic, uses existing intelligence only
class ConversationService extends ChangeNotifier {
  ConversationService({
    required this._briefEngine,
    required this._crossFeatureEngine,
    required this._explanationEngine,
    required this._academyService,
    required this._habitService,
    required this._timelineService,
    required this._knowledgeService,
    required this._decisionService,
    required this._memoryGraphService,
    ConversationEngine? conversationEngine,
  }) : _conversationEngine = conversationEngine ?? const ConversationEngine();

  final DailyBriefEngine _briefEngine;
  final CrossFeatureReasoner _crossFeatureEngine;
  final ExplanationEngine _explanationEngine;
  final AcademyService _academyService;
  final HabitService _habitService;
  final TimelineService _timelineService;
  final KnowledgeService _knowledgeService;
  final DecisionIntelligenceService _decisionService;
  final MemoryGraphService _memoryGraphService;
  final ConversationEngine _conversationEngine;

  ConversationSession? _currentSession;
  List<Explanation>? _cachedExplanations;

  /// The current conversation session, or `null` if none active.
  ConversationSession? get currentSession => _currentSession;

  /// Whether there is an active conversation.
  bool get hasActiveSession =>
      _currentSession != null && _currentSession!.isActive;

  // ── Session Management ───────────────────────────────────────────────

  /// Starts a new conversation session.
  void startSession() {
    _currentSession = ConversationSession(
      id: 'conv-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );
    _cachedExplanations = _explanationEngine.explainAll();
    notifyListeners();
  }

  /// Ends the current session.
  void endSession() {
    if (_currentSession != null) {
      _currentSession = _currentSession!.withState(SessionState.completed);
      notifyListeners();
    }
  }

  /// Clears the current session.
  void clearSession() {
    _currentSession = null;
    _cachedExplanations = null;
    notifyListeners();
  }

  // ── Message Processing ───────────────────────────────────────────────

  /// Processes a user message and returns a mentor response.
  ///
  /// Flow:
  /// 1. Create user message with detected intent
  /// 2. Build conversation context from services
  /// 3. Route through appropriate engine
  /// 4. Generate mentor response
  /// 5. Generate follow-up suggestions
  /// 6. Return updated session with both messages
  Future<ConversationSession> processMessage(String userMessage) async {
    // Auto-start session if none active
    if (_currentSession == null) {
      startSession();
    }

    var session = _currentSession!;

    // Step 1: Detect intent
    final (intent, confidence) = _conversationEngine.detectIntentWithContext(
      userMessage,
      session.context?.currentTopic,
    );

    // Step 2: Create user message
    final userMsg = ConversationMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}-user',
      role: MessageRole.user,
      content: userMessage,
      intent: intent,
      confidence: confidence,
      timestamp: DateTime.now(),
    );
    session = session.addMessage(userMsg);

    // Step 3: Build context from services
    final context = ConversationContext.fromServices(
      academyService: _academyService,
      habitService: _habitService,
      timelineService: _timelineService,
      knowledgeService: _knowledgeService,
      decisionService: _decisionService,
      memoryGraphService: _memoryGraphService,
      recentMessages: session.messages
          .map((m) => m.content)
          .toList(),
      currentTopic: intent,
      turnCount: session.messageCount,
    );

    // Step 4: Generate response based on intent
    final mentorResponse = await _generateResponse(intent, context, userMessage);
    session = session.addMessage(mentorResponse);

    // Step 5: Update session with new context
    session = session.withContext(context);

    // Step 6: Handle context switching
    if (_conversationEngine.shouldSwitchContext(intent, context.currentTopic)) {
      session = session.withContext(context.copyWith(currentTopic: intent));
    }

    _currentSession = session;
    notifyListeners();
    return session;
  }

  // ── Response Generation ──────────────────────────────────────────────

  Future<ConversationMessage> _generateResponse(
    ConversationIntent intent,
    ConversationContext context,
    String userMessage,
  ) async {
    // Check for explanation requests first
    if (intent == ConversationIntent.explanation) {
      return _handleExplanationRequest(userMessage, context);
    }

    // Check for insight/risk/opportunity requests
    if (intent == ConversationIntent.insight) {
      return _handleInsightRequest(context);
    }

    // Check for recommendation requests
    if (intent == ConversationIntent.recommendation) {
      return _handleRecommendationRequest(context);
    }

    // For all other intents, use the conversation engine's built-in templates
    final response = _conversationEngine.buildResponse(intent, context);

    return ConversationMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}-mentor',
      role: MessageRole.mentor,
      content: response.message,
      intent: intent,
      confidence: response.confidence,
      timestamp: DateTime.now(),
      suggestions: _conversationEngine.topSuggestions(intent, context),
      sourceServices: response.sourceServices,
      actionable: true,
    );
  }

  // ── Explanation Handling ─────────────────────────────────────────────

  ConversationMessage _handleExplanationRequest(
    String userMessage,
    ConversationContext context,
  ) {
    // Find the most relevant recommendation to explain
    _ensureExplanationsLoaded();
    final explanations = _cachedExplanations ?? [];

    if (explanations.isEmpty) {
      return ConversationMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}-mentor',
        role: MessageRole.mentor,
        content: 'I don\'t have any recommendations to explain right now. '
            'Start using the platform and I\'ll be able to explain every suggestion.',
        confidence: 0.8,
        timestamp: DateTime.now(),
        sourceServices: ['ExplanationEngine'],
      );
    }

    // Return the top explanation
    final top = explanations.first;
    final chain = top.reasonChain;
    final evidenceStr = chain.evidence
        .map((e) => '• ${e.statement} (${(e.relevance * 100).round()}% relevant)')
        .join('\n');

    final content = StringBuffer()
      ..writeln('Here\'s my reasoning for "${top.title}":\n')
      ..writeln(top.description)
      ..writeln('\n**Confidence:** ${(top.confidence * 100).round()}%')
      ..writeln('\n**Reasoning steps:**')
      ..writeln(chain.steps
          .asMap()
          .entries
          .map((e) => '${e.key + 1}. ${e.value}')
          .join('\n'))
      ..writeln('\n**Evidence:**\n$evidenceStr');

    return ConversationMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}-mentor',
      role: MessageRole.mentor,
      content: content.toString(),
      confidence: top.confidence,
      explanationId: top.recommendation.id,
      timestamp: DateTime.now(),
      sourceServices: top.sourceDomains,
      suggestions: [
        'What evidence supports this?',
        'What is the confidence level?',
        'What should I do next?',
      ],
      actionable: true,
    );
  }

  // ── Insight Handling ─────────────────────────────────────────────────

  ConversationMessage _handleInsightRequest(ConversationContext context) {
    final crossResult = _crossFeatureEngine.reason();
    final insights = crossResult.insights;
    final risks = crossResult.risks;
    final opportunities = crossResult.opportunities;

    if (!crossResult.hasSignals) {
      return ConversationMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}-mentor',
        role: MessageRole.mentor,
        content: 'I don\'t have enough data to generate insights yet. '
            'Continue using the platform — track habits, complete lessons, '
            'and record decisions. The more data you provide, '
            'the better insights I can offer.',
        confidence: 0.7,
        timestamp: DateTime.now(),
        sourceServices: ['CrossFeatureReasoner'],
        suggestions: ['How do I get started?', 'What should I do first?'],
      );
    }

    final contentBuffer = StringBuffer()
      ..writeln('Here\'s my analysis across your platform:\n');

    if (insights.isNotEmpty) {
      contentBuffer.writeln('**Insights:**');
      for (final i in insights.take(2)) {
        contentBuffer.writeln('• ${i.title} — ${i.description}');
      }
      contentBuffer.writeln();
    }

    if (risks.isNotEmpty) {
      contentBuffer.writeln('**Risks to watch:**');
      for (final r in risks.take(2)) {
        contentBuffer.writeln('• ${r.title} [${r.severity.name.toUpperCase()}]');
      }
      contentBuffer.writeln();
    }

    if (opportunities.isNotEmpty) {
      contentBuffer.writeln('**Opportunities:**');
      for (final o in opportunities.take(2)) {
        contentBuffer.writeln('• ${o.title}');
      }
    }

    return ConversationMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}-mentor',
      role: MessageRole.mentor,
      content: contentBuffer.toString(),
      confidence: 0.8,
      timestamp: DateTime.now(),
      sourceServices: ['CrossFeatureReasoner'],
      suggestions: [
        'What risks should I address first?',
        'Tell me more about these insights',
        'Any opportunities I\'m missing?',
      ],
      actionable: true,
    );
  }

  // ── Recommendation Handling ──────────────────────────────────────────

  ConversationMessage _handleRecommendationRequest(ConversationContext context) {
    final recommendations = _briefEngine.collectRecommendations();
    final top = _briefEngine.topFocus(recommendations);

    if (recommendations.isEmpty) {
      return ConversationMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}-mentor',
        role: MessageRole.mentor,
        content: 'All caught up! Complete your current activities and '
            'I\'ll generate new recommendations. Check back after your '
            'next session.',
        confidence: 0.7,
        timestamp: DateTime.now(),
        sourceServices: ['DailyBriefEngine'],
        suggestions: [
          'How am I doing?',
          'What should I learn next?',
          'Any risks or opportunities?',
        ],
      );
    }

    final topStr = top != null
        ? '\n**Top priority:** ${top.title}\n${top.description ?? ''}\n(confidence: ${(top.confidence * 100).round()}%)'
        : '';

    final recsStr = recommendations
        .take(5)
        .toList()
        .asMap()
        .entries
        .map((e) =>
            '${e.key + 1}. ${e.value.title} [${e.value.priority.name}]')
        .join('\n');

    return ConversationMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}-mentor',
      role: MessageRole.mentor,
      content:
          'I have ${recommendations.length} recommendation${recommendations.length == 1 ? '' : 's'} for you today.'
          '$topStr\n\n**Full list:**\n$recsStr',
      confidence: 0.85,
      timestamp: DateTime.now(),
      sourceServices: ['DailyBriefEngine'],
      suggestions: [
        'Why this recommendation?',
        'Explain the top priority',
        'What are the risks?',
      ],
      actionable: true,
    );
  }

  // ── Lazy Loading ─────────────────────────────────────────────────────

  void _ensureExplanationsLoaded() {
    _cachedExplanations ??= _explanationEngine.explainAll();
  }

  // ── Action Handling ──────────────────────────────────────────────────

  /// Marks a recommendation as completed.
  void markCompleted(String recommendationId) {
    debugPrint('ConversationService: completed $recommendationId');
    _cachedExplanations = null; // Refresh on next request
  }

  /// Dismisses a recommendation.
  void dismiss(String recommendationId) {
    debugPrint('ConversationService: dismissed $recommendationId');
    _cachedExplanations = null;
  }

  /// Sets a reminder for later.
  void remindLater(String recommendationId) {
    debugPrint('ConversationService: remind later for $recommendationId');
  }
}
