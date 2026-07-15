import 'package:flutter/material.dart';

import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_icons.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../core/design/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_bar.dart';
import '../../../core/design/widgets/phoenix_stat_tile.dart';

/// Displays the user's portfolio snapshot: projects completed,
/// portfolio completion score, and featured/recent project.
///
/// Reads from [PortfolioService.buildPortfolio()].
/// Presentation-only — no business logic.
class PortfolioSnapshotCard extends StatelessWidget {
  const PortfolioSnapshotCard({
    super.key,
    required this.portfolioScore,
    required this.projectCount,
    required this.achievementCount,
    required this.technologyCount,
    required this.featuredProjectTitle,
    this.onViewPortfolio,
    this.onProjectsTap,
    this.onAchievementsTap,
    this.onTechnologiesTap,
  });

  /// Portfolio score from 0.0 to 1.0.
  final double portfolioScore;

  /// Number of completed projects.
  final int projectCount;

  /// Number of achievements.
  final int achievementCount;

  /// Number of technologies.
  final int technologyCount;

  /// Title of the featured/recent project.
  final String featuredProjectTitle;

  /// Navigate to the full portfolio screen.
  final VoidCallback? onViewPortfolio;

  /// Called when the Projects stat tile is tapped.
  final VoidCallback? onProjectsTap;

  /// Called when the Achievements stat tile is tapped.
  final VoidCallback? onAchievementsTap;

  /// Called when the Technologies stat tile is tapped.
  final VoidCallback? onTechnologiesTap;

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 200),
      child: PhoenixCard(
        header: 'Portfolio Snapshot',
        action: onViewPortfolio != null
            ? TextButton(
                onPressed: onViewPortfolio,
                child: Text(
                  'View All',
                  style: PhoenixTypography.label.copyWith(
                    color: PhoenixColors.primary,
                  ),
                ),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stats Row ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TappableStatTile(
                  onTap: onProjectsTap,
                  child: PhoenixStatTile(
                    icon: PhoenixIcons.launch,
                    label: 'Projects',
                    value: '$projectCount',
                    color: PhoenixColors.primary,
                  ),
                ),
                _verticalDivider(),
                _TappableStatTile(
                  onTap: onAchievementsTap,
                  child: PhoenixStatTile(
                    icon: PhoenixIcons.achievement,
                    label: 'Achievements',
                    value: '$achievementCount',
                    color: PhoenixColors.gold,
                  ),
                ),
                _verticalDivider(),
                _TappableStatTile(
                  onTap: onTechnologiesTap,
                  child: PhoenixStatTile(
                    icon: PhoenixIcons.knowledge,
                    label: 'Technologies',
                    value: '$technologyCount',
                    color: PhoenixColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: PhoenixSpacing.lg),

            // ── Completion Score ───────────────────────────────────
            PhoenixProgressBar(
              value: portfolioScore,
              label: 'Portfolio Completion',
              showPercentage: true,
              minHeight: 6,
              animationDuration: const Duration(milliseconds: 800),
            ),
            SizedBox(height: PhoenixSpacing.md),

            // ── Featured Project ───────────────────────────────────
            if (featuredProjectTitle.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(PhoenixSpacing.md),
                decoration: BoxDecoration(
                  color: PhoenixColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(PhoenixSpacing.sm),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhoenixIcons.launch,
                      size: 16,
                      color: PhoenixColors.primary,
                    ),
                    SizedBox(width: PhoenixSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Featured Project',
                            style: PhoenixTypography.caption.copyWith(
                              color: PhoenixColors.textSecondary,
                            ),
                          ),
                          Text(
                            featuredProjectTitle,
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
            ],
          ],
        ),
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 48,
      color: PhoenixColors.border,
    );
  }
}

/// Wraps a stat tile in an [InkWell] to make it interactive.
class _TappableStatTile extends StatelessWidget {
  const _TappableStatTile({
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: child,
      ),
    );
  }
}
