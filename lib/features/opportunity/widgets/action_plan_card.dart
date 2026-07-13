import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../models/opportunity.dart';

/// Displays recommended actions to improve opportunity readiness.
class ActionPlanCard extends StatelessWidget {
  const ActionPlanCard({super.key, required this.opportunities});

  final List<Opportunity> opportunities;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Collect unique recommended actions from all opportunities
    final allActions = <String>[];
    for (final opp in opportunities) {
      for (final action in opp.recommendedActions) {
        if (!allActions.contains(action)) {
          allActions.add(action);
        }
      }
    }

    if (allActions.isEmpty) return const SizedBox.shrink();

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Action Plan', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...allActions.take(5).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(action, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
