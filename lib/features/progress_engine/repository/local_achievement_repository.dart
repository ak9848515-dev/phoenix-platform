import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../achievement_snapshot.dart';
import 'achievement_repository_interface.dart';

/// Local implementation of [AchievementRepositoryInterface] using SharedPreferences.
class LocalAchievementRepository implements AchievementRepositoryInterface {
  const LocalAchievementRepository();

  static const String _snapshotKey = 'achievement_snapshot';

  @override
  Future<AchievementSnapshot?> loadCachedSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_snapshotKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return AchievementSnapshot(
        badges: List<String>.from(map['badges'] as List? ?? []),
        milestones: List<String>.from(map['milestones'] as List? ?? []),
        rewards: List<String>.from(map['rewards'] as List? ?? []),
        certificates: List<String>.from(map['certificates'] as List? ?? []),
        totalBadges: map['totalBadges'] as int? ?? 0,
        totalMilestones: map['totalMilestones'] as int? ?? 0,
        totalRewards: map['totalRewards'] as int? ?? 0,
        totalCertificates: map['totalCertificates'] as int? ?? 0,
        lastUpdated: map['lastUpdated'] != null
            ? DateTime.parse(map['lastUpdated'] as String)
            : null,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheSnapshot(AchievementSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{
      'badges': snapshot.badges,
      'milestones': snapshot.milestones,
      'rewards': snapshot.rewards,
      'certificates': snapshot.certificates,
      'totalBadges': snapshot.totalBadges,
      'totalMilestones': snapshot.totalMilestones,
      'totalRewards': snapshot.totalRewards,
      'totalCertificates': snapshot.totalCertificates,
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
