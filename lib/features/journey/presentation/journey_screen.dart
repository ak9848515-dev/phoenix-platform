import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';
import '../../../core/sample_repository.dart';
import '../../../theme/spacing.dart';
import '../services/journey_service.dart';
import '../widgets/current_stage_card.dart';
import '../widgets/journey_actions_card.dart';
import '../widgets/journey_header.dart';
import '../widgets/journey_statistics_card.dart';
import '../widgets/journey_timeline_card.dart';
import '../widgets/upcoming_stage_card.dart';

/// The Journey Screen presents a complete journey generated from the user's
/// Identity.
///
/// Every Journey is composed of Stages. Every Stage contains Missions.
/// Knowledge DNA measures progress through the Journey. Recommendation
/// selects the next best Journey step.
///
/// The Journey is derived from the selected Identity via JourneyService,
/// ensuring Identity → Journey is the first integration in the platform
/// data flow.
///
/// This is a presentation-only screen. No AI, no persistence, no state
/// management.
class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = const SampleRepository();
    final journeyService = JourneyService(repository: repository);
    final journey = journeyService.getJourney();

    final currentStageIndex = journey.currentStage;
    final currentStage = journey.stages[currentStageIndex];

    // Find the next available or locked stage after current
    final upcomingStage = journey.stages.length > currentStageIndex + 1
        ? journey.stages[currentStageIndex + 1]
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          JourneyHeader(
            title: journey.title,
            description: journey.description,
            completionPercentage: journey.completion,
          ),
          const SizedBox(height: AppSpacing.lg),
          JourneyTimelineCard(stages: journey.stages),
          const SizedBox(height: AppSpacing.lg),
          CurrentStageCard(
            stage: currentStage,
            onContinue: () => _onContinueStage(context),
          ),
          if (upcomingStage != null) ...[
            const SizedBox(height: AppSpacing.lg),
            UpcomingStageCard(stage: upcomingStage),
          ],
          const SizedBox(height: AppSpacing.lg),
          JourneyStatisticsCard(stages: journey.stages),
          const SizedBox(height: AppSpacing.lg),
          JourneyActionsCard(
            onContinueJourney: () => _onContinueStage(context),
            onDashboard: () =>
                Navigator.of(context).pushNamed(AppRoutes.dashboard),
            onLearn: () => Navigator.of(context).pushNamed(AppRoutes.academy),
            onProfile: () => Navigator.of(context).pushNamed(AppRoutes.profile),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  void _onContinueStage(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.missionCenter);
  }
}
