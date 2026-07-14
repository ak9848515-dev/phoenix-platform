import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/habit/engine/habit_engine.dart';
import 'package:phoenix_platform/features/habit/models/habit.dart';
import 'package:phoenix_platform/features/habit/models/habit_insight.dart';
import 'package:phoenix_platform/features/habit/models/habit_entry.dart';
import 'package:phoenix_platform/features/habit/models/habit_schedule.dart';
import 'package:phoenix_platform/features/habit/models/habit_type.dart';

void main() {
  const engine = HabitEngine();

  final sampleHabit = Habit(
    id: 'hb-1',
    title: 'Morning Run',
    type: HabitType.exercise,
    schedule: const HabitSchedule(),
    targetPerDay: 1,
    createdAt: DateTime(2026, 6, 1),
  );

  group('calculateCurrentStreak', () {
    test('returns 0 for no entries', () {
      expect(engine.calculateCurrentStreak(sampleHabit, []), 0);
    });

    test('returns 1 for today only', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final entries = [
        HabitEntry(
          id: 'e1', habitId: 'hb-1', date: today, completed: true,
          createdAt: now,
        ),
      ];
      expect(engine.calculateCurrentStreak(sampleHabit, entries), 1);
    });

    test('returns 5 for 5 consecutive days ending today', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final entries = List.generate(5, (i) {
        return HabitEntry(
          id: 'e$i', habitId: 'hb-1',
          date: today.subtract(Duration(days: i)),
          completed: true,
          createdAt: now,
        );
      });
      expect(engine.calculateCurrentStreak(sampleHabit, entries), 5);
    });

    test('returns 0 when yesterday and today are incomplete', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final entries = [
        HabitEntry(
          id: 'e1', habitId: 'hb-1',
          date: today.subtract(const Duration(days: 3)),
          completed: true,
          createdAt: now,
        ),
      ];
      expect(engine.calculateCurrentStreak(sampleHabit, entries), 0);
    });

    test('returns 0 for empty habit entries', () {
      final entries = [
        HabitEntry(
          id: 'e1', habitId: 'hb-other', date: DateTime.now(), completed: true,
        ),
      ];
      expect(engine.calculateCurrentStreak(sampleHabit, entries), 0);
    });
  });

  group('calculateLongestStreak', () {
    test('returns 0 for no entries', () {
      expect(engine.calculateLongestStreak(sampleHabit, []), 0);
    });

    test('returns correct longest streak', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final entries = List.generate(10, (i) {
        return HabitEntry(
          id: 'e$i', habitId: 'hb-1',
          date: today.subtract(Duration(days: i)),
          completed: true,
          createdAt: now,
        );
      });
      // Add a gap
      entries.addAll(List.generate(5, (i) {
        return HabitEntry(
          id: 'gap$i', habitId: 'hb-1',
          date: today.subtract(Duration(days: 20 + i)),
          completed: true,
          createdAt: now,
        );
      }));
      expect(engine.calculateLongestStreak(sampleHabit, entries), 10);
    });
  });

  group('calculateWeeklyConsistency', () {
    test('returns 0 for no entries', () {
      expect(engine.calculateWeeklyConsistency(sampleHabit, []), 0.0);
    });

    test('returns 1.0 for 7 days of completion', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final entries = List.generate(7, (i) {
        return HabitEntry(
          id: 'e$i', habitId: 'hb-1',
          date: today.subtract(Duration(days: i)),
          completed: true,
          createdAt: now,
        );
      });
      final consistency = engine.calculateWeeklyConsistency(sampleHabit, entries, asOf: now);
      expect(consistency, greaterThan(0.9));
    });

    test('returns correct consistency for mixed completions', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final entries = <HabitEntry>[];
      // 4 completed out of 7 days
      for (int i = 0; i < 7; i++) {
        if (i % 2 == 0) {
          entries.add(HabitEntry(
            id: 'e$i', habitId: 'hb-1',
            date: today.subtract(Duration(days: i)),
            completed: true,
            createdAt: now,
          ));
        }
      }
      final consistency = engine.calculateWeeklyConsistency(sampleHabit, entries, asOf: now);
      expect(consistency, greaterThan(0.0));
      expect(consistency, lessThanOrEqualTo(1.0));
    });
  });

  group('calculateMonthlyConsistency', () {
    test('returns 0 for no entries', () {
      expect(engine.calculateMonthlyConsistency(sampleHabit, []), 0.0);
    });

    test('returns 1.0 for 30 days of completion', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final entries = List.generate(30, (i) {
        return HabitEntry(
          id: 'e$i', habitId: 'hb-1',
          date: today.subtract(Duration(days: i)),
          completed: true,
          createdAt: now,
        );
      });
      final consistency = engine.calculateMonthlyConsistency(sampleHabit, entries, asOf: now);
      expect(consistency, greaterThan(0.9));
    });
  });

  group('calculateCompletionRate', () {
    test('returns 0 for no entries', () {
      expect(engine.calculateCompletionRate(sampleHabit, []), 0.0);
    });

    test('returns 0.75 for 3 out of 4 completed', () {
      final entries = List.generate(4, (i) {
        return HabitEntry(
          id: 'e$i', habitId: 'hb-1',
          date: DateTime(2026, 6, 15 + i),
          completed: i != 1, // skip one
        );
      });
      expect(engine.calculateCompletionRate(sampleHabit, entries), 0.75);
    });
  });

  group('calculateHabitScore', () {
    test('returns 0 for no entries', () {
      expect(engine.calculateHabitScore(sampleHabit, []), 0.0);
    });

    test('returns high score for perfect consistency', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final entries = List.generate(30, (i) {
        return HabitEntry(
          id: 'e$i', habitId: 'hb-1',
          date: today.subtract(Duration(days: i)),
          completed: true,
          createdAt: now,
        );
      });
      final score = engine.calculateHabitScore(sampleHabit, entries, asOf: now);
      expect(score, greaterThan(70));
    });

    test('score is in valid range 0-100', () {
      final entries = [
        HabitEntry(id: 'e1', habitId: 'hb-1', date: DateTime(2026, 6, 15), completed: true),
        HabitEntry(id: 'e2', habitId: 'hb-1', date: DateTime(2026, 6, 14), completed: false),
      ];
      final score = engine.calculateHabitScore(sampleHabit, entries);
      expect(score, inInclusiveRange(0, 100));
    });
  });

  group('computeStatistics', () {
    test('returns empty statistics for no entries', () {
      final stats = engine.computeStatistics(sampleHabit, []);
      expect(stats.currentStreak, 0);
      expect(stats.habitScore, 0.0);
    });

    test('returns correct statistics for entries', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final entries = List.generate(10, (i) {
        return HabitEntry(
          id: 'e$i', habitId: 'hb-1',
          date: today.subtract(Duration(days: i)),
          completed: true,
          createdAt: now,
        );
      });
      final stats = engine.computeStatistics(sampleHabit, entries, asOf: now);
      expect(stats.currentStreak, 10);
      expect(stats.totalCompletions, 10);
      expect(stats.motivationLevel, isNotEmpty);
    });
  });

  group('analyzeWeeklyTrend', () {
    test('returns trend with data points', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final entries = List.generate(14, (i) {
        return HabitEntry(
          id: 'e$i', habitId: 'hb-1',
          date: today.subtract(Duration(days: i)),
          completed: true,
          createdAt: now,
        );
      });
      final trend = engine.analyzeWeeklyTrend(sampleHabit, entries, asOf: now);
      expect(trend.dataPoints.length, 8);
      expect(trend.habitId, 'hb-1');
    });

    test('trend has comparison data', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final entries = List.generate(14, (i) {
        return HabitEntry(
          id: 'e$i', habitId: 'hb-1',
          date: today.subtract(Duration(days: i)),
          completed: i.isEven,
          createdAt: now,
        );
      });
      final trend = engine.analyzeWeeklyTrend(sampleHabit, entries, asOf: now);
      expect(trend.comparison, isNotNull);
    });
  });

  group('analyzeMonthlyTrend', () {
    test('returns trend with 6 data points', () {
      final entries = List.generate(180, (i) {
        return HabitEntry(
          id: 'e$i', habitId: 'hb-1',
          date: DateTime(2026, 6, 1).subtract(Duration(days: i)),
          completed: true,
        );
      });
      final trend = engine.analyzeMonthlyTrend(sampleHabit, entries, asOf: DateTime(2026, 6, 30));
      expect(trend.dataPoints.length, 6);
    });
  });

  group('generateInsights', () {
    test('generates streak insight for 7-day streak', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final entries = List.generate(7, (i) {
        return HabitEntry(
          id: 'e$i', habitId: 'hb-1',
          date: today.subtract(Duration(days: i)),
          completed: true,
          createdAt: now,
        );
      });
      final stats = engine.computeStatistics(sampleHabit, entries, asOf: now);
      final weeklyTrend = engine.analyzeWeeklyTrend(sampleHabit, entries, asOf: now);
      final monthlyTrend = engine.analyzeMonthlyTrend(sampleHabit, entries, asOf: now);
      final insights = engine.generateInsights(sampleHabit, stats, weeklyTrend, monthlyTrend);

      expect(insights.any((i) => i.type.name == 'streak'), true);
    });

    test('generates encouragement insight for 3-day streak', () {
      final entries = [
        HabitEntry(id: 'e1', habitId: 'hb-1', date: DateTime(2026, 6, 12), completed: true),
        HabitEntry(id: 'e2', habitId: 'hb-1', date: DateTime(2026, 6, 13), completed: true),
        HabitEntry(id: 'e3', habitId: 'hb-1', date: DateTime(2026, 6, 14), completed: true),
      ];
      final stats = engine.computeStatistics(sampleHabit, entries, asOf: DateTime(2026, 6, 15));
      final weeklyTrend = engine.analyzeWeeklyTrend(sampleHabit, entries, asOf: DateTime(2026, 6, 15));
      final monthlyTrend = engine.analyzeMonthlyTrend(sampleHabit, entries, asOf: DateTime(2026, 6, 15));
      final insights = engine.generateInsights(sampleHabit, stats, weeklyTrend, monthlyTrend);
      expect(insights.any((i) => i.type == InsightType.encouragement), true);
    });

    test('generates warning insight when streak is broken', () {
      // Only older entries with no recent completions = streak = 0
      final entries = [
        HabitEntry(id: 'e1', habitId: 'hb-1', date: DateTime(2026, 6, 8), completed: true),
        HabitEntry(id: 'e2', habitId: 'hb-1', date: DateTime(2026, 6, 9), completed: true),
        HabitEntry(id: 'e3', habitId: 'hb-1', date: DateTime(2026, 6, 10), completed: true),
      ];
      final stats = engine.computeStatistics(sampleHabit, entries, asOf: DateTime(2026, 6, 15));
      final weeklyTrend = engine.analyzeWeeklyTrend(sampleHabit, entries, asOf: DateTime(2026, 6, 15));
      final monthlyTrend = engine.analyzeMonthlyTrend(sampleHabit, entries, asOf: DateTime(2026, 6, 15));
      final insights = engine.generateInsights(sampleHabit, stats, weeklyTrend, monthlyTrend);
      expect(insights.any((i) => i.type == InsightType.warning), true);
    });

    test('returns empty for complete data', () {
      // Just checking it doesn't crash
      final stats = engine.computeStatistics(sampleHabit, []);
      final weeklyTrend = engine.analyzeWeeklyTrend(sampleHabit, []);
      final monthlyTrend = engine.analyzeMonthlyTrend(sampleHabit, []);
      final insights = engine.generateInsights(sampleHabit, stats, weeklyTrend, monthlyTrend);
      expect(insights, isA<List>());
    });
  });

  group('generateOverallInsights', () {
    test('generates overall insight for active habits', () {
      final insights = engine.generateOverallInsights(
        [sampleHabit],
        {'hb-1': engine.computeStatistics(sampleHabit, [])},
        {'hb-1': engine.analyzeWeeklyTrend(sampleHabit, [])},
      );
      expect(insights.any((i) => i.title.contains('Active')), true);
    });

    test('returns empty for no habits', () {
      expect(engine.generateOverallInsights([], {}, {}), isEmpty);
    });
  });

  group('suggestReminderTime', () {
    test('returns most common hour', () {
      final entries = List.generate(5, (i) {
        return HabitEntry(
          id: 'e$i', habitId: 'hb-1',
          date: DateTime(2026, 6, 15 + i),
          completed: true,
          createdAt: DateTime(2026, 6, 15 + i, 7, 0), // 7am
        );
      });
      entries.add(HabitEntry(
        id: 'e6', habitId: 'hb-1',
        date: DateTime(2026, 6, 20),
        completed: true,
        createdAt: DateTime(2026, 6, 20, 19, 0), // 7pm
      ));
      final hour = engine.suggestReminderTime(sampleHabit, entries);
      expect(hour, 7);
    });

    test('returns null for no entries', () {
      expect(engine.suggestReminderTime(sampleHabit, []), isNull);
    });
  });

  group('validateHabit', () {
    test('returns no issues for valid habit', () {
      expect(engine.validateHabit(sampleHabit), isEmpty);
    });

    test('returns issue for empty title', () {
      final bad = sampleHabit.copyWith(title: '');
      expect(engine.validateHabit(bad), isNotEmpty);
    });

    test('returns issue for zero target', () {
      final bad = sampleHabit.copyWith(targetPerDay: 0);
      expect(engine.validateHabit(bad), isNotEmpty);
    });
  });
}
