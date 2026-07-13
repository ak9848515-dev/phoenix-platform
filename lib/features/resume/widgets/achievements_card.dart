import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../shared/widgets/phoenix_card.dart';

/// Displays the user's achievements on the resume.
class AchievementsCard extends StatelessWidget {
  const AchievementsCard({super.key, required this.achievements});

  final List<String> achievements;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (achievements.isEmpty) return const SizedBox.shrink();

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Achievements', style: theme.textTheme.titleMedium),
              const Spacer(),
              Text(
                '${achievements.length} items',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...achievements.map(
            (achievement) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(achievement, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
