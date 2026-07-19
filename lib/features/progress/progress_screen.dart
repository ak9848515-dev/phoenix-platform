import 'package:flutter/material.dart';

import '../../core/bootstrap.dart';
import '../../core/design/theme/phoenix_colors.dart';
import '../../core/design/theme/phoenix_spacing.dart';
import '../../routes/app_routes.dart';

/// Progress Screen — clean, minimal growth overview.
///
/// PHX-087: Simplified. Shows only:
/// • Growth overview (level, XP, overall score)
/// • Quick links to key areas
///
/// No redundant sections, no dividers, maximum clarity.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final growthEngine = AppBootstrap.maybeGrowthEngine;
    final growthSnap = growthEngine?.snapshot;
    final identitySnap = AppBootstrap.maybeIdentityEngine?.snapshot;

    final level = growthSnap?.currentLevel ?? identitySnap?.level ?? 1;
    final totalXp = growthSnap?.totalXp ?? identitySnap?.totalXp ?? 0;
    final overallScore = growthSnap?.overallScore ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(PhoenixSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Growth Hero ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(PhoenixSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PhoenixColors.success.withValues(alpha: 0.08),
                  theme.colorScheme.surface,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: PhoenixColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.trending_up_rounded,
                        color: PhoenixColors.success,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: PhoenixSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level $level',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '$totalXp XP · ${(overallScore * 100).round()}% growth',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (growthSnap != null) ...[
                  const SizedBox(height: PhoenixSpacing.lg),
                  // Dimension chips
                  Wrap(
                    spacing: PhoenixSpacing.sm,
                    runSpacing: PhoenixSpacing.sm,
                    children: [
                      _DimensionChip(
                        label: 'Knowledge',
                        score: growthSnap.knowledge.score,
                      ),
                      _DimensionChip(
                        label: 'Career',
                        score: growthSnap.career.score,
                      ),
                      _DimensionChip(
                        label: 'Skills',
                        score: growthSnap.skills.score,
                      ),
                      _DimensionChip(
                        label: 'Portfolio',
                        score: growthSnap.portfolio.score,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: PhoenixSpacing.xxl),

          // ── Section Title ────────────────────────────────────────
          _buildSectionTitle(theme, 'Explore'),
          const SizedBox(height: PhoenixSpacing.md),

          // ── Navigation Grid ──────────────────────────────────────
          _NavCard(
            icon: Icons.work_outline_rounded,
            label: 'Career',
            subtitle: 'Readiness, resume, interviews',
            color: PhoenixColors.warning,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.career),
          ),
          const SizedBox(height: PhoenixSpacing.md),
          _NavCard(
            icon: Icons.folder_outlined,
            label: 'Portfolio',
            subtitle: 'Projects, skills, achievements',
            color: PhoenixColors.primary,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.portfolio),
          ),
          const SizedBox(height: PhoenixSpacing.md),
          _NavCard(
            icon: Icons.psychology_outlined,
            label: 'Knowledge',
            subtitle: 'Graph, skills, learning insights',
            color: PhoenixColors.info,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.knowledgeDna),
          ),
          const SizedBox(height: PhoenixSpacing.md),
          _NavCard(
            icon: Icons.timeline_rounded,
            label: 'Timeline',
            subtitle: 'Activity, milestones, history',
            color: PhoenixColors.warning,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.timeline),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        letterSpacing: 1.2,
      ),
    );
  }
}

/// Small colored chip showing a dimension score.
class _DimensionChip extends StatelessWidget {
  const _DimensionChip({
    required this.label,
    required this.score,
  });

  final String label;
  final double score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = score >= 0.6
        ? PhoenixColors.success
        : score >= 0.3
            ? PhoenixColors.warning
            : PhoenixColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label ${(score * 100).round()}%',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Navigation card for feature areas.
class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PhoenixSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: PhoenixSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
