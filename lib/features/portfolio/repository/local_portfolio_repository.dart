import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../engine/portfolio_snapshot.dart';
import 'portfolio_repository_interface.dart';

/// Local implementation of [PortfolioRepositoryInterface] using SharedPreferences.
class LocalPortfolioRepository implements PortfolioRepositoryInterface {
  const LocalPortfolioRepository();

  static const String _snapshotKey = 'portfolio_snapshot';

  @override
  Future<PortfolioSnapshot?> loadCachedSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_snapshotKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return PortfolioSnapshot(
        portfolioScore: (map['portfolioScore'] as num?)?.toDouble() ?? 0.0,
        projectCount: map['projectCount'] as int? ?? 0,
        skillCount: map['skillCount'] as int? ?? 0,
        technologyCount: map['technologyCount'] as int? ?? 0,
        achievementCount: map['achievementCount'] as int? ?? 0,
        careerReadiness: map['careerReadiness'] as String? ?? '',
        strengthAreas: List<String>.from(map['strengthAreas'] as List? ?? []),
        improvementAreas:
            List<String>.from(map['improvementAreas'] as List? ?? []),
        technologies: List<String>.from(map['technologies'] as List? ?? []),
        lastUpdated: map['lastUpdated'] != null
            ? DateTime.parse(map['lastUpdated'] as String)
            : null,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheSnapshot(PortfolioSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{
      'portfolioScore': snapshot.portfolioScore,
      'projectCount': snapshot.projectCount,
      'skillCount': snapshot.skillCount,
      'technologyCount': snapshot.technologyCount,
      'achievementCount': snapshot.achievementCount,
      'careerReadiness': snapshot.careerReadiness,
      'strengthAreas': snapshot.strengthAreas,
      'improvementAreas': snapshot.improvementAreas,
      'technologies': snapshot.technologies,
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
