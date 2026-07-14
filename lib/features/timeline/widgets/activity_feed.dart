import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../models/timeline_event.dart';
import 'timeline_card.dart';

/// A grouped activity feed showing events organized by date.
class ActivityFeed extends StatelessWidget {
  const ActivityFeed({
    super.key,
    required this.eventsByDay,
    this.onEventTap,
    this.maxDays = 7,
  });

  /// Events grouped by day (date string → events).
  final Map<String, List<TimelineEvent>> eventsByDay;

  /// Called when an event card is tapped.
  final void Function(TimelineEvent event)? onEventTap;

  /// Maximum number of days to show.
  final int maxDays;

  @override
  Widget build(BuildContext context) {
    final sortedDays = eventsByDay.keys.toList()..sort((a, b) => b.compareTo(a));
    final days = sortedDays.take(maxDays).toList();

    if (days.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No activity yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final dayEvents = eventsByDay[day]!;
        return _DayGroup(
          dateLabel: _formatDateLabel(day),
          events: dayEvents,
          onEventTap: onEventTap,
        );
      },
    );
  }

  String _formatDateLabel(String dateKey) {
    final parts = dateKey.split('-');
    if (parts.length != 3) return dateKey;
    final year = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 1;
    final day = int.tryParse(parts[2]) ?? 1;

    final date = DateTime(year, month, day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(date).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[month - 1]} $day, $year';
  }
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({
    required this.dateLabel,
    required this.events,
    this.onEventTap,
  });

  final String dateLabel;
  final List<TimelineEvent> events;
  final void Function(TimelineEvent event)? onEventTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(
            dateLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ...events.map((event) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: TimelineCard(
            event: event,
            onTap: onEventTap != null ? () => onEventTap!(event) : null,
          ),
        )),
      ],
    );
  }
}
