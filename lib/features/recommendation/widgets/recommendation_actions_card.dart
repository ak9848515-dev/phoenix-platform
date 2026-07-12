import 'package:flutter/material.dart';

import '../../../shared/widgets/experience/experience_secondary_button.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../../theme/spacing.dart';
import '../models/recommendation.dart';

/// Displays action buttons for the current recommendation.
class RecommendationActionsCard extends StatelessWidget {
  const RecommendationActionsCard({
    super.key,
    required this.recommendation,
    required this.onStart,
    required this.onDismiss,
  });

  /// The recommendation to show actions for.
  final Recommendation recommendation;

  /// Called when the user starts the recommended action.
  final VoidCallback onStart;

  /// Called when the user dismisses the recommendation.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.touch_app_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Actions', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PhoenixPrimaryButton(
            onPressed: onStart,
            label: recommendation.actionLabel,
            icon: Icons.play_arrow_outlined,
            fullWidth: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          ExperienceSecondaryButton(
            icon: Icons.close_outlined,
            label: 'Dismiss',
            onTap: onDismiss,
          ),
        ],
      ),
    );
  }
}
