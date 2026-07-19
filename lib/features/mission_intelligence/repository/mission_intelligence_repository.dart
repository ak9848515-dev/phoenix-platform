import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/mission_history.dart';
import '../models/mission_history_entry.dart';
import '../models/mission_snapshot.dart';
import 'mission_intelligence_repository_interface.dart';

/// Local implementation of [MissionIntelligenceRepositoryInterface] using
/// [SharedPreferences] for persistence.
///
/// Consistent with [LocalIdentityRepository] and [LocalGrowthRepository]
/// patterns — uses JSON serialization and SharedPreferences for lightweight
/// offline-first caching.
class LocalMissionIntelligenceRepository
    implements MissionIntelligenceRepositoryInterface {
  const LocalMissionIntelligenceRepository();

  static const String _snapshotKey = 'mission_intelligence_snapshot';
  static const String _historyKey = 'mission_intelligence_history';

  @override
  Future<MissionSnapshot?> loadCachedSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_snapshotKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return MissionSnapshot(
        confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
        impactScore: (map['impactScore'] as num?)?.toDouble() ?? 0.0,
        completionPercent:
            (map['completionPercent'] as num?)?.toDouble() ?? 0.0,
        reason: map['reason'] as String? ?? '',
        estimatedDuration: map['estimatedDuration'] as int? ?? 0,
        rewardXP: map['rewardXP'] as int? ?? 0,
        lastUpdated: map['lastUpdated'] != null
            ? DateTime.parse(map['lastUpdated'] as String)
            : null,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheSnapshot(MissionSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{
      'confidence': snapshot.confidence,
      'impactScore': snapshot.impactScore,
      'completionPercent': snapshot.completionPercent,
      'reason': snapshot.reason,
      'estimatedDuration': snapshot.estimatedDuration,
      'rewardXP': snapshot.rewardXP,
      'lastUpdated': snapshot.lastUpdated?.toIso8601String(),
    };
    await prefs.setString(_snapshotKey, json.encode(map));
  }

  @override
  Future<MissionHistory> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) {
      return const MissionHistory();
    }
    try {
      final list = json.decode(raw) as List<dynamic>;
      final entries = list.map((e) {
        final m = e as Map<String, dynamic>;
        return MissionHistoryEntry(
          missionId: m['missionId'] as String,
          missionTitle: m['missionTitle'] as String,
          recommendationId: m['recommendationId'] as String,
          ruleName: m['ruleName'] as String,
          recommendedAt: DateTime.parse(m['recommendedAt'] as String),
          acceptedAt: m['acceptedAt'] != null
              ? DateTime.parse(m['acceptedAt'] as String)
              : null,
          rejectedAt: m['rejectedAt'] != null
              ? DateTime.parse(m['rejectedAt'] as String)
              : null,
          completedAt: m['completedAt'] != null
              ? DateTime.parse(m['completedAt'] as String)
              : null,
          accepted: m['accepted'] as bool? ?? false,
          rejected: m['rejected'] as bool? ?? false,
          completed: m['completed'] as bool? ?? false,
          xpEarned: m['xpEarned'] as int?,
          completionTimeMinutes: m['completionTimeMinutes'] as int?,
        );
      }).toList();
      return MissionHistory(entries: entries);
    } catch (_) {
      return const MissionHistory();
    }
  }

  @override
  Future<void> saveHistory(MissionHistory history) async {
    final prefs = await SharedPreferences.getInstance();
    final list = history.entries.map((e) => {
          'missionId': e.missionId,
          'missionTitle': e.missionTitle,
          'recommendationId': e.recommendationId,
          'ruleName': e.ruleName,
          'recommendedAt': e.recommendedAt.toIso8601String(),
          'acceptedAt': e.acceptedAt?.toIso8601String(),
          'rejectedAt': e.rejectedAt?.toIso8601String(),
          'completedAt': e.completedAt?.toIso8601String(),
          'accepted': e.accepted,
          'rejected': e.rejected,
          'completed': e.completed,
          'xpEarned': e.xpEarned,
          'completionTimeMinutes': e.completionTimeMinutes,
        }).toList();
    await prefs.setString(_historyKey, json.encode(list));
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_snapshotKey);
    await prefs.remove(_historyKey);
  }
}
