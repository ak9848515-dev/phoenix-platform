import 'package:flutter/material.dart';

import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_icons.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';

/// A single progress item in the Recent Progress list.
class _ProgressItem extends StatelessWidget {
  const _ProgressItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'View: $title',
      button: onTap != null,
      enabled: onTap != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 4,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: PhoenixSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: PhoenixTypography.label.copyWith(
                          color: PhoenixColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: PhoenixTypography.caption.copyWith(
                          color: PhoenixColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: PhoenixColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Recent Progress card for the Phoenix Command Center.
///
/// Displays recently completed items:
/// - Completed missions
/// - Completed lessons
/// - Completed projects
/// - Unlocked achievements
///
/// Each item is tappable and navigates to its detail screen.
/// Shows empty state with a "Start Something" CTA if nothing is completed.
class RecentProgressCard extends StatelessWidget {
  const RecentProgressCard({
    super.key,
    this.completedMissions = const [],
    this.completedLessons = const [],
    this.completedProjects = const [],
    this.unlockedAchievements = const [],
    this.onMissionTap,
    this.onLessonTap,
    this.onProjectTap,
    this.onAchievementTap,
    this.onStartExploring,
  });

  /// Titles of recently completed missions.
  final List<String> completedMissions;

  /// Titles of recently completed lessons.
  final List<String> completedLessons;

  /// Titles of recently completed projects.
  final List<String> completedProjects;

  /// Titles of recently unlocked achievements.
  final List<String> unlockedAchievements;

  /// Called when a mission item is tapped.
  final void Function(String title)? onMissionTap;

  /// Called when a lesson item is tapped.
  final void Function(String title)? onLessonTap;

  /// Called when a project item is tapped.
  final void Function(String title)? onProjectTap;

  /// Called when an achievement item is tapped.
  final void Function(String title)? onAchievementTap;

  /// Called when the Start Exploring button is tapped (empty state).
  final VoidCallback? onStartExploring;

  @override
  Widget build(BuildContext context) {
    // Collect all completed items for display
    final items = <_ProgressItemData>[];

    for (final mission in completedMissions) {
      items.add(_ProgressItemData(
        icon: PhoenixIcons.mission,
        title: mission,
        subtitle: 'Completed mission',
        color: PhoenixColors.success,
        type: _ProgressType.mission,
      ));
    }
    for (final lesson in completedLessons) {
      items.add(_ProgressItemData(
        icon: Icons.school_rounded,
        title: lesson,
        subtitle: 'Completed lesson',
        color: PhoenixColors.primary,
        type: _ProgressType.lesson,
      ));
    }
    for (final project in completedProjects) {
      items.add(_ProgressItemData(
        icon: PhoenixIcons.launch,
        title: project,
        subtitle: 'Completed project',
        color: PhoenixColors.primary,
        type: _ProgressType.project,
      ));
    }
    for (final achievement in unlockedAchievements) {
      items.add(_ProgressItemData(
        icon: PhoenixIcons.achievement,
        title: achievement,
        subtitle: 'Achievement unlocked',
        color: PhoenixColors.gold,
        type: _ProgressType.achievement,
      ));
    }

    final hasItems = items.isNotEmpty;

    return PhoenixCard(
        header: 'Recent Progress',
        child: hasItems
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items.take(5).map((item) {
                  return _ProgressItem(
                    icon: item.icon,
                    title: item.title,
                    subtitle: item.subtitle,
                    color: item.color,
                    onTap: () {
                      switch (item.type) {
                        case _ProgressType.mission:
                          onMissionTap?.call(item.title);
                        case _ProgressType.lesson:
                          onLessonTap?.call(item.title);
                        case _ProgressType.project:
                          onProjectTap?.call(item.title);
                        case _ProgressType.achievement:
                          onAchievementTap?.call(item.title);
                      }
                    },
                  );
                }).toList(),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: PhoenixSpacing.lg),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 40,
                        color: PhoenixColors.textDisabled,
                      ),
                      const SizedBox(height: PhoenixSpacing.sm),
                      Text(
                        'No progress yet',
                        style: PhoenixTypography.bodySmall.copyWith(
                          color: PhoenixColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: PhoenixSpacing.sm),
                      Text(
                        'Complete missions and lessons to see your progress here.',
                        textAlign: TextAlign.center,
                        style: PhoenixTypography.caption.copyWith(
                          color: PhoenixColors.textDisabled,
                        ),
                      ),
                      if (onStartExploring != null) ...[
                        const SizedBox(height: PhoenixSpacing.lg),
                        PhoenixPrimaryButton(
                          onPressed: onStartExploring!,
                          label: 'Start Learning',
                          icon: Icons.school_outlined,
                          fullWidth: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }
}

/// Internal data class for a progress item.
class _ProgressItemData {
  const _ProgressItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.type,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final _ProgressType type;
}

enum _ProgressType { mission, lesson, project, achievement }
