import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/spacing.dart';

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({
    super.key,
    required this.greeting,
    required this.currentLevel,
    required this.totalXp,
  });

  final String greeting;
  final int currentLevel;
  final int totalXp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Level $currentLevel • $totalXp XP',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
