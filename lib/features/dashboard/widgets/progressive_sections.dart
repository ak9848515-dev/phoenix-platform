import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../routes/app_routes.dart';

/// The progressive scroll sections that tell the user's growth story.
///
/// Scrolling reveals in order:
/// 1. Growth Journey Timeline
/// 2. Today's Missions
/// 3. Progress
/// 4. AI Insight
/// 5. Continue Learning
/// 6. Personalized Recommendations
class ProgressiveSections extends StatelessWidget {
  const ProgressiveSections({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: PhoenixSpacing.xxl),
        _ScrollSection(
          delay: const Duration(milliseconds: 100),
          child: const _JourneyTimelineSection(),
        ),
        const SizedBox(height: PhoenixSpacing.xl),
        _ScrollSection(
          delay: const Duration(milliseconds: 250),
          child: const _MissionsSection(),
        ),
        const SizedBox(height: PhoenixSpacing.xl),
        _ScrollSection(
          delay: const Duration(milliseconds: 400),
          child: const _ProgressSection(),
        ),
        const SizedBox(height: PhoenixSpacing.xl),
        _ScrollSection(
          delay: const Duration(milliseconds: 550),
          child: const _AIInsightSection(),
        ),
        const SizedBox(height: PhoenixSpacing.xl),
        _ScrollSection(
          delay: const Duration(milliseconds: 700),
          child: const _ContinueLearningSection(),
        ),
        const SizedBox(height: PhoenixSpacing.xl),
        _ScrollSection(
          delay: const Duration(milliseconds: 850),
          child: const _RecommendationsSection(),
        ),
        const SizedBox(height: PhoenixSpacing.xxl * 2),
      ],
    );
  }
}

/// A section that fades in as the user scrolls.
class _ScrollSection extends StatelessWidget {
  const _ScrollSection({
    required this.child,
    required this.delay,
  });

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      duration: const Duration(milliseconds: 600),
      delay: delay,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PhoenixSpacing.lg),
        child: child,
      ),
    );
  }
}

// ── 1. GROWTH JOURNEY TIMELINE ───────────────────────────────────────

class _JourneyTimelineSection extends StatelessWidget {
  const _JourneyTimelineSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final identityEngine = AppBootstrap.maybeIdentityEngine;
    final identitySnap = identityEngine?.snapshot;
    final currentGoal = identitySnap?.currentGoal ?? 'Begin your journey';
    final experience = identitySnap?.experience ?? 'Beginner';
    final currentMission = identitySnap?.currentMissionTitle;

    return _SectionCard(
      icon: Icons.timeline_rounded,
      color: PhoenixColors.primary,
      title: 'Your Growth Journey',
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.journey),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Journey stage indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(PhoenixSpacing.md),
            decoration: BoxDecoration(
              color: PhoenixColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: PhoenixColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.explore_rounded,
                    color: PhoenixColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: PhoenixSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Stage',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentGoal,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: PhoenixColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    experience,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: PhoenixColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (currentMission != null && currentMission.isNotEmpty) ...[
            const SizedBox(height: PhoenixSpacing.sm),
            Row(
              children: [
                Icon(Icons.flag_outlined, size: 14, color: PhoenixColors.warning),
                const SizedBox(width: 6),
                Text(
                  'Active: $currentMission',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── 2. TODAY'S MISSIONS ──────────────────────────────────────────────

class _MissionsSection extends StatelessWidget {
  const _MissionsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userStateService = AppBootstrap.maybeUserStateService;
    final missions = userStateService?.missions ?? [];
    final actionableMissions = missions.where((m) => m.isActionable).take(3).toList();

    return _SectionCard(
      icon: Icons.rocket_launch_rounded,
      color: PhoenixColors.warning,
      title: "Today's Missions",
      subtitle: '${actionableMissions.length} actionable',
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.missionCenter),
      child: actionableMissions.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: PhoenixSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 18, color: PhoenixColors.success),
                  const SizedBox(width: PhoenixSpacing.sm),
                  Text(
                    'All missions completed',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: actionableMissions.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: PhoenixSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: m.isCompleted
                            ? PhoenixColors.success
                            : PhoenixColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: PhoenixSpacing.sm),
                    Expanded(
                      child: Text(
                        m.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (m.isCompleted)
                      Icon(Icons.check_circle, size: 16, color: PhoenixColors.success)
                    else
                      Text(
                        '15 min',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              )).toList(),
            ),
    );
  }
}

// ── 3. PROGRESS ──────────────────────────────────────────────────────

class _ProgressSection extends StatelessWidget {
  const _ProgressSection();

  @override
  Widget build(BuildContext context) {
    final growthEngine = AppBootstrap.maybeGrowthEngine;
    final growthSnap = growthEngine?.snapshot;
    final level = growthSnap?.currentLevel ?? 1;
    final totalXp = growthSnap?.totalXp ?? 0;

    // Get knowledge growth rate
    final knowledgeScore = growthSnap?.knowledge.score ?? 0.0;
    final careerScore = growthSnap?.career.score ?? 0.0;

    return _SectionCard(
      icon: Icons.trending_up_rounded,
      color: PhoenixColors.success,
      title: 'Your Progress',
      subtitle: 'Level $level · $totalXp XP',
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.progress),
      child: Row(
        children: [
          Expanded(
            child: _ProgressStat(
              label: 'Knowledge',
              value: '${(knowledgeScore * 100).round()}%',
              color: PhoenixColors.info,
            ),
          ),
          const SizedBox(width: PhoenixSpacing.md),
          Expanded(
            child: _ProgressStat(
              label: 'Career',
              value: '${(careerScore * 100).round()}%',
              color: PhoenixColors.success,
            ),
          ),
          const SizedBox(width: PhoenixSpacing.md),
          Expanded(
            child: _ProgressStat(
              label: 'Level',
              value: '$level',
              color: PhoenixColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(PhoenixSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 4. AI INSIGHT ────────────────────────────────────────────────────

class _AIInsightSection extends StatelessWidget {
  const _AIInsightSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decisionEngine = AppBootstrap.maybeDecisionIntelligenceEngine;
    final decisionSnap = decisionEngine?.snapshot;
    final topDecision = decisionSnap?.top;

    return _SectionCard(
      icon: Icons.auto_awesome_rounded,
      color: PhoenixColors.primary,
      title: 'AI Insight',
      subtitle: 'Intelligence by Phoenix AI',
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.ai),
      child: topDecision != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topDecision.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: PhoenixSpacing.xs),
                Text(
                  topDecision.reason.why,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          : Text(
              'Complete your profile to receive AI-powered insights.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
    );
  }
}

// ── 5. CONTINUE LEARNING ─────────────────────────────────────────────

class _ContinueLearningSection extends StatelessWidget {
  const _ContinueLearningSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final acdService = AppBootstrap.maybeAcademyService;
    final activePath = acdService?.activePathProgress;
    final currentLesson = acdService?.currentLesson;

    return _SectionCard(
      icon: Icons.school_rounded,
      color: PhoenixColors.info,
      title: 'Continue Learning',
      subtitle: activePath?.pathId ?? 'Explore new topics',
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.academy),
      child: currentLesson != null
          ? Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: PhoenixColors.info,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: PhoenixSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resume where you left off',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentLesson.lessonId,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: PhoenixColors.info,
                  size: 32,
                ),
              ],
            )
          : Text(
              'Search for something you\'d like to learn',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
    );
  }
}

// ── 6. PERSONALIZED RECOMMENDATIONS ──────────────────────────────────

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recEngine = AppBootstrap.maybeRecommendationEngine;
    final recs = recEngine?.snapshot?.allRanked ?? [];

    return _SectionCard(
      icon: Icons.auto_awesome_rounded,
      color: PhoenixColors.warning,
      title: 'Recommended for You',
      subtitle: 'Based on your growth journey',
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.recommendation),
      child: recs.isEmpty
          ? Text(
              'Complete more missions to get personalized recommendations.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : Column(
              children: recs.take(3).map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: PhoenixSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: PhoenixColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: PhoenixSpacing.sm),
                    Expanded(
                      child: Text(
                        rec.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${(rec.score.confidence * 100).round()}% match',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
    );
  }
}

// ── REUSABLE SECTION CARD ────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    required this.child,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(PhoenixSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: PhoenixSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Text(
                          subtitle!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: PhoenixSpacing.md),
            // Content
            child,
          ],
        ),
      ),
    );
  }
}