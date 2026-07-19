import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/identity_profile.dart';
import '../models/identity_snapshot.dart';
import 'identity_repository_interface.dart';

/// [IdentityRepositoryInterface] implementation backed by SharedPreferences.
///
/// Uses its own storage keys for identity data. On first launch when no
/// data is persisted, returns `null` so the engine falls back to defaults.
///
/// Consistent with the persistence pattern used across the platform.
class LocalIdentityRepository implements IdentityRepositoryInterface {
  const LocalIdentityRepository();

  // ── Storage Keys ─────────────────────────────────────────────────

  static const String _profileKey = 'phx_identity_profile';
  static const String _snapshotCacheKey = 'phx_identity_snapshot_cache';

  // ── Profile ──────────────────────────────────────────────────────

  @override
  Future<IdentityProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null) return null;
    try {
      return IdentityProfile.fromMap(
        Map<String, dynamic>.from(json.decode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveProfile(IdentityProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, json.encode(profile.toMap()));
  }

  // ── Snapshot Cache ───────────────────────────────────────────────

  @override
  Future<IdentitySnapshot?> loadCachedSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_snapshotCacheKey);
    if (raw == null) return null;
    try {
      final map = Map<String, dynamic>.from(json.decode(raw) as Map);
      return IdentitySnapshot(
        profile: IdentityProfile.fromMap(
          Map<String, dynamic>.from(map['profile'] as Map),
        ),
        currentIdentityTitle: map['currentIdentityTitle'] as String,
        targetIdentityTitle: map['targetIdentityTitle'] as String,
        currentGoal: map['currentGoal'] as String,
        experience: map['experience'] as String,
        progress: map['progress'] as String,
        currentMissionTitle: map['currentMissionTitle'] as String? ?? '',
        currentLearningPathTitle:
            map['currentLearningPathTitle'] as String? ?? '',
        currentCareerPathTitle:
            map['currentCareerPathTitle'] as String? ?? '',
        growthIndex: (map['growthIndex'] as num?)?.toDouble() ?? 0.0,
        completionPercent: map['completionPercent'] as int? ?? 0,
        lastUpdated: map['lastUpdated'] != null
            ? DateTime.parse(map['lastUpdated'] as String)
            : DateTime.now(),
        missionCount: map['missionCount'] as int? ?? 0,
        completedMissions: map['completedMissions'] as int? ?? 0,
        lessonCount: map['lessonCount'] as int? ?? 0,
        completedLessons: map['completedLessons'] as int? ?? 0,
        totalXp: map['totalXp'] as int? ?? 0,
        level: map['level'] as int? ?? 1,
        activeHabitCount: map['activeHabitCount'] as int? ?? 0,
        knowledgeNodeCount: map['knowledgeNodeCount'] as int? ?? 0,
        hasActiveMission: map['hasActiveMission'] as bool? ?? false,
        hasActiveLearning: map['hasActiveLearning'] as bool? ?? false,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheSnapshot(IdentitySnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _snapshotCacheKey,
      json.encode({
        'profile': snapshot.profile.toMap(),
        'currentIdentityTitle': snapshot.currentIdentityTitle,
        'targetIdentityTitle': snapshot.targetIdentityTitle,
        'currentGoal': snapshot.currentGoal,
        'experience': snapshot.experience,
        'progress': snapshot.progress,
        'currentMissionTitle': snapshot.currentMissionTitle,
        'currentLearningPathTitle': snapshot.currentLearningPathTitle,
        'currentCareerPathTitle': snapshot.currentCareerPathTitle,
        'growthIndex': snapshot.growthIndex,
        'completionPercent': snapshot.completionPercent,
        'lastUpdated': snapshot.lastUpdated.toIso8601String(),
        'missionCount': snapshot.missionCount,
        'completedMissions': snapshot.completedMissions,
        'lessonCount': snapshot.lessonCount,
        'completedLessons': snapshot.completedLessons,
        'totalXp': snapshot.totalXp,
        'level': snapshot.level,
        'activeHabitCount': snapshot.activeHabitCount,
        'knowledgeNodeCount': snapshot.knowledgeNodeCount,
        'hasActiveMission': snapshot.hasActiveMission,
        'hasActiveLearning': snapshot.hasActiveLearning,
      }),
    );
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    await prefs.remove(_snapshotCacheKey);
  }
}
