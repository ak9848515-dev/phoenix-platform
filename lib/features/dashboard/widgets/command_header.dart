import 'package:flutter/material.dart';

import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_icons.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_bar.dart';

/// The Phoenix Command Center header.
///
/// Answers: Who am I? Who am I becoming?
///
/// Displays:
/// - Time-based greeting (Good morning/afternoon/evening)
/// - User identity title
/// - Current goal (from journey stage)
/// - Current level badge with XP indicator
class CommandHeader extends StatelessWidget {
  const CommandHeader({
    super.key,
    required this.userName,
    required this.currentIdentity,
    required this.currentGoal,
    required this.currentLevel,
    this.totalXp,
    this.xpProgress,
    this.nextLevelXp,
  });

  /// The user's name or identity title.
  final String userName;

  /// The user's current identity title (e.g. "Flutter Engineer").
  final String currentIdentity;

  /// The user's current goal (from journey stage).
  final String currentGoal;

  /// The user's current level.
  final int currentLevel;

  /// Optional total XP for detailed display.
  final int? totalXp;

  /// XP progress toward next level (0.0–1.0).
  final double? xpProgress;

  /// XP needed for next level, shown on the progress bar.
  final int? nextLevelXp;

  /// Returns a time-appropriate greeting string.
  static String timeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final greeting = timeBasedGreeting();

    return PhoenixCard(
        padding: const EdgeInsets.all(PhoenixSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting ────────────────────────────────────────────
            Text(
              greeting,
              style: PhoenixTypography.h2.copyWith(
                color: PhoenixColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),

            // ── User Name ───────────────────────────────────────────
            Text(
              userName,
              style: PhoenixTypography.h1.copyWith(
                color: PhoenixColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: PhoenixSpacing.md),

            // ── Identity & Goal Row ────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(PhoenixSpacing.md),
              decoration: BoxDecoration(
                color: PhoenixColors.surfaceVariant,
                borderRadius: PhoenixRadius.mdRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Identity
                  Row(
                    children: [
                      Icon(
                        PhoenixIcons.profile,
                        size: 16,
                        color: PhoenixColors.primary,
                      ),
                      const SizedBox(width: PhoenixSpacing.sm),
                      Text(
                        currentIdentity,
                        style: PhoenixTypography.label.copyWith(
                          color: PhoenixColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: PhoenixSpacing.sm),

                  // Current Goal
                  Row(
                    children: [
                      Icon(
                        PhoenixIcons.target,
                        size: 16,
                        color: PhoenixColors.warning,
                      ),
                      const SizedBox(width: PhoenixSpacing.sm),
                      Expanded(
                        child: Text(
                          currentGoal,
                          style: PhoenixTypography.bodySmall.copyWith(
                            color: PhoenixColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: PhoenixSpacing.md),

            // ── Level Badge Row ─────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PhoenixSpacing.md,
                    vertical: PhoenixSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PhoenixColors.primary,
                        PhoenixColors.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: PhoenixColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: PhoenixSpacing.sm),
                      Text(
                        'Level $currentLevel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (totalXp != null) ...[
                  const SizedBox(width: PhoenixSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PhoenixSpacing.md,
                      vertical: PhoenixSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: PhoenixColors.primaryContainer(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhoenixIcons.xp,
                          size: 16,
                          color: PhoenixColors.primary,
                        ),
                        const SizedBox(width: PhoenixSpacing.sm),
                        Text(
                          _formatXp(totalXp!),
                          style: PhoenixTypography.label.copyWith(
                            color: PhoenixColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: PhoenixSpacing.md),

            // ── XP Progress Bar ────────────────────────────────────
            if (xpProgress != null) ...[
              PhoenixProgressBar(
                value: xpProgress!,
                label: nextLevelXp != null
                    ? 'XP to Level ${currentLevel + 1}'
                    : 'XP Progress',
                showPercentage: true,
                minHeight: 8,
                animationDuration: const Duration(milliseconds: 800),
              ),
            ],
          ],
        ),
    );
  }

  String _formatXp(int xp) {
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k XP';
    return '$xp XP';
  }
}
