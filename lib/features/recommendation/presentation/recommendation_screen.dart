import 'package:flutter/material.dart';

import '../../../core/sample_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/spacing.dart';
import '../models/recommendation.dart';
import '../services/recommendation_service.dart';
import '../widgets/recommendation_actions_card.dart';
import '../widgets/recommendation_header.dart';
import '../widgets/recommendation_reason_card.dart';
import '../widgets/recommended_learning_card.dart';
import '../widgets/recommended_missions_card.dart';
import '../widgets/todays_focus_card.dart';

/// The Recommendation Screen answers the question:
///
/// "What is the highest impact thing this user should do next?"
///
/// Displays only the highest priority recommendations with clear explanations
/// so users understand why Phoenix suggested each one.
///
/// This is a presentation-only screen. No AI, persistence, or business logic.
class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = const SampleRepository();
    final recommendationService = RecommendationService(repository: repository);
    final todaysFocus = recommendationService.getTodaysFocus();
    final highPriority = recommendationService.getHighPriorityRecommendations();
    final missions = recommendationService.getByType(
      RecommendationType.mission,
    );
    final learningItems = recommendationService.getByType(
      RecommendationType.learning,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const RecommendationHeader(),
          const SizedBox(height: AppSpacing.lg),
          if (todaysFocus != null) ...[
            TodaysFocusCard(recommendation: todaysFocus),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (highPriority.length > 1) ...[
            RecommendedLearningCard(learningItems: learningItems),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (missions.isNotEmpty) ...[
            RecommendedMissionsCard(missions: missions),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (todaysFocus != null) ...[
            RecommendationReasonCard(recommendation: todaysFocus),
            const SizedBox(height: AppSpacing.lg),
            RecommendationActionsCard(
              recommendation: todaysFocus,
              onStart: () => _onStart(context, todaysFocus),
              onDismiss: () => _onDismiss(context, todaysFocus),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ],
      ),
    );
  }

  void _onStart(BuildContext context, Recommendation recommendation) {
    // Navigate to the most relevant screen based on recommendation type
    switch (recommendation.type) {
      case RecommendationType.mission:
        Navigator.of(context).pushNamed(AppRoutes.missionCenter);
      case RecommendationType.learning:
        Navigator.of(context).pushNamed(AppRoutes.academy);
      case RecommendationType.practice:
        Navigator.of(context).pushNamed(AppRoutes.knowledgeDna);
      case RecommendationType.project:
        Navigator.of(context).pushNamed(AppRoutes.portfolio);
      case RecommendationType.career:
        Navigator.of(context).pushNamed(AppRoutes.career);
      case RecommendationType.business:
        Navigator.of(context).pushNamed(AppRoutes.marketplace);
      case RecommendationType.reflection:
        Navigator.of(context).pushNamed(AppRoutes.journey);
      case RecommendationType.review:
        Navigator.of(context).pushNamed(AppRoutes.progress);
    }
  }

  void _onDismiss(BuildContext context, Recommendation recommendation) {
    // Dismiss returns to the dashboard where users can find new recommendations
    Navigator.of(context).pushNamed(AppRoutes.dashboard);
  }
}
