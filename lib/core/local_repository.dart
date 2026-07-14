import '../features/identity/models/identity.dart';
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
  List<Academy> get academySummaries => _fallback.academySummaries;

  @override
  Academy get featuredAcademy => _fallback.featuredAcademy;

  @override
  List<Progress> get dashboardSections => _fallback.dashboardSections;

  // ── Knowledge DNA ────────────────────────────────────────────────────

  @override
  KnowledgeDNA get knowledgeProfile => _fallback.knowledgeProfile;

  // ── Quick Actions ────────────────────────────────────────────────────

  @override
  List<QuickActionItem> get quickActions => _fallback.quickActions;
}
