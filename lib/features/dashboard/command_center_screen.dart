import 'package:flutter/material.dart';

import '../../core/bootstrap.dart';
import '../../core/design/animations/fade_animation.dart';
import '../../core/design/theme/phoenix_colors.dart';
import '../../core/design/theme/phoenix_radius.dart';
import '../../core/design/theme/phoenix_spacing.dart';
import '../../core/sample_repository.dart';
import '../../routes/app_routes.dart';
import '../career/services/career_service.dart';
import '../interview/services/interview_service.dart';
import '../knowledge_dna/knowledge_dna_service.dart';
import '../portfolio/services/portfolio_service.dart';
import '../progress_engine/progress_engine.dart' show AchievementProgress;
import '../progress_engine/progress_service.dart';
import '../recommendation/services/recommendation_service.dart';
import 'widgets/command_header.dart';
import 'widgets/continue_journey_card.dart';
import 'widgets/daily_brief_card.dart';
import 'widgets/growth_snapshot_card.dart';
import 'widgets/recent_progress_card.dart';
import 'widgets/recommendation_card.dart';
import 'widgets/today_mission_card.dart';

/// The Phoenix Command Center — the unified dashboard that answers:
///
/// 1. Who am I? → CommandHeader (greeting, identity, goal, level)
/// 2. Who am I becoming? → GrowthSnapshot (5 tappable trend cards)
/// 3. What should I do today? -> Today's Mission + Daily Brief
/// 4. How much have I improved? → Recent Progress (completed items)
/// 5. What should I do next? → Continue Journey + Recommended Next Action
///
/// Every section is actionable. All data comes from existing services.
/// No business logic, no calculations, no AI orchestration.
///
/// Sections animate in with staggered FadeAnimation delays (100ms gaps)
/// so that content cascades down as the user scrolls.
class CommandCenterScreen extends StatelessWidget {
  const CommandCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Gather all data from existing services ───────────────────────
    final repository = const SampleRepository();
    final userStateService = AppBootstrap.maybeUserStateService;
    final acdService = AppBootstrap.maybeAcademyService;
    final decisionService = AppBootstrap.maybeDecisionService;

    // Identity & Journey
    final identity = userStateService?.identity ?? repository.selectedIdentity;
    final journey = userStateService?.journey ?? repository.journey;
    final stage = userStateService?.currentJourneyStage ??
        repository.currentJourneyStage;
    final journeyPercent = (journey.completion * 100).round();
    final motivationalSubtitle = journeyPercent < 100 && stage.title.isNotEmpty
        ? 'Stage ${(journey.currentStage) + 1} of ${journey.stages.length} - ${stage.title}'
        : 'Journey complete - well done!';

    // Missions
    final missions = userStateService?.missions ?? [];
    final activeMissions = missions.where((m) => m.isActionable).toList();
    final featuredMission =
        activeMissions.isNotEmpty ? activeMissions.first : null;

    // Progress Service for XP/Level details
    final progressService = ProgressService(
      repository: repository,
      userStateService: userStateService,
    );
    final progressSummary = progressService.buildSummary();

    // Calculate XP progress toward next level
    // Level N needs N*250 total XP. XP in current level = totalXp - (level-1)*250
    final level = userStateService?.level ?? progressSummary.level;
    final totalXp = userStateService?.totalXp ?? progressSummary.totalXp;
    final xpForCurrentLevel = (level - 1) * 250;
    final xpForNextLevel = level * 250;
    final xpInCurrentLevel = totalXp - xpForCurrentLevel;
    final xpNeeded = xpForNextLevel - xpForCurrentLevel;
    final xpProgress = xpNeeded > 0
        ? (xpInCurrentLevel / xpNeeded).clamp(0.0, 1.0)
        : 1.0;

    // Knowledge DNA
    final knowledgeService = KnowledgeDNAService(repository: repository);
    final knowledgeAnalysis = knowledgeService.buildAnalysis();

    // Academy / Learning
    final activePath = acdService?.activePathProgress;
    final currentLesson = acdService?.currentLesson;

    // Portfolio
    final portfolioService = PortfolioService(repository: repository);
    final portfolio = portfolioService.buildPortfolio();

    // Career
    final careerProfile = CareerService(repository: repository).buildProfile();

    // Interview
    final interviewProfile =
        InterviewService(repository: repository).buildProfile();

    // Habits
    final habitService = AppBootstrap.maybeHabitService;
    final activeHabits = habitService?.activeHabits ?? [];
    final completedToday = activeHabits
        .where((h) => habitService?.isCompletedToday(h.id) ?? false)
        .length;
    final habitCompletionRate = activeHabits.isNotEmpty
        ? completedToday / activeHabits.length
        : 0.0;

    // Recommendation
    final recommendationService =
        RecommendationService(repository: repository);
    final todaysFocus = recommendationService.getTodaysFocus();

    // Achievements
    final achievements = <AchievementProgress>[];
    final state = userStateService?.currentState;
    final achievementMessages = state?.achievements ?? [];
    for (final a in achievementMessages) {
      achievements.add(AchievementProgress(
        id: a.hashCode.toString(),
        title: a.title,
        progress: 1.0,
        completed: true,
      ));
    }

    // Decisions
    final allAnalyses = decisionService?.allAnalyses ?? [];
    final pendingDecisions =
        allAnalyses.where((d) => d.outcome == null).toList();

    // Build Recent Progress lists
    final recentMissions = missions
        .where((m) => m.isCompleted)
        .map((m) => m.title)
        .take(3)
        .toList();
    final recentProjects = portfolio.featuredProjects
        .where((p) => p.isCompleted)
        .map((p) => p.title)
        .take(2)
        .toList();
    final recentAchievements = achievements
        .where((a) => a.completed)
        .map((a) => a.title)
        .take(3)
        .toList();
    final completedLessonTitles =
        activePath != null ? [activePath.pathId] : <String>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. WELCOME HEADER (delay 0ms)
          FadeAnimation(
            duration: const Duration(milliseconds: 500),
            delay: Duration.zero,
            child: CommandHeader(
              userName: identity.title,
              currentIdentity: identity.title,
              currentGoal: motivationalSubtitle,
              currentLevel: level,
              totalXp: totalXp,
              xpProgress: xpProgress,
              nextLevelXp: xpNeeded,
            ),
          ),
          const SizedBox(height: PhoenixSpacing.lg),

          // 2. TODAY'S MISSION (delay 100ms)
          FadeAnimation(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 100),
            child: featuredMission != null
                ? TodayMissionCard(
                    missionTitle: featuredMission.title,
                    missionDescription: featuredMission.description,
                    progress: _missionProgress(featuredMission),
                    isComplete: featuredMission.isCompleted,
                    estimatedTime: '15 min',
                    rewardXp: 50,
                    difficulty: 'Intermediate',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.missionCenter),
                  )
                : _buildNoMissionCard(context),
          ),
          const SizedBox(height: PhoenixSpacing.lg),

          // 3. GROWTH SNAPSHOT (delay 200ms)
          FadeAnimation(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 200),
            child: GrowthSnapshotCard(
              knowledgeScore: knowledgeAnalysis.knowledgeScore,
              careerScore: careerProfile.careerScore,
              portfolioScore: portfolio.portfolioScore,
              interviewReadiness: interviewProfile.interviewReadiness,
              habitCompletionRate: habitCompletionRate,
              onKnowledgeTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.knowledgeDna),
              onCareerTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.career),
              onProjectsTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.portfolio),
              onInterviewTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.interview),
              onHabitsTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.habits),
            ),
          ),
          const SizedBox(height: PhoenixSpacing.lg),

          // 4. CONTINUE JOURNEY (delay 300ms)
          FadeAnimation(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 300),
            child: ContinueJourneyCard(
              currentLessonTitle: currentLesson?.lessonId,
              currentLessonPath: activePath?.pathId,
              activeMissionTitle: featuredMission?.title,
              featuredProjectTitle: portfolio.featuredProjects.isNotEmpty
                  ? portfolio.featuredProjects.first.title
                  : null,
              interviewReadiness: interviewProfile.interviewReadiness,
              onContinueLesson: () =>
                  Navigator.of(context).pushNamed(AppRoutes.academy),
              onContinueMission: () =>
                  Navigator.of(context).pushNamed(AppRoutes.missionCenter),
              onContinueProject: () =>
                  Navigator.of(context).pushNamed(AppRoutes.portfolio),
              onContinueInterview: () =>
                  Navigator.of(context).pushNamed(AppRoutes.interview),
            ),
          ),
          const SizedBox(height: PhoenixSpacing.lg),

          // 5. PHOENIX DAILY BRIEF (delay 400ms)
          FadeAnimation(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 400),
            child: DailyBriefCard(
              currentLessonTitle: currentLesson?.lessonId,
              activeMissionTitle: featuredMission?.title,
              pendingHabitCount: activeHabits.length - completedToday,
              totalHabitCount: activeHabits.length,
              pendingDecisionCount: pendingDecisions.length,
              completedAchievements: achievements.where((a) => a.completed).length,
              onLessonTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.academy),
              onMissionTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.missionCenter),
              onHabitsTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.habits),
              onDecisionsTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.recommendation),
              onAchievementsTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.progress),
            ),
          ),
          const SizedBox(height: PhoenixSpacing.lg),

          // 6. RECOMMENDED NEXT ACTION (delay 500ms)
          FadeAnimation(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 500),
            child: todaysFocus != null
                ? RecommendationCard(
                    recommendation: todaysFocus,
                    onAction: () =>
                        Navigator.of(context).pushNamed(AppRoutes.recommendation),
                  )
                : _buildFallbackRecommendation(context),
          ),
          const SizedBox(height: PhoenixSpacing.lg),

          // 7. RECENT PROGRESS (delay 600ms)
          FadeAnimation(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 600),
            child: RecentProgressCard(
              completedMissions: recentMissions,
              completedLessons: completedLessonTitles,
              completedProjects: recentProjects,
              unlockedAchievements: recentAchievements,
              onMissionTap: (_) =>
                  Navigator.of(context).pushNamed(AppRoutes.progress),
              onLessonTap: (_) =>
                  Navigator.of(context).pushNamed(AppRoutes.academy),
              onProjectTap: (_) =>
                  Navigator.of(context).pushNamed(AppRoutes.portfolio),
              onAchievementTap: (_) =>
                  Navigator.of(context).pushNamed(AppRoutes.progress),
              onStartExploring: () =>
                  Navigator.of(context).pushNamed(AppRoutes.academy),
            ),
          ),
          const SizedBox(height: PhoenixSpacing.xxl),
        ],
      ),
    );
  }

  /// Returns mission progress as a value between 0.0 and 1.0.
  double _missionProgress(dynamic mission) {
    return mission.isCompleted ? 1.0 : 0.3;
  }

  /// Displays "No active mission" state with a Start Mission CTA.
  Widget _buildNoMissionCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PhoenixSpacing.xl),
      decoration: BoxDecoration(
        color: PhoenixColors.surfaceVariant,
        borderRadius: PhoenixRadius.xlRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rocket_launch_outlined,
                size: 20,
                color: PhoenixColors.textSecondary,
              ),
              const SizedBox(width: PhoenixSpacing.sm),
              Text(
                "Today's Mission",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: PhoenixColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: PhoenixSpacing.md),
          Text(
            'No active mission',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: PhoenixColors.textSecondary,
            ),
          ),
          const SizedBox(height: PhoenixSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.missionCenter),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Start Mission'),
            ),
          ),
        ],
      ),
    );
  }

  /// Fallback recommendation when no todaysFocus is available.
  Widget _buildFallbackRecommendation(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      decoration: BoxDecoration(
        color: PhoenixColors.surfaceVariant,
        borderRadius: PhoenixRadius.xlRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 20,
                color: PhoenixColors.primary,
              ),
              const SizedBox(width: PhoenixSpacing.sm),
              Text(
                "Today's Focus",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: PhoenixSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Complete missions to get personalized recommendations.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: PhoenixSpacing.md),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context)
                    .pushNamed(AppRoutes.missionCenter),
                icon: const Icon(Icons.rocket_launch_outlined, size: 18),
                label: const Text('Explore'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
