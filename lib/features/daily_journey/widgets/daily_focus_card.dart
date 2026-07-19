import 'package:flutter/material.dart';
import '../../../theme/spacing.dart';
import '../models/daily_journey_snapshot.dart';

/// Displays today's single focus item.
class DailyFocusCard extends StatelessWidget {
  const DailyFocusCard({super.key, required this.snapshot});

  final DailyJourneySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focus = snapshot.todaysFocus;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.track_changes_rounded, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text("Today's Focus",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(focus.isNotEmpty ? focus : 'Complete your profile to get started.',
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.4)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.schedule_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('Est. ${snapshot.plan.totalMinutes} min',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(width: AppSpacing.md),
                Icon(Icons.star_outline, size: 14, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('${snapshot.dailyBrief.totalXp} XP',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
