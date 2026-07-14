import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/habit_entry.dart';

/// A compact monthly calendar showing habit completion dots.
class HabitCalendar extends StatelessWidget {
  const HabitCalendar({
    super.key,
    required this.entries,
    this.year,
    this.month,
    this.onDayTap,
  });

  final List<HabitEntry> entries;
  final int? year;
  final int? month;
  final void Function(DateTime date)? onDayTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final y = year ?? now.year;
    final m = month ?? now.month;

    final firstDay = DateTime(y, m, 1);
    final lastDay = DateTime(y, m + 1, 0);
    final daysInMonth = lastDay.day;
    final startWeekday = firstDay.weekday; // 1=Mon ... 7=Sun

    // Build set of completed date keys
    final completedKeys = <String>{};
    final skipKeys = <String>{};
    for (final entry in entries) {
      if (entry.completed) completedKeys.add(entry.dateKey);
      if (entry.skipped) skipKeys.add(entry.dateKey);
    }

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return Column(
      children: [
        // Month header
        Row(
          children: [
            Text(
              '${months[m - 1]} $y',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // Day of week headers
        Row(
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.xs),
        // Calendar grid
        ...List.generate(_numRows(startWeekday, daysInMonth), (row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: List.generate(7, (col) {
                final dayNum = row * 7 + col - (startWeekday - 1) + 1;
                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const Expanded(child: SizedBox());
                }

                final date = DateTime(y, m, dayNum);
                final key = _dateKey(date);
                final isCompleted = completedKeys.contains(key);
                final isSkipped = skipKeys.contains(key);
                final isToday = date == DateTime(now.year, now.month, now.day);

                return Expanded(
                  child: GestureDetector(
                    onTap: onDayTap != null ? () => onDayTap!(date) : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$dayNum',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: isToday ? FontWeight.bold : null,
                              color: isToday
                                  ? AppColors.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (isCompleted)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.success,
                              ),
                            )
                          else if (isSkipped)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                              ),
                            )
                          else
                            const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  int _numRows(int startWeekday, int daysInMonth) {
    final totalCells = startWeekday - 1 + daysInMonth;
    return (totalCells / 7).ceil();
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
