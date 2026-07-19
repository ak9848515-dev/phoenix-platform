import 'package:flutter/material.dart';
import '../../../theme/spacing.dart';
import '../models/daily_journey_snapshot.dart';

/// AI Daily Summary — personalized greeting with today's priorities.
class DailySummaryCard extends StatelessWidget {
  const DailySummaryCard({super.key, required this.snapshot});

  final DailyJourneySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brief = snapshot.dailyBrief;

    // Build smart summary
    final parts = <String>[];
    if (snapshot.todaysMission.isNotEmpty) {
      parts.add('Complete "${snapshot.todaysMission}"');
    }
    if (snapshot.hasInterviewData && snapshot.interviewReadiness < 0.6) {
      parts.add('Practice interview skills');
    }
    if (snapshot.journeyCompletion < 0.5) {
      parts.add('Continue your journey');
    }
    if (snapshot.hasOpportunityData && snapshot.opportunityMatchScore > 0.6) {
      parts.add('Review matching opportunities');
    }

    final summary = parts.isNotEmpty
        ? '${parts.take(3).join(', ')}.'
        : 'Start learning to build your profile.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withAlpha(60),
            theme.colorScheme.primaryContainer.withAlpha(20),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('Daily Summary',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(summary,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
          const SizedBox(height: AppSpacing.sm),
          // Progress indicators
          Row(
            children: [
              _miniStat(theme, '${snapshot.plan.total}', 'Tasks', Icons.checklist_rounded),
              const SizedBox(width: AppSpacing.md),
              _miniStat(theme, '${brief.totalXp}', 'XP Today', Icons.star_outline),
              const SizedBox(width: AppSpacing.md),
              _miniStat(theme, '${(snapshot.dailyCompletionPercent * 100).round()}%', 'Progress',
                  Icons.trending_up_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(ThemeData theme, String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(height: 4),
          Text(value,
              style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
