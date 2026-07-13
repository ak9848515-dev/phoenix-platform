import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../mission_engine.dart';

/// Dedicated persistence entry point for all mission data.
///
/// The [MissionRepository] is the ONLY persistence layer for missions.
/// No feature should read or write mission data directly through any
/// other storage mechanism.
///
/// This repository manages:
/// - Mission CRUD operations
/// - Mission state persistence
/// - Mission cache
/// - History loading with lazy pagination
///
/// All data is stored under the `phx_missions_*` key prefix in
/// SharedPreferences.
class MissionRepository {
  static const String _missionsKey = 'phx_missions';
  static const String _historyKey = 'phx_mission_history';
  static const String _cacheKey = 'phx_mission_cache';

  // ── Active Missions ───────────────────────────────────────────────

  /// Loads all active missions from persistence.
  Future<List<Mission>> loadMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_missionsKey);
    if (raw == null) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((item) =>
              Mission.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Saves all missions to persistence (replaces existing).
  Future<void> saveMissions(List<Mission> missions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = missions.map((m) => m.toMap()).toList();
    await prefs.setString(_missionsKey, json.encode(jsonList));
  }

  /// Updates a single mission in the persisted list.
  Future<void> updateMission(Mission mission) async {
    final missions = await loadMissions();
    final index = missions.indexWhere((m) => m.id == mission.id);
    if (index == -1) {
      missions.add(mission);
    } else {
      missions[index] = mission;
    }
    await saveMissions(missions);
  }

  /// Deletes a mission from persistence.
  Future<void> deleteMission(String missionId) async {
    final missions = await loadMissions();
    missions.removeWhere((m) => m.id == missionId);
    await saveMissions(missions);
  }

  /// Clears all persisted missions.
  Future<void> clearMissions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_missionsKey);
  }

  // ── Cached Missions (for performance) ─────────────────────────────

  /// Saves a cache snapshot of generated missions for quick loading.
  /// Does not affect active mission state.
  Future<void> cacheGeneratedMissions(List<Mission> missions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = missions.map((m) => m.toMap()).toList();
    await prefs.setString(_cacheKey, json.encode(jsonList));
  }

  /// Loads the cached generated missions, or null if none.
  Future<List<Mission>?> loadCachedMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((item) =>
              Mission.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ── Mission History ──────────────────────────────────────────────

  /// Loads completed mission history (lazy-loaded for performance).
  Future<List<Mission>> loadHistory({int limit = 50, int offset = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      final all = list
          .map((item) =>
              Mission.fromMap(Map<String, dynamic>.from(item as Map)))
          .where((m) => m.isCompleted)
          .toList();
      // Return paginated results (most recent first).
      all.sort((a, b) {
        final aDate = a.completedDate ?? a.createdDate ?? DateTime(2000);
        final bDate = b.completedDate ?? b.createdDate ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });
      if (offset >= all.length) return [];
      final end = (offset + limit) > all.length ? all.length : offset + limit;
      return all.sublist(offset, end);
    } catch (_) {
      return [];
    }
  }

  /// Archives completed missions to history.
  Future<void> archiveToHistory(List<Mission> completedMissions) async {
    final history = await loadHistory(limit: 1000);
    final all = [...history, ...completedMissions];
    final prefs = await SharedPreferences.getInstance();
    final jsonList = all.map((m) => m.toMap()).toList();
    await prefs.setString(_historyKey, json.encode(jsonList));
  }
}
