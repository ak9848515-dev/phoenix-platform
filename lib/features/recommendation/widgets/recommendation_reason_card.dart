import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/spacing.dart';
import '../models/recommendation.dart';

/// Displays the reasoning behind a specific recommendation.
///
/// Every recommendation includes a clear explanation so users understand
/// *why* Phoenix suggested it.
class RecommendationReasonCard extends StatelessWidget {
  const RecommendationReasonCard({super.key, required this.recommendation});

  /// The recommendation whose reason to display.
  final Recommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.lightbulb_outlined,
                size: 20,
                color: Colors.amber.shade600,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Why this recommendation?',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            recommendation.reason,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              if (recommendation.relatedIdentity != null) ...[
                Icon(
                  Icons.person_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _formatIdentity(recommendation.relatedIdentity!),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              if (recommendation.relatedSkill != null) ...[
                Icon(
                  Icons.psychology_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  recommendation.relatedSkill!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatIdentity(String identityId) {
    // Convert identity IDs like "identity-software-engineer" to "Software Engineer"
    return identityId
        .replaceAll('identity-', '')
        .split('-')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }
}
