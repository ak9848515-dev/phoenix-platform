import 'package:flutter/material.dart';

import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_icons.dart';
import '../../../routes/app_routes.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';

/// A resumable item shown in the Continue Journey section.
class _ResumableItem extends StatelessWidget {
  const _ResumableItem({
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
      label: 'Resume: $title',
      button: onTap != null,
      enabled: onTap != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: PhoenixSpacing.sm,
              horizontal: PhoenixSpacing.xs,
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
                          fontWeight: FontWeight.w600,
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
                const SizedBox(width: PhoenixSpacing.sm),
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

/// Continue Journey card for the Phoenix Command Center.
///
/// Displays what the user can resume:
/// - Lesson (from Academy)
/// - Mission (from Mission Center)
/// - Project (from Portfolio)
/// - Interview Prep
///
/// Shows a "Start Exploring" CTA if nothing is available to resume.
class ContinueJourneyCard extends StatelessWidget {
  const ContinueJourneyCard({
    super.key,
    this.currentLessonTitle,
    this.currentLessonPath,
    this.activeMissionTitle,
    this.featuredProjectTitle,
    this.interviewReadiness,
    this.onContinueLesson,
    this.onContinueMission,
    this.onContinueProject,
    this.onContinueInterview,
  });

  /// The title of the current lesson the user is taking.
  final String? currentLessonTitle;

  /// The path name for the current lesson.
  final String? currentLessonPath;

  /// The title of the active mission.
  final String? activeMissionTitle;

  /// The title of the featured project.
  final String? featuredProjectTitle;

  /// Interview readiness percentage (0.0–1.0) — shown if >= 0.5.
  final double? interviewReadiness;

  /// Called when the lesson item is tapped.
  final VoidCallback? onContinueLesson;

  /// Called when the mission item is tapped.
  final VoidCallback? onContinueMission;

  /// Called when the project item is tapped.
  final VoidCallback? onContinueProject;

  /// Called when the interview item is tapped.
  final VoidCallback? onContinueInterview;

  @override
  Widget build(BuildContext context) {
    final hasLesson = currentLessonTitle != null;
    final hasMission = activeMissionTitle != null;
    final hasProject = featuredProjectTitle != null;
    final hasInterview = interviewReadiness != null && interviewReadiness! >= 0.5;
    final hasAnything = hasLesson || hasMission || hasProject || hasInterview;

    return PhoenixCard(
        header: 'Continue Journey',
        child: hasAnything
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasLesson)
                    _ResumableItem(
                      icon: Icons.school_rounded,
                      title: currentLessonTitle!,
                      subtitle: currentLessonPath ?? 'Resume learning',
                      color: PhoenixColors.primary,
                      onTap: onContinueLesson,
                    ),
                  if (hasLesson && (hasMission || hasProject || hasInterview))
                    const Divider(height: 1, indent: 48),

                  if (hasMission)
                    _ResumableItem(
                      icon: PhoenixIcons.mission,
                      title: activeMissionTitle!,
                      subtitle: 'Continue mission',
                      color: PhoenixColors.warning,
                      onTap: onContinueMission,
                    ),
                  if (hasMission && (hasProject || hasInterview))
                    const Divider(height: 1, indent: 48),

                  if (hasProject)
                    _ResumableItem(
                      icon: PhoenixIcons.launch,
                      title: featuredProjectTitle!,
                      subtitle: 'Continue project',
                      color: PhoenixColors.primary,
                      onTap: onContinueProject,
                    ),
                  if (hasProject && hasInterview)
                    const Divider(height: 1, indent: 48),

                  if (hasInterview)
                    _ResumableItem(
                      icon: PhoenixIcons.interview,
                      title: 'Interview Prep',
                      subtitle: '${(interviewReadiness! * 100).round()}% readiness',
                      color: PhoenixColors.warning,
                      onTap: onContinueInterview,
                    ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: PhoenixSpacing.md),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.explore_outlined,
                          size: 20,
                          color: PhoenixColors.textSecondary,
                        ),
                        const SizedBox(width: PhoenixSpacing.sm),
                        Text(
                          'Start your journey',
                          style: PhoenixTypography.bodySmall.copyWith(
                            color: PhoenixColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: PhoenixSpacing.md),
                    PhoenixPrimaryButton(
                      onPressed: () {
                        if (onContinueMission != null) {
                          onContinueMission!();
                        } else {
                          Navigator.of(context).pushNamed(AppRoutes.academy);
                        }
                      },
                      label: 'Start Exploring',
                      icon: Icons.rocket_launch_outlined,
                      fullWidth: true,
                    ),
                  ],
                ),
              ),
    );
  }
}
