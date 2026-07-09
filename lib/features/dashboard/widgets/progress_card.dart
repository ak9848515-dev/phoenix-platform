import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_indicator.dart';
import '../../../theme/spacing.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.currentLevel,
    required this.totalXp,
    required this.overallProgress,
  });

  final int currentLevel;
  final int totalXp;
  final double overallProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Level $currentLevel',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$totalXp XP',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PhoenixProgressIndicator(value: overallProgress),
        ],
      ),
    );
  }
}
