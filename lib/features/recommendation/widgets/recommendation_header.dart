import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';

/// Header for the Recommendation Screen.
///
/// Asks the core question: "What is the highest impact thing you should do next?"
class RecommendationHeader extends StatelessWidget {
  const RecommendationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.auto_awesome_outlined,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Recommendations',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'What is the highest impact thing you should do next?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
