import 'package:flutter/material.dart';

import '../../../core/design/animations/slide_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_icons.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../core/design/widgets/phoenix_badge.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../../shared/widgets/phoenix_progress_bar.dart';

/// Displays the user's current featured mission with progress.
///
/// Reads from [MissionService] — no mission generation logic here.
class TodayMissionCard extends StatelessWidget {
  const TodayMissionCard({
    super.key,
    required this.missionTitle,
    required this.missionDescription,
    required this.progress,
    required this.isComplete,
    this.onTap,
    this.estimatedTime,
    this.rewardXp,
    this.difficulty,
    this.continueLabel,
  });

  /// The featured mission title.
  final String missionTitle;

  /// Short description of the current mission.
  final String missionDescription;

  /// Progress as a value between 0.0 and 1.0.
  final double progress;

  /// Whether the mission is complete.
  final bool isComplete;

  /// Optional tap handler for navigation to mission center.
  final VoidCallback? onTap;

  /// Estimated time to complete (e.g. "15 min").
  final String? estimatedTime;

  /// Reward XP on completion.
  final int? rewardXp;

  /// Difficulty label (e.g. "Beginner", "Intermediate", "Advanced").
  final String? difficulty;

  /// Custom label for the continue button (defaults to "Continue").
  final String? continueLabel;

  @override
  Widget build(BuildContext context) {
    final statusBadge = isComplete
        ? const PhoenixBadge(
            label: 'Complete',
            variant: BadgeVariant.success,
            isSmall: true,
          )
        : const PhoenixBadge(
            label: 'In Progress',
            variant: BadgeVariant.primary,
            isSmall: true,
          );

    final diffBadge = difficulty != null
        ? PhoenixBadge(
            label: difficulty!,
            variant: _difficultyVariant(difficulty!),
            isSmall: true,
          )
        : null;

    return SlideAnimation(
      offsetBegin: const Offset(0, 0.06),
      duration: const Duration(milliseconds: 500),
      child: Semantics(
        label: "Today's Mission: $missionTitle",
        hint: 'Double-tap to view mission details',
        button: onTap != null,
        enabled: onTap != null,
        child: GestureDetector(
          onTap: onTap,
          child: PhoenixCard(
            header: "Today's Mission",
            action: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (diffBadge != null) ...[
                  diffBadge,
                  const SizedBox(width: 8),
                ],
                statusBadge,
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title ──────────────────────────────────────────────
                Text(
                  missionTitle,
                  style: PhoenixTypography.h3.copyWith(
                    color: PhoenixColors.textPrimary,
                  ),
                ),
                SizedBox(height: PhoenixSpacing.sm),

                // ── Description ─────────────────────────────────────────
                Text(
                  missionDescription,
                  style: PhoenixTypography.bodySmall.copyWith(
                    color: PhoenixColors.textSecondary,
                  ),
                ),
                SizedBox(height: PhoenixSpacing.lg),

                // ── Meta Row: Estimated Time + Reward ─────────────────
                if (estimatedTime != null || rewardXp != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: PhoenixSpacing.md),
                    child: Row(
                      children: [
                        if (estimatedTime != null) ...[
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: PhoenixColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            estimatedTime!,
                            style: PhoenixTypography.caption.copyWith(
                              color: PhoenixColors.textSecondary,
                            ),
                          ),
                        ],
                        if (estimatedTime != null && rewardXp != null)
                          const SizedBox(width: PhoenixSpacing.md),
                        if (rewardXp != null) ...[
                          Icon(
                            PhoenixIcons.xp,
                            size: 14,
                            color: PhoenixColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$rewardXp XP',
                            style: PhoenixTypography.caption.copyWith(
                              color: PhoenixColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                // ── Progress ───────────────────────────────────────────
                PhoenixProgressBar(
                  value: progress,
                  minHeight: 6,
                  showPercentage: true,
                  label: 'Progress',
                  animationDuration: const Duration(milliseconds: 800),
                ),
                SizedBox(height: PhoenixSpacing.md),

                // ── Continue Button ────────────────────────────────────
                PhoenixPrimaryButton(
                  onPressed: onTap ?? () {},
                  label: continueLabel ?? (isComplete ? 'View' : 'Continue'),
                  icon: isComplete
                      ? Icons.visibility_outlined
                      : Icons.play_arrow_outlined,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BadgeVariant _difficultyVariant(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
      case 'easy':
        return BadgeVariant.success;
      case 'intermediate':
      case 'medium':
        return BadgeVariant.warning;
      case 'advanced':
      case 'hard':
      case 'expert':
        return BadgeVariant.error;
      default:
        return BadgeVariant.neutral;
    }
  }
}
