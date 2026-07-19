import 'package:flutter/material.dart';
import '../../../theme/spacing.dart';
import '../models/daily_journey_snapshot.dart';

/// Displays the top matching opportunity.
class DailyOpportunityCard extends StatelessWidget {
  const DailyOpportunityCard({super.key, required this.snapshot});

  final DailyJourneySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchScore = snapshot.opportunityMatchScore;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.work_outline, size: 24, color: Colors.purple),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Top Opportunity',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('Match: ${(matchScore * 100).round()}%',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.purple)),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View'),
            ),
          ],
        ),
      ),
    );
  }
}
