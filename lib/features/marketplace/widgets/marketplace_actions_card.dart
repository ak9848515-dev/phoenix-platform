import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../../shared/widgets/experience/experience_secondary_button.dart';

/// Action buttons for navigating to related marketplace experiences.
class MarketplaceActionsCard extends StatelessWidget {
  const MarketplaceActionsCard({
    super.key,
    required this.onDashboard,
    required this.onIdentity,
    required this.onJourney,
    required this.onCareer,
  });

  final VoidCallback onDashboard;
  final VoidCallback onIdentity;
  final VoidCallback onJourney;
  final VoidCallback onCareer;

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
            onPressed: onDashboard,
            label: 'Back to Dashboard',
            icon: Icons.dashboard_outlined,
            fullWidth: true,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ExperienceSecondaryButton(
                  icon: Icons.face_outlined,
                  label: 'Identity',
                  onTap: onIdentity,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ExperienceSecondaryButton(
                  icon: Icons.flag_outlined,
                  label: 'Journey',
                  onTap: onJourney,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ExperienceSecondaryButton(
                  icon: Icons.trending_up_outlined,
                  label: 'Career',
                  onTap: onCareer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
