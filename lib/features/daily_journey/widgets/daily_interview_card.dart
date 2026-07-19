import 'package:flutter/material.dart';
import '../../../theme/spacing.dart';
import '../models/daily_journey_snapshot.dart';

/// Interview practice reminder card.
class DailyInterviewCard extends StatelessWidget {
  const DailyInterviewCard({super.key, required this.snapshot});

  final DailyJourneySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readiness = snapshot.interviewReadiness;
    final isReady = snapshot.hasInterviewData && readiness >= 0.6;
    final needsPrep = snapshot.hasInterviewData && readiness < 0.4;
    final color = isReady ? Colors.green : needsPrep ? Colors.orange : Colors.blue;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.record_voice_over_rounded, size: 24, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Interview Practice',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    isReady
                        ? 'Ready at ${(readiness * 100).round()}%'
                        : needsPrep
                            ? 'Needs preparation (${(readiness * 100).round()}%)'
                            : 'Score: ${(readiness * 100).round()}%',
                    style: theme.textTheme.bodySmall?.copyWith(color: color),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Practice'),
            ),
          ],
        ),
      ),
    );
  }
}
