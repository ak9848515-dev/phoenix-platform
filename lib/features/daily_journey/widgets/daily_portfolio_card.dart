import 'package:flutter/material.dart';
import '../../../theme/spacing.dart';
import '../models/daily_journey_snapshot.dart';

/// Portfolio improvement reminder card.
class DailyPortfolioCard extends StatelessWidget {
  const DailyPortfolioCard({super.key, required this.snapshot});

  final DailyJourneySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = snapshot.portfolioScore;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.indigo.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.folder_outlined, size: 24, color: Colors.indigo),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Portfolio',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('Score: ${(score * 100).round()}%',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.indigo)),
                ],
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('View')),
          ],
        ),
      ),
    );
  }
}
