import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../../shared/widgets/experience/experience_secondary_button.dart';

/// Action buttons for navigating to related interview experiences.
class InterviewActionsCard extends StatelessWidget {
  const InterviewActionsCard({
    super.key,
    required this.onDashboard,
    required this.onResume,
    required this.onCareer,
    required this.onPortfolio,
  });

  final VoidCallback onDashboard;
  final VoidCallback onResume;
  final VoidCallback onCareer;
  final VoidCallback onPortfolio;

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
                  icon: Icons.description_outlined,
                  label: 'Resume',
                  onTap: onResume,
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
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ExperienceSecondaryButton(
                  icon: Icons.auto_awesome,
                  label: 'Portfolio',
                  onTap: onPortfolio,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
