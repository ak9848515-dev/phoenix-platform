import 'package:flutter/material.dart';

import '../../core/bootstrap.dart';
import '../../routes/app_routes.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../progress_engine/progress_engine.dart' show AchievementProgress;
import 'widgets/dashboard_header.dart';
import 'widgets/progress_summary_card.dart';
import 'widgets/today_mission_card.dart';
import 'widgets/upcoming_milestones_card.dart';
import 'widgets/continue_learning_card.dart';

/// Phoenix Home — the unified operating system home screen.
///
/// Surfaces all 9 sections from existing services:
/// 1. Today's Mission
/// 2. AI Recommendation
/// 3. Habit Summary
/// 4. Learning Progress
/// 5. Recent Timeline Activity
/// 6. Knowledge Insights
/// 7. Decision Reminder
/// 8. Voice Shortcut (via shell)
/// 9. Quick Search (via shell)
///
/// No new business logic. Uses only existing services.
class PhoenixHomeScreen extends StatelessWidget {
  const PhoenixHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userStateService = AppBootstrap.maybeUserStateService;
    final acdService = AppBootstrap.maybeAcademyService;
    final knowledgeService = AppBootstrap.maybeKnowledgeService;
    final habitService = AppBootstrap.maybeHabitService;
    final timelineService = AppBootstrap.maybeTimelineService;
    final decisionService = AppBootstrap.maybeDecisionService;

    // Build derived data from existing services
    final identity = userStateService?.identity;
    final journey = userStateService?.journey;
    final stage = userStateService?.currentJourneyStage;
    final journeyPercent =
        journey != null ? (journey.completion * 100).round() : 0;
    final state = userStateService?.currentState;

    final motivationalSubtitle = journeyPercent < 100 && stage != null
        ? 'Stage ${(journey?.currentStage ?? 0) + 1} of ${journey?.stages.length ?? 0} — ${stage.title}'
        : 'Journey complete — well done!';

    // Habit summary
    final activeHabits = habitService?.activeHabits ?? [];
    final completedToday = activeHabits
        .where((h) => habitService?.isCompletedToday(h.id) ?? false)
        .length;

    // Timeline recent activity
    final recentEvents = timelineService?.todayEvents ?? [];

    // Decision reminders
    final allAnalyses = decisionService?.allAnalyses ?? [];
    final pendingDecisions = allAnalyses
        .where((d) => d.outcome == null)
        .toList();

    // Knowledge insights
    final knowledgeInsights = knowledgeService?.insights ?? [];

    // Learning progress
    final activePath = acdService?.activePathProgress;

    // Today's mission
    final missions = userStateService?.missions ?? [];
    final activeMissions = missions.where((m) => m.isActionable).toList();
    final featured = activeMissions.isNotEmpty ? activeMissions.first : null;
    final totalMissions = missions.length;
    final completedMissions = missions.where((m) => m.isCompleted).length;
    final missionProgress = totalMissions > 0 ? completedMissions / totalMissions : 0.0;

    // Milestones
    final achievements = <AchievementProgress>[];
    final achievementMessages = state?.achievements ?? [];
    for (final a in achievementMessages) {
      achievements.add(AchievementProgress(
        id: a.hashCode.toString(),
        title: a.title,
        progress: 1.0,
        completed: true,
      ));
    }

    final totalXp = userStateService?.totalXp ?? 0;
    final level = userStateService?.level ?? 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Quick Search Bar ───────────────────────────────────
          _buildQuickSearch(context),
          const SizedBox(height: AppSpacing.md),

          // ── 1. Dynamic Greeting ───────────────────────────────
          DashboardHeader(
            userName: identity?.title ?? 'Phoenix User',
            motivationalSubtitle: motivationalSubtitle,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── 2. Today's Mission ────────────────────────────────
          if (featured != null)
            TodayMissionCard(
              missionTitle: featured.title,
              missionDescription: featured.description,
              progress: missionProgress,
              isComplete: featured.isCompleted,
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.missionCenter),
            ),
          if (featured != null) const SizedBox(height: AppSpacing.lg),

          // ── 3. Progress Summary ──────────────────────────────
          ProgressSummaryCard(
            totalXp: totalXp,
            currentLevel: level,
            currentStreak: completedMissions,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── 4. Habit Summary ─────────────────────────────────
          _buildHabitSummary(context, activeHabits, completedToday),
          const SizedBox(height: AppSpacing.lg),

          // ── 5. Learning Progress ─────────────────────────────
          if (activePath != null)
            ContinueLearningCard(
              courseTitle: activePath.pathId,
              lessonTitle: '${(activePath.completionPercentage * 100).round()}% complete',
              onContinue: () =>
                  Navigator.of(context).pushNamed(AppRoutes.academy),
            ),
          if (activePath != null) const SizedBox(height: AppSpacing.lg),

          // ── 6. Knowledge Insights ────────────────────────────
          if (knowledgeInsights.isNotEmpty)
            _buildKnowledgeInsights(context, knowledgeInsights.take(3).toList()),
          if (knowledgeInsights.isNotEmpty) const SizedBox(height: AppSpacing.lg),

          // ── 7. Phoenix Recommendation ────────────────────────
          _buildRecommendation(context),
          const SizedBox(height: AppSpacing.lg),

          // ── 8. Recent Timeline Activity ─────────────────────
          if (recentEvents.isNotEmpty)
            _buildRecentActivity(context, recentEvents),
          if (recentEvents.isNotEmpty) const SizedBox(height: AppSpacing.lg),

          // ── 9. Decision Reminder ─────────────────────────────
          if (pendingDecisions.isNotEmpty)
            _buildDecisionReminder(context, pendingDecisions),
          if (pendingDecisions.isNotEmpty) const SizedBox(height: AppSpacing.lg),

          // ── 10. Upcoming Milestones ─────────────────────────
          UpcomingMilestonesCard(
            achievements: achievements,
            completedCount: completedMissions,
            totalCount: totalMissions,
            onViewAll: () =>
                Navigator.of(context).pushNamed(AppRoutes.progress),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildQuickSearch(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.globalSearch),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: theme.colorScheme.onSurfaceVariant, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Search missions, habits, knowledge...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Icon(Icons.shortcut_rounded, color: theme.colorScheme.onSurfaceVariant, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitSummary(
    BuildContext context,
    List<dynamic> activeHabits,
    int completedToday,
  ) {
    final theme = Theme.of(context);
    if (activeHabits.isEmpty) return const SizedBox.shrink();

    final total = activeHabits.length;
    final progress = total > 0 ? completedToday / total : 0.0;
    final percentage = (progress * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist_rounded, size: 20, color: AppColors.success),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Habit Summary',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '$completedToday / $total done',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: AppColors.success,
                minHeight: 6,
              ),
            ),
            if (total > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Text(
                    '$percentage% today',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.open_in_new_rounded, size: 14),
                    label: const Text('View All'),
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.habits),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKnowledgeInsights(BuildContext context, List<dynamic> insights) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Knowledge Insights',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.open_in_new_rounded, size: 14),
                  label: const Text('Knowledge'),
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.knowledge),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: theme.textTheme.bodySmall),
                  Expanded(
                    child: Text(
                      insight.title,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendation(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.auto_awesome_rounded,
                  size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Recommendation',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Complete your missions to get personalized recommendations',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_rounded),
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.recommendation),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, List<dynamic> events) {
    final theme = Theme.of(context);
    final recent = events.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Recent Activity',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.open_in_new_rounded, size: 14),
                  label: const Text('Timeline'),
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.timeline),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...recent.map((event) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 6, color: theme.colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      event.title,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDecisionReminder(BuildContext context, List<dynamic> decisions) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.account_tree_rounded,
                  size: 20, color: AppColors.warning),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${decisions.length} pending decision${decisions.length == 1 ? '' : 's'}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    decisions.first.title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_rounded),
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.recommendation),
            ),
          ],
        ),
      ),
    );
  }
}

