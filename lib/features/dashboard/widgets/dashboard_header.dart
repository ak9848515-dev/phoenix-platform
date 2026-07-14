import 'package:flutter/material.dart';

import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../shared/widgets/phoenix_card.dart';

/// Dynamic greeting header for the Phoenix Dashboard.
///
/// Displays a time-based greeting ("Good morning/afternoon/evening"),
/// the user's identity title, and a motivational subtitle derived
/// from the user's current progress.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.userName,
    required this.motivationalSubtitle,
    this.greeting,
  });

  /// The user's name or identity title.
  final String userName;

  /// A dynamic motivational line based on progress.
  final String motivationalSubtitle;

  /// Optional override for the time-based greeting.
  final String? greeting;

  /// Returns a time-appropriate greeting string.
  static String timeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final displayGreeting = greeting ?? timeBasedGreeting();

    return FadeAnimation(
      duration: const Duration(milliseconds: 500),
      child: PhoenixCard(
        padding: const EdgeInsets.all(PhoenixSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting ──────────────────────────────────────────────
            Text(
              displayGreeting,
              style: PhoenixTypography.h1.copyWith(
                color: PhoenixColors.textPrimary,
              ),
            ),
            SizedBox(height: PhoenixSpacing.xs),

            // ── User Name ─────────────────────────────────────────────
            Text(
              userName,
              style: PhoenixTypography.h2.copyWith(
                color: PhoenixColors.primary,
              ),
            ),
            SizedBox(height: PhoenixSpacing.sm),

            // ── Motivational Subtitle ─────────────────────────────────
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: PhoenixSpacing.md,
                vertical: PhoenixSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: PhoenixColors.primaryContainer(0.08),
                borderRadius: PhoenixRadius.smRadius,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 16,
                    color: PhoenixColors.primary,
                  ),
                  SizedBox(width: PhoenixSpacing.sm),
                  Flexible(
                    child: Text(
                      motivationalSubtitle,
                      style: PhoenixTypography.bodySmall.copyWith(
                        color: PhoenixColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
