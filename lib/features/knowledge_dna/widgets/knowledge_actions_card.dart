import 'package:flutter/material.dart';

import '../../../shared/widgets/experience/experience_secondary_button.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../../theme/spacing.dart';

class KnowledgeActionsCard extends StatelessWidget {
  const KnowledgeActionsCard({
    super.key,
    required this.onDashboard,
    required this.onMission,
    required this.onLearn,
    required this.onProgress,
  });

  final VoidCallback onDashboard;
  final VoidCallback onMission;
  final VoidCallback onLearn;
  final VoidCallback onProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          PhoenixPrimaryButton(
            onPressed: onDashboard,
            label: 'Dashboard',
            icon: Icons.dashboard_outlined,
            fullWidth: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final useTwoColumns = constraints.maxWidth >= 400;

              if (useTwoColumns) {
                return Row(
                  children: [
                    Expanded(
                      child: ExperienceSecondaryButton(
                        icon: Icons.rocket_launch_outlined,
                        label: 'Mission',
                        onTap: onMission,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ExperienceSecondaryButton(
                        icon: Icons.school_outlined,
                        label: 'Learn',
                        onTap: onLearn,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ExperienceSecondaryButton(
                        icon: Icons.trending_up_outlined,
                        label: 'Progress',
                        onTap: onProgress,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  ExperienceSecondaryButton(
                    icon: Icons.rocket_launch_outlined,
                    label: 'Mission',
                    onTap: onMission,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ExperienceSecondaryButton(
                    icon: Icons.school_outlined,
                    label: 'Learn',
                    onTap: onLearn,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ExperienceSecondaryButton(
                    icon: Icons.trending_up_outlined,
                    label: 'Progress',
                    onTap: onProgress,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
