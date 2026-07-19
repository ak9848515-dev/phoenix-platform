import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/journey_history.dart';
import '../models/journey_history_entry.dart';
import '../models/journey_resume_point.dart';
import '../models/journey_snapshot.dart';
import 'journey_repository_interface.dart';

/// Local implementation of [JourneyRepositoryInterface] using [SharedPreferences].
class LocalJourneyRepository implements JourneyRepositoryInterface {
  const LocalJourneyRepository();

  static const String _snapshotKey = 'journey_snapshot';
  static const String _historyKey = 'journey_history';

  @override
  Future<JourneySnapshot?> loadCachedSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_snapshotKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return JourneySnapshot(
        currentJourney: map['currentJourney'] as String? ?? '',
        currentStage: map['currentStage'] as String? ?? '',
        completionPercent: (map['completionPercent'] as num?)?.toDouble() ?? 0.0,
        estimatedRemainingMinutes: map['estimatedRemainingMinutes'] as int? ?? 0,
        priority: map['priority'] as int? ?? 0,
        reason: map['reason'] as String? ?? '',
        lastUpdated: map['lastUpdated'] != null
            ? DateTime.parse(map['lastUpdated'] as String)
            : null,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheSnapshot(JourneySnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{
      'currentJourney': snapshot.currentJourney,
      'currentStage': snapshot.currentStage,
      'completionPercent': snapshot.completionPercent,
      'estimatedRemainingMinutes': snapshot.estimatedRemainingMinutes,
      'priority': snapshot.priority,
      'reason': snapshot.reason,
      'lastUpdated': snapshot.lastUpdated?.toIso8601String(),
    };
    await prefs.setString(_snapshotKey, json.encode(map));
  }

  @override
  Future<JourneyHistory> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return const JourneyHistory();
    try {
      final list = json.decode(raw) as List<dynamic>;
      final entries = list.map((e) {
        final m = e as Map<String, dynamic>;
        return JourneyHistoryEntry(
          activityId: m['activityId'] as String,
          activityTitle: m['activityTitle'] as String? ?? '',
          activityType: _parseType(m['activityType'] as String? ?? ''),
          status: m['status'] as String? ?? 'started',
          startedAt: m['startedAt'] != null
              ? DateTime.parse(m['startedAt'] as String)
              : null,
          completedAt: m['completedAt'] != null
              ? DateTime.parse(m['completedAt'] as String)
              : null,
          resumeCount: m['resumeCount'] as int? ?? 0,
          totalMinutesSpent: m['totalMinutesSpent'] as int? ?? 0,
          xpEarned: m['xpEarned'] as int? ?? 0,
        );
      }).toList();
      return JourneyHistory(entries: entries);
    } catch (_) {
      return const JourneyHistory();
    }
  }

  @override
  Future<void> saveHistory(JourneyHistory history) async {
    final prefs = await SharedPreferences.getInstance();
    final list = history.entries.map((e) => {
          'activityId': e.activityId,
          'activityTitle': e.activityTitle,
          'activityType': e.activityType.name,
          'status': e.status,
          'startedAt': e.startedAt?.toIso8601String(),
          'completedAt': e.completedAt?.toIso8601String(),
          'resumeCount': e.resumeCount,
          'totalMinutesSpent': e.totalMinutesSpent,
          'xpEarned': e.xpEarned,
        }).toList();
    await prefs.setString(_historyKey, json.encode(list));
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_snapshotKey);
    await prefs.remove(_historyKey);
  }

  JourneyResumePoint _parseType(String name) {
    return JourneyResumePoint.values.firstWhere(
      (t) => t.name == name,
      orElse: () => JourneyResumePoint.unknown,
    );
  }
}
