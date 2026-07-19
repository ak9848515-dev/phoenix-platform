import 'package:flutter/material.dart';

import '../../../shared/widgets/experience/experience_secondary_button.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../../core/design/theme/phoenix_spacing.dart';

class MissionActionsCard extends StatelessWidget {
  const MissionActionsCard({
    super.key,
    required this.onContinueMission,
    required this.onDashboard,
    required this.onLearn,
    required this.onProfile,
  });

  final VoidCallback onContinueMission;
  final VoidCallback onDashboard;
  final VoidCallback onLearn;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: theme.textTheme.titleMedium),
          const SizedBox(height: PhoenixSpacing.md),
          PhoenixPrimaryButton(
            onPressed: onContinueMission,
            label: 'Continue Mission',
            icon: Icons.play_arrow_outlined,
            fullWidth: true,
          ),
          const SizedBox(height: PhoenixSpacing.sm),
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
                    const SizedBox(width: PhoenixSpacing.sm),
                    Expanded(
                      child: ExperienceSecondaryButton(
                        icon: Icons.school_outlined,
                        label: 'Learn',
                        onTap: onLearn,
                      ),
                    ),
                    const SizedBox(width: PhoenixSpacing.sm),
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
                  const SizedBox(height: PhoenixSpacing.sm),
                  ExperienceSecondaryButton(
                    icon: Icons.school_outlined,
                    label: 'Learn',
                    onTap: onLearn,
                  ),
                  const SizedBox(height: PhoenixSpacing.sm),
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
