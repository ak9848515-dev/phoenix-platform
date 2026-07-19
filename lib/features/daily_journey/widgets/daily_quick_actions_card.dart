import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/spacing.dart';
import '../models/daily_journey_snapshot.dart';

/// Quick action buttons for the Daily Journey.
class DailyQuickActionsCard extends StatelessWidget {
  const DailyQuickActionsCard({super.key, required this.snapshot});

  final DailyJourneySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on_rounded, size: 20, color: Colors.amber.shade700),
                const SizedBox(width: AppSpacing.sm),
                Text('Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _actionChip(context, 'Continue Mission', Icons.rocket_launch_outlined, AppRoutes.missionCenter),
                _actionChip(context, 'Start Learning', Icons.school_outlined, AppRoutes.academy),
                _actionChip(context, 'Practice Interview', Icons.record_voice_over_outlined, AppRoutes.interview),
                _actionChip(context, 'Improve Resume', Icons.description_outlined, AppRoutes.resume),
                _actionChip(context, 'Improve Portfolio', Icons.folder_outlined, AppRoutes.portfolio),
                if (snapshot.hasOpportunityData)
                  _actionChip(context, 'View Opportunities', Icons.work_outline, AppRoutes.opportunity),
                _actionChip(context, 'View Dashboard', Icons.dashboard_outlined, AppRoutes.dashboard),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionChip(BuildContext context, String label, IconData icon, String route) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () => Navigator.of(context).pushNamed(route),
    );
  }
}
