import 'package:flutter/material.dart';

import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../core/design/widgets/phoenix_badge.dart';
import '../../../core/design/widgets/phoenix_card.dart';

/// Displays the AI Mentor home header with greeting, identity,
/// journey stage, daily focus, and a motivation message.
///
/// Presentation-only — all data comes from [AIMentorService].
class AIHomeHeader extends StatelessWidget {
  const AIHomeHeader({
    super.key,
    required this.greeting,
    required this.journeyStage,
    required this.dailyFocus,
    required this.motivation,
    required this.level,
    required this.journeyCompletion,
  });

  /// Time-based personalized greeting with identity title.
  final String greeting;

  /// Current journey stage name.
  final String journeyStage;

  /// Today's recommended focus.
  final String dailyFocus;

  /// Motivational message.
  final String motivation;

  /// Current level number.
  final int level;

  /// Journey completion fraction (0.0–1.0).
  final double journeyCompletion;

  @override
  Widget build(BuildContext context) {
    final journeyPercent = (journeyCompletion * 100).round();

    return FadeAnimation(
      duration: const Duration(milliseconds: 500),
      child: PhoenixCard(
        padding: const EdgeInsets.all(PhoenixSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting + Level Badge ──────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    greeting,
                    style: PhoenixTypography.h2.copyWith(
                      color: PhoenixColors.textPrimary,
                    ),
                  ),
                ),
                PhoenixBadge(
                  label: 'Level $level',
                  variant: BadgeVariant.primary,
                  isSmall: true,
                ),
              ],
            ),
            SizedBox(height: PhoenixSpacing.sm),

            // ── Journey Stage ──────────────────────────────────────
            Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  size: 16,
                  color: PhoenixColors.primary,
                ),
                SizedBox(width: PhoenixSpacing.xs),
                Text(
                  'Stage: $journeyStage • $journeyPercent% complete',
                  style: PhoenixTypography.bodySmall.copyWith(
                    color: PhoenixColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: PhoenixSpacing.lg),

            // ── Daily Focus ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(PhoenixSpacing.md),
              decoration: BoxDecoration(
                color: PhoenixColors.primaryContainer(0.08),
                borderRadius: PhoenixRadius.smRadius,
                border: Border.all(
                  color: PhoenixColors.primary.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: PhoenixColors.primary,
                  ),
                  SizedBox(width: PhoenixSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Focus',
                          style: PhoenixTypography.caption.copyWith(
                            color: PhoenixColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          dailyFocus,
                          style: PhoenixTypography.label.copyWith(
                            color: PhoenixColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: PhoenixSpacing.md),

            // ── Motivation ─────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  size: 16,
                  color: PhoenixColors.textDisabled,
                ),
                SizedBox(width: PhoenixSpacing.sm),
                Expanded(
                  child: Text(
                    motivation,
                    style: PhoenixTypography.bodySmall.copyWith(
                      color: PhoenixColors.textSecondary,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
