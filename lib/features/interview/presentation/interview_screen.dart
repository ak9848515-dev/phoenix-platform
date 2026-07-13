import 'package:flutter/material.dart';

import '../../../core/sample_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/spacing.dart';
import '../services/interview_service.dart';
import '../widgets/improvement_card.dart';
import '../widgets/interview_actions_card.dart';
import '../widgets/interview_header.dart';
import '../widgets/interview_statistics_card.dart';
import '../widgets/mock_questions_card.dart';
import '../widgets/readiness_card.dart';
import '../widgets/strengths_card.dart';

/// The Interview Intelligence screen prepares users for real interviews.
///
/// All data is derived from existing Phoenix modules — no AI, no
/// networking, no persistence, no duplicate business logic.
///
/// Presentation only. StatelessWidget.
class InterviewScreen extends StatelessWidget {
  const InterviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = const SampleRepository();
    final interviewService = InterviewService(repository: repository);
    final profile = interviewService.buildProfile();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InterviewHeader(
            identityTitle: repository.selectedIdentity.title,
            interviewReadiness: profile.interviewReadiness,
            estimatedPreparationDays: profile.estimatedPreparationDays,
          ),
          const SizedBox(height: AppSpacing.lg),
          InterviewStatisticsCard(
            questionCount: profile.questionCount,
            estimatedPreparationDays: profile.estimatedPreparationDays,
            interviewReadiness: profile.interviewReadiness,
          ),
          const SizedBox(height: AppSpacing.lg),
          ReadinessCard(
            technicalScore: profile.technicalScore,
            behavioralScore: profile.behavioralScore,
            communicationScore: profile.communicationScore,
          ),
          const SizedBox(height: AppSpacing.lg),
          StrengthsCard(strengths: profile.strengths),
          const SizedBox(height: AppSpacing.lg),
          ImprovementCard(
            improvementAreas: profile.improvementAreas,
            recommendedTopics: profile.recommendedTopics,
          ),
          const SizedBox(height: AppSpacing.lg),
          MockQuestionsCard(questions: profile.mockQuestions),
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
}
