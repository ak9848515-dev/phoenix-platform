import '../../../features/academy/services/academy_service.dart';
import '../../../features/habit/services/habit_service.dart';
import '../../../features/timeline/services/timeline_service.dart';
import '../../../features/personal_knowledge/services/knowledge_service.dart';
import '../../../features/decision/services/decision_intelligence_service.dart';
import '../../../features/memory_graph/services/memory_graph_service.dart';
import 'conversation_intent.dart' show ConversationIntent;

/// Snapshot of the user's current state across all platform services.
///
/// Used by the conversation system to provide context-aware responses.
/// Immutable. Created fresh for each conversation turn.
class ConversationContext {
  const ConversationContext({
    this.currentTopic,
    this.recentMessages = const [],
    this.recommendationCount = 0,
    this.activeHabitCount = 0,
    this.lessonInProgress = false,
    this.pendingDecisions = 0,
    this.todaysEvents = 0,
    this.knowledgeNodes = 0,
    this.turnCount = 0,
  });

  /// The topic being discussed in the current conversation segment.
  final ConversationIntent? currentTopic;

  /// Recent message history (last N messages for context window).
  final List<String> recentMessages;

  /// Number of current recommendations.
  final int recommendationCount;

  /// Number of active habits.
  final int activeHabitCount;

  /// Whether there's a lesson in progress.
  final bool lessonInProgress;

  /// Number of decisions pending follow-up.
  final int pendingDecisions;

  /// Number of timeline events today.
  final int todaysEvents;

  /// Number of knowledge graph nodes.
  final int knowledgeNodes;

  /// How many turns in the current conversation.
  final int turnCount;

  /// Whether the user is new to the platform (no data yet).
  bool get isNewUser =>
      activeHabitCount == 0 &&
      !lessonInProgress &&
      knowledgeNodes == 0 &&
      todaysEvents == 0;

  /// Builds a [ConversationContext] from all six platform services.
  static ConversationContext fromServices({
    required AcademyService academyService,
    required HabitService habitService,
    required TimelineService timelineService,
    required KnowledgeService knowledgeService,
    required DecisionIntelligenceService decisionService,
    required MemoryGraphService memoryGraphService,
    List<String> recentMessages = const [],
    ConversationIntent? currentTopic,
    int turnCount = 0,
  }) {
    final analytics = knowledgeService.analytics;
    return ConversationContext(
      currentTopic: currentTopic,
      recentMessages: recentMessages,
      recommendationCount: 0, // populated by ConversationService
      activeHabitCount: habitService.activeHabits.length,
      lessonInProgress: academyService.currentLesson != null,
      pendingDecisions: decisionService.allAnalyses
          .where((a) => a.outcome == null)
          .length,
      todaysEvents: timelineService.todayEvents.length,
      knowledgeNodes: analytics['nodeCount'] as int? ?? 0,
      turnCount: turnCount,
    );
  }

  ConversationContext copyWith({
    ConversationIntent? currentTopic,
    List<String>? recentMessages,
    int? recommendationCount,
    int? activeHabitCount,
    bool? lessonInProgress,
    int? pendingDecisions,
    int? todaysEvents,
    int? knowledgeNodes,
    int? turnCount,
  }) {
    return ConversationContext(
      currentTopic: currentTopic ?? this.currentTopic,
      recentMessages: recentMessages ?? this.recentMessages,
      recommendationCount: recommendationCount ?? this.recommendationCount,
      activeHabitCount: activeHabitCount ?? this.activeHabitCount,
      lessonInProgress: lessonInProgress ?? this.lessonInProgress,
      pendingDecisions: pendingDecisions ?? this.pendingDecisions,
      todaysEvents: todaysEvents ?? this.todaysEvents,
      knowledgeNodes: knowledgeNodes ?? this.knowledgeNodes,
      turnCount: turnCount ?? this.turnCount,
    );
  }
}
