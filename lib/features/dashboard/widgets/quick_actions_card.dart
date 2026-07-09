import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../../theme/spacing.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({
    super.key,
    required this.onContinueLearning,
    required this.onViewAcademy,
    required this.onViewMissions,
  });

  final VoidCallback onContinueLearning;
  final VoidCallback onViewAcademy;
  final VoidCallback onViewMissions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              PhoenixPrimaryButton(
                onPressed: onContinueLearning,
                label: 'Continue Learning',
                icon: Icons.play_arrow_outlined,
              ),
              PhoenixPrimaryButton(
                onPressed: onViewAcademy,
                label: 'View Academy',
                icon: Icons.school_outlined,
              ),
              PhoenixPrimaryButton(
                onPressed: onViewMissions,
                label: 'View Missions',
                icon: Icons.rocket_launch_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
