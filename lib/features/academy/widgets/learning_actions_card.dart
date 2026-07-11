import 'package:flutter/material.dart';

import '../../../shared/widgets/experience/experience_secondary_button.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../../theme/spacing.dart';

class LearningActionsCard extends StatelessWidget {
  const LearningActionsCard({
    super.key,
    required this.onContinueLearning,
    required this.onDashboard,
    required this.onMission,
    required this.onProfile,
  });

  final VoidCallback onContinueLearning;
  final VoidCallback onDashboard;
  final VoidCallback onMission;
  final VoidCallback onProfile;

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
            onPressed: onContinueLearning,
            label: 'Continue Learning',
            icon: Icons.play_arrow_outlined,
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
                        icon: Icons.dashboard_outlined,
                        label: 'Dashboard',
                        onTap: onDashboard,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
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
                        icon: Icons.person_outlined,
                        label: 'Profile',
                        onTap: onProfile,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  ExperienceSecondaryButton(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    onTap: onDashboard,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ExperienceSecondaryButton(
                    icon: Icons.rocket_launch_outlined,
                    label: 'Mission',
                    onTap: onMission,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ExperienceSecondaryButton(
                    icon: Icons.person_outlined,
                    label: 'Profile',
                    onTap: onProfile,
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
