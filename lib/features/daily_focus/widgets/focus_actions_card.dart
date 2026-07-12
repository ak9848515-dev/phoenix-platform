import 'package:flutter/material.dart';

import '../../../shared/widgets/experience/experience_secondary_button.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../../theme/spacing.dart';

class FocusActionsCard extends StatelessWidget {
  const FocusActionsCard({
    super.key,
    required this.onStartFocus,
    required this.actionLabel,
    this.onDashboard,
    this.onJourney,
    this.onLearn,
  });

  final VoidCallback onStartFocus;
  final String actionLabel;
  final VoidCallback? onDashboard;
  final VoidCallback? onJourney;
  final VoidCallback? onLearn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Actions', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          PhoenixPrimaryButton(
            onPressed: onStartFocus,
            label: actionLabel,
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
                    if (onDashboard != null)
                      Expanded(
                        child: ExperienceSecondaryButton(
                          icon: Icons.dashboard_outlined,
                          label: 'Dashboard',
                          onTap: onDashboard!,
                        ),
                      ),
                    if (onDashboard != null && onJourney != null)
                      const SizedBox(width: AppSpacing.sm),
                    if (onJourney != null)
                      Expanded(
                        child: ExperienceSecondaryButton(
                          icon: Icons.route_outlined,
                          label: 'Journey',
                          onTap: onJourney!,
                        ),
                      ),
                    if (onJourney != null && onLearn != null)
                      const SizedBox(width: AppSpacing.sm),
                    if (onLearn != null)
                      Expanded(
                        child: ExperienceSecondaryButton(
                          icon: Icons.school_outlined,
                          label: 'Learn',
                          onTap: onLearn!,
                        ),
                      ),
                  ],
                );
              }

              return Column(
                children: [
                  if (onDashboard != null)
                    ExperienceSecondaryButton(
                      icon: Icons.dashboard_outlined,
                      label: 'Dashboard',
                      onTap: onDashboard!,
                    ),
                  if (onDashboard != null && onJourney != null)
                    const SizedBox(height: AppSpacing.sm),
                  if (onJourney != null)
                    ExperienceSecondaryButton(
                      icon: Icons.route_outlined,
                      label: 'Journey',
                      onTap: onJourney!,
                    ),
                  if (onJourney != null && onLearn != null)
                    const SizedBox(height: AppSpacing.sm),
                  if (onLearn != null)
                    ExperienceSecondaryButton(
                      icon: Icons.school_outlined,
                      label: 'Learn',
                      onTap: onLearn!,
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
