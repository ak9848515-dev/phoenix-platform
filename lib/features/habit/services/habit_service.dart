import 'package:flutter/foundation.dart';

import '../../ai/services/ai_mentor_service.dart';
import '../../timeline/services/timeline_service.dart';
import '../../user_state/services/user_state_service.dart';
import '../engine/habit_engine.dart';
import '../models/habit.dart';
import '../models/habit_entry.dart';
import '../models/habit_insight.dart';
import '../models/habit_statistics.dart';
import '../models/habit_trend.dart';

/// Public API for the Habit Intelligence Engine.
///
/// [HabitService] is the ONLY entry point for habit functionality.
/// Screens and widgets never interact with [HabitEngine] directly.
///
/// Responsibilities:
/// - Habit CRUD (create, read, update, delete)
/// - Habit completion tracking
/// - Streak, consistency, and scoring analytics
/// - Trend analysis (weekly, monthly)
/// - Insight generation (rule-based + AI-enhanced)
/// - Timeline event emission (habit completions feed into Timeline)
/// - Persistence through [UserStateService]
///
/// **Architecture Rules:**
/// - NEVER own Mission, Timeline, Decision, AI, or UserState logic
/// - [HabitEngine] owns behavioural intelligence — never duplicated
/// - AI integration uses [AIMentorService] only
class HabitService extends ChangeNotifier {
  HabitService({
    required this._userStateService,
    required this._aiMentorService,
    this._timelineService,
    HabitEngine? engine,
  }) : _engine = engine ?? const HabitEngine();

  final UserStateService _userStateService;
  final AIMentorService _aiMentorService;
  final TimelineService? _timelineService;
  final HabitEngine _engine;

  // ── Habit CRUD ────────────────────────────────────────────────────

  /// All habits (active + inactive), sorted by sortOrder.
  List<Habit> get allHabits {
    final habits = _userStateService.currentState.habits;
    final sorted = List<Habit>.from(habits)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sorted;
  }

  /// Active habits only.
  List<Habit> get activeHabits =>
      allHabits.where((h) => h.isActive).toList();

  /// Gets a single habit by ID.
  Habit? getHabit(String id) {
    try {
      return allHabits.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  /// All habit entries.
  List<HabitEntry> get allEntries =>
      _userStateService.currentState.habitEntries;

  /// Entries for a specific habit.
  List<HabitEntry> entriesForHabit(String habitId) {
    return allEntries.where((e) => e.habitId == habitId).toList();
  }

  /// Today's entries for a specific habit.
  List<HabitEntry> todayEntriesForHabit(String habitId) {
    final todayStr = _dateKey(DateTime.now());
    return allEntries.where((e) =>
        e.habitId == habitId && e.dateKey == todayStr).toList();
  }

  /// Creates a new habit.
  Future<void> createHabit(Habit habit) async {
    final current = List<Habit>.from(allHabits);
    current.add(habit);
    await _userStateService.update((s) =>
        s.copyWith(habits: current, lastActivityAt: DateTime.now()));
    notifyListeners();
  }

  /// Updates an existing habit.
  Future<void> updateHabit(Habit updated) async {
    final current = List<Habit>.from(allHabits);
    final index = current.indexWhere((h) => h.id == updated.id);
    if (index >= 0) {
      current[index] = updated;
      await _userStateService.update((s) =>
          s.copyWith(habits: current, lastActivityAt: DateTime.now()));
      notifyListeners();
    }
  }

  /// Deletes a habit and all its entries.
  Future<void> deleteHabit(String habitId) async {
    final allH = List<Habit>.from(allHabits);
    allH.removeWhere((h) => h.id == habitId);
    final allE = allEntries.where((e) => e.habitId != habitId).toList();
    await _userStateService.update((s) =>
        s.copyWith(habits: allH, habitEntries: allE, lastActivityAt: DateTime.now()));
    notifyListeners();
  }

  // ── Habit Completion ─────────────────────────────────────────────

  /// Marks a habit as completed for today.
  Future<HabitEntry> completeHabit(
    String habitId, {
    int count = 1,
    String? notes,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final entry = HabitEntry(
      id: 'he-$habitId-${_dateKey(now)}-${now.millisecondsSinceEpoch}',
      habitId: habitId,
      date: today,
      completed: true,
      count: count,
      notes: notes,
      createdAt: now,
    );

    final current = List<HabitEntry>.from(allEntries);
    current.add(entry);
    await _userStateService.update((s) =>
        s.copyWith(habitEntries: current, lastActivityAt: now, totalXp: s.totalXp + 5));
    notifyListeners();

    // Invalidate timeline cache so habit events are reflected
    _timelineService?.invalidateCache();

    return entry;
  }

  /// Marks a habit as skipped for today.
  Future<HabitEntry> skipHabit(
    String habitId, {
    String? reason,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final entry = HabitEntry(
      id: 'he-$habitId-skip-${_dateKey(now)}',
      habitId: habitId,
      date: today,
      completed: false,
      skipped: true,
      skipReason: reason,
      createdAt: now,
    );

    final current = List<HabitEntry>.from(allEntries);
    current.add(entry);
    await _userStateService.update((s) =>
        s.copyWith(habitEntries: current, lastActivityAt: now));
    notifyListeners();

    return entry;
  }

  /// Undoes the most recent completion or skip for today.
  Future<void> undoToday(String habitId) async {
    final todayStr = _dateKey(DateTime.now());
    final current = List<HabitEntry>.from(allEntries);
    current.removeWhere((e) =>
        e.habitId == habitId && e.dateKey == todayStr);
    await _userStateService.update((s) =>
        s.copyWith(habitEntries: current, lastActivityAt: DateTime.now()));
    notifyListeners();
  }

  /// Whether a habit is completed for today.
  bool isCompletedToday(String habitId) {
    return todayEntriesForHabit(habitId).any((e) => e.completed);
  }

  // ── Analytics ────────────────────────────────────────────────────

  /// Computes statistics for a single habit.
  HabitStatistics statisticsFor(String habitId) {
    final habit = getHabit(habitId);
    if (habit == null) return const HabitStatistics();
    return _engine.computeStatistics(habit, allEntries);
  }

  /// Computes statistics for all active habits.
  Map<String, HabitStatistics> allStatistics() {
    final result = <String, HabitStatistics>{};
    for (final habit in activeHabits) {
      result[habit.id] = _engine.computeStatistics(habit, allEntries);
    }
    return result;
  }

  /// Weekly trend for a habit.
  HabitTrend weeklyTrendFor(String habitId) {
    final habit = getHabit(habitId);
    if (habit == null) {
      return HabitTrend(
        habitId: habitId,
        period: TrendPeriod.weekly,
      );
    }
    return _engine.analyzeWeeklyTrend(habit, allEntries);
  }

  /// Monthly trend for a habit.
  HabitTrend monthlyTrendFor(String habitId) {
    final habit = getHabit(habitId);
    if (habit == null) {
      return HabitTrend(
        habitId: habitId,
        period: TrendPeriod.monthly,
      );
    }
    return _engine.analyzeMonthlyTrend(habit, allEntries);
  }

  // ── Insights ─────────────────────────────────────────────────────

  /// Generates insights for a specific habit.
  List<HabitInsight> insightsFor(String habitId) {
    final habit = getHabit(habitId);
    if (habit == null) return [];
    final stats = statisticsFor(habitId);
    final weeklyTrend = weeklyTrendFor(habitId);
    final monthlyTrend = monthlyTrendFor(habitId);
    return _engine.generateInsights(habit, stats, weeklyTrend, monthlyTrend);
  }

  /// Generates overall insights across all habits.
  List<HabitInsight> overallInsights() {
    final habits = activeHabits;
    final statsMap = allStatistics();
    final weeklyTrends = <String, HabitTrend>{};
    for (final habit in habits) {
      weeklyTrends[habit.id] = weeklyTrendFor(habit.id);
    }
    return _engine.generateOverallInsights(habits, statsMap, weeklyTrends);
  }

  /// Gets AI-enhanced explanation for an insight.
  Future<String> explainInsight(HabitInsight insight) async {
    final response = await _aiMentorService.chat(
      'I have a habit insight: "${insight.title}" - '
      '${insight.description ?? ''} '
      'Give me a brief, encouraging explanation and a practical tip.',
    );
    return response.content;
  }

  // ── Helpers ──────────────────────────────────────────────────────

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
