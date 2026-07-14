import 'dart:convert';

import '../features/academy/models/learning_path.dart';
import '../features/decision/models/decision_analysis.dart';
import '../features/habit/models/habit.dart';
import '../features/habit/models/habit_entry.dart';
import '../features/identity/models/identity.dart';
import '../features/timeline/models/milestone.dart';
import '../features/timeline/models/timeline_event.dart';
import '../features/journey/models/journey.dart';
import '../features/journey/models/journey_stage.dart';
import '../features/knowledge_dna/models/knowledge_dna.dart';
import '../features/mission_engine/mission_engine.dart' as mission_engine;
import '../models/academy.dart';
import '../models/mission.dart';
import '../models/progress.dart';
import '../services/sample_data_service.dart';
import 'repository.dart';
import 'sample_repository.dart';
import 'storage_service.dart';

/// [Repository] implementation backed by local storage via [StorageService].
///
/// Reads persisted data from [StorageService] on each property access.
/// If no persisted data is found for a given domain, falls back to
/// [SampleRepository] defaults so the app remains functional on first launch.
///
/// Writes are delegated through the [StorageService] so that any feature
/// service that writes to the repository can do so through the same interface.
///
/// This class is intentionally **not** const because it depends on an
/// async-initialized storage backend.
class LocalRepository implements Repository {
  LocalRepository({required StorageService storageService})
    : _storage = storageService;

  final StorageService _storage;
  final Repository _fallback = const SampleRepository();

  // ── Identity ─────────────────────────────────────────────────────────

  @override
  Identity get selectedIdentity =>
      _storage.readSelectedIdentity() ?? _fallback.selectedIdentity;

  // ── Journey ──────────────────────────────────────────────────────────

  @override
  Journey get journey => _storage.readJourney() ?? _fallback.journey;

  @override
  JourneyStage get currentJourneyStage => journey.stages[journey.currentStage];

  // ── Missions ─────────────────────────────────────────────────────────

  @override
  CurriculumMission get featuredMission => _fallback.featuredMission;

  @override
  List<Progress> get missionProgress => _fallback.missionProgress;

  @override
  List<mission_engine.Mission> get dailyMissions => _fallback.dailyMissions;

  @override
  List<mission_engine.Mission> get weeklyMissions => _fallback.weeklyMissions;

  // ── Progression ──────────────────────────────────────────────────────

  @override
  List<Progress> get knowledgeProgress => _fallback.knowledgeProgress;

  @override
  List<Academy> get academySummaries {
    final raw = _storage.readAcademySummaries();
    if (raw == null) return _fallback.academySummaries;
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((item) =>
              Academy.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return _fallback.academySummaries;
    }
  }

  @override
  Academy get featuredAcademy {
    final raw = _storage.readFeaturedAcademy();
    if (raw == null) return _fallback.featuredAcademy;
    try {
      return Academy.fromJson(raw);
    } catch (_) {
      return _fallback.featuredAcademy;
    }
  }

  // ── Habits ───────────────────────────────────────────────────────────

  /// Loads habits from storage, or returns an empty list.
  List<Habit> get habits {
    final raw = _storage.readHabits();
    if (raw == null) return const [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((item) =>
              Habit.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Loads habit entries from storage, or returns an empty list.
  List<HabitEntry> get habitEntries {
    final raw = _storage.readHabitEntries();
    if (raw == null) return const [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((item) =>
              HabitEntry.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  // ── Timeline ─────────────────────────────────────────────────────────

  /// Loads timeline events from storage, or returns an empty list.
  List<TimelineEvent> get timelineEvents {
    final raw = _storage.readTimelineEvents();
    if (raw == null) return const [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((item) => TimelineEvent.fromMap(
              Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Loads milestones from storage, or returns an empty list.
  List<Milestone> get milestones {
    final raw = _storage.readMilestones();
    if (raw == null) return const [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((item) =>
              Milestone.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  // ── Decision History ────────────────────────────────────────────────

  /// Loads decision history from storage, or returns an empty list.
  List<DecisionAnalysis> get decisionHistory {
    final raw = _storage.readDecisionHistory();
    if (raw == null) return const [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((item) => DecisionAnalysis.fromMap(
              Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  // ── Knowledge Snapshot ──────────────────────────────────────────────

  /// Loads the knowledge snapshot from storage, or returns null.
  Map<String, dynamic>? get knowledgeSnapshot {
    final raw = _storage.readKnowledgeSnapshot();
    if (raw == null) return null;
    try {
      return Map<String, dynamic>.from(
          json.decode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── Memory Graph ────────────────────────────────────────────────

  /// Loads the memory graph data from storage, or returns null.
  Map<String, dynamic>? get memoryGraph {
    final raw = _storage.readMemoryGraph();
    if (raw == null) return null;
    try {
      return Map<String, dynamic>.from(
          json.decode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Loads learning paths from storage, or returns default paths.
  List<LearningPath> get learningPaths {
    final raw = _storage.readLearningPaths();
    if (raw == null) return const [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((item) =>
              LearningPath.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  List<Progress> get dashboardSections => _fallback.dashboardSections;

  // ── Knowledge DNA ────────────────────────────────────────────────────

  @override
  KnowledgeDNA get knowledgeProfile => _fallback.knowledgeProfile;

  // ── Quick Actions ────────────────────────────────────────────────────

  @override
  List<QuickActionItem> get quickActions => _fallback.quickActions;
}
