import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/storage_service.dart';
import '../../ai/services/ai_mentor_service.dart';
import '../../user_state/services/user_state_service.dart';
import '../engine/life_timeline_engine.dart';
import '../models/milestone.dart';
import '../models/timeline_category.dart';
import '../models/timeline_event.dart';

/// Public API for the Life Timeline Engine.
///
/// [TimelineService] is the ONLY entry point for timeline functionality.
/// Screens and widgets never interact with [LifeTimelineEngine] directly.
///
/// Responsibilities:
/// - Event aggregation from all platform engines
/// - Timeline display (chronological, filtered, grouped)
/// - Milestone detection and management
/// - Timeline search
/// - AI-powered summaries (via [AIMentorService])
/// - Persistence through [UserStateService]
///
/// **Architecture Rules:**
/// - NEVER own Mission, Academy, Decision, AI, or UserState logic
/// - Only reads from existing services — never creates source data
class TimelineService extends ChangeNotifier {
  TimelineService({
    required this._userStateService,
    required this._aiMentorService,
    LifeTimelineEngine? engine,
    /// Optional [StorageService] for persistent caching of computed
    /// timeline events and milestones. When provided, computed data
    /// is written to storage on cache invalidation and loaded on init.
    StorageService? storageService,
  })  : _engine = engine ?? const LifeTimelineEngine(),
        _storage = storageService;

  final UserStateService _userStateService;
  final AIMentorService _aiMentorService;
  final LifeTimelineEngine _engine;
  final StorageService? _storage;

  // Cached events — rebuilt on demand.
  List<TimelineEvent>? _cachedEvents;
  List<Milestone>? _cachedMilestones;

  /// Whether persisted data has been loaded into cache.
  bool _initialized = false;

  /// Loads persisted timeline data from storage into cache.
  ///
  /// Called once during bootstrap. Prevents recomputing events
  /// from source data on every app restart. Only loads non-empty
  /// data — empty storage means "not yet computed" so events will
  /// be computed lazily on first access via [allEvents].
  Future<void> initFromStorage() async {
    if (_initialized) return;
    _initialized = true;

    final storage = _storage;
    if (storage == null) return;

    final eventsRaw = storage.readTimelineEvents();
    if (eventsRaw != null) {
      try {
        final list = json.decode(eventsRaw) as List<dynamic>;
        // Only load non-empty data. Empty arrays from seed should
        // not prevent lazy computation on first access.
        if (list.isNotEmpty) {
          _cachedEvents = list
              .map((item) => TimelineEvent.fromMap(
                  Map<String, dynamic>.from(item as Map)))
              .toList();
        }
      } catch (e) {
        debugPrint('TimelineService: failed to parse persisted events: $e');
      }
    }

    final milestonesRaw = storage.readMilestones();
    if (milestonesRaw != null) {
      try {
        final list = json.decode(milestonesRaw) as List<dynamic>;
        // Only load non-empty data.
        if (list.isNotEmpty) {
          _cachedMilestones = list
              .map((item) =>
                  Milestone.fromMap(Map<String, dynamic>.from(item as Map)))
              .toList();
        }
      } catch (e) {
        debugPrint('TimelineService: failed to parse persisted milestones: $e');
      }
    }
  }

  /// Persists current cached events and milestones to storage.
  Future<void> _persistToStorage() async {
    final storage = _storage;
    if (storage == null) return;
    try {
      if (_cachedEvents != null) {
        await storage.saveTimelineEvents(
          json.encode(_cachedEvents!.map((e) => e.toMap()).toList()),
        );
      }
      if (_cachedMilestones != null) {
        await storage.saveMilestones(
          json.encode(_cachedMilestones!.map((m) => m.toMap()).toList()),
        );
      }
    } catch (e) {
      debugPrint('TimelineService: failed to persist timeline data: $e');
    }
  }

  // ── Event Access ─────────────────────────────────────────────────

  /// All aggregated events, newest first.
  List<TimelineEvent> get allEvents {
    if (_cachedEvents == null && _storage != null) {
      // First access — compute and persist
      _cachedEvents = _engine.aggregate(_collectEvents());
      _persistToStorage();
    } else {
      _cachedEvents ??= _engine.aggregate(_collectEvents());
    }
    return _cachedEvents!;
  }

  /// Events filtered by category.
  List<TimelineEvent> eventsByCategory(TimelineCategory category) {
    return _engine.filterByCategory(allEvents, category);
  }

  /// Events filtered by source engine.
  List<TimelineEvent> eventsBySource(String sourceEngine) {
    return _engine.filterBySource(allEvents, sourceEngine);
  }

  /// Events within a date range.
  List<TimelineEvent> eventsInRange({
    required DateTime start,
    required DateTime end,
  }) {
    return _engine.filterByDateRange(allEvents, start: start, end: end);
  }

  /// Events for today.
  List<TimelineEvent> get todayEvents {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return eventsInRange(start: start, end: end);
  }

  /// Events for this week.
  List<TimelineEvent> get thisWeekEvents {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(start.year, start.month, start.day);
    final weekEnd = weekStart.add(const Duration(days: 7));
    return eventsInRange(start: weekStart, end: weekEnd);
  }

  // ── Search ───────────────────────────────────────────────────────

  /// Searches events by text query.
  List<TimelineEvent> search(String query) {
    return _engine.search(allEvents, query);
  }

  // ── Grouping ─────────────────────────────────────────────────────

  /// Events grouped by day.
  Map<String, List<TimelineEvent>> get eventsByDay =>
      _engine.groupByDay(allEvents);

  /// Events grouped by week.
  Map<String, List<TimelineEvent>> get eventsByWeek =>
      _engine.groupByWeek(allEvents);

  /// Events grouped by month.
  Map<String, List<TimelineEvent>> get eventsByMonth =>
      _engine.groupByMonth(allEvents);

  // ── Milestones ───────────────────────────────────────────────────

  /// All detected milestones, newest first.
  List<Milestone> get milestones {
    if (_cachedMilestones == null && _storage != null) {
      // First access — compute and persist
      _cachedMilestones = _engine.sortMilestones(
          _engine.detectMilestones(allEvents));
      _persistToStorage();
    } else {
      _cachedMilestones ??= _engine.sortMilestones(
          _engine.detectMilestones(allEvents));
    }
    return _cachedMilestones!;
  }

  /// Pinned milestones.
  List<Milestone> get pinnedMilestones {
    return milestones.where((m) => m.isPinned).toList();
  }

  /// Toggle pin state for a milestone.
  Future<void> togglePinMilestone(String milestoneId) async {
    // In a full implementation, this would persist pin state
    // via UserStateService. For v1, it's in-memory only.
    notifyListeners();
  }

  // ── AI Integration ───────────────────────────────────────────────

  /// Gets an AI summary of events for a period.
  Future<String> summarizePeriod({
    required DateTime start,
    required DateTime end,
  }) async {
    final events = eventsInRange(start: start, end: end);
    final categories = events.map((e) => e.category.label).toSet().join(', ');
    final response = await _aiMentorService.chat(
      'Summarize my activity from $start to $end. '
      'I had ${events.length} events across these categories: $categories. '
      'Give me a concise summary of what I accomplished.',
    );
    return response.content;
  }

  /// Gets AI-highlighted milestones.
  Future<String> getAiMilestoneHighlight() async {
    final ms = milestones.take(5).toList();
    if (ms.isEmpty) return 'No milestones yet.';

    final descriptions =
        ms.map((m) => '${m.title} (${m.category.label})').join('\n');
    final response = await _aiMentorService.chat(
      'Here are my recent milestones:\n$descriptions\n'
      'Give me an encouraging summary of my progress.',
    );
    return response.content;
  }

  /// Invalidates the cache so events/milestones are rebuilt.
  void invalidateCache() {
    _cachedEvents = null;
    _cachedMilestones = null;
    notifyListeners();
  }

  /// Persists the current cached data to storage.
  ///
  /// Call this after the cache has been populated (e.g. after
  /// events have been accessed) to persist the computed data.
  Future<void> persistCache() async {
    // Ensure cache is populated first
    if (_cachedEvents == null) {
      allEvents;
    }
    if (_cachedMilestones == null) {
      milestones;
    }
    await _persistToStorage();
  }

  // ── Event Collection ─────────────────────────────────────────────

  /// Collects events from all platform sources.
  ///
  /// Each source engine's data is normalized into [TimelineEvent]s.
  /// No business logic is duplicated — only timestamps and titles
  /// are read from the source data.
  List<List<TimelineEvent>> _collectEvents() {
    final sources = <List<TimelineEvent>>[
      _eventsFromUserState(),
      _eventsFromDecisions(),
    ];
    return sources;
  }

  List<TimelineEvent> _eventsFromUserState() {
    final events = <TimelineEvent>[];
    final state = _userStateService.currentState;
    final now = DateTime.now();

    // Identity selection
    if (state.identity != null) {
      events.add(TimelineEvent(
        id: 'sys-identity',
        title: 'Identified as ${state.identity!.title}',
        description: 'Selected the ${state.identity!.title} identity path.',
        category: TimelineCategory.system,
        timestamp: state.lastActivityAt ?? now,
        sourceEngine: 'user_state',
        importance: 2,
      ));
    }

    // Level up
    if (state.level > 1) {
      events.add(TimelineEvent(
        id: 'sys-level-${state.level}',
        title: 'Reached Level ${state.level}',
        description:
            'Earned ${state.totalXp} XP and reached level ${state.level}.',
        category: TimelineCategory.system,
        timestamp: state.lastActivityAt ?? now,
        sourceEngine: 'user_state',
        importance: 2,
      ));
    }

    // Mission completions
    for (final mission in state.missions) {
      if (mission.isCompleted && mission.completedDate != null) {
        events.add(TimelineEvent(
          id: 'ms-${mission.id}',
          title: 'Mission: ${mission.title}',
          description: mission.description,
          category: TimelineCategory.mission,
          timestamp: mission.completedDate!,
          sourceEngine: 'mission_engine',
          sourceId: mission.id,
          importance: 1,
          metadata: {'xp': mission.rewardXP, 'difficulty': mission.difficulty.name},
        ));
      }
    }

    return events;
  }

  List<TimelineEvent> _eventsFromDecisions() {
    final events = <TimelineEvent>[];
    final decisions = _userStateService.currentState.decisionHistory;

    for (final analysis in decisions) {
      events.add(TimelineEvent(
        id: 'dec-${analysis.id}',
        title: 'Decision: ${analysis.title}',
        description:
            'Analyzed ${analysis.options.length} options across '
            '${analysis.criteria.length} criteria. '
            'Confidence: ${(analysis.confidence * 100).round()}%.',
        category: TimelineCategory.decision,
        timestamp: analysis.createdAt ?? DateTime.now(),
        sourceEngine: 'decision',
        sourceId: analysis.id,
        importance: analysis.outcome != null ? 2 : 1,
      ));
    }

    return events;
  }

  // ── Diagnostics ──────────────────────────────────────────────────

  Map<String, dynamic> diagnostics() {
    return {
      'eventCount': allEvents.length,
      'milestoneCount': milestones.length,
      'pinnedMilestones': pinnedMilestones.length,
    };
  }
}
