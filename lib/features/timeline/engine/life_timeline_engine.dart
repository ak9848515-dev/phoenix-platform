import '../models/milestone.dart';
import '../models/timeline_category.dart';
import '../models/timeline_event.dart';

/// The core Life Timeline Engine.
///
/// Owns:
/// - Event aggregation (collecting events from all sources)
/// - Chronological ordering
/// - Timeline filtering (by category, date, engine)
/// - Timeline search (text, category, date)
/// - Milestone detection (pattern recognition)
/// - Date grouping (daily, weekly, monthly)
///
/// **Never** owns business logic from Mission, Academy, Decision,
/// Portfolio, Resume, Interview, or AI engines.
///
/// This engine is pure Dart — no dependencies on Flutter widgets
/// or other platform services. Integration happens in [TimelineService].
class LifeTimelineEngine {
  const LifeTimelineEngine();

  // ── Aggregation ──────────────────────────────────────────────────

  /// Combines events from multiple sources, deduplicates by ID,
  /// and sorts chronologically (newest first).
  List<TimelineEvent> aggregate(List<List<TimelineEvent>> sourceEvents) {
    final seen = <String>{};
    final combined = <TimelineEvent>[];

    for (final events in sourceEvents) {
      for (final event in events) {
        if (seen.add(event.id)) {
          combined.add(event);
        }
      }
    }

    combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return combined;
  }

  // ── Ordering ─────────────────────────────────────────────────────

  /// Returns events sorted newest-first.
  List<TimelineEvent> newestFirst(List<TimelineEvent> events) {
    final sorted = List<TimelineEvent>.from(events);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }

  /// Returns events sorted oldest-first.
  List<TimelineEvent> oldestFirst(List<TimelineEvent> events) {
    final sorted = List<TimelineEvent>.from(events);
    sorted.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return sorted;
  }

  // ── Filtering ────────────────────────────────────────────────────

  /// Filters events by category.
  List<TimelineEvent> filterByCategory(
    List<TimelineEvent> events,
    TimelineCategory category,
  ) {
    return events.where((e) => e.category == category).toList();
  }

  /// Filters events by source engine.
  List<TimelineEvent> filterBySource(
    List<TimelineEvent> events,
    String sourceEngine,
  ) {
    return events.where((e) => e.sourceEngine == sourceEngine).toList();
  }

  /// Filters events within a date range (inclusive).
  List<TimelineEvent> filterByDateRange(
    List<TimelineEvent> events, {
    required DateTime start,
    required DateTime end,
  }) {
    return events.where((e) {
      return !e.timestamp.isBefore(start) && !e.timestamp.isAfter(end);
    }).toList();
  }

  /// Filters events by importance threshold.
  List<TimelineEvent> filterByImportance(
    List<TimelineEvent> events, {
    int minImportance = 1,
  }) {
    return events.where((e) => e.importance >= minImportance).toList();
  }

  // ── Search ───────────────────────────────────────────────────────

  /// Searches events by text (case-insensitive).
  /// Matches title, description, and source engine.
  List<TimelineEvent> search(
    List<TimelineEvent> events,
    String query,
  ) {
    if (query.trim().isEmpty) return events;
    final lower = query.toLowerCase();
    return events.where((e) {
      return e.title.toLowerCase().contains(lower) ||
          e.description.toLowerCase().contains(lower) ||
          e.sourceEngine.toLowerCase().contains(lower);
    }).toList();
  }

  // ── Date Grouping ────────────────────────────────────────────────

  /// Groups events by day. Returns map of date string → events.
  Map<String, List<TimelineEvent>> groupByDay(List<TimelineEvent> events) {
    final grouped = <String, List<TimelineEvent>>{};
    for (final event in events) {
      final key = _dateKey(event.timestamp);
      grouped.putIfAbsent(key, () => []).add(event);
    }
    return grouped;
  }

  /// Groups events by week (ISO week). Returns map of week string → events.
  Map<String, List<TimelineEvent>> groupByWeek(List<TimelineEvent> events) {
    final grouped = <String, List<TimelineEvent>>{};
    for (final event in events) {
      final key = _weekKey(event.timestamp);
      grouped.putIfAbsent(key, () => []).add(event);
    }
    return grouped;
  }

  /// Groups events by month. Returns map of month string → events.
  Map<String, List<TimelineEvent>> groupByMonth(List<TimelineEvent> events) {
    final grouped = <String, List<TimelineEvent>>{};
    for (final event in events) {
      final key = _monthKey(event.timestamp);
      grouped.putIfAbsent(key, () => []).add(event);
    }
    return grouped;
  }

  // ── Milestone Detection ──────────────────────────────────────────

  /// Detects milestones from events.
  ///
  /// Current patterns:
  /// - First event of each category → milestone
  /// - Events with importance >= 2 → milestone
  /// - Every 10th learning event → milestone
  /// - Every 10th mission event → milestone
  /// - First decision with outcome → milestone
  List<Milestone> detectMilestones(List<TimelineEvent> events) {
    final milestones = <Milestone>[];
    final seenCategories = <TimelineCategory>{};
    final ordered = oldestFirst(events);

    var learningCount = 0;
    var missionCount = 0;
    final decisionsWithOutcomes = <String>{};

    for (final event in ordered) {
      // First event of each category
      if (seenCategories.add(event.category)) {
        milestones.add(Milestone(
          id: 'ms-first-${event.category.name}',
          title: 'First ${event.category.label}',
          description: event.title,
          category: event.category,
          timestamp: event.timestamp,
          eventIds: [event.id],
        ));
      }

      // High importance events
      if (event.importance >= 2) {
        milestones.add(Milestone(
          id: 'ms-importance-${event.id}',
          title: event.title,
          description: event.description,
          category: event.category,
          timestamp: event.timestamp,
          eventIds: [event.id],
        ));
      }

      // Learning milestones every 10 events
      if (event.category == TimelineCategory.learning) {
        learningCount++;
        if (learningCount % 10 == 0) {
          milestones.add(Milestone(
            id: 'ms-learning-$learningCount',
            title: '$learningCount Lessons Completed',
            description: 'You have completed $learningCount learning lessons.',
            category: TimelineCategory.learning,
            timestamp: event.timestamp,
            eventIds: [event.id],
          ));
        }
      }

      // Mission milestones every 10 events
      if (event.category == TimelineCategory.mission) {
        missionCount++;
        if (missionCount % 10 == 0) {
          milestones.add(Milestone(
            id: 'ms-mission-$missionCount',
            title: '$missionCount Missions Completed',
            description:
                'You have completed $missionCount missions.',
            category: TimelineCategory.mission,
            timestamp: event.timestamp,
            eventIds: [event.id],
          ));
        }
      }

      // First decision with outcome
      if (event.category == TimelineCategory.decision &&
          event.sourceEngine == 'decision' &&
          decisionsWithOutcomes.add(event.sourceEngine)) {
        milestones.add(Milestone(
          id: 'ms-first-decision',
          title: 'First Decision Made',
          description: 'You made your first tracked decision.',
          category: TimelineCategory.decision,
          timestamp: event.timestamp,
          eventIds: [event.id],
        ));
      }
    }

    return milestones;
  }

  /// Returns milestones sorted by timestamp (newest first).
  List<Milestone> sortMilestones(List<Milestone> milestones) {
    final sorted = List<Milestone>.from(milestones);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }

  /// Returns pinned milestones first.
  List<Milestone> prioritizePinned(List<Milestone> milestones) {
    final sorted = List<Milestone>.from(milestones);
    sorted.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.timestamp.compareTo(a.timestamp);
    });
    return sorted;
  }

  // ── Helpers ──────────────────────────────────────────────────────

  String _dateKey(DateTime dt) =>
      '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)}';

  String _weekKey(DateTime dt) {
    // Approximate ISO week calculation
    final dayOfYear =
        int.parse('${dt.year}${_pad(dt.month)}${_pad(dt.day)}');
    return '${dt.year}-W${_pad((dayOfYear ~/ 7) % 52 + 1)}';
  }

  String _monthKey(DateTime dt) => '${dt.year}-${_pad(dt.month)}';

  String _pad(int n) => n.toString().padLeft(2, '0');
}
