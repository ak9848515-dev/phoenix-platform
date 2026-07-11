import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_indicator.dart';
import '../../../theme/spacing.dart';

class XpSummaryCard extends StatelessWidget {
  const XpSummaryCard({
    super.key,
    required this.currentXp,
    required this.xpToNextLevel,
    required this.progressPercentage,
  });

  final int currentXp;
  final int xpToNextLevel;
  final double progressPercentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (progressPercentage * 100).round();

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('XP Summary', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentXp.toString(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Current XP',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    xpToNextLevel.toString(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                  Text(
                    'XP to next level',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PhoenixProgressIndicator(value: progressPercentage),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$percent% toward next level',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
