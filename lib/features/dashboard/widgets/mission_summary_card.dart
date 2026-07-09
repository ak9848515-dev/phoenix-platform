import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_indicator.dart';
import '../../../theme/spacing.dart';

class MissionSummaryCard extends StatelessWidget {
  const MissionSummaryCard({
    super.key,
    required this.missionsAvailable,
    required this.missionsCompleted,
    required this.completionPercentage,
  });

  final int missionsAvailable;
  final int missionsCompleted;
  final double completionPercentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (completionPercentage * 100).round();

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Mission Summary", style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$missionsCompleted of $missionsAvailable missions complete',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PhoenixProgressIndicator(value: completionPercentage),
          const SizedBox(height: AppSpacing.sm),
          Text('$percent% complete', style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}
