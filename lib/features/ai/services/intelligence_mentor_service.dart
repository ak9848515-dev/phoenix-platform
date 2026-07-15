import '../../academy/services/academy_service.dart';
import '../../habit/services/habit_service.dart';
import '../../timeline/services/timeline_service.dart';
import '../../personal_knowledge/services/knowledge_service.dart';
import '../../decision/services/decision_intelligence_service.dart';
import '../../memory_graph/services/memory_graph_service.dart';
import '../../voice/models/voice_command.dart' show VoiceCommand;
import '../models/mentor_response.dart';
import '../models/mentor_suggestion.dart';
import '../models/mentor_topic.dart';
import 'phoenix_ai_service.dart';

/// Intelligence-powered AI Mentor that produces structured coaching
/// responses from Phoenix platform data.
///
/// [IntelligenceMentorService] consumes [PhoenixAIService] and the six
/// PHX-062 intelligence services to generate [MentorResponse] objects.
///
/// **Responsibilities:**
/// - Daily coaching (todays plan, focus, summary)
/// - Learning mentor (paths, lessons, progress)
/// - Habit mentor (consistency, streaks, insights)
/// - Career mentor (readiness, portfolio alignment)
/// - Decision mentor (outcomes, follow-ups, patterns)
/// - Goal mentor (objectives, progress, milestones)
/// - Voice command routing (natural language → structured response)
///
/// **Architecture Rules:**
/// - Never generates business logic — explains existing intelligence
/// - Consumes services only — no persistence, no AI APIs
/// - All computation delegated to [PhoenixAIService] engines
class IntelligenceMentorService {
  IntelligenceMentorService({
    required this._phoenixAI,
    required this._academyService,
    required this._habitService,
    required this._timelineService,
    required this._knowledgeService,
    required this._decisionService,
    required this._memoryGraphService,
  });

  final PhoenixAIService _phoenixAI;
  final AcademyService _academyService;
  final HabitService _habitService;
  final TimelineService _timelineService;
  final KnowledgeService _knowledgeService;
  final DecisionIntelligenceService _decisionService;
  final MemoryGraphService _memoryGraphService;

  // ── Mentor Topics ───────────────────────────────────────────────────

  /// Daily coaching — today's focus and plan.
  MentorResponse dailyCoaching() {
    final brief = _phoenixAI.generateBrief();
    final suggestions = <MentorSuggestion>[];

    if (brief.recommendations.isNotEmpty) {
      for (final rec in brief.recommendations.take(3)) {
        suggestions.add(MentorSuggestion(
          id: 'coach-${rec.id}',
          topic: MentorTopic.daily,
          title: rec.title,
          description: rec.description ?? '',
          reason: 'Priority ${rec.priority.name}, '
              'confidence ${(rec.confidence * 100).round()}%',
          confidence: rec.confidence,
          isActionable: rec.isActionable,
        ));
      }
    }

    return MentorResponse(
      message: brief.todaysFocus,
      topic: MentorTopic.daily,
      suggestions: suggestions,
      confidence: brief.confidenceScore,
      insightCount: brief.recommendations.length,
    );
  }

  /// Learning mentor — paths, lessons, and progress.
  MentorResponse learningMentor() {
    final brief = _phoenixAI.generateBrief();
    final currentLesson = _academyService.currentLesson;
    final nextLesson = _academyService.nextLesson;
    final activePaths = _academyService.allProgress;

    final suggestions = <MentorSuggestion>[];

    if (currentLesson != null && !currentLesson.state.isFinished) {
      suggestions.add(MentorSuggestion(
        id: 'learning-resume',
        topic: MentorTopic.learning,
        title: 'Resume current lesson',
        description: 'You have an active lesson in progress.',
        confidence: 0.9,
        isActionable: true,
      ));
    }

    if (nextLesson != null) {
      suggestions.add(MentorSuggestion(
        id: 'learning-next',
        topic: MentorTopic.learning,
        title: 'Start next lesson',
        description: 'Your next lesson is ready.',
        confidence: 0.8,
        isActionable: true,
      ));
    }

    final msg = activePaths.isNotEmpty
        ? 'You have ${activePaths.length} learning path'
            '${activePaths.length == 1 ? '' : 's'} in progress. '
            '${brief.learningRecommendation}'
        : 'No active learning paths. '
            '${brief.learningRecommendation}';

    return MentorResponse(
      message: msg,
      topic: MentorTopic.learning,
      suggestions: suggestions,
      confidence: brief.confidenceScore,
      insightCount: suggestions.length,
    );
  }

  /// Habit mentor — consistency, streaks, and insights.
  MentorResponse habitMentor() {
    final brief = _phoenixAI.generateBrief();
    final activeHabits = _habitService.activeHabits;
    final stats = _habitService.allStatistics();

    final suggestions = <MentorSuggestion>[];

    for (final entry in stats.entries.take(3)) {
      final habit = _habitService.getHabit(entry.key);
      final s = entry.value;
      suggestions.add(MentorSuggestion(
        id: 'habit-${entry.key}',
        topic: MentorTopic.habit,
        title: habit?.title ?? 'Habit',
        description: 'Streak: ${s.currentStreak} days, '
            'Rate: ${(s.completionRate * 100).round()}%',
        reason: s.hasStreak
            ? 'On a ${s.currentStreak}-day streak — keep going!'
            : 'Streak at ${s.currentStreak} days — '
                '${s.currentStreak == 0 ? "start today!" : "build momentum!"}',
        confidence: s.habitScore / 100.0,
        isActionable: !s.hasStreak,
      ));
    }

    final msg = activeHabits.isNotEmpty
        ? 'You have ${activeHabits.length} active habits. '
            '${brief.habitInsight}'
        : 'No habits tracked yet. ${brief.habitInsight}';

    return MentorResponse(
      message: msg,
      topic: MentorTopic.habit,
      suggestions: suggestions,
      confidence: brief.confidenceScore,
      insightCount: stats.length,
    );
  }

  /// Decision mentor — outcomes, follow-ups, and patterns.
  MentorResponse decisionMentor() {
    final brief = _phoenixAI.generateBrief();
    final analyses = _decisionService.allAnalyses;
    final pending = analyses.where((a) => a.outcome == null).toList();

    final suggestions = <MentorSuggestion>[];
    if (pending.isNotEmpty) {
      suggestions.add(MentorSuggestion(
        id: 'decision-followup',
        topic: MentorTopic.decision,
        title: 'Record ${pending.length} pending outcome'
            '${pending.length == 1 ? '' : 's'}',
        description: 'Track outcomes to improve future decisions.',
        confidence: 0.8,
        isActionable: true,
      ));
    }

    return MentorResponse(
      message: brief.decisionFollowUp,
      topic: MentorTopic.decision,
      suggestions: suggestions,
      confidence: brief.confidenceScore,
      insightCount: analyses.length,
    );
  }

  /// Goal mentor — objectives, progress, and milestones.
  MentorResponse goalMentor() {
    final brief = _phoenixAI.generateBrief();
    final milestones = _timelineService.milestones;
    final crossResult = _phoenixAI.analyzeCrossFeature();

    final suggestions = <MentorSuggestion>[];
    for (final opp in crossResult.opportunities.take(2)) {
      suggestions.add(MentorSuggestion(
        id: 'goal-${opp.id}',
        topic: MentorTopic.goal,
        title: opp.title,
        description: opp.description,
        reason: 'Estimated impact: ${(opp.estimatedImpact * 100).round()}%',
        confidence: opp.confidence,
        isActionable: opp.estimatedImpact >= 0.6,
      ));
    }

    final msg = milestones.isNotEmpty
        ? 'You have ${milestones.length} milestone'
            '${milestones.length == 1 ? '' : 's'}. '
            '${brief.overallDailySummary}'
        : brief.overallDailySummary;

    return MentorResponse(
      message: msg,
      topic: MentorTopic.goal,
      suggestions: suggestions,
      confidence: brief.confidenceScore,
      insightCount: crossResult.opportunities.length +
          crossResult.insights.length,
    );
  }

  /// Knowledge mentor — knowledge graph exploration.
  MentorResponse knowledgeMentor() {
    final analytics = _knowledgeService.analytics;
    final insights = _knowledgeService.insights;
    final nodeCount = analytics['nodeCount'] as int? ?? 0;

    final suggestions = <MentorSuggestion>[];
    for (final insight in insights.take(3)) {
      suggestions.add(MentorSuggestion(
        id: 'knowledge-${insight.id}',
        topic: MentorTopic.knowledge,
        title: insight.title,
        description: insight.description ?? '',
        confidence: insight.relevance,
      ));
    }

    return MentorResponse(
      message: nodeCount > 0
          ? 'Your knowledge graph has $nodeCount nodes. '
              '${insights.isNotEmpty ? insights.first.title : "Explore your topics to grow it."}'
          : 'Your knowledge graph is empty. Complete activities to populate it.',
      topic: MentorTopic.knowledge,
      suggestions: suggestions,
      confidence: insights.isNotEmpty
          ? insights.first.relevance
          : 0.3,
      insightCount: insights.length,
    );
  }

  /// Memory mentor — graph entities and patterns.
  MentorResponse memoryMentor() {
    final graph = _memoryGraphService.graph;
    final clusters = _memoryGraphService.detectClusters();

    return MentorResponse(
      message: graph.entityCount > 0
          ? 'Your memory graph has ${graph.entityCount} entities '
              'with ${graph.relationCount} relationships. '
              '${clusters.length} cluster${clusters.length == 1 ? '' : 's'} detected.'
          : 'Your memory graph is empty. Complete missions and decisions to populate it.',
      topic: MentorTopic.memory,
      confidence: graph.entityCount > 0 ? 0.8 : 0.3,
      insightCount: graph.entityCount + clusters.length,
    );
  }

  /// Progress mentor — overall momentum and summary.
  MentorResponse progressMentor() {
    final brief = _phoenixAI.generateBrief();
    final crossResult = _phoenixAI.analyzeCrossFeature();
    final graph = _memoryGraphService.graph;

    final totalInsights = crossResult.insights.length +
        crossResult.risks.length +
        crossResult.opportunities.length;

    return MentorResponse(
      message: brief.overallDailySummary,
      topic: MentorTopic.progress,
      confidence: brief.confidenceScore,
      insightCount: brief.recommendations.length + totalInsights +
          graph.entityCount,
    );
  }

  // ── Voice Command Routing ──────────────────────────────────────────

  /// Routes a voice command to the appropriate mentor topic.
  ///
  /// Returns a [MentorResponse] based on the command's intent.
  /// If the intent is not recognized, returns daily coaching.
  MentorResponse respondToCommand(VoiceCommand command) {
    final text = command.transcript.toLowerCase();

    if (_matches(text, ['learn', 'study', 'lesson', 'academy', 'course'])) {
      return learningMentor();
    }
    if (_matches(text, ['habit', 'streak', 'routine', 'daily'])) {
      return habitMentor();
    }
    if (_matches(text, ['decision', 'choose', 'option', 'outcome'])) {
      return decisionMentor();
    }
    if (_matches(text, ['goal', 'milestone', 'objective', 'aim'])) {
      return goalMentor();
    }
    if (_matches(text, ['knowledge', 'know', 'skill', 'expertise'])) {
      return knowledgeMentor();
    }
    if (_matches(text, ['memory', 'graph', 'entity', 'connect', 'map'])) {
      return memoryMentor();
    }
    if (_matches(text, [
      'progress', 'status', 'overview', 'summary', 'track',
      'how am i', 'what did i do',
    ])) {
      return progressMentor();
    }

    // Default: daily coaching for greetings, plans, and general queries
    if (_matches(text, [
      'hello', 'hi', 'hey', 'good morning', 'good afternoon',
      'today', 'plan', 'focus', 'what should i do',
    ])) {
      return dailyCoaching();
    }

    return dailyCoaching();
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  bool _matches(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }
}
