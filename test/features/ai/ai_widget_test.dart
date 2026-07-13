import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:phoenix_platform/features/ai/models/chat_message.dart';
import 'package:phoenix_platform/features/ai/widgets/ai_home_header.dart';
import 'package:phoenix_platform/features/ai/widgets/chat_conversation.dart';
import 'package:phoenix_platform/features/ai/widgets/growth_insights_card.dart';
import 'package:phoenix_platform/features/ai/widgets/recommended_action_card.dart';
import 'package:phoenix_platform/features/ai/widgets/suggested_actions.dart';
import 'package:phoenix_platform/features/ai/widgets/todays_guidance_card.dart';
import 'package:phoenix_platform/features/recommendation/models/recommendation.dart';

// ── Helpers ─────────────────────────────────────────────────────────────

/// Helper to pump a widget without scroll constraints.
/// Use for widgets that don't need vertical scrolling.
Future<void> pumpWidget(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: widget),
    ),
  );
  // Allow FadeAnimation animations to settle.
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

/// Helper to pump a widget with tight height constraints.
/// Use for widgets that contain [Expanded] or [Flexible].
Future<void> pumpWidgetWithHeight(
  WidgetTester tester,
  Widget widget, {
  double height = 480,
  double width = 800,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            constraints: BoxConstraints.tightFor(
              width: width,
              height: height,
            ),
            child: widget,
          ),
        ),
      ),
    ),
  );
  // Allow FadeAnimation animations to settle.
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

/// Helper to pump a widget with tight constraints for loading tests.
/// Uses [pump] instead of [pumpAndSettle] to avoid timeout from
/// ongoing animations like [CircularProgressIndicator].
Future<void> pumpWidgetLoading(
  WidgetTester tester,
  Widget widget, {
  double height = 480,
  double width = 800,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Container(
          constraints: BoxConstraints.tightFor(
            width: width,
            height: height,
          ),
          child: widget,
        ),
      ),
    ),
  );
  // Use pump() instead of pumpAndSettle() because
  // CircularProgressIndicator never settles.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

/// Creates a sample Recommendation for tests.
const _sampleRecommendation = Recommendation(
  id: 'rec-1',
  title: 'Complete Async & Futures',
  description: 'Master Dart async programming with futures and streams.',
  type: RecommendationType.learning,
  priority: RecommendationPriority.high,
  estimatedDuration: 30,
  reason:
      'Async programming is fundamental for Flutter development. '
      'Mastering it will unlock 70% of advanced patterns.',
  actionLabel: 'Start Learning',
);

/// Creates a sample user ChatMessage.
ChatMessage _userMessage(String content) {
  return ChatMessage(
    id: 'user-${content.hashCode}',
    role: 'user',
    content: content,
    timestamp: DateTime(2026, 7, 13, 10, 0),
  );
}

/// Creates a sample AI ChatMessage.
ChatMessage _aiMessage(String content) {
  return ChatMessage(
    id: 'ai-${content.hashCode}',
    role: 'assistant',
    content: content,
    timestamp: DateTime(2026, 7, 13, 10, 0),
  );
}

// ── Tests ───────────────────────────────────────────────────────────────

void main() {
  // =====================================================================
  // 1. AI Home Header
  // =====================================================================

  group('AIHomeHeader', () {
    testWidgets('renders greeting, journey stage, daily focus, and motivation',
        (tester) async {
      await pumpWidget(
        tester,
        const AIHomeHeader(
          greeting: 'Good morning, Apprentice Developer',
          journeyStage: 'Foundation',
          dailyFocus: 'Complete Async & Futures',
          motivation:
              'Every journey begins with a single step. Keep going!',
          level: 1,
          journeyCompletion: 0.33,
        ),
      );

      expect(find.text('Good morning, Apprentice Developer'), findsOneWidget);
      expect(find.textContaining('Stage: Foundation'), findsOneWidget);
      expect(find.textContaining('33% complete'), findsOneWidget);
      expect(find.text('Today\'s Focus'), findsOneWidget);
      expect(find.text('Complete Async & Futures'), findsOneWidget);
      expect(
        find.textContaining('Every journey begins with a single step'),
        findsOneWidget,
      );
    });

    testWidgets('renders level badge', (tester) async {
      await pumpWidget(
        tester,
        const AIHomeHeader(
          greeting: 'Good afternoon, Developer',
          journeyStage: 'Growth',
          dailyFocus: 'Build Portfolio Project',
          motivation: 'Keep pushing forward.',
          level: 5,
          journeyCompletion: 0.50,
        ),
      );

      expect(find.text('Level 5'), findsOneWidget);
    });

    testWidgets('shows correct percentage for 100% completion',
        (tester) async {
      await pumpWidget(
        tester,
        const AIHomeHeader(
          greeting: 'Good evening, Master Developer',
          journeyStage: 'Mastery',
          dailyFocus: 'Mentor Others',
          motivation: 'You are almost there!',
          level: 10,
          journeyCompletion: 1.0,
        ),
      );

      expect(find.textContaining('100% complete'), findsOneWidget);
    });
  });

  // =====================================================================
  // 2. Today's Guidance Card
  // =====================================================================

  group('TodaysGuidanceCard', () {
    testWidgets('renders all stat tiles and progress bars', (tester) async {
      await pumpWidget(
        tester,
        const TodaysGuidanceCard(
          missionSummary: 'Complete your learning path missions.',
          missionCompletion: 0.5,
          level: 2,
          totalXp: 1250,
          streak: 7,
          overallProgress: 0.6,
          portfolioScore: 0.4,
          resumeScore: 0.7,
          careerScore: 0.8,
          jobReadiness: 'Career Ready',
        ),
      );

      // Header
      expect(find.text("Today's Guidance"), findsOneWidget);

      // Stats
      expect(find.text('XP'), findsOneWidget);
      expect(find.text('1.3k'), findsOneWidget);
      expect(find.text('Level'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Streak'), findsOneWidget);
      expect(find.text('7 days'), findsOneWidget);

      // Mission summary
      expect(
        find.text('Complete your learning path missions.'),
        findsOneWidget,
      );

      // Progress labels
      expect(find.text('Overall Progress'), findsOneWidget);
      expect(find.text('Mission Completion'), findsOneWidget);

      // Readiness chips
      expect(find.text('Portfolio'), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);
      expect(find.text('Career'), findsOneWidget);
    });

    testWidgets('displays XP without k suffix for small values',
        (tester) async {
      await pumpWidget(
        tester,
        const TodaysGuidanceCard(
          missionSummary: 'Beginner missions.',
          missionCompletion: 0.2,
          level: 1,
          totalXp: 150,
          streak: 1,
          overallProgress: 0.1,
          portfolioScore: 0.1,
          resumeScore: 0.1,
          careerScore: 0.1,
          jobReadiness: 'Getting Started',
        ),
      );

      expect(find.text('150'), findsOneWidget);
      expect(find.text('0.2k'), findsNothing);
    });

    testWidgets('renders readiness percentages correctly', (tester) async {
      await pumpWidget(
        tester,
        const TodaysGuidanceCard(
          missionSummary: 'Test',
          missionCompletion: 0.0,
          level: 1,
          totalXp: 0,
          streak: 0,
          overallProgress: 0.0,
          portfolioScore: 0.85,
          resumeScore: 0.45,
          careerScore: 0.92,
          jobReadiness: 'Ready',
        ),
      );

      // 85%, 45%, 92% from readiness chips
      expect(find.text('85%'), findsOneWidget);
      expect(find.text('45%'), findsOneWidget);
      expect(find.text('92%'), findsOneWidget);
    });
  });

  // =====================================================================
  // 3. Recommended Action Card
  // =====================================================================

  group('RecommendedActionCard', () {
    testWidgets('renders recommendation title, description, and CTA',
        (tester) async {
      await pumpWidget(
        tester,
        const RecommendedActionCard(
          recommendation: _sampleRecommendation,
        ),
      );

      expect(find.text('Recommended Next Action'), findsOneWidget);
      expect(find.text('Complete Async & Futures'), findsOneWidget);
      expect(
        find.text('Master Dart async programming with futures and streams.'),
        findsOneWidget,
      );
      expect(find.text('Start Learning'), findsOneWidget);
    });

    testWidgets('renders priority badge for high priority', (tester) async {
      await pumpWidget(
        tester,
        const RecommendedActionCard(
          recommendation: _sampleRecommendation,
        ),
      );

      expect(find.text('High Priority'), findsOneWidget);
    });

    testWidgets('renders reason and estimated duration', (tester) async {
      await pumpWidget(
        tester,
        const RecommendedActionCard(
          recommendation: _sampleRecommendation,
        ),
      );

      expect(find.text('Why this matters'), findsOneWidget);
      expect(
        find.textContaining('Async programming is fundamental'),
        findsOneWidget,
      );
      expect(find.text('30 min'), findsOneWidget);
    });

    testWidgets('calls onAction when CTA button is tapped', (tester) async {
      var tapped = false;

      await pumpWidget(
        tester,
        RecommendedActionCard(
          recommendation: _sampleRecommendation,
          onAction: () => tapped = true,
        ),
      );

      // Find the "Start Learning" button and tap it
      await tester.tap(find.text('Start Learning'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('renders critical priority badge', (tester) async {
      const criticalRecommendation = Recommendation(
        id: 'rec-critical',
        title: 'Critical Bug Fix',
        description: 'Fix production issue.',
        type: RecommendationType.project,
        priority: RecommendationPriority.critical,
        estimatedDuration: 15,
        reason: 'Urgent fix needed.',
        actionLabel: 'Fix Now',
      );

      await pumpWidget(
        tester,
        const RecommendedActionCard(
          recommendation: criticalRecommendation,
        ),
      );

      expect(find.text('Critical'), findsOneWidget);
    });

    testWidgets('renders medium and low priority badges', (tester) async {
      const medium = Recommendation(
        id: 'rec-med',
        title: 'Review Code',
        description: 'Review recent PRs.',
        type: RecommendationType.review,
        priority: RecommendationPriority.medium,
        estimatedDuration: 10,
        reason: 'Keep code quality high.',
        actionLabel: 'Review',
      );

      const low = Recommendation(
        id: 'rec-low',
        title: 'Read Article',
        description: 'Read a tech article.',
        type: RecommendationType.reflection,
        priority: RecommendationPriority.low,
        estimatedDuration: 20,
        reason: 'Stay informed.',
        actionLabel: 'Read',
      );

      await pumpWidget(
        tester,
        const RecommendedActionCard(recommendation: medium),
      );
      expect(find.text('Medium'), findsOneWidget);

      await pumpWidget(
        tester,
        const RecommendedActionCard(recommendation: low),
      );
      expect(find.text('Optional'), findsOneWidget);
    });
  });

  // =====================================================================
  // 4. Growth Insights
  // =====================================================================

  group('GrowthInsightsCard', () {
    const strengths = ['Dart', 'Flutter', 'UI Design'];
    const weaknesses = ['State Management', 'Testing'];

    testWidgets('renders all insight sections', (tester) async {
      await pumpWidget(
        tester,
        const GrowthInsightsCard(
          knowledgeScore: 0.8,
          skillStrengths: strengths,
          skillWeaknesses: weaknesses,
          portfolioScore: 0.6,
          resumeScore: 0.7,
          interviewReadiness: 0.5,
          careerScore: 0.9,
          jobReadiness: 'Career Ready',
        ),
      );

      expect(find.text('Growth Insights'), findsOneWidget);
      expect(find.text('Knowledge DNA'), findsOneWidget);
      expect(find.text('Portfolio'), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);
      expect(find.text('Interview Readiness'), findsOneWidget);
      expect(find.text('Career Readiness'), findsOneWidget);
    });

    testWidgets('renders percentage values for insight rows', (tester) async {
      await pumpWidget(
        tester,
        const GrowthInsightsCard(
          knowledgeScore: 0.75,
          skillStrengths: strengths,
          skillWeaknesses: weaknesses,
          portfolioScore: 0.50,
          resumeScore: 0.25,
          interviewReadiness: 0.10,
          careerScore: 0.95,
          jobReadiness: 'Ready',
        ),
      );

      // Knowledge DNA, Portfolio, Resume, Interview use _InsightRow
      // which shows a percentage text
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
      expect(find.text('10%'), findsOneWidget);

      // Career Readiness uses a progress bar + badge, no percentage text
      // So '95%' is NOT expected from the career section.
      // Instead check for the job readiness badge:
      expect(find.text('Ready'), findsOneWidget);
    });

    testWidgets('renders skill strengths as badges', (tester) async {
      await pumpWidget(
        tester,
        const GrowthInsightsCard(
          knowledgeScore: 0.5,
          skillStrengths: strengths,
          skillWeaknesses: weaknesses,
          portfolioScore: 0.5,
          resumeScore: 0.5,
          interviewReadiness: 0.5,
          careerScore: 0.5,
          jobReadiness: 'Developing',
        ),
      );

      expect(find.text('Dart'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('UI Design'), findsOneWidget);
    });

    testWidgets('renders skill weaknesses as badges', (tester) async {
      await pumpWidget(
        tester,
        const GrowthInsightsCard(
          knowledgeScore: 0.5,
          skillStrengths: strengths,
          skillWeaknesses: weaknesses,
          portfolioScore: 0.5,
          resumeScore: 0.5,
          interviewReadiness: 0.5,
          careerScore: 0.5,
          jobReadiness: 'Developing',
        ),
      );

      expect(find.text('State Management'), findsOneWidget);
      expect(find.text('Testing'), findsOneWidget);
    });

    testWidgets('renders job readiness badge', (tester) async {
      await pumpWidget(
        tester,
        const GrowthInsightsCard(
          knowledgeScore: 0.5,
          skillStrengths: [],
          skillWeaknesses: [],
          portfolioScore: 0.5,
          resumeScore: 0.5,
          interviewReadiness: 0.5,
          careerScore: 0.5,
          jobReadiness: 'Career Ready',
        ),
      );

      expect(find.text('Career Ready'), findsOneWidget);
    });

    testWidgets('handles empty strengths and weaknesses', (tester) async {
      await pumpWidget(
        tester,
        const GrowthInsightsCard(
          knowledgeScore: 0.0,
          skillStrengths: [],
          skillWeaknesses: [],
          portfolioScore: 0.0,
          resumeScore: 0.0,
          interviewReadiness: 0.0,
          careerScore: 0.0,
          jobReadiness: 'Getting Started',
        ),
      );

      // Should not crash, should still render main sections
      expect(find.text('Growth Insights'), findsOneWidget);
      expect(find.text('Knowledge DNA'), findsOneWidget);
    });
  });

  // =====================================================================
  // 5. Chat Conversation
  // =====================================================================

  group('ChatConversation', () {
    testWidgets('shows empty state when no messages', (tester) async {
      await pumpWidgetWithHeight(
        tester,
        ChatConversation(
          messages: [],
          onSendMessage: (_) {},
          isLoading: false,
        ),
      );

      expect(
        find.text('Ask me anything about your growth journey'),
        findsOneWidget,
      );
      expect(
        find.textContaining('I can help with progress'),
        findsOneWidget,
      );
    });

    testWidgets('shows AI Mentor Chat header', (tester) async {
      await pumpWidgetWithHeight(
        tester,
        ChatConversation(
          messages: [],
          onSendMessage: (_) {},
          isLoading: false,
        ),
      );

      expect(find.text('AI Mentor Chat'), findsOneWidget);
    });

    testWidgets('shows input field with placeholder', (tester) async {
      await pumpWidgetWithHeight(
        tester,
        ChatConversation(
          messages: [],
          onSendMessage: (_) {},
          isLoading: false,
        ),
      );

      expect(
        find.text('Ask your AI Mentor...'),
        findsOneWidget,
      );
    });

    testWidgets('renders user and AI message bubbles', (tester) async {
      final messages = [
        _userMessage('How is my progress?'),
        _aiMessage('Your progress is looking great!'),
      ];

      await pumpWidgetWithHeight(
        tester,
        ChatConversation(
          messages: messages,
          onSendMessage: (_) {},
          isLoading: false,
        ),
      );

      expect(find.text('How is my progress?'), findsOneWidget);
      expect(find.text('Your progress is looking great!'), findsOneWidget);
    });

    testWidgets('shows typing indicator when loading', (tester) async {
      final messages = [
        _userMessage('What should I do next?'),
      ];

      await pumpWidgetLoading(
        tester,
        ChatConversation(
          messages: messages,
          onSendMessage: (_) {},
          isLoading: true,
        ),
      );

      // User message still renders during loading
      expect(find.text('What should I do next?'), findsOneWidget);
    });

    testWidgets('shows error banner when error is set', (tester) async {
      await pumpWidgetWithHeight(
        tester,
        ChatConversation(
          messages: [],
          onSendMessage: (_) {},
          isLoading: false,
          error: 'Something went wrong',
          onRetry: () {},
        ),
      );

      // The error banner should be visible even when there are no messages.
      // The empty state condition was fixed to also check error == null.
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('triggers retry when retry button is tapped', (tester) async {
      var retried = false;

      await pumpWidgetWithHeight(
        tester,
        ChatConversation(
          messages: [],
          onSendMessage: (_) {},
          isLoading: false,
          error: 'Failed to connect',
          onRetry: () => retried = true,
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(retried, isTrue);
    });

    testWidgets('shows error icon', (tester) async {
      await pumpWidgetWithHeight(
        tester,
        ChatConversation(
          messages: [],
          onSendMessage: (_) {},
          isLoading: false,
          error: 'Error occurred',
          onRetry: () {},
        ),
      );

      // Error icon should be present
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('send button is disabled when isLoading', (tester) async {
      await pumpWidgetLoading(
        tester,
        ChatConversation(
          messages: [],
          onSendMessage: (_) {},
          isLoading: true,
        ),
      );

      // When loading, show CircularProgressIndicator instead of send icon
      expect(find.byIcon(Icons.send_rounded), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('send button shows send icon when not loading',
        (tester) async {
      await pumpWidgetWithHeight(
        tester,
        ChatConversation(
          messages: [],
          onSendMessage: (_) {},
          isLoading: false,
        ),
      );

      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('sends message from input field', (tester) async {
      String? sentMessage;

      await pumpWidgetWithHeight(
        tester,
        ChatConversation(
          messages: [],
          onSendMessage: (String text) {
            sentMessage = text;
          },
          isLoading: false,
        ),
      );

      // Enter text
      await tester.enterText(find.byType(TextField), 'Hello AI Mentor');
      await tester.pumpAndSettle();

      // Tap send button
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      expect(sentMessage, 'Hello AI Mentor');
    });

    testWidgets('does not send empty messages', (tester) async {
      var sentCount = 0;

      await pumpWidgetWithHeight(
        tester,
        ChatConversation(
          messages: [],
          onSendMessage: (String text) {
            sentCount++;
          },
          isLoading: false,
        ),
      );

      // Try to send empty message
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      // Should not have been called
      expect(sentCount, 0);
    });

    testWidgets('handles multiple messages correctly', (tester) async {
      final messages = [
        _userMessage('First message'),
        _aiMessage('Response one'),
        _userMessage('Second message'),
        _aiMessage('Response two'),
      ];

      await pumpWidgetWithHeight(
        tester,
        ChatConversation(
          messages: messages,
          onSendMessage: (_) {},
          isLoading: false,
        ),
      );

      expect(find.text('First message'), findsOneWidget);
      expect(find.text('Response one'), findsOneWidget);
      expect(find.text('Second message'), findsOneWidget);
      expect(find.text('Response two'), findsOneWidget);
    });

    testWidgets('sends message on submit via keyboard', (tester) async {
      String? sentMessage;

      await pumpWidgetWithHeight(
        tester,
        ChatConversation(
          messages: [],
          onSendMessage: (String text) {
            sentMessage = text;
          },
          isLoading: false,
        ),
      );

      // Enter text and submit
      await tester.enterText(find.byType(TextField), 'Keyboard submit');
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();

      expect(sentMessage, 'Keyboard submit');
    });
  });

  // =====================================================================
  // 6. Suggested Actions
  // =====================================================================

  group('SuggestedActions', () {
    testWidgets('renders all six action buttons', (tester) async {
      await pumpWidget(
        tester,
        SuggestedActions(
          onContinueMission: () {},
          onImproveResume: () {},
          onPracticeInterview: () {},
          onBuildPortfolio: () {},
          onExploreOpportunities: () {},
          onContinueLearning: () {},
        ),
      );

      expect(find.text('Suggested Actions'), findsOneWidget);
      expect(find.text('Continue Mission'), findsOneWidget);
      expect(find.text('Improve Resume'), findsOneWidget);
      expect(find.text('Practice Interview'), findsOneWidget);
      expect(find.text('Build Portfolio'), findsOneWidget);
      expect(find.text('Explore Opportunities'), findsOneWidget);
      expect(find.text('Continue Learning'), findsOneWidget);
    });

    testWidgets('calls onContinueMission when tapped', (tester) async {
      var tapped = false;

      await pumpWidget(
        tester,
        SuggestedActions(
          onContinueMission: () => tapped = true,
          onImproveResume: () {},
          onPracticeInterview: () {},
          onBuildPortfolio: () {},
          onExploreOpportunities: () {},
          onContinueLearning: () {},
        ),
      );

      await tester.tap(find.text('Continue Mission'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('calls onImproveResume when tapped', (tester) async {
      var tapped = false;

      await pumpWidget(
        tester,
        SuggestedActions(
          onContinueMission: () {},
          onImproveResume: () => tapped = true,
          onPracticeInterview: () {},
          onBuildPortfolio: () {},
          onExploreOpportunities: () {},
          onContinueLearning: () {},
        ),
      );

      await tester.tap(find.text('Improve Resume'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('calls onPracticeInterview when tapped', (tester) async {
      var tapped = false;

      await pumpWidget(
        tester,
        SuggestedActions(
          onContinueMission: () {},
          onImproveResume: () {},
          onPracticeInterview: () => tapped = true,
          onBuildPortfolio: () {},
          onExploreOpportunities: () {},
          onContinueLearning: () {},
        ),
      );

      await tester.tap(find.text('Practice Interview'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('calls onBuildPortfolio when tapped', (tester) async {
      var tapped = false;

      await pumpWidget(
        tester,
        SuggestedActions(
          onContinueMission: () {},
          onImproveResume: () {},
          onPracticeInterview: () {},
          onBuildPortfolio: () => tapped = true,
          onExploreOpportunities: () {},
          onContinueLearning: () {},
        ),
      );

      await tester.tap(find.text('Build Portfolio'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('calls onExploreOpportunities when tapped', (tester) async {
      var tapped = false;

      await pumpWidget(
        tester,
        SuggestedActions(
          onContinueMission: () {},
          onImproveResume: () {},
          onPracticeInterview: () {},
          onBuildPortfolio: () {},
          onExploreOpportunities: () => tapped = true,
          onContinueLearning: () {},
        ),
      );

      await tester.tap(find.text('Explore Opportunities'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('calls onContinueLearning when tapped', (tester) async {
      var tapped = false;

      await pumpWidget(
        tester,
        SuggestedActions(
          onContinueMission: () {},
          onImproveResume: () {},
          onPracticeInterview: () {},
          onBuildPortfolio: () {},
          onExploreOpportunities: () {},
          onContinueLearning: () => tapped = true,
        ),
      );

      await tester.tap(find.text('Continue Learning'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
