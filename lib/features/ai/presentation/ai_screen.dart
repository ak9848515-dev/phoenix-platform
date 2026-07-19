import 'package:flutter/material.dart';



import '../../../core/bootstrap.dart';
import '../../../shared/widgets/phoenix_loading_widget.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../routes/app_routes.dart';
import '../../ai_assistant/models/assistant_conversation.dart';
import '../../ai_assistant/services/phoenix_assistant_service.dart';
import '../../recommendation/models/recommendation.dart';
import '../models/chat_message.dart';
import '../widgets/ai_home_header.dart';
import '../widgets/chat_conversation.dart';
import '../widgets/growth_insights_card.dart';
import '../widgets/recommended_action_card.dart';
import '../widgets/suggested_actions.dart';
import '../widgets/todays_guidance_card.dart';

/// The Phoenix AI Mentor Experience — now powered by the full AI pipeline.
class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  PhoenixAssistantService? _assistantService;
  AssistantConversation? _conversation;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _assistantService = AppBootstrap.maybePhoenixAssistantService;
    _initialize();
  }

  Future<void> _initialize() async {
    if (_assistantService == null) {
      setState(() => _initialized = true);
      return;
    }

    try {
      final svc = _assistantService!;
      final conv = await svc.loadConversation();
      _conversation = conv;

      final historyMessages = <ChatMessage>[];
      if (conv != null) {
        for (final msg in conv.messages) {
          historyMessages.add(ChatMessage(
            id: msg.id,
            role: msg.role,
            content: msg.content,
            timestamp: msg.timestamp,
          ));
        }
      }

      if (conv == null || conv.isEmpty) {
        final greetingResponse = await svc.greeting();
        final greetingMsg = ChatMessage(
          id: 'msg-greeting-${DateTime.now().millisecondsSinceEpoch}',
          role: 'assistant',
          content: greetingResponse.message,
          timestamp: greetingResponse.generatedAt,
        );
        historyMessages.add(greetingMsg);

        _conversation = AssistantConversation.createNew();
        _conversation = _conversation!.withMessage(
          AssistantMessage.fromResponse(
            id: greetingMsg.id,
            response: greetingResponse,
          ),
        );
        await svc.saveConversation(_conversation!);
      }

      if (mounted) {
        setState(() {
          _messages = historyMessages;
          _initialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _initialized = true);
      }
    }
  }

  Future<void> _handleSendMessage(String text) async {
    final userMessage = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    );

    _conversation ??= AssistantConversation.createNew();

    setState(() {
      _messages = [..._messages, userMessage];
      _isLoading = true;
      _error = null;
    });

    try {
      final svc = _assistantService!;
      _conversation = _conversation!.withMessage(
        AssistantMessage.user(
          id: userMessage.id,
          content: userMessage.content,
        ),
      );

      final response = await svc.chat(
        userMessage: text,
        conversation: _conversation,
      );

      final aiMessage = ChatMessage(
        id: 'msg-ai-${DateTime.now().millisecondsSinceEpoch}',
        role: 'assistant',
        content: response.message,
        timestamp: response.generatedAt,
      );

      _conversation = _conversation!.withMessage(
        AssistantMessage.fromResponse(
          id: aiMessage.id,
          response: response,
        ),
      );

      await svc.saveConversation(_conversation!);

      setState(() {
        _messages = [..._messages, aiMessage];
        _isLoading = false;
      });
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
    if (!_initialized) {
      return const PhoenixLoadingWidget(
        icon: Icons.auto_awesome_rounded,
        title: 'Preparing Phoenix Assistant...',
        subtitle: 'Loading your context and conversation history.',
      );
    }

    final userStateService = AppBootstrap.maybeUserStateService;
    final growthEngine = AppBootstrap.maybeGrowthEngine;
    final identityEngine = AppBootstrap.maybeIdentityEngine;

    final identitySnap = identityEngine?.snapshot;
    final growthSnap = growthEngine?.snapshot;

    final userName = identitySnap?.currentIdentityTitle ??
        userStateService?.identity?.title ??
        'Phoenix User';
    final currentGoal = identitySnap?.currentGoal ??
        'Begin your journey with Phoenix';
    final level = growthSnap?.currentLevel ?? userStateService?.level ?? 1;
    final totalXp = growthSnap?.totalXp ?? userStateService?.totalXp ?? 0;
    final growthScore = growthSnap?.knowledge.score ?? 0.0;
    final careerScore = growthSnap?.career.score ?? 0.0;
    final portfolioScore = growthSnap?.portfolio.score ?? 0.0;

    final strongestDim = growthSnap?.strongestDimension;
    final weakestDim = growthSnap?.weakestDimension;

    final activeMissions = userStateService?.missions
    .where((m) => !m.isCompleted)
            .toList() ??
        [];
    final missionSummary = activeMissions.isNotEmpty
        ? '${activeMissions.length} active mission${activeMissions.length == 1 ? '' : 's'}'
        : 'No active missions';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AIHomeHeader(
            greeting: _buildGreeting(userName),
            journeyStage: currentGoal,
            dailyFocus: _buildDailyFocus(),
            motivation: _buildMotivation(level, growthScore),
            level: level,
            journeyCompletion: growthScore,
          ),
          SizedBox(height: PhoenixSpacing.lg),
          TodaysGuidanceCard(
            missionSummary: missionSummary,
            missionCompletion: activeMissions.isNotEmpty
                ? activeMissions.where((m) => m.isCompleted).length /
                    activeMissions.length
                : 0.0,
            level: level,
            totalXp: totalXp,
            streak: 0,
            overallProgress: growthScore,
            portfolioScore: portfolioScore,
            resumeScore: careerScore,
            careerScore: careerScore,
            jobReadiness: _buildJobReadiness(careerScore),
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
          RecommendedActionCard(
            recommendation: _buildDefaultRecommendation(),
            onAction: () =>
                Navigator.of(context).pushNamed(AppRoutes.recommendation),
          ),
          SizedBox(height: PhoenixSpacing.lg),
          GrowthInsightsCard(
            knowledgeScore: growthScore,
            skillStrengths: strongestDim != null
                ? [strongestDim.dimension.displayName]
                : [],
            skillWeaknesses: weakestDim != null
                ? [weakestDim.dimension.displayName]
                : [],
            portfolioScore: portfolioScore,
            resumeScore: careerScore,
            interviewReadiness: careerScore,
            careerScore: careerScore,
            jobReadiness: _buildJobReadiness(careerScore),
          ),
          SizedBox(height: PhoenixSpacing.lg),
          SizedBox(
            height: 420,
            child: ChatConversation(
              messages: _messages,
              onSendMessage: _handleSendMessage,
              isLoading: _isLoading,
              error: _error,
              onRetry: _handleRetry,
            ),
          ),
          SizedBox(height: PhoenixSpacing.lg),
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

  String _buildGreeting(String userName) {
    final hour = DateTime.now().hour;
    final base = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    return '$base, $userName';
  }

  String _buildDailyFocus() {
    final recommendationEngine = AppBootstrap.maybeRecommendationEngine;
    final primary = recommendationEngine?.snapshot?.primary;
    return primary?.title ?? 'Complete your missions for today';
  }

  String _buildMotivation(int level, double growthScore) {
    if (growthScore < 0.3) {
      return 'Every journey begins with a single step. '
          'You\'re building momentum. Keep going!';
    }
    if (growthScore < 0.7) {
      return 'You\'ve made solid progress. '
          'Stay consistent and keep building on your strengths.';
    }
    return 'Almost there! You\'re level $level with ${(growthScore * 100).round()}% growth. '
        'The finish line is in sight.';
  }

  Recommendation _buildDefaultRecommendation() {
    final recommendationEngine = AppBootstrap.maybeRecommendationEngine;
    final primary = recommendationEngine?.snapshot?.primary;
    if (primary != null) {
      return Recommendation(
        id: 'rec-${DateTime.now().millisecondsSinceEpoch}',
        title: primary.title,
        description: primary.description.isNotEmpty
            ? primary.description
            : 'Focus on this priority for the best growth impact.',
        type: RecommendationType.learning,
        priority: RecommendationPriority.high,
        estimatedDuration: primary.estimatedDuration > 0
            ? primary.estimatedDuration
            : 30,
        reason: primary.reason.fullExplanation.isNotEmpty
            ? primary.reason.fullExplanation
            : 'This recommendation is based on your current growth data.',
        actionLabel: 'View Details',
      );
    }
    return Recommendation(
      id: 'rec-daily-focus',
      title: 'Complete Your Missions',
      description: 'Stay on track with your active missions and learning paths.',
      type: RecommendationType.mission,
      priority: RecommendationPriority.medium,
      estimatedDuration: 25,
      reason: 'Completing missions consistently builds momentum toward your goals.',
      actionLabel: 'View Missions',
    );
  }

  String _buildJobReadiness(double score) {
    if (score >= 0.8) return 'Ready';
    if (score >= 0.5) return 'Building';
    return 'Exploring';
  }
}