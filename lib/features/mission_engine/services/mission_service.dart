import '../../user_state/services/user_state_service.dart';
import '../../progress_engine/progress_service.dart';
import '../engine/mission_engine.dart';
import '../engine/mission_prioritizer.dart';
import '../engine/mission_scheduler.dart';
import '../mission_engine.dart' as model;
import '../repository/mission_repository.dart';

/// Public API for all mission features in Phoenix OS.
///
/// The [MissionService] is the ONLY entry point for consuming missions.
/// All features (Dashboard, AI, Profile, Academy, etc.) must go through
/// this service — never through [MissionRepository] or [MissionEngine]
/// directly.
///
/// Exposes:
/// - Today's missions
/// - Upcoming missions
/// - Active missions
/// - Completed missions
/// - Mission history
/// - Complete mission
/// - Skip mission
/// - Refresh missions
class MissionService {
  MissionService({
    required this._engine,
    required this._repository,
    required this._prioritizer,
    required this._scheduler,
    required this._progressService,
    List<model.Mission>? initialMissions,
    this._userStateService,
  }) : _allMissions = initialMissions ?? [];

  final MissionEngine _engine;
  final MissionRepository _repository;
  final MissionPrioritizer _prioritizer;
  final MissionScheduler _scheduler;
  final ProgressService _progressService;
  final UserStateService? _userStateService;

  List<model.Mission> _allMissions;
  bool _initialized = false;

  // ── Initialization ────────────────────────────────────────────────

  /// Initializes the service by loading persisted missions and generating
  /// new ones if needed. Call once before accessing mission data.
  Future<void> init() async {
    if (_initialized) return;

    // Load persisted missions
    final persisted = await _repository.loadMissions();
    if (persisted.isNotEmpty) {
      _allMissions = _engine.refreshRecurring(persisted);
      await _repository.saveMissions(_allMissions);
    }

    _initialized = true;
  }

  // ── Today's Missions ──────────────────────────────────────────────

  /// Returns missions scheduled for today, sorted by priority.
  List<model.Mission> getTodaysMissions() {
    return _prioritizer.prioritize(
      _scheduler.getTodaysMissions(_allMissions),
    );
  }

  // ── Upcoming Missions ─────────────────────────────────────────────

  /// Returns missions due in the next 7 days.
  List<model.Mission> getUpcomingMissions() {
    return _prioritizer.prioritize(
      _scheduler.getUpcomingMissions(_allMissions),
    );
  }

  // ── Active Missions ───────────────────────────────────────────────

  /// Returns all currently actionable missions (pending, in-progress).
  List<model.Mission> getActiveMissions() {
    return _allMissions.where((m) => m.isActionable).toList();
  }

  // ── Completed Missions ────────────────────────────────────────────

  /// Returns all completed missions.
  List<model.Mission> getCompletedMissions() {
    return _allMissions.where((m) => m.isCompleted).toList();
  }

  // ── All Missions ──────────────────────────────────────────────────

  /// Returns all missions (active + completed).
  List<model.Mission> getAllMissions() => List.unmodifiable(_allMissions);

  // ── Mission History (lazy-loaded) ─────────────────────────────────

  /// Loads mission history from persistence (lazy-loaded).
  Future<List<model.Mission>> loadHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    return _repository.loadHistory(limit: limit, offset: offset);
  }

  // ── Complete Mission ──────────────────────────────────────────────

  /// Completes a mission. Returns the updated mission and XP awarded.
  ///
  /// The UI simply triggers completion — the engine handles all side
  /// effects (XP, recurrence, dependency unblocking, persistence).
  Future<(model.Mission, int)> completeMission(String missionId) async {
    final index = _allMissions.indexWhere((m) => m.id == missionId);
    if (index == -1) {
      throw StateError('Mission not found: $missionId');
    }

    final (updated, xpAwarded) = _engine.completeMission(
      _allMissions[index],
    );

    _allMissions[index] = updated;

    // Unblock dependents
    _allMissions = _engine.unblockDependents(
      completedMissionId: missionId,
      allMissions: _allMissions,
    );

    // Update progress service
    _progressService.addXp(xpAwarded);

    // Update UserStateService with new missions and XP
    await _userStateService?.setMissions(_allMissions);
    await _userStateService?.addXp(xpAwarded);
    await _userStateService?.touch();

    // Persist changes
    await _repository.saveMissions(_allMissions);

    return (updated, xpAwarded);
  }

  // ── Skip Mission ──────────────────────────────────────────────────

  /// Skips a mission without completing it.
  Future<model.Mission> skipMission(String missionId) async {
    final index = _allMissions.indexWhere((m) => m.id == missionId);
    if (index == -1) {
      throw StateError('Mission not found: $missionId');
    }

    _allMissions[index] = _engine.skipMission(_allMissions[index]);
    await _repository.saveMissions(_allMissions);
    await _userStateService?.setMissions(_allMissions);

    return _allMissions[index];
  }

  // ── Refresh Missions ──────────────────────────────────────────────

  /// Generates new missions from all platform services and merges them
  /// with existing missions.
  Future<void> refreshMissions({int maxNewMissions = 5}) async {
    final newMissions = _engine.generateMissions(
      currentMissions: _allMissions,
      maxMissions: maxNewMissions,
    );

    _allMissions = [..._allMissions, ...newMissions];

    // Generate daily batch
    final dailyBatch = _engine.generateDailyBatch(
      existingMissions: _allMissions,
      availableTemplates: newMissions,
    );

    _allMissions = [
      ..._allMissions,
      ...dailyBatch.where((m) => !_allMissions.any((e) => e.id == m.id)),
    ];

    // Refresh recurring missions
    _allMissions = _engine.refreshRecurring(_allMissions);

    // Cache the generated missions for quick loading
    await _repository.cacheGeneratedMissions(newMissions);
    await _repository.saveMissions(_allMissions);
    await _userStateService?.setMissions(_allMissions);
    await _userStateService?.touch();
  }

  // ── Utility ───────────────────────────────────────────────────────

  /// Returns the highest-priority mission for today.
  model.Mission? getFeaturedMission() {
    return _engine.findTopPriority(getTodaysMissions());
  }

  /// Returns the count of completed missions today.
  int getTodaysCompletedCount() {
    final today = DateTime.now();
    return _allMissions
        .where((m) =>
            m.isCompleted &&
            m.completedDate != null &&
            m.completedDate!.year == today.year &&
            m.completedDate!.month == today.month &&
            m.completedDate!.day == today.day)
        .length;
  }

  /// Validates all missions and returns error messages.
  List<String> validateAll() {
    return _allMissions
        .map((m) => _engine.validateMission(m))
        .where((e) => e != null)
        .cast<String>()
        .toList();
  }
}
