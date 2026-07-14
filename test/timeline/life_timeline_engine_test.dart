import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/timeline/engine/life_timeline_engine.dart';
import 'package:phoenix_platform/features/timeline/models/milestone.dart';
import 'package:phoenix_platform/features/timeline/models/timeline_category.dart';
import 'package:phoenix_platform/features/timeline/models/timeline_event.dart';

void main() {
  const engine = LifeTimelineEngine();

  group('aggregate', () {
    test('combines events from multiple sources', () {
      final events1 = [
        _event('1', 'Event 1', TimelineCategory.learning,
            DateTime(2026, 6, 15, 10, 0)),
      ];
      final events2 = [
        _event('2', 'Event 2', TimelineCategory.mission,
            DateTime(2026, 6, 15, 11, 0)),
      ];
      final result = engine.aggregate([events1, events2]);
      expect(result.length, 2);
    });

    test('deduplicates by id', () {
      final event = _event(
        '1', 'Duplicate', TimelineCategory.learning, DateTime(2026, 6, 15),
      );
      final result = engine.aggregate([[event], [event]]);
      expect(result.length, 1);
    });

    test('sorts newest first', () {
      final older = _event('1', 'Older', TimelineCategory.learning,
          DateTime(2026, 6, 14));
      final newer = _event('2', 'Newer', TimelineCategory.mission,
          DateTime(2026, 6, 15));
      final result = engine.aggregate([[older, newer]]);
      expect(result.first.id, '2');
      expect(result.last.id, '1');
    });

    test('returns empty list for no sources', () {
      expect(engine.aggregate([]), isEmpty);
    });

    test('returns empty list for empty sources', () {
      expect(engine.aggregate([[], []]), isEmpty);
    });
  });

  group('ordering', () {
    test('newestFirst orders correctly', () {
      final events = [
        _event('1', 'Old', TimelineCategory.learning, DateTime(2026, 6, 14)),
        _event('2', 'New', TimelineCategory.mission, DateTime(2026, 6, 15)),
        _event('3', 'Mid', TimelineCategory.system, DateTime(2026, 6, 15, 10)),
      ];
      final result = engine.newestFirst(events);
      expect(result[0].id, '3');
      expect(result[1].id, '2');
      expect(result[2].id, '1');
    });

    test('oldestFirst orders correctly', () {
      final events = [
        _event('1', 'New', TimelineCategory.mission, DateTime(2026, 6, 15)),
        _event('2', 'Old', TimelineCategory.learning, DateTime(2026, 6, 14)),
      ];
      final result = engine.oldestFirst(events);
      expect(result[0].id, '2');
      expect(result[1].id, '1');
    });
  });

  group('filterByCategory', () {
    test('filters events to matching category', () {
      final events = [
        _event('1', 'L', TimelineCategory.learning, DateTime(2026, 6, 15)),
        _event('2', 'M', TimelineCategory.mission, DateTime(2026, 6, 15)),
        _event('3', 'L2', TimelineCategory.learning, DateTime(2026, 6, 15)),
      ];
      final result = engine.filterByCategory(events, TimelineCategory.learning);
      expect(result.length, 2);
      expect(result.every((e) => e.category == TimelineCategory.learning), true);
    });

    test('returns empty for non-matching category', () {
      final events = [
        _event('1', 'L', TimelineCategory.learning, DateTime(2026, 6, 15)),
      ];
      expect(engine.filterByCategory(events, TimelineCategory.mission), isEmpty);
    });

    test('returns empty for empty input', () {
      expect(engine.filterByCategory([], TimelineCategory.learning), isEmpty);
    });
  });

  group('filterBySource', () {
    test('filters events by source engine', () {
      final events = [
        _event('1', 'A', TimelineCategory.learning, DateTime(2026, 6, 15),
            sourceEngine: 'academy'),
        _event('2', 'M', TimelineCategory.mission, DateTime(2026, 6, 15),
            sourceEngine: 'mission_engine'),
      ];
      final result = engine.filterBySource(events, 'academy');
      expect(result.length, 1);
      expect(result.first.sourceEngine, 'academy');
    });

    test('returns empty for non-matching source', () {
      final events = [
        _event('1', 'L', TimelineCategory.learning, DateTime(2026, 6, 15)),
      ];
      expect(engine.filterBySource(events, 'unknown'), isEmpty);
    });
  });

  group('filterByDateRange', () {
    final events = [
      _event('1', 'Jun14', TimelineCategory.learning, DateTime(2026, 6, 14)),
      _event('2', 'Jun15', TimelineCategory.mission, DateTime(2026, 6, 15)),
      _event('3', 'Jun16', TimelineCategory.system, DateTime(2026, 6, 16)),
    ];

    test('filters to inclusive date range', () {
      final result = engine.filterByDateRange(
        events,
        start: DateTime(2026, 6, 15),
        end: DateTime(2026, 6, 15, 23, 59, 59),
      );
      expect(result.length, 1);
      expect(result.first.id, '2');
    });

    test('includes boundary dates', () {
      final result = engine.filterByDateRange(
        events,
        start: DateTime(2026, 6, 14),
        end: DateTime(2026, 6, 15, 23, 59, 59),
      );
      expect(result.length, 2);
    });

    test('returns empty for out-of-range dates', () {
      final result = engine.filterByDateRange(
        events,
        start: DateTime(2025, 1, 1),
        end: DateTime(2025, 12, 31),
      );
      expect(result, isEmpty);
    });
  });

  group('filterByImportance', () {
    test('filters events with minimum importance', () {
      final events = [
        _event('1', 'N', TimelineCategory.learning, DateTime(2026, 6, 15)),
        _event('2', 'I', TimelineCategory.mission, DateTime(2026, 6, 15),
            importance: 1),
        _event('3', 'C', TimelineCategory.system, DateTime(2026, 6, 15),
            importance: 2),
      ];
      final result = engine.filterByImportance(events, minImportance: 1);
      expect(result.length, 2);
      expect(result.every((e) => e.importance >= 1), true);
    });

    test('returns only high importance with threshold 2', () {
      final events = [
        _event('1', 'N', TimelineCategory.learning, DateTime(2026, 6, 15)),
        _event('2', 'I', TimelineCategory.mission, DateTime(2026, 6, 15),
            importance: 2),
      ];
      final result = engine.filterByImportance(events, minImportance: 2);
      expect(result.length, 1);
      expect(result.first.id, '2');
    });
  });

  group('search', () {
    final events = [
      _event('1', 'Flutter Lesson Complete', TimelineCategory.learning,
          DateTime(2026, 6, 15),
          description: 'Completed the Flutter basics module'),
      _event('2', 'Mission: Build Portfolio', TimelineCategory.mission,
          DateTime(2026, 6, 15),
          description: 'Built a portfolio project'),
      _event('3', 'System Update', TimelineCategory.system,
          DateTime(2026, 6, 15),
          description: 'System configuration updated'),
    ];

    test('searches in title', () {
      expect(engine.search(events, 'flutter').length, 1);
    });

    test('searches in description (case insensitive)', () {
      expect(engine.search(events, 'PORTFOLIO').length, 1);
    });

    test('searches in source engine', () {
      expect(engine.search(events, 'test_engine').length, 3);
    });

    test('returns all events for empty query', () {
      expect(engine.search(events, '').length, 3);
    });

    test('returns all events for whitespace query', () {
      expect(engine.search(events, '   ').length, 3);
    });

    test('returns empty for non-matching query', () {
      expect(engine.search(events, 'nonexistent'), isEmpty);
    });

    test('handles partial word match', () {
      expect(engine.search(events, 'basics').length, 1);
    });
  });

  group('groupByDay', () {
    test('groups events by date key', () {
      final events = [
        _event('1', 'D1', TimelineCategory.learning, DateTime(2026, 6, 15)),
        _event('2', 'D2', TimelineCategory.mission, DateTime(2026, 6, 16)),
        _event('3', 'D3', TimelineCategory.system, DateTime(2026, 6, 15)),
      ];
      final result = engine.groupByDay(events);
      expect(result.keys.length, 2);
      expect(result['2026-06-15']!.length, 2);
      expect(result['2026-06-16']!.length, 1);
    });

    test('returns empty map for empty events', () {
      expect(engine.groupByDay([]), isEmpty);
    });
  });

  group('groupByMonth', () {
    test('groups events by month key', () {
      final events = [
        _event('1', 'Jun', TimelineCategory.learning, DateTime(2026, 6, 15)),
        _event('2', 'Jul', TimelineCategory.mission, DateTime(2026, 7, 1)),
        _event('3', 'Jun2', TimelineCategory.system, DateTime(2026, 6, 20)),
      ];
      final result = engine.groupByMonth(events);
      expect(result.keys.length, 2);
      expect(result['2026-06']!.length, 2);
      expect(result['2026-07']!.length, 1);
    });
  });

  group('detectMilestones', () {
    test('detects first event of each category as milestone', () {
      final events = [
        _event('1', 'FL', TimelineCategory.learning, DateTime(2026, 6, 15)),
        _event('2', 'FM', TimelineCategory.mission, DateTime(2026, 6, 16)),
      ];
      final milestones = engine.detectMilestones(events);
      expect(milestones.length, 2);
      expect(
        milestones.where((m) => m.category == TimelineCategory.learning),
        hasLength(1),
      );
      expect(
        milestones.where((m) => m.category == TimelineCategory.mission),
        hasLength(1),
      );
    });

    test('detects milestone for high importance events', () {
      final events = [
        _event('1', 'Critical', TimelineCategory.system, DateTime(2026, 6, 15),
            importance: 2),
      ];
      final milestones = engine.detectMilestones(events);
      expect(milestones.any((m) => m.title == 'Critical'), true);
    });

    test('detects milestone at 10th learning event', () {
      final events = List.generate(10, (i) {
        return _event(
          'lrn-$i',
          'Lesson $i',
          TimelineCategory.learning,
          DateTime(2026, 6, 15, i ~/ 24, i % 60),
        );
      });
      final milestones = engine.detectMilestones(events);
      final learningMilestones =
          milestones.where((m) => m.category == TimelineCategory.learning);
      expect(learningMilestones.length, 2);
      expect(learningMilestones.any((m) => m.title.contains('10 Lessons')), true);
    });

    test('detects milestone at 10th mission event', () {
      final events = List.generate(10, (i) {
        return _event(
          'ms-$i',
          'Mission $i',
          TimelineCategory.mission,
          DateTime(2026, 6, 15, i ~/ 24, i % 60),
        );
      });
      final milestones = engine.detectMilestones(events);
      final missionMilestones =
          milestones.where((m) => m.category == TimelineCategory.mission);
      expect(missionMilestones.length, 2);
      expect(missionMilestones.any((m) => m.title.contains('10 Missions')), true);
    });

    test('returns empty for empty events', () {
      expect(engine.detectMilestones([]), isEmpty);
    });

    test('milestones have correct titles', () {
      final events = [
        _event('1', 'Hello Flutter', TimelineCategory.learning,
            DateTime(2026, 6, 15)),
      ];
      final milestones = engine.detectMilestones(events);
      expect(milestones.first.title, 'First Learning');
      expect(milestones.first.description, 'Hello Flutter');
    });
  });

  group('sortMilestones', () {
    test('sorts milestones newest first', () {
      final milestones = [
        _milestone('1', 'Old', DateTime(2026, 6, 14)),
        _milestone('2', 'New', DateTime(2026, 6, 15)),
      ];
      final result = engine.sortMilestones(milestones);
      expect(result[0].id, '2');
      expect(result[1].id, '1');
    });
  });

  group('prioritizePinned', () {
    test('pinned milestones come first', () {
      final milestones = [
        _milestone('1', 'UO', DateTime(2026, 6, 14)),
        _milestone('2', 'PN', DateTime(2026, 6, 15), isPinned: true),
        _milestone('3', 'UN', DateTime(2026, 6, 16)),
      ];
      final result = engine.prioritizePinned(milestones);
      expect(result[0].id, '2');
      expect(result[0].isPinned, true);
    });

    test('within pinned group, newer first', () {
      final milestones = [
        _milestone('1', 'OP', DateTime(2026, 6, 14), isPinned: true),
        _milestone('2', 'NP', DateTime(2026, 6, 15), isPinned: true),
      ];
      final result = engine.prioritizePinned(milestones);
      expect(result[0].id, '2');
      expect(result[1].id, '1');
    });
  });
}

TimelineEvent _event(
  String id,
  String title,
  TimelineCategory category,
  DateTime timestamp, {
  String description = 'Test event description',
  String sourceEngine = 'test_engine',
  String? sourceId,
  String? iconName,
  Map<String, dynamic>? metadata,
  int importance = 0,
}) {
  return TimelineEvent(
    id: id,
    title: title,
    description: description,
    category: category,
    timestamp: timestamp,
    sourceEngine: sourceEngine,
    sourceId: sourceId,
    iconName: iconName,
    metadata: metadata ?? const {},
    importance: importance,
  );
}

Milestone _milestone(
  String id,
  String title,
  DateTime timestamp, {
  bool isPinned = false,
}) {
  return Milestone(
    id: id,
    title: title,
    description: 'Test milestone',
    category: TimelineCategory.learning,
    timestamp: timestamp,
    isPinned: isPinned,
  );
}
