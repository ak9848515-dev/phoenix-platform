import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../engine/career_snapshot.dart';
import 'career_repository_interface.dart';

/// Local implementation of [CareerRepositoryInterface] using SharedPreferences.
class LocalCareerRepository implements CareerRepositoryInterface {
  const LocalCareerRepository();

  static const String _snapshotKey = 'career_snapshot';

  @override
  Future<CareerSnapshot?> loadCachedSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_snapshotKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return CareerSnapshot(
        careerScore: (map['careerScore'] as num?)?.toDouble() ?? 0.0,
        jobReadiness: map['jobReadiness'] as String? ?? 'Starting Out',
        strengths: List<String>.from(map['strengths'] as List? ?? []),
        skillGaps: List<String>.from(map['skillGaps'] as List? ?? []),
        nextGoal: map['nextGoal'] as String? ?? '',
        estimatedWeeks: map['estimatedWeeks'] as int? ?? 12,
        portfolioProgress:
            (map['portfolioProgress'] as num?)?.toDouble() ?? 0.0,
        resumeProgress: (map['resumeProgress'] as num?)?.toDouble() ?? 0.0,
        interviewReadiness:
            (map['interviewReadiness'] as num?)?.toDouble() ?? 0.0,
        applicationCount: map['applicationCount'] as int? ?? 0,
        offerCount: map['offerCount'] as int? ?? 0,
        careerTimeline:
            List<String>.from(map['careerTimeline'] as List? ?? []),
        lastUpdated: map['lastUpdated'] != null
            ? DateTime.parse(map['lastUpdated'] as String)
            : null,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheSnapshot(CareerSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{
      'careerScore': snapshot.careerScore,
      'jobReadiness': snapshot.jobReadiness,
      'strengths': snapshot.strengths,
      'skillGaps': snapshot.skillGaps,
      'nextGoal': snapshot.nextGoal,
      'estimatedWeeks': snapshot.estimatedWeeks,
      'portfolioProgress': snapshot.portfolioProgress,
      'resumeProgress': snapshot.resumeProgress,
      'interviewReadiness': snapshot.interviewReadiness,
      'applicationCount': snapshot.applicationCount,
      'offerCount': snapshot.offerCount,
      'careerTimeline': snapshot.careerTimeline,
      'lastUpdated': snapshot.lastUpdated?.toIso8601String(),
    };
    await prefs.setString(_snapshotKey, json.encode(map));
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_snapshotKey);
  }
}
