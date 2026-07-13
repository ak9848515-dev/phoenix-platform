import '../features/identity/models/identity.dart';
import '../features/journey/models/journey.dart';
import '../features/journey/models/journey_stage.dart';
import '../features/knowledge_dna/models/knowledge_dna.dart';
import '../features/mission_engine/mission_engine.dart' as mission_engine;
import '../models/academy.dart';
import '../models/mission.dart';
import '../models/progress.dart';
import '../services/sample_data_service.dart';

/// Abstract data access boundary for the Phoenix platform.
///
/// Every feature service depends on this interface rather than on a concrete
/// data source. This allows the implementation to be swapped (e.g. from
/// sample data to a database) without changing any service or screen code.
///
/// Current implementation: [SampleRepository] backed by [SampleDataService].
abstract class Repository {
  // ── Identity ────────────────────────────────────────────────────────

  /// The user's selected identity.
  Identity get selectedIdentity;

  // ── Journey ─────────────────────────────────────────────────────────

  /// The user's full journey.
  Journey get journey;

  /// The current in-progress journey stage.
  JourneyStage get currentJourneyStage;

  // ── Missions ────────────────────────────────────────────────────────

  /// The featured/today's mission.
  Mission get featuredMission;

  /// Mission progress indicators.
  List<Progress> get missionProgress;

  /// Daily missions derived from the current journey stage.
  List<mission_engine.Mission> get dailyMissions;

  /// Weekly missions spanning other stages and skill areas.
  List<mission_engine.Mission> get weeklyMissions;

  // ── Progression ─────────────────────────────────────────────────────

  /// Knowledge DNA progress indicators.
  List<Progress> get knowledgeProgress;

  /// Available academy summaries.
  List<Academy> get academySummaries;

  /// The featured/primary academy.
  Academy get featuredAcademy;

  /// Dashboard section progress indicators.
  List<Progress> get dashboardSections;

  // ── Knowledge DNA ───────────────────────────────────────────────────

  /// The user's Knowledge DNA profile.
  KnowledgeDNA get knowledgeProfile;

  // ── Quick Actions ───────────────────────────────────────────────────

  /// Available quick action items for the dashboard.
  List<QuickActionItem> get quickActions;
}
