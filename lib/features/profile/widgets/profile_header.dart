import 'package:flutter/material.dart';

import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_icons.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../core/design/widgets/phoenix_badge.dart';
import '../../../core/design/widgets/phoenix_card.dart';

/// Displays the user's profile header with avatar, identity title,
/// journey stage, and current level badge.
///
/// Reads from [Repository.selectedIdentity] and [Repository.journey].
/// Presentation-only — no business logic.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.identityTitle,
    required this.journeyStage,
    required this.currentLevel,
    required this.journeyCompletion,
    this.onEditProfile,
  });

  /// The user's identity title (e.g. "Flutter Developer").
  final String identityTitle;

  /// The current journey stage name (e.g. "Dart").
  final String journeyStage;

  /// The user's current level number.
  final int currentLevel;

  /// Journey completion as a value between 0.0 and 1.0.
  final double journeyCompletion;

  /// Optional handler for editing the profile.
  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    final journeyPercent = (journeyCompletion * 100).round();

    return FadeAnimation(
      duration: const Duration(milliseconds: 500),
      child: PhoenixCard(
        padding: const EdgeInsets.all(PhoenixSpacing.xl),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ─────────────────────────────────────────────
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: PhoenixColors.primaryContainer(0.1),
                borderRadius: PhoenixRadius.lgRadius,
              ),
              child: Center(
                child: Icon(
                  PhoenixIcons.profile,
                  size: 32,
                  color: PhoenixColors.primary,
                ),
              ),
            ),
            SizedBox(width: PhoenixSpacing.lg),

            // ── Info ───────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Identity title
                  Text(
                    identityTitle,
                    style: PhoenixTypography.h2.copyWith(
                      color: PhoenixColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: PhoenixSpacing.xs),

                  // Journey stage
                  Row(
                    children: [
                      Icon(
                        PhoenixIcons.mission,
                        size: 14,
                        color: PhoenixColors.textSecondary,
                      ),
                      SizedBox(width: PhoenixSpacing.xs),
                      Text(
                        'Stage: $journeyStage',
                        style: PhoenixTypography.bodySmall.copyWith(
                          color: PhoenixColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: PhoenixSpacing.sm),

                  // Level badge + journey progress
                  Row(
                    children: [
                      PhoenixBadge(
                        label: 'Level $currentLevel',
                        variant: BadgeVariant.primary,
                        icon: PhoenixIcons.star,
                        isSmall: true,
                      ),
                      SizedBox(width: PhoenixSpacing.sm),
                      PhoenixBadge(
                        label: '$journeyPercent% Journey',
                        variant: BadgeVariant.neutral,
                        isSmall: true,
                      ),
                    ],
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
