import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/context/models/phoenix_context.dart';
import '../../../core/context/services/context_service.dart';
import '../../../core/omniroute/models/ai_response.dart';
import '../../../core/omniroute/models/ai_task.dart';
import '../../../core/omniroute/services/omniroute_service.dart';
import '../../../core/repository.dart';
import '../../career/services/career_service.dart';
import '../../interview/services/interview_service.dart';
import '../../knowledge_dna/knowledge_dna_service.dart';
import '../../mission_engine/mission_service.dart';
import '../../portfolio/services/portfolio_service.dart';
import '../../progress_engine/progress_service.dart';
import '../../recommendation/services/recommendation_service.dart';
import '../../resume/services/resume_service.dart';
import '../models/chat_message.dart';

/// Orchestrates the Phoenix AI Mentor experience.
///
/// This service is an orchestration layer — it reads from existing platform
/// services (Mission, Progress, KnowledgeDNA, Portfolio, Resume, Career,
/// Interview, Recommendation) and coordinates responses. It does NOT
/// duplicate business logic or make external AI calls.
///
/// Conversation history is persisted through the existing SharedPreferences
/// storage mechanism.
class AIMentorService {
  AIMentorService({required Repository repository})
    : _repository = repository,
      _contextService = ContextService(repository: repository),
      _missionService = MissionService(repository: repository),
      _progressService = ProgressService(repository: repository),
      _knowledgeDnaService = KnowledgeDNAService(repository: repository),
      _portfolioService = PortfolioService(repository: repository),
      _resumeService = ResumeService(repository: repository),
      _careerService = CareerService(repository: repository),
      _interviewService = InterviewService(repository: repository),
      _recommendationService = RecommendationService(repository: repository),
      _omniroute = OmniRouteService();

  final Repository _repository;
  final ContextService _contextService;
  final MissionService _missionService;
  final ProgressService _progressService;
  final KnowledgeDNAService _knowledgeDnaService;
  final PortfolioService _portfolioService;
  final ResumeService _resumeService;
  final CareerService _careerService;
  final InterviewService _interviewService;
  final RecommendationService _recommendationService;
  final OmniRouteService _omniroute;

  static const String _historyKey = 'phx_ai_conversation';

  // ── Conversation History ─────────────────────────────────────────────

  /// Loads persisted conversation history.
  Future<List<ChatMessage>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((item) =>
              ChatMessage.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Persists a list of messages.
  Future<void> saveHistory(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = messages.map((m) => m.toMap()).toList();
    await prefs.setString(_historyKey, json.encode(jsonList));
  }

  /// Clears all conversation history.
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // ── AI Home Data ─────────────────────────────────────────────────────

  /// Returns a personalised greeting string based on time and user context.
  String getGreeting() {
    final hour = DateTime.now().hour;
    final base = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    final identity = _repository.selectedIdentity;
    return '$base, $identity.title';
  }

  /// Returns a daily motivation message based on user context.
  String getMotivation() {
    final progress = _progressService.buildSummary();
    final journey = _repository.journey;
    final stage = _repository.currentJourneyStage;
    final journeyPercent = (journey.completion * 100).round();

    if (journeyPercent < 25) {
      return 'Every journey begins with a single step. '
          'You\'re building momentum on your ${stage.title} stage. '
          'Keep going!';
    }
    if (journeyPercent < 75) {
      return 'You\'ve completed $journeyPercent% of your journey. '
          'Your ${stage.title} stage is progressing well. '
          'Stay consistent!';
    }
    return 'Almost there! You\'re ${(progress.level * 100)}% through your journey. '
        'The finish line is in sight.';
  }

  /// Returns the user's daily focus from the recommendation service.
  String getDailyFocus() {
    final today = _recommendationService.getTodaysFocus();
    return today?.title ?? 'Complete your missions for today';
  }

  // ── Today's Guidance ─────────────────────────────────────────────────

  /// Builds contextual guidance from all existing services.
  AIMentorGuidance buildGuidance() {
    final missionProgress = _missionService.buildProgress();
    final progress = _progressService.buildSummary();
    final knowledge = _knowledgeDnaService.buildAnalysis();
    final portfolio = _portfolioService.buildPortfolio();
    final resume = _resumeService.buildResume();
    final career = _careerService.buildProfile();
    final interview = _interviewService.buildProfile();

    return AIMentorGuidance(
      missionSummary: missionProgress.summary,
      missionCompletion: missionProgress.completionPercentage,
      overallProgress: progress.completionPercentage,
      level: progress.level,
      totalXp: progress.totalXp,
      streak: progress.streaks.daily,
      knowledgeScore: knowledge.knowledgeScore,
      skillStrengths: knowledge.skillStrengths,
      skillWeaknesses: knowledge.skillWeaknesses,
      portfolioScore: portfolio.portfolioScore,
      resumeScore: resume.resumeScore,
      careerScore: career.careerScore,
      jobReadiness: career.jobReadiness,
      interviewReadiness: interview.interviewReadiness,
    );
  }

  // ── Chat ─────────────────────────────────────────────────────────────

  /// Processes a user message and returns an AI mentor response.
  ///
  /// Uses the OmniRoute orchestration layer with the current PhoenixContext
  /// to produce a contextual, mentor-quality response. No external AI calls.
  Future<AIResponse> chat(String userMessage) async {
    final context = _contextService.buildContext();
    final task = AITask(
      id: 'ai-chat-${DateTime.now().millisecondsSinceEpoch}',
      taskType: 'mentor',
      userPrompt: userMessage,
    );

    final response = _omniroute.route(task: task, context: context);

    // Build a contextual mentor response enriched with platform data.
    final mentorContent = _buildMentorResponse(userMessage, context);

    return AIResponse(
      provider: response.provider,
      model: response.model,
      content: mentorContent,
      tokens: response.tokens,
      latency: response.latency,
      costEstimate: response.costEstimate,
      success: true,
    );
  }

  /// Builds a context-aware mentor response without external AI.
  String _buildMentorResponse(String userMessage, PhoenixContext context) {
    final lower = userMessage.toLowerCase();

    if (_matchesIntent(lower, ['progress', 'how am i', 'status', 'stats'])) {
      return _respondProgress(context);
    }
    if (_matchesIntent(lower, ['mission', 'task', 'what should i do'])) {
      return _respondMission(context);
    }
    if (_matchesIntent(lower, ['skill', 'learn', 'knowledge', 'study'])) {
      return _respondKnowledge(context);
    }
    if (_matchesIntent(lower, ['career', 'job', 'interview', 'resume'])) {
      return _respondCareer(context);
    }
    if (_matchesIntent(lower, ['portfolio', 'project', 'showcase'])) {
      return _respondPortfolio(context);
    }
    if (_matchesIntent(lower, ['recommend', 'suggest', 'next', 'focus'])) {
      return _respondRecommendation(context);
    }
    if (_matchesIntent(lower, ['hello', 'hi', 'hey', 'help', 'start'])) {
      return _respondGreeting(context);
    }

    // Default: general encouragement with context.
    return _respondGeneral(context);
  }

  bool _matchesIntent(String lower, List<String> keywords) {
    return keywords.any((keyword) => lower.contains(keyword));
  }

  String _respondProgress(PhoenixContext context) {
    final p = context.progress;
    final mp = context.missionProgress;
    final totalMissions =
        mp.dailyMissions.length + mp.weeklyMissions.length;
    final completedMissions = mp.completedCount;

    return 'Here is your current progress overview:\n\n'
        '- Level ${p.level} - ${p.totalXp} XP earned\n'
        '- Missions: $completedMissions / $totalMissions completed\n'
        '- Streak: ${p.streaks.daily} days\n'
        '- ${(p.completionPercentage * 100).round()}% overall completion\n\n'
        'You are making consistent progress! Keep up the momentum. '
        'Focus on completing your pending missions to unlock the next stage.';
  }

  String _respondMission(PhoenixContext context) {
    final mp = context.missionProgress;
    final featured = mp.featuredMission;
    final stage = context.currentStage;

    return 'Your current focus should be on ${featured.title}.\n\n'
        '${featured.description}\n\n'
        'You are in the ${stage.title} stage of your journey. '
        'Completing this mission will advance your progress significantly.';
  }

  String _respondKnowledge(PhoenixContext context) {
    final k = context.knowledgeDNA;
    final strengths = k.skillStrengths;
    final weaknesses = k.skillWeaknesses;

    final buf = StringBuffer()
      ..writeln('Your Knowledge DNA shows:\n')
      ..writeln('- Knowledge Score: ${(k.knowledgeScore * 100).round()}%')
      ..writeln('- Confidence: ${(k.confidenceScore * 100).round()}%')
      ..writeln('- Retention: ${(k.retentionScore * 100).round()}%\n');

    if (strengths.isNotEmpty) {
      buf.writeln('Strengths: ${strengths.join(', ')}\n');
    }
    if (weaknesses.isNotEmpty) {
      buf.writeln('Areas to grow: ${weaknesses.join(', ')}\n');
    }

    buf.writeln(
        'Focus on improving your weaker areas through targeted missions. '
        'Your learning velocity is strong -- keep it up!');

    return buf.toString();
  }

  String _respondCareer(PhoenixContext context) {
    final career = context.career;

    return 'Your career readiness is looking solid:\n\n'
        '- ${career.jobReadiness} - '
        'Career score: ${(career.careerScore * 100).round()}%\n'
        '- Next goal: ${career.nextGoal}\n'
        '- Estimated timeline: ${career.estimatedWeeks} weeks\n\n'
        'Keep building your portfolio and practising interviews. '
        'You are on a great trajectory!';
  }

  String _respondPortfolio(PhoenixContext context) {
    final portfolio = _portfolioService.buildPortfolio();

    return 'Your Living Portfolio is taking shape:\n\n'
        '- Score: ${(portfolio.portfolioScore * 100).round()}%\n'
        '- Projects: ${portfolio.projectCount}\n'
        '- Achievements: ${portfolio.achievementCount}\n'
        '- Technologies: ${portfolio.technologyCount}\n\n'
        'Complete more missions to strengthen your portfolio. '
        'Each completed project is a showcase of your growing expertise.';
  }

  String _respondRecommendation(PhoenixContext context) {
    final rec = _recommendationService.getTodaysFocus();
    if (rec == null) {
      return 'All caught up! Complete your current missions and '
          'I will have new recommendations ready for you.';
    }

    return 'Here is what I recommend you focus on:\n\n'
        '${rec.title}\n'
        '${rec.description}\n\n'
        'Why? ${rec.reason}\n\n'
        'Estimated time: ${rec.estimatedDuration} minutes. '
        'This will make a real impact on your progress!';
  }

  String _respondGreeting(PhoenixContext context) {
    final identity = context.selectedIdentity;
    final stage = context.currentStage;

    return 'Welcome! I\'m your Phoenix AI Mentor. '
        'I\'m here to help you become an amazing $identity.title.\n\n'
        'You\'re currently in the ${stage.title} stage of your journey. '
        'Here\'s what I can help you with:\n\n'
        '- Progress - how you\'re tracking\n'
        '- Missions - what to do next\n'
        '- Skills - knowledge insights\n'
        '- Career - readiness and preparation\n'
        '- Portfolio - project showcase\n'
        '- Recommendations - personalised suggestions\n\n'
        'What would you like to explore?';
  }

  String _respondGeneral(PhoenixContext context) {
    final identity = context.selectedIdentity;
    final stage = context.currentStage;
    final rec = _recommendationService.getTodaysFocus();

    final recText = rec != null
        ? 'I would recommend starting with ${rec.title} - '
            'it is your top priority for today.'
        : 'Complete your current missions to unlock new recommendations.';

    return 'As your AI Mentor for the $identity.title path, '
        'here is what I see:\n\n'
        'You are in the ${stage.title} stage '
        '(${(stage.completion * 100).round()}% complete). '
        '$recText\n\n'
        'You can ask me about your progress, missions, skills, '
        'career readiness, portfolio, or anything else. '
        'I am here to help you grow!';
  }
}

/// Structured guidance data built from all existing services.
///
/// Presentation-only — no business logic.
class AIMentorGuidance {
  const AIMentorGuidance({
    required this.missionSummary,
    required this.missionCompletion,
    required this.overallProgress,
    required this.level,
    required this.totalXp,
    required this.streak,
    required this.knowledgeScore,
    required this.skillStrengths,
    required this.skillWeaknesses,
    required this.portfolioScore,
    required this.resumeScore,
    required this.careerScore,
    required this.jobReadiness,
    required this.interviewReadiness,
  });

  final String missionSummary;
  final double missionCompletion;
  final double overallProgress;
  final int level;
  final int totalXp;
  final int streak;
  final double knowledgeScore;
  final List<String> skillStrengths;
  final List<String> skillWeaknesses;
  final double portfolioScore;
  final double resumeScore;
  final double careerScore;
  final String jobReadiness;
  final double interviewReadiness;
}
