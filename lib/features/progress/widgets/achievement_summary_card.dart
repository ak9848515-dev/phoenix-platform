import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/spacing.dart';

class AchievementSummaryCard extends StatelessWidget {
  const AchievementSummaryCard({
    super.key,
    required this.totalAchievements,
    required this.completedAchievements,
    required this.recentAchievements,
  });

  final int totalAchievements;
  final int completedAchievements;
  final List<String> recentAchievements;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Achievements', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AchievementStat(
                value: totalAchievements.toString(),
                label: 'Total',
                icon: Icons.emoji_events_outlined,
                color: theme.colorScheme.primary,
                theme: theme,
              ),
              _AchievementStat(
                value: completedAchievements.toString(),
                label: 'Completed',
                icon: Icons.check_circle_outline,
                color: theme.colorScheme.tertiary,
                theme: theme,
              ),
            ],
          ),
          if (recentAchievements.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Divider(color: theme.colorScheme.outlineVariant),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Recent',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...recentAchievements
                .take(3)
                .map(
                  (achievement) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          size: 18,
                          color: theme.colorScheme.tertiary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            achievement,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _AchievementStat extends StatelessWidget {
  const _AchievementStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.theme,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
