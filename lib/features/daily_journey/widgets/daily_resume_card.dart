import 'package:flutter/material.dart';
import '../../../theme/spacing.dart';
import '../models/daily_journey_snapshot.dart';

/// Resume improvement reminder card.
class DailyResumeCard extends StatelessWidget {
  const DailyResumeCard({super.key, required this.snapshot});

  final DailyJourneySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = snapshot.resumeHealthScore;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description_outlined, size: 24, color: Colors.teal),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Resume Health',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('Score: ${score.round()}%',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.teal)),
                ],
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('Review')),
          ],
        ),
      ),
    );
  }
}
