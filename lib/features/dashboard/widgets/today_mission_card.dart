import 'package:flutter/material.dart';

import '../../../core/design/animations/slide_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../core/design/widgets/phoenix_badge.dart';
import '../../../shared/widgets/phoenix_card.dart';
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

    return SlideAnimation(
      offsetBegin: const Offset(0, 0.06),
      duration: const Duration(milliseconds: 500),
      child: Semantics(
        label: 'Today\'s Mission: $missionTitle',
        hint: 'Double-tap to view mission details',
        button: onTap != null,
        enabled: onTap != null,
        child: GestureDetector(
        onTap: onTap,
        child: PhoenixCard(
        header: "Today's Mission",
        action: statusBadge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ────────────────────────────────────────────────
            Text(
              missionTitle,
              style: PhoenixTypography.h3.copyWith(
                color: PhoenixColors.textPrimary,
              ),
            ),
            SizedBox(height: PhoenixSpacing.sm),

            // ── Description ──────────────────────────────────────────
            Text(
              missionDescription,
              style: PhoenixTypography.bodySmall.copyWith(
                color: PhoenixColors.textSecondary,
              ),
            ),
            SizedBox(height: PhoenixSpacing.lg),

            // ── Progress ─────────────────────────────────────────────
            PhoenixProgressBar(
              value: progress,
              minHeight: 6,
              showPercentage: true,
              label: 'Progress',
              animationDuration: const Duration(milliseconds: 800),
            ),
          ],
        ),
      ),
      ),
      ),
    );
  }
}
