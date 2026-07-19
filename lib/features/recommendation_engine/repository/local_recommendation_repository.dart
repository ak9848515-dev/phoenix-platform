import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/recommendation_history.dart';
import '../models/recommendation_history_entry.dart';
import '../models/recommendation_snapshot.dart';
import 'recommendation_repository_interface.dart';

/// Local implementation of [RecommendationRepositoryInterface] using
/// [SharedPreferences] for persistence.
class LocalRecommendationRepository
    implements RecommendationRepositoryInterface {
  const LocalRecommendationRepository();

  static const String _snapshotKey = 'rec_snapshot';
  static const String _historyKey = 'rec_history';

  @override
  Future<RecommendationSnapshot?> loadCachedSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_snapshotKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return RecommendationSnapshot(
        priority: map['priority'] as int? ?? 0,
        urgencyScore: (map['urgencyScore'] as num?)?.toDouble() ?? 0.0,
        confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
        estimatedBenefit:
            (map['estimatedBenefit'] as num?)?.toDouble() ?? 0.0,
        estimatedDuration: map['estimatedDuration'] as int? ?? 0,
        missionLink: map['missionLink'] as String? ?? '',
        growthImpact: (map['growthImpact'] as num?)?.toDouble() ?? 0.0,
        careerImpact: (map['careerImpact'] as num?)?.toDouble() ?? 0.0,
        learningImpact: (map['learningImpact'] as num?)?.toDouble() ?? 0.0,
        lastUpdated: map['lastUpdated'] != null
            ? DateTime.parse(map['lastUpdated'] as String)
            : null,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheSnapshot(RecommendationSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{
      'priority': snapshot.priority,
      'urgencyScore': snapshot.urgencyScore,
      'confidence': snapshot.confidence,
      'estimatedBenefit': snapshot.estimatedBenefit,
      'estimatedDuration': snapshot.estimatedDuration,
      'missionLink': snapshot.missionLink,
      'growthImpact': snapshot.growthImpact,
      'careerImpact': snapshot.careerImpact,
      'learningImpact': snapshot.learningImpact,
      'lastUpdated': snapshot.lastUpdated?.toIso8601String(),
    };
    await prefs.setString(_snapshotKey, json.encode(map));
  }

  @override
  Future<RecommendationHistory> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) {
      return const RecommendationHistory();
    }
    try {
      final list = json.decode(raw) as List<dynamic>;
      final entries = list.map((e) {
        final m = e as Map<String, dynamic>;
        return RecommendationHistoryEntry(
          recommendationId: m['recommendationId'] as String,
          title: m['title'] as String,
          categoryName: m['categoryName'] as String,
          ruleName: m['ruleName'] as String,
          recommendedAt: DateTime.parse(m['recommendedAt'] as String),
          acceptedAt: m['acceptedAt'] != null
              ? DateTime.parse(m['acceptedAt'] as String)
              : null,
          dismissedAt: m['dismissedAt'] != null
              ? DateTime.parse(m['dismissedAt'] as String)
              : null,
          completedAt: m['completedAt'] != null
              ? DateTime.parse(m['completedAt'] as String)
              : null,
          accepted: m['accepted'] as bool? ?? false,
          dismissed: m['dismissed'] as bool? ?? false,
          completed: m['completed'] as bool? ?? false,
          ignored: m['ignored'] as bool? ?? false,
          completionTimeMinutes: m['completionTimeMinutes'] as int?,
        );
      }).toList();
      return RecommendationHistory(entries: entries);
    } catch (_) {
      return const RecommendationHistory();
    }
  }

  @override
  Future<void> saveHistory(RecommendationHistory history) async {
    final prefs = await SharedPreferences.getInstance();
    final list = history.entries.map((e) => {
          'recommendationId': e.recommendationId,
          'title': e.title,
          'categoryName': e.categoryName,
          'ruleName': e.ruleName,
          'recommendedAt': e.recommendedAt.toIso8601String(),
          'acceptedAt': e.acceptedAt?.toIso8601String(),
          'dismissedAt': e.dismissedAt?.toIso8601String(),
          'completedAt': e.completedAt?.toIso8601String(),
          'accepted': e.accepted,
          'dismissed': e.dismissed,
          'completed': e.completed,
          'ignored': e.ignored,
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
