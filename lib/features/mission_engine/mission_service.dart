import '../../core/repository.dart';
import '../../core/sample_repository.dart';
import '../growth_index/engine/growth_index_engine.dart';
import '../user_state/services/user_state_service.dart';
import '../progress_engine/progress_service.dart';
import '../knowledge_dna/knowledge_dna_service.dart';
import '../portfolio/services/portfolio_service.dart';
import '../resume/services/resume_service.dart';
import '../interview/services/interview_service.dart';
import '../opportunity/services/opportunity_service.dart';
import '../recommendation/services/recommendation_service.dart';
import 'engine/mission_engine.dart';
import 'engine/mission_generator.dart';
import 'engine/mission_prioritizer.dart';
import 'engine/mission_scheduler.dart';
import 'mission_engine.dart' as model;
import 'repository/mission_repository.dart';
import 'services/mission_service.dart' as new_service;

/// Central service for mission management in Phoenix OS.
///
/// This is the backward-compatible facade that delegates to the
/// new Dynamic Mission Engine. All existing consumers continue
/// to work without modification.
class MissionService {
  MissionService({
    Repository? repository,
    this._userStateService,
    this._growthEngine,
  }) : _repository = repository ?? const SampleRepository();

  final Repository _repository;
  final UserStateService? _userStateService;
  final GrowthIndexEngine? _growthEngine;

  late final MissionRepository _missionRepository =
      MissionRepository();
  late final ProgressService _progressService =
      ProgressService(repository: _repository);

  late final MissionPrioritizer _prioritizer =
      MissionPrioritizer(growthEngine: _growthEngine);

  late final MissionScheduler _scheduler = MissionScheduler();

  late final MissionEngine _engine = MissionEngine(
    generator: _createGenerator(),
    prioritizer: _prioritizer,
    scheduler: _scheduler,
  );

  late final new_service.MissionService _newService =
      new_service.MissionService(
    engine: _engine,
    repository: _missionRepository,
    prioritizer: _prioritizer,
    scheduler: _scheduler,
    progressService: _progressService,
    userStateService: _userStateService,
    growthEngine: _growthEngine,
    initialMissions: _loadSeededMissions(),
  );

  MissionGenerator _createGenerator() {
    return MissionGenerator(
      knowledgeDnaService: KnowledgeDNAService(repository: _repository),
      portfolioService: PortfolioService(repository: _repository),
      resumeService: ResumeService(repository: _repository),
      interviewService: InterviewService(repository: _repository),
      opportunityService: OpportunityService(repository: _repository),
      recommendationService:
          RecommendationService(repository: _repository),
      growthEngine: _growthEngine,
    );
  }

  Future<void> init() => _newService.init();

  // ── Backward-compatible API ───────────────────────────────────────

  List<model.Mission> get dailyMissions => _repository.dailyMissions;

  List<model.Mission> get weeklyMissions => _repository.weeklyMissions;

  model.Mission get featuredMission {
    final featured = _newService.getFeaturedMission();
    if (featured != null) return featured;
    final missions = <model.Mission>[
      ..._repository.dailyMissions,
      ..._repository.weeklyMissions,
    ];
    return missions.firstWhere(
      (m) => m.isActionable,
      orElse: () => missions.first,
    );
  }

  MissionProgress buildProgress() {
    final daily = _repository.dailyMissions;
    final weekly = _repository.weeklyMissions;
    final missions = <model.Mission>[...daily, ...weekly];
    final completedCount = missions.where((m) => m.isCompleted).length;
    final pendingCount = missions.length - completedCount;
    final completionPercentage = missions.isEmpty
        ? 0.0
        : completedCount / missions.length;
    final streak = _calculateStreak(missions);

    return MissionProgress(
      dailyMissions: daily,
      weeklyMissions: weekly,
      completionPercentage: completionPercentage,
      completedCount: completedCount,
      pendingCount: pendingCount,
      streak: streak,
      summary: '$completedCount of ${missions.length} missions complete',
      featuredMission: featuredMission,
    );
  }

  MissionStatistics buildStatistics() {
    final progress = buildProgress();
    return MissionStatistics(
      totalMissions:
          progress.dailyMissions.length + progress.weeklyMissions.length,
      completedCount: progress.completedCount,
      pendingCount: progress.pendingCount,
      completionPercentage: progress.completionPercentage,
      streak: progress.streak,
      summary: progress.summary,
    );
  }

  // ── New API (delegated) ───────────────────────────────────────────

  Future<List<model.Mission>> loadHistory({
    int limit = 50,
    int offset = 0,
  }) =>
      _newService.loadHistory(limit: limit, offset: offset);

  Future<(model.Mission, int)> completeMission(String missionId) =>
      _newService.completeMission(missionId);

  Future<model.Mission> skipMission(String missionId) =>
      _newService.skipMission(missionId);

  Future<void> refreshMissions({int maxNewMissions = 5}) =>
      _newService.refreshMissions(maxNewMissions: maxNewMissions);

  List<model.Mission> getTodaysMissions() => _newService.getTodaysMissions();

  List<model.Mission> getUpcomingMissions() =>
      _newService.getUpcomingMissions();

  List<model.Mission> getActiveMissions() => _newService.getActiveMissions();

  List<model.Mission> getCompletedMissions() =>
      _newService.getCompletedMissions();

  List<model.Mission> getAllMissions() => _newService.getAllMissions();

  int getTodaysCompletedCount() => _newService.getTodaysCompletedCount();

  // ── Private helpers ───────────────────────────────────────────────

  List<model.Mission> _loadSeededMissions() {
    return [
      ..._repository.dailyMissions,
      ..._repository.weeklyMissions,
    ];
  }

  int _calculateStreak(List<model.Mission> missions) {
    var streak = 0;
    for (final mission in missions) {
      if (mission.isCompleted) {
        streak += 1;
      } else {
        break;
      }
    }
    return streak;
  }
}

// ═════════════════════════════════════════════════════════════════════
// Backward-compatible data classes
// ═════════════════════════════════════════════════════════════════════

class MissionProgress {
  const MissionProgress({
    required this.dailyMissions,
    required this.weeklyMissions,
    required this.completionPercentage,
    required this.completedCount,
    required this.pendingCount,
    required this.streak,
    required this.summary,
    required this.featuredMission,
  });

  final List<model.Mission> dailyMissions;
  final List<model.Mission> weeklyMissions;
  final double completionPercentage;
  final int completedCount;
  final int pendingCount;
  final int streak;
  final String summary;
  final model.Mission featuredMission;
}

class MissionStatistics {
  const MissionStatistics({
    required this.totalMissions,
    required this.completedCount,
    required this.pendingCount,
    required this.completionPercentage,
    required this.streak,
    required this.summary,
  });

  final int totalMissions;
  final int completedCount;
  final int pendingCount;
  final double completionPercentage;
  final int streak;
  final String summary;
}
