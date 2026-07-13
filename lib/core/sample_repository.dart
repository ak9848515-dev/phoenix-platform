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

/// Sample implementation of [Repository] backed by [SampleDataService].
///
/// This is the default repository used throughout presentation screens and
/// services. It provides coherent sample data across all Phoenix modules
/// without requiring persistence, networking, or AI.
///
/// In the future this can be replaced by a database-backed implementation
/// without changing any code that depends on the [Repository] interface.
class SampleRepository implements Repository {
  const SampleRepository() : _data = const SampleDataService();

  final SampleDataService _data;

  @override
  Identity get selectedIdentity => _data.selectedIdentity;

  @override
  Journey get journey => _data.journey;

  @override
  JourneyStage get currentJourneyStage => _data.currentJourneyStage;

  @override
  Mission get featuredMission => _data.featuredMission;

  @override
  List<Progress> get missionProgress => _data.missionProgress;

  @override
  List<mission_engine.Mission> get dailyMissions => _data.dailyMissions;

  @override
  List<mission_engine.Mission> get weeklyMissions => _data.weeklyMissions;

  @override
  List<Progress> get knowledgeProgress => _data.knowledgeProgress;

  @override
  List<Academy> get academySummaries => _data.academySummaries;

  @override
  Academy get featuredAcademy => _data.featuredAcademy;

  @override
  List<Progress> get dashboardSections => _data.dashboardSections;

  @override
  KnowledgeDNA get knowledgeProfile => _data.knowledgeProfile;

  @override
  List<QuickActionItem> get quickActions => _data.quickActions;
}
