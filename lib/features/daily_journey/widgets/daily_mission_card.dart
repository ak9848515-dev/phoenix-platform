import 'package:flutter/material.dart';
import '../../../theme/spacing.dart';
import '../models/daily_journey_snapshot.dart';

/// Displays today's primary mission.
class DailyMissionCard extends StatelessWidget {
  const DailyMissionCard({super.key, required this.snapshot});

  final DailyJourneySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mission = snapshot.dailyBrief.todaysMission;
    final goal = snapshot.dailyBrief.todaysGoal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rocket_launch_outlined, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text("Today's Mission",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(mission, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
            if (goal.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.flag_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(goal,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
