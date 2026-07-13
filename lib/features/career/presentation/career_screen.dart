import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';
import '../../../core/sample_repository.dart';
import '../../../theme/spacing.dart';
import '../services/career_service.dart';
import '../widgets/career_actions_card.dart';
import '../widgets/career_header.dart';
import '../widgets/next_goal_card.dart';
import '../widgets/readiness_card.dart';
import '../widgets/skill_gap_card.dart';
import '../widgets/strengths_card.dart';

/// The Career Screen measures how close the user is to becoming employable.
///
/// Aggregates data from Identity, Journey, Mission, Knowledge DNA, Progress,
/// and Decision modules to present a holistic career readiness view with
/// strengths, skill gaps, next goal, and readiness breakdown.
///
/// Presentation only. No AI, no persistence, no networking, no state management.
class CareerScreen extends StatelessWidget {
  const CareerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = const SampleRepository();
    final careerService = CareerService(repository: repository);

    final profile = careerService.buildProfile();
    final strengths = careerService.getStrengthDetails();
    final gaps = careerService.getGapDetails();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CareerHeader(
            identityTitle: profile.identityId == repository.selectedIdentity.id
                ? repository.selectedIdentity.title
                : 'Career Path',
            careerScore: profile.careerScore,
            jobReadiness: profile.jobReadiness,
          ),
          const SizedBox(height: AppSpacing.lg),
          ReadinessCard(
            portfolioProgress: profile.portfolioProgress,
            resumeProgress: profile.resumeProgress,
            interviewReadiness: profile.interviewReadiness,
            estimatedWeeks: profile.estimatedWeeks,
          ),
          const SizedBox(height: AppSpacing.lg),
          NextGoalCard(
            goal: profile.nextGoal,
            estimatedWeeks: profile.estimatedWeeks,
            onStartGoal: () => _onStartGoal(context, profile.nextGoal),
          ),
          const SizedBox(height: AppSpacing.lg),
          StrengthsCard(strengths: strengths),
          const SizedBox(height: AppSpacing.lg),
          SkillGapCard(gaps: gaps),
          const SizedBox(height: AppSpacing.lg),
          CareerActionsCard(
            onWorkOnGoal: () => _onStartGoal(context, profile.nextGoal),
            goalLabel: profile.jobReadiness == 'Ready'
                ? 'Prepare Applications'
                : 'Work on Next Goal',
            onDashboard: () =>
                Navigator.of(context).pushNamed(AppRoutes.dashboard),
            onJourney: () => Navigator.of(context).pushNamed(AppRoutes.journey),
            onProgress: () =>
                Navigator.of(context).pushNamed(AppRoutes.progress),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  void _onStartGoal(BuildContext context, String goal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting: $goal'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
