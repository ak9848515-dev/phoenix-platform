import 'package:flutter/material.dart';

import '../../core/bootstrap.dart';
import '../../core/design/animations/fade_animation.dart';
import '../../core/design/theme/phoenix_colors.dart';
import '../../core/design/theme/phoenix_radius.dart';
import '../../core/design/theme/phoenix_spacing.dart';
import '../../core/design/theme/phoenix_typography.dart';
import '../../core/sample_repository.dart';
import '../../routes/app_routes.dart';
import '../mission_engine/mission_service.dart';
import '../progress_engine/progress_service.dart';
import '../recommendation/services/recommendation_service.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/progress_summary_card.dart';
import 'widgets/quick_actions_card.dart';
import 'widgets/recommendation_card.dart';
import 'widgets/today_mission_card.dart';
import 'widgets/upcoming_milestones_card.dart';

/// The premium Dashboard 2.0 experience for Phoenix OS.
///
/// Presentation-only. All data comes from existing services.
/// No business logic, no mission generation, no calculations.
///
/// Sections:
/// 1. Dynamic Greeting — time-based + user identity + motivational subtitle
/// 2. Today's Mission — from MissionService
/// 3. Progress Summary — XP, Level, Streak from ProgressService
/// 4. Phoenix Recommendation — from RecommendationService
/// 5. Upcoming Milestones — achievements from AchievementEngine
/// 6. Quick Actions — navigation to core features
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = const SampleRepository();
    final userStateService = AppBootstrap.maybeUserStateService;
    final missionService = MissionService(
      repository: repository,
      userStateService: userStateService,
    );
    final missionProgress = missionService.buildProgress();
    final progressSummary = ProgressService(
      repository: repository,
      userStateService: userStateService,
    ).buildSummary();
    final recommendationService = RecommendationService(
      repository: repository,
    );

    final todaysFocus = recommendationService.getTodaysFocus();
    final featuredMission = missionProgress.featuredMission;

    // Read identity and journey from UserStateService when available,
    // fall back to SampleRepository for backward compatibility.
    final identity = userStateService?.identity ?? repository.selectedIdentity;
    final journey = userStateService?.journey ?? repository.journey;
    final stage = userStateService?.currentJourneyStage ?? repository.currentJourneyStage;
    final journeyPercent = (journey.completion * 100).round();

    // Motivational subtitle based on journey progress.
    final motivationalSubtitle = journeyPercent < 100
        ? 'Stage ${journey.currentStage + 1} of ${journey.stages.length} '
            '— ${stage.title}'
        : 'Journey complete — well done!';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Dynamic Greeting ─────────────────────────────────────
          DashboardHeader(
            userName: identity.title,
            motivationalSubtitle: motivationalSubtitle,
          ),
          SizedBox(height: PhoenixSpacing.lg),

          // ── 2. Today's Mission ──────────────────────────────────────
          TodayMissionCard(
            missionTitle: featuredMission.title,
            missionDescription: featuredMission.description,
            progress: missionProgress.completionPercentage,
            isComplete: missionProgress.pendingCount == 0,
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.missionCenter),
          ),
          SizedBox(height: PhoenixSpacing.lg),

          // ── 3. Progress Summary ────────────────────────────────────
          ProgressSummaryCard(
            totalXp: progressSummary.totalXp,
            currentLevel: progressSummary.level,
            currentStreak: progressSummary.streaks.daily,
          ),
          SizedBox(height: PhoenixSpacing.lg),

          // ── 4. Phoenix Recommendation ──────────────────────────────
          if (todaysFocus != null)
            RecommendationCard(
              recommendation: todaysFocus,
              onAction: () => Navigator.of(context).pushNamed(
                AppRoutes.recommendation,
              ),
            )
          else
            _emptySection('No recommendations yet'),

          SizedBox(height: PhoenixSpacing.lg),

          // ── 5. Upcoming Milestones ─────────────────────────────────
          UpcomingMilestonesCard(
            achievements: progressSummary.achievements,
            completedCount: missionProgress.completedCount,
            totalCount:
                missionProgress.dailyMissions.length +
                missionProgress.weeklyMissions.length,
            onViewAll: () =>
                Navigator.of(context).pushNamed(AppRoutes.progress),
          ),
          SizedBox(height: PhoenixSpacing.lg),

          // ── 6. Quick Actions ───────────────────────────────────────
          QuickActionsCard(
            onPortfolio: () =>
                Navigator.of(context).pushNamed(AppRoutes.portfolio),
            onResume: () =>
                Navigator.of(context).pushNamed(AppRoutes.resume),
            onInterview: () =>
                Navigator.of(context).pushNamed(AppRoutes.interview),
            onOpportunities: () =>
                Navigator.of(context).pushNamed(AppRoutes.opportunity),
            onMarketplace: () =>
                Navigator.of(context).pushNamed(AppRoutes.marketplace),
          ),
          SizedBox(height: PhoenixSpacing.xxl),
        ],
      ),
    );
  }

  Widget _emptySection(String message) {
    return FadeAnimation(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(PhoenixSpacing.xl),
        decoration: BoxDecoration(
          color: PhoenixColors.surfaceVariant,
          borderRadius: PhoenixRadius.xlRadius,
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: PhoenixTypography.body.copyWith(
            color: PhoenixColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
