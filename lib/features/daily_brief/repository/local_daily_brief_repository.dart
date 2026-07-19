import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_brief_snapshot.dart';
import '../models/daily_history.dart';
import '../models/daily_history_entry.dart';
import 'daily_brief_repository_interface.dart';

/// Local implementation of [DailyBriefRepositoryInterface] using [SharedPreferences].
class LocalDailyBriefRepository implements DailyBriefRepositoryInterface {
  const LocalDailyBriefRepository();

  static const String _snapshotKey = 'daily_brief_snapshot';
  static const String _historyKey = 'daily_brief_history';

  @override
  Future<DailyBriefSnapshot?> loadCachedSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_snapshotKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return DailyBriefSnapshot(
        todaysFocus: map['todaysFocus'] as String? ?? '',
        todaysMission: map['todaysMission'] as String? ?? '',
        todaysGoal: map['todaysGoal'] as String? ?? '',
        totalMinutes: map['totalMinutes'] as int? ?? 0,
        totalXp: map['totalXp'] as int? ?? 0,
        expectedGrowth: (map['expectedGrowth'] as num?)?.toDouble() ?? 0.0,
        lastUpdated: map['lastUpdated'] != null
            ? DateTime.parse(map['lastUpdated'] as String)
            : null,
        date: map['date'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheSnapshot(DailyBriefSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{
      'todaysFocus': snapshot.todaysFocus,
      'todaysMission': snapshot.todaysMission,
      'todaysGoal': snapshot.todaysGoal,
      'totalMinutes': snapshot.totalMinutes,
      'totalXp': snapshot.totalXp,
      'expectedGrowth': snapshot.expectedGrowth,
      'lastUpdated': snapshot.lastUpdated?.toIso8601String(),
      'date': snapshot.date,
    };
    await prefs.setString(_snapshotKey, json.encode(map));
  }

  @override
  Future<DailyHistory> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return const DailyHistory();
    try {
      final list = json.decode(raw) as List<dynamic>;
      final entries = list.map((e) {
        final m = e as Map<String, dynamic>;
        return DailyHistoryEntry(
          date: m['date'] as String,
          todaysFocus: m['todaysFocus'] as String? ?? '',
          totalTasks: m['totalTasks'] as int? ?? 0,
          completedTasks: m['completedTasks'] as int? ?? 0,
          xpEarned: m['xpEarned'] as int? ?? 0,
          growthDelta: (m['growthDelta'] as num?)?.toDouble() ?? 0.0,
          completionRatio:
              (m['completionRatio'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
      return DailyHistory(entries: entries);
    } catch (_) {
      return const DailyHistory();
    }
  }

  @override
  Future<void> saveHistory(DailyHistory history) async {
    final prefs = await SharedPreferences.getInstance();
    final list = history.entries.map((e) => {
          'date': e.date,
          'todaysFocus': e.todaysFocus,
          'totalTasks': e.totalTasks,
          'completedTasks': e.completedTasks,
          'xpEarned': e.xpEarned,
          'growthDelta': e.growthDelta,
          'completionRatio': e.completionRatio,
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
