import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../../shared/widgets/experience/experience_secondary_button.dart';

/// Action buttons for navigating to related portfolio experiences.
class PortfolioActionsCard extends StatelessWidget {
  const PortfolioActionsCard({
    super.key,
    required this.onDashboard,
    required this.onCareer,
    required this.onJourney,
    required this.onProgress,
  });

  final VoidCallback onDashboard;
  final VoidCallback onCareer;
  final VoidCallback onJourney;
  final VoidCallback onProgress;

  @override
  Widget build(BuildContext context) {
    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Explore More', style: Theme.of(context).textTheme.titleMedium),
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
                  icon: Icons.trending_up_outlined,
                  label: 'Career',
                  onTap: onCareer,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ExperienceSecondaryButton(
                  icon: Icons.route_outlined,
                  label: 'Journey',
                  onTap: onJourney,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ExperienceSecondaryButton(
                  icon: Icons.bar_chart_outlined,
                  label: 'Progress',
                  onTap: onProgress,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
