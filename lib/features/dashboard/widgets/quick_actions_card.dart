import 'package:flutter/material.dart';

import '../../../shared/widgets/experience/experience_secondary_button.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/spacing.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({
    super.key,
    required this.onMission,
    required this.onLearn,
    required this.onProgress,
    required this.onProfile,
  });

  final VoidCallback onMission;
  final VoidCallback onLearn;
  final VoidCallback onProgress;
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
          LayoutBuilder(
            builder: (context, constraints) {
              final useTwoColumns = constraints.maxWidth >= 400;

              if (useTwoColumns) {
                return Column(
                  children: [
                    Row(
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
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: ExperienceSecondaryButton(
                            icon: Icons.trending_up_outlined,
                            label: 'Progress',
                            onTap: onProgress,
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
