import 'package:flutter/material.dart';

import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_icons.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../shared/widgets/phoenix_card.dart';

/// A single brief item in the Daily Brief.
class _BriefItem extends StatelessWidget {
  const _BriefItem({
    required this.icon,
    required this.text,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: text,
      button: onTap != null,
      enabled: onTap != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 4,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 12, color: color),
                ),
                const SizedBox(width: PhoenixSpacing.sm),
                Expanded(
                  child: Text(
                    text,
                    style: PhoenixTypography.bodySmall.copyWith(
                      color: PhoenixColors.textPrimary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Phoenix Daily Brief card for the Command Center.
///
/// Displays today's concise summary with actionable items:
/// - Continue lesson
/// - Complete mission
/// - Review interview questions
/// - Complete habits
///
/// Each item is tappable and navigates to the relevant detail screen.
class DailyBriefCard extends StatelessWidget {
  const DailyBriefCard({
    super.key,
    this.currentLessonTitle,
    this.activeMissionTitle,
    this.pendingHabitCount,
    this.totalHabitCount,
    this.pendingDecisionCount,
    this.completedAchievements,
    this.onLessonTap,
    this.onMissionTap,
    this.onHabitsTap,
    this.onDecisionsTap,
    this.onAchievementsTap,
  });

  /// The current lesson title (if any).
  final String? currentLessonTitle;

  /// The active mission title (if any).
  final String? activeMissionTitle;

  /// Number of pending (not yet completed) habits today.
  final int? pendingHabitCount;

  /// Total number of habits today.
  final int? totalHabitCount;

  /// Number of pending decisions.
  final int? pendingDecisionCount;

  /// Number of achievements unlocked today.
  final int? completedAchievements;

  /// Called when the lesson item is tapped.
  final VoidCallback? onLessonTap;

  /// Called when the mission item is tapped.
  final VoidCallback? onMissionTap;

  /// Called when the habits item is tapped.
  final VoidCallback? onHabitsTap;

  /// Called when the decisions item is tapped.
  final VoidCallback? onDecisionsTap;

  /// Called when the achievements item is tapped.
  final VoidCallback? onAchievementsTap;

  @override
  Widget build(BuildContext context) {
    return PhoenixCard(
        header: "Today's Brief",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Continue Lesson ────────────────────────────────────
            if (currentLessonTitle != null)
              _BriefItem(
                icon: Icons.school_rounded,
                text: 'Continue $currentLessonTitle',
                color: PhoenixColors.primary,
                onTap: onLessonTap,
              ),

            // ── Complete Mission ───────────────────────────────────
            if (activeMissionTitle != null)
              _BriefItem(
                icon: PhoenixIcons.mission,
                text: 'Complete $activeMissionTitle',
                color: PhoenixColors.warning,
                onTap: onMissionTap,
              ),

            // ── Pending Habits ─────────────────────────────────────
            if (pendingHabitCount != null && totalHabitCount != null) ...[
              if (pendingHabitCount! > 0)
                _BriefItem(
                  icon: Icons.checklist_rounded,
                  text: '$pendingHabitCount of $totalHabitCount habits remaining today',
                  color: pendingHabitCount! > 2 ? PhoenixColors.error : PhoenixColors.warning,
                  onTap: onHabitsTap,
                )
              else
                _BriefItem(
                  icon: Icons.checklist_rounded,
                  text: 'All habits completed today',
                  color: PhoenixColors.success,
                  onTap: onHabitsTap,
                ),
            ],

            // ── Pending Decisions ──────────────────────────────────
            if (pendingDecisionCount != null && pendingDecisionCount! > 0)
              _BriefItem(
                icon: Icons.account_tree_rounded,
                text: '$pendingDecisionCount pending decision${pendingDecisionCount == 1 ? '' : 's'}',
                color: PhoenixColors.info,
                onTap: onDecisionsTap,
              ),

            // ── Achievements ───────────────────────────────────────
            if (completedAchievements != null && completedAchievements! > 0)
              _BriefItem(
                icon: PhoenixIcons.achievement,
                text: '$completedAchievements achievement${completedAchievements == 1 ? '' : 's'} unlocked',
                color: PhoenixColors.gold,
                onTap: onAchievementsTap,
              ),

            // ── No items fallback ──────────────────────────────────
            if (currentLessonTitle == null &&
                activeMissionTitle == null &&
                pendingHabitCount == null &&
                pendingDecisionCount == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: PhoenixSpacing.sm),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: PhoenixColors.success,
                    ),
                    const SizedBox(width: PhoenixSpacing.sm),
                    Text(
                      'All tasks completed — great work!',
                      style: PhoenixTypography.bodySmall.copyWith(
                        color: PhoenixColors.success,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
    );
  }
}
