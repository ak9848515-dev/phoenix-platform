import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../shared/infrastructure/logging/phoenix_logger.dart';

import '../features/career/models/career_profile.dart';
import '../features/identity/models/identity.dart';
import '../features/journey/models/journey.dart';
import '../features/memory/models/memory_entry.dart';
import '../models/user_settings.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Storage keys
// ─────────────────────────────────────────────────────────────────────────────

abstract final class _StorageKeys {
  static const selectedIdentity = 'phx_selected_identity';
  static const journey = 'phx_journey';
  static const progress = 'phx_progress';
  static const memories = 'phx_memories';
  static const careerProfile = 'phx_career_profile';
  static const userSettings = 'phx_user_settings';
  static const learningPaths = 'phx_learning_paths';
  static const academySummaries = 'phx_academy_summaries';
  static const featuredAcademy = 'phx_featured_academy';
  static const habits = 'phx_habits';
  static const habitEntries = 'phx_habit_entries';
  static const habitStatistics = 'phx_habit_statistics';
  static const timelineEvents = 'phx_timeline_events';
  static const milestones = 'phx_milestones';
  static const decisionHistory = 'phx_decision_history';
  static const knowledgeSnapshot = 'phx_knowledge_snapshot';
  static const memoryGraph = 'phx_memory_graph';
}

// ─────────────────────────────────────────────────────────────────────────────
// StorageService
// ─────────────────────────────────────────────────────────────────────────────

/// Abstract local persistence boundary for the Phoenix platform.
///
/// Provides typed read/write access for all domain models that need
/// to survive application restarts. The current implementation is
/// [SharedPreferencesStorageService], backed by `shared_preferences`.
///
/// No cloud sync, no networking, no AI.
abstract class StorageService {
  // ── Lifecycle ────────────────────────────────────────────────────────

  /// Initialize the storage backend. Must be called once before any
  /// read or write operation.
  Future<void> init();

  // ── Identity ─────────────────────────────────────────────────────────

  /// Persists the user's selected identity.
  Future<void> saveSelectedIdentity(Identity identity);

  /// Reads the previously persisted selected identity, or `null` if none.
  Identity? readSelectedIdentity();

  // ── Journey ──────────────────────────────────────────────────────────

  /// Persists the user's journey.
  Future<void> saveJourney(Journey journey);

  /// Reads the previously persisted journey, or `null` if none.
  Journey? readJourney();

  // ── Progress ─────────────────────────────────────────────────────────

  /// Persists the progress JSON blob.
  Future<void> saveProgress(String progressJson);

  /// Reads the previously persisted progress JSON, or `null` if none.
  String? readProgress();

  // ── Memories ─────────────────────────────────────────────────────────

  /// Persists a list of memory entries.
  Future<void> saveMemories(List<MemoryEntry> memories);

  /// Reads the previously persisted memory entries, or an empty list.
  List<MemoryEntry> readMemories();

  // ── Career Profile ───────────────────────────────────────────────────

  /// Persists the user's career profile.
  Future<void> saveCareerProfile(CareerProfile profile);

  /// Reads the previously persisted career profile, or `null` if none.
  CareerProfile? readCareerProfile();

  // ── User Settings ────────────────────────────────────────────────────

  /// Persists user settings.
  Future<void> saveUserSettings(UserSettings settings);

  /// Reads the previously persisted user settings, or defaults.
  UserSettings readUserSettings();

  // ── Academy Learning Paths ─────────────────────────────────────────

  /// Persists the learning paths JSON blob.
  Future<void> saveLearningPaths(String json);

  /// Reads the previously persisted learning paths JSON, or `null`.
  String? readLearningPaths();

  // ── Academy Summaries (legacy Academy model) ───────────────────────

  /// Persists the academy summaries JSON blob.
  Future<void> saveAcademySummaries(String json);

  /// Reads the previously persisted academy summaries JSON, or `null`.
  String? readAcademySummaries();

  // ── Featured Academy (legacy Academy model) ────────────────────────

  /// Persists the featured academy JSON.
  Future<void> saveFeaturedAcademy(String json);

  /// Reads the previously persisted featured academy JSON, or `null`.
  String? readFeaturedAcademy();

  // ── Habits ────────────────────────────────────────────────────────

  /// Persists the habits JSON blob (list of serialized Habit maps).
  Future<void> saveHabits(String json);

  /// Reads the previously persisted habits JSON, or `null`.
  String? readHabits();

  // ── Habit Entries ─────────────────────────────────────────────────

  /// Persists the habit entries JSON blob (list of serialized HabitEntry maps).
  Future<void> saveHabitEntries(String json);

  /// Reads the previously persisted habit entries JSON, or `null`.
  String? readHabitEntries();

  // ── Habit Statistics ──────────────────────────────────────────────

  /// Persists the habit statistics JSON blob (map of habitId → HabitStatistics).
  Future<void> saveHabitStatistics(String json);

  /// Reads the previously persisted habit statistics JSON, or `null`.
  String? readHabitStatistics();

  // ── Timeline Events ──────────────────────────────────────────────

  /// Persists the timeline events JSON blob (list of serialized TimelineEvent maps).
  Future<void> saveTimelineEvents(String json);

  /// Reads the previously persisted timeline events JSON, or `null`.
  String? readTimelineEvents();

  // ── Milestones ───────────────────────────────────────────────────

  /// Persists the milestones JSON blob (list of serialized Milestone maps).
  Future<void> saveMilestones(String json);

  /// Reads the previously persisted milestones JSON, or `null`.
  String? readMilestones();

  // ── Decision History ─────────────────────────────────────────────

  /// Persists the decision history JSON blob (list of serialized DecisionAnalysis maps).
  Future<void> saveDecisionHistory(String json);

  /// Reads the previously persisted decision history JSON, or `null`.
  String? readDecisionHistory();

  // ── Knowledge Snapshot ───────────────────────────────────────────

  /// Persists the knowledge snapshot JSON blob (serialized KnowledgeSnapshot map).
  Future<void> saveKnowledgeSnapshot(String json);

  /// Reads the previously persisted knowledge snapshot JSON, or `null`.
  String? readKnowledgeSnapshot();

  // ── Memory Graph ───────────────────────────────────────────────

  /// Persists the memory graph JSON blob (serialized MemoryGraph map
  /// containing entities and relations).
  Future<void> saveMemoryGraph(String json);

  /// Reads the previously persisted memory graph JSON, or `null`.
  String? readMemoryGraph();
}

// ─────────────────────────────────────────────────────────────────────────────
// SharedPreferencesStorageService
// ─────────────────────────────────────────────────────────────────────────────

/// [StorageService] implementation backed by `shared_preferences`.
///
/// All data is stored as JSON strings under well-known keys.
class SharedPreferencesStorageService implements StorageService {
  SharedPreferencesStorageService();

  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _sharedPrefs {
    final p = _prefs;
    assert(p != null, 'StorageService not initialized. Call init() first.');
    return p!;
  }

  // ── Identity ─────────────────────────────────────────────────────────

  @override
  Future<void> saveSelectedIdentity(Identity identity) async {
    await _sharedPrefs.setString(
      _StorageKeys.selectedIdentity,
      identity.toJson(),
    );
  }

  @override
  Identity? readSelectedIdentity() {
    final raw = _sharedPrefs.getString(_StorageKeys.selectedIdentity);
    if (raw == null) return null;
    try {
      return Identity.fromJson(raw);
    } catch (e) {
      PhoenixLogger.shared.warning(
        'StorageService: failed to parse Identity: $e',
        category: LogCategory.engine,
        source: 'StorageService',
      );
      return null;
    }
  }

  // ── Journey ──────────────────────────────────────────────────────────

  @override
  Future<void> saveJourney(Journey journey) async {
    await _sharedPrefs.setString(_StorageKeys.journey, journey.toJson());
  }

  @override
  Journey? readJourney() {
    final raw = _sharedPrefs.getString(_StorageKeys.journey);
    if (raw == null) return null;
    try {
      return Journey.fromJson(raw);
    } catch (e) {
      PhoenixLogger.shared.warning(
        'StorageService: failed to parse Journey: $e',
        category: LogCategory.engine,
        source: 'StorageService',
      );
      return null;
    }
  }

  // ── Progress ─────────────────────────────────────────────────────────

  @override
  Future<void> saveProgress(String progressJson) async {
    await _sharedPrefs.setString(_StorageKeys.progress, progressJson);
  }

  @override
  String? readProgress() {
    return _sharedPrefs.getString(_StorageKeys.progress);
  }

  // ── Memories ─────────────────────────────────────────────────────────

  @override
  Future<void> saveMemories(List<MemoryEntry> memories) async {
    final jsonList = memories.map((m) => m.toMap()).toList();
    await _sharedPrefs.setString(_StorageKeys.memories, json.encode(jsonList));
  }

  @override
  List<MemoryEntry> readMemories() {
    final raw = _sharedPrefs.getString(_StorageKeys.memories);
    if (raw == null) return const [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map(
            (item) =>
                MemoryEntry.fromMap(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (e) {
      PhoenixLogger.shared.warning(
        'StorageService: failed to parse Memories: $e',
        category: LogCategory.engine,
        source: 'StorageService',
      );
      return const [];
    }
  }

  // ── Career Profile ───────────────────────────────────────────────────

  @override
  Future<void> saveCareerProfile(CareerProfile profile) async {
    await _sharedPrefs.setString(_StorageKeys.careerProfile, profile.toJson());
  }

  @override
  CareerProfile? readCareerProfile() {
    final raw = _sharedPrefs.getString(_StorageKeys.careerProfile);
    if (raw == null) return null;
    try {
      return CareerProfile.fromJson(raw);
    } catch (e) {
      PhoenixLogger.shared.warning(
        'StorageService: failed to parse CareerProfile: $e',
        category: LogCategory.engine,
        source: 'StorageService',
      );
      return null;
    }
  }

  // ── User Settings ────────────────────────────────────────────────────

  @override
  Future<void> saveUserSettings(UserSettings settings) async {
    await _sharedPrefs.setString(_StorageKeys.userSettings, settings.toJson());
  }

  @override
  UserSettings readUserSettings() {
    final raw = _sharedPrefs.getString(_StorageKeys.userSettings);
    if (raw == null) return const UserSettings();
    try {
      return UserSettings.fromJson(raw);
    } catch (e) {
      PhoenixLogger.shared.warning(
        'StorageService: failed to parse UserSettings: $e',
        category: LogCategory.engine,
        source: 'StorageService',
      );
      return const UserSettings();
    }
  }

  // ── Academy Learning Paths ─────────────────────────────────────────

  @override
  Future<void> saveLearningPaths(String json) async {
    await _sharedPrefs.setString(_StorageKeys.learningPaths, json);
  }

  @override
  String? readLearningPaths() {
    return _sharedPrefs.getString(_StorageKeys.learningPaths);
  }

  // ── Academy Summaries ──────────────────────────────────────────────

  @override
  Future<void> saveAcademySummaries(String json) async {
    await _sharedPrefs.setString(_StorageKeys.academySummaries, json);
  }

  @override
  String? readAcademySummaries() {
    return _sharedPrefs.getString(_StorageKeys.academySummaries);
  }

  // ── Featured Academy ───────────────────────────────────────────────

  @override
  Future<void> saveFeaturedAcademy(String json) async {
    await _sharedPrefs.setString(_StorageKeys.featuredAcademy, json);
  }

  @override
  String? readFeaturedAcademy() {
    return _sharedPrefs.getString(_StorageKeys.featuredAcademy);
  }

  // ── Habits ─────────────────────────────────────────────────────────

  @override
  Future<void> saveHabits(String json) async {
    await _sharedPrefs.setString(_StorageKeys.habits, json);
  }

  @override
  String? readHabits() {
    return _sharedPrefs.getString(_StorageKeys.habits);
  }

  // ── Habit Entries ──────────────────────────────────────────────────

  @override
  Future<void> saveHabitEntries(String json) async {
    await _sharedPrefs.setString(_StorageKeys.habitEntries, json);
  }

  @override
  String? readHabitEntries() {
    return _sharedPrefs.getString(_StorageKeys.habitEntries);
  }

  // ── Habit Statistics ───────────────────────────────────────────────

  @override
  Future<void> saveHabitStatistics(String json) async {
    await _sharedPrefs.setString(_StorageKeys.habitStatistics, json);
  }

  @override
  String? readHabitStatistics() {
    return _sharedPrefs.getString(_StorageKeys.habitStatistics);
  }

  // ── Timeline Events ────────────────────────────────────────────────

  @override
  Future<void> saveTimelineEvents(String json) async {
    await _sharedPrefs.setString(_StorageKeys.timelineEvents, json);
  }

  @override
  String? readTimelineEvents() {
    return _sharedPrefs.getString(_StorageKeys.timelineEvents);
  }

  // ── Milestones ─────────────────────────────────────────────────────

  @override
  Future<void> saveMilestones(String json) async {
    await _sharedPrefs.setString(_StorageKeys.milestones, json);
  }

  @override
  String? readMilestones() {
    return _sharedPrefs.getString(_StorageKeys.milestones);
  }

  // ── Decision History ───────────────────────────────────────────────

  @override
  Future<void> saveDecisionHistory(String json) async {
    await _sharedPrefs.setString(_StorageKeys.decisionHistory, json);
  }

  @override
  String? readDecisionHistory() {
    return _sharedPrefs.getString(_StorageKeys.decisionHistory);
  }

  // ── Knowledge Snapshot ─────────────────────────────────────────────

  @override
  Future<void> saveKnowledgeSnapshot(String json) async {
    await _sharedPrefs.setString(_StorageKeys.knowledgeSnapshot, json);
  }

  @override
  String? readKnowledgeSnapshot() {
    return _sharedPrefs.getString(_StorageKeys.knowledgeSnapshot);
  }

  // ── Memory Graph ───────────────────────────────────────────────

  @override
  Future<void> saveMemoryGraph(String json) async {
    await _sharedPrefs.setString(_StorageKeys.memoryGraph, json);
  }

  @override
  String? readMemoryGraph() {
    return _sharedPrefs.getString(_StorageKeys.memoryGraph);
  }
}
