import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/phoenix_error_state.dart';
import '../../../theme/spacing.dart';
import '../models/journey_stage.dart';
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
/// Data sourced from [ContinueJourneyEngine] and [IdentityEngine] snapshots.
/// No SampleRepository. Presentation only.
class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final identityEngine = AppBootstrap.maybeIdentityEngine;
    final identitySnap = identityEngine?.snapshot;

    if (identityEngine == null || identitySnap == null) {
      return PhoenixErrorState(
        category: PhoenixErrorCategory.data,
        title: 'Journey data unavailable',
        message: "We couldn't load your growth journey right now. "
            'Your progress is safe and will be available shortly.',
        actionLabel: 'Try Again',
        onAction: () => Navigator.of(context).pushReplacementNamed(
          AppRoutes.journey,
        ),
      );
    }

    final journeyTitle = identitySnap.currentIdentityTitle;
    final journeyDescription = identitySnap.currentGoal;
    final completionPercent = identitySnap.completionPercent;
    final currentStage = identitySnap.statusLabel;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          JourneyHeader(
            title: journeyTitle,
            description: journeyDescription,
            completionPercentage: completionPercent / 100.0,
          ),
          const SizedBox(height: AppSpacing.lg),
          JourneyTimelineCard(stages: []),
          const SizedBox(height: AppSpacing.lg),
          CurrentStageCard(
            stage: JourneyStage(
              id: 'current-stage',
              title: currentStage,
              description: journeyDescription,
              order: 0,
              completion: completionPercent / 100.0,
              status: StageStatus.inProgress,
              missions: [],
            ),
            onContinue: () => _onContinueStage(context),
          ),
          if (completionPercent < 100) ...[
            const SizedBox(height: AppSpacing.lg),
            UpcomingStageCard(
              stage: JourneyStage(
                id: 'next-stage',
                title: 'Next Adventure',
                description: 'Continue your journey to unlock the next stage.',
                order: 1,
                status: StageStatus.locked,
                missions: [],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          JourneyStatisticsCard(stages: []),
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
