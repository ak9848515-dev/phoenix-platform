import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';
import '../../../core/sample_repository.dart';
import '../../../theme/spacing.dart';
import '../../decision/services/decision_service.dart';
import '../../mission_engine/mission_service.dart';
import '../../progress_engine/progress_service.dart';
import '../widgets/daily_focus_header.dart';
import '../widgets/focus_actions_card.dart';
import '../widgets/focus_progress_card.dart';
import '../widgets/focus_reason_card.dart';
import '../widgets/todays_focus_card.dart';

/// The Daily Focus Screen presents ONE highest-impact task for the user today.
///
/// This task is derived from the existing integrated sample services:
/// Identity → Journey → Mission → Progress → Memory → Recommendation.
///
/// The screen surfaces the single most important action the user should take
/// right now, with clear context on why it matters and how it fits into
/// their broader Journey.
///
/// This is a presentation-only screen. No AI, no persistence, no state
/// management, no new engines.
class DailyFocusScreen extends StatelessWidget {
  const DailyFocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = const SampleRepository();
    final decisionService = DecisionService(repository: repository);
    final missionService = MissionService(repository: repository);
    final progressService = ProgressService(repository: repository);

    // Derive today's focus from the Decision Engine, which aggregates
    // inputs from all Phoenix modules (Identity, Journey, Mission,
    // Knowledge DNA, Progress, Memory, Recommendations).
    final decision = decisionService.getDecision();

    // Derive journey and progress context
    final journey = repository.journey;
    final currentStage = repository.currentJourneyStage;
    final identity = repository.selectedIdentity;
    final missionProgress = missionService.buildProgress();
    final progressSummary = progressService.buildSummary();

    // Format today's date
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final dateLabel = '${months[now.month - 1]} ${now.day}, ${now.year}';

    // Derive missions completed count
    final missionsCompleted = missionProgress.completedCount;
    final missionsTotal =
        missionProgress.dailyMissions.length +
        missionProgress.weeklyMissions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DailyFocusHeader(
            userName: 'Ava',
            identityTitle: identity.title,
            dateLabel: dateLabel,
          ),
          const SizedBox(height: AppSpacing.lg),
          TodaysFocusCard(
            title: decision.title,
            description: decision.description,
            estimatedDuration: decision.estimatedDuration,
            actionLabel: decision.actionLabel ?? 'Start',
            priority: decision.priority.name,
            onStart: () => _onStartFocus(context, decision.title),
          ),
          const SizedBox(height: AppSpacing.lg),
          FocusReasonCard(
            reason: decision.reason,
            stageName: currentStage.title,
            stageProgress: currentStage.completion,
          ),
          const SizedBox(height: AppSpacing.lg),
          FocusProgressCard(
            missionsCompleted: missionsCompleted,
            missionsTotal: missionsTotal,
            missionProgress: missionProgress.completionPercentage,
            journeyCompletion: journey.completion,
            currentLevel: progressSummary.level,
            streak: missionProgress.streak,
          ),
          const SizedBox(height: AppSpacing.lg),
          FocusActionsCard(
            onStartFocus: () => _onStartFocus(context, decision.title),
            actionLabel: decision.actionLabel ?? 'Start',
            onDashboard: () =>
                Navigator.of(context).pushNamed(AppRoutes.dashboard),
            onJourney: () => Navigator.of(context).pushNamed(AppRoutes.journey),
            onLearn: () => Navigator.of(context).pushNamed(AppRoutes.academy),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  void _onStartFocus(BuildContext context, String focusTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting: $focusTitle'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
