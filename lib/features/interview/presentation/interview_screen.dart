import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/phoenix_empty_state.dart';
import '../../../shared/widgets/phoenix_loading_widget.dart';
import '../../../theme/spacing.dart';
import '../intelligence/models/interview_enums.dart';
import '../widgets/interview_actions_card.dart';
import '../widgets/interview_ai_coach_card.dart';
import '../widgets/interview_header.dart';
import '../widgets/interview_recommendations_card.dart';
import '../widgets/interview_session_history_card.dart';
import '../widgets/interview_statistics_card.dart';
import '../widgets/interview_weak_topics_card.dart';
import '../widgets/readiness_card.dart';

/// The Interview Intelligence screen prepares users for real interviews.
///
/// All data is derived from the [InterviewIntelligenceEngine] snapshot —
/// no SampleRepository, no AI, no networking.
///
/// Presentation only. StatelessWidget.
class InterviewScreen extends StatelessWidget {
  const InterviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final interviewEngine = AppBootstrap.maybeInterviewIntelligenceEngine;
    final snap = interviewEngine?.snapshot;
    final identityEngine = AppBootstrap.maybeIdentityEngine;
    final identitySnap = identityEngine?.snapshot;

    if (snap == null) {
      return const PhoenixLoadingWidget(
        icon: Icons.record_voice_over_rounded,
        title: 'Loading interview insights?',
        subtitle: 'Preparing your personalized interview preparation',
      );
    }

    final identityTitle = identitySnap?.currentIdentityTitle ?? 'Phoenix User';

    if (!snap.hasData) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            InterviewHeader(
              identityTitle: identityTitle,
              interviewReadiness: snap.readiness.overall,
              estimatedPreparationDays: 30,
            ),
            const SizedBox(height: AppSpacing.xl),
            PhoenixEmptyState(
              icon: Icons.record_voice_over_outlined,
              title: 'Start Your Interview Prep',
              message: 'Complete your first mock interview session to get '
                  'personalized readiness insights, weak topic detection, '
                  'and AI-powered coaching recommendations.',
              positiveMessage: 'Your journey to interview confidence starts here',
              primaryAction: FilledButton.icon(
                onPressed: () => _startPractice(context, interviewEngine!),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Start Practice'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            InterviewActionsCard(
              onDashboard: () =>
                  Navigator.of(context).pushNamed(AppRoutes.dashboard),
              onResume: () => Navigator.of(context).pushNamed(AppRoutes.resume),
              onCareer: () => Navigator.of(context).pushNamed(AppRoutes.career),
              onPortfolio: () =>
                  Navigator.of(context).pushNamed(AppRoutes.portfolio),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER
          InterviewHeader(
            identityTitle: identityTitle,
            interviewReadiness: snap.readiness.overall,
            estimatedPreparationDays: 30,
          ),
          const SizedBox(height: AppSpacing.lg),

          // 2. STATISTICS
          InterviewStatisticsCard(
            questionCount: snap.progress.totalSessions,
            estimatedPreparationDays: 30,
            interviewReadiness: snap.readiness.overall,
            completedSessions: snap.progress.completedSessions,
            averageScore: snap.progress.averageScore,
            weakTopicCount: snap.weakTopics.length,
          ),
          const SizedBox(height: AppSpacing.lg),

          // 3. READINESS BREAKDOWN
          ReadinessCard(
            technicalScore: snap.readiness.knowledgeScore,
            behavioralScore: snap.readiness.careerReadinessScore,
            communicationScore: snap.readiness.confidenceScore,
          ),
          const SizedBox(height: AppSpacing.lg),

          // 4. AI COACH SUMMARY
          if (snap.aiCoachSummary.isNotEmpty) ...[
            InterviewAICoachCard(
              summary: snap.aiCoachSummary,
              nextBestAction: snap.nextBestAction,
              readinessScore: snap.readiness.overall,
              onStartPractice: () => _startPractice(context, interviewEngine!),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // 5. WEAK TOPICS
          if (snap.hasWeakTopics) ...[
            InterviewWeakTopicsCard(
              weakTopics: snap.weakTopics,
              onStudyTopic: (topic) {
                interviewEngine?.createSession(
                  title: 'Practice: $topic',
                  focusTopics: [topic],
                );
                _startPractice(context, interviewEngine!);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // 6. RECOMMENDATIONS
          if (snap.hasRecommendations) ...[
            InterviewRecommendationsCard(
              recommendations: snap.recommendations,
              onAction: (rec) {
                final route = rec.route ?? AppRoutes.interview;
                if (rec.actionType == InterviewActionType.practice ||
                    rec.actionType == InterviewActionType.retryPractice) {
                  interviewEngine?.createSession(
                    title: rec.title,
                    focusTopics: rec.relatedTopics,
                  );
                }
                Navigator.of(context).pushNamed(route);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // 7. SESSION HISTORY
          if (snap.recentSessions.isNotEmpty) ...[
            InterviewSessionHistoryCard(
              sessions: snap.recentSessions.take(5).toList(),
              onViewSession: (session) {
                Navigator.of(context).pushNamed(
                  AppRoutes.interviewSession,
                  arguments: {'sessionId': session.id},
                );
              },
              onStartNew: () => _startPractice(context, interviewEngine!),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // 8. ACTION BUTTONS
          InterviewActionsCard(
            onDashboard: () =>
                Navigator.of(context).pushNamed(AppRoutes.dashboard),
            onResume: () => Navigator.of(context).pushNamed(AppRoutes.resume),
            onCareer: () => Navigator.of(context).pushNamed(AppRoutes.career),
            onPortfolio: () =>
                Navigator.of(context).pushNamed(AppRoutes.portfolio),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  void _startPractice(BuildContext context, dynamic engine) {
    final session = engine.createSession();
    Navigator.of(context).pushNamed(
      AppRoutes.interviewSession,
      arguments: {'sessionId': session.id},
    );
  }
}
