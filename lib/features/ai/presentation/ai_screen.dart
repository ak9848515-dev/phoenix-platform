import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../shared/widgets/phoenix_loading_widget.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/sample_repository.dart';
import '../../../routes/app_routes.dart';
import '../../recommendation/services/recommendation_service.dart';
import '../models/chat_message.dart';
import '../services/ai_mentor_service.dart';
import '../widgets/ai_home_header.dart';
import '../widgets/chat_conversation.dart';
import '../widgets/growth_insights_card.dart';
import '../widgets/recommended_action_card.dart';
import '../widgets/suggested_actions.dart';
import '../widgets/todays_guidance_card.dart';

/// The Phoenix AI Mentor Experience.
///
/// Presentation-only. All data comes from existing services and the
/// [AIMentorService] orchestration layer. No external AI calls.
///
/// Sections:
/// 1. AI Home Header — greeting, journey stage, daily focus, motivation
/// 2. Today's Guidance — mission, progress, knowledge, portfolio, career
/// 3. Recommended Next Action — top recommendation from RecommendationService
/// 4. Growth Insights — learning, portfolio, resume, interview, career
/// 5. AI Conversation — full chat interface with history
/// 6. Suggested Actions — navigation shortcuts
class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  late final AIMentorService _aiService;
  late final RecommendationService _recommendationService;
  late final SampleRepository _repository;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  bool _historyLoaded = false;

  @override
  void initState() {
    super.initState();
    _repository = const SampleRepository();
    _aiService = AIMentorService(repository: _repository);
    _recommendationService = RecommendationService(repository: _repository);
    _aiService.loadHistory().then((messages) {
      _messages = messages;
      _historyLoaded = true;
      if (mounted) setState(() {});
    });
  }

  // ── Chat handlers ─────────────────────────────────────────────────

  Future<void> _handleSendMessage(String text) async {
    final userMessage = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages = [..._messages, userMessage];
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _aiService.chat(text);

      final aiMessage = ChatMessage(
        id: 'msg-ai-${DateTime.now().millisecondsSinceEpoch}',
        role: 'assistant',
        content: response.content,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages = [..._messages, aiMessage];
        _isLoading = false;
      });

      await _aiService.saveHistory(_messages);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to get response. Please try again.';
      });
    }
  }

  void _handleRetry() {
    if (_messages.isNotEmpty) {
      final lastUserMessage = _messages.lastWhere(
        (m) => m.isUser,
        orElse: () => _messages.last,
      );
      if (lastUserMessage.isUser) {
        _handleSendMessage(lastUserMessage.content);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // All data flows through AIMentorService to avoid duplicating
    // service instantiation. Guidance is the single source for today's data.
    final userStateService = AppBootstrap.maybeUserStateService;
    final guidance = _aiService.buildGuidance();
    final todaysFocus = _recommendationService.getTodaysFocus();

    // Read journey and stage from UserStateService when available,
    // fall back to SampleRepository for backward compatibility.
    final journey = userStateService?.journey ?? _repository.journey;
    final stage = userStateService?.currentJourneyStage ?? _repository.currentJourneyStage;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. AI Home Header ─────────────────────────────────────
          AIHomeHeader(
            greeting: _aiService.getGreeting(),
            journeyStage: stage.title,
            dailyFocus: _aiService.getDailyFocus(),
            motivation: _aiService.getMotivation(),
            level: guidance.level,
            journeyCompletion: journey.completion,
          ),
          SizedBox(height: PhoenixSpacing.lg),

          // ── 2. Today's Guidance ──────────────────────────────────
          TodaysGuidanceCard(
            missionSummary: guidance.missionSummary,
            missionCompletion: guidance.missionCompletion,
            level: guidance.level,
            totalXp: guidance.totalXp,
            streak: guidance.streak,
            overallProgress: guidance.overallProgress,
            portfolioScore: guidance.portfolioScore,
            resumeScore: guidance.resumeScore,
            careerScore: guidance.careerScore,
            jobReadiness: guidance.jobReadiness,
            onXpTap: () => Navigator.of(context).pushNamed(
              AppRoutes.progress,
              arguments: {'focus': 'xp'},
            ),
            onLevelTap: () => Navigator.of(context).pushNamed(
              AppRoutes.progress,
              arguments: {'focus': 'level'},
            ),
            onStreakTap: () => Navigator.of(context).pushNamed(
              AppRoutes.progress,
              arguments: {'focus': 'streak'},
            ),
          ),
          SizedBox(height: PhoenixSpacing.lg),

          // ── 3. Recommended Next Action ───────────────────────────
          if (todaysFocus != null)
            RecommendedActionCard(
              recommendation: todaysFocus,
              onAction: () =>
                  Navigator.of(context).pushNamed(AppRoutes.recommendation),
            ),
          SizedBox(height: PhoenixSpacing.lg),

          // ── 4. Growth Insights ───────────────────────────────────
          GrowthInsightsCard(
            knowledgeScore: guidance.knowledgeScore,
            skillStrengths: guidance.skillStrengths,
            skillWeaknesses: guidance.skillWeaknesses,
            portfolioScore: guidance.portfolioScore,
            resumeScore: guidance.resumeScore,
            interviewReadiness: guidance.interviewReadiness,
            careerScore: guidance.careerScore,
            jobReadiness: guidance.jobReadiness,
          ),
          SizedBox(height: PhoenixSpacing.lg),

          // ── 5. AI Conversation ───────────────────────────────────
          SizedBox(
            height: 420,
            child: _historyLoaded
                ? ChatConversation(
                    messages: _messages,
                    onSendMessage: _handleSendMessage,
                    isLoading: _isLoading,
                    error: _error,
                    onRetry: _handleRetry,
                  )
                : const PhoenixLoadingWidget(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Preparing AI Mentor...',
                    subtitle: 'Loading conversation history.',
                  ),
          ),
          SizedBox(height: PhoenixSpacing.lg),

          // ── 6. Suggested Actions ─────────────────────────────────
          SuggestedActions(
            onContinueMission: () =>
                Navigator.of(context).pushNamed(AppRoutes.missionCenter),
            onImproveResume: () =>
                Navigator.of(context).pushNamed(AppRoutes.resume),
            onPracticeInterview: () =>
                Navigator.of(context).pushNamed(AppRoutes.interview),
            onBuildPortfolio: () =>
                Navigator.of(context).pushNamed(AppRoutes.portfolio),
            onExploreOpportunities: () =>
                Navigator.of(context).pushNamed(AppRoutes.opportunity),
            onContinueLearning: () =>
                Navigator.of(context).pushNamed(AppRoutes.academy),
          ),
          SizedBox(height: PhoenixSpacing.xxl),
        ],
      ),
    );
  }
}
