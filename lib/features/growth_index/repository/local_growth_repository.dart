import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/growth_snapshot.dart';
import 'growth_repository_interface.dart';

/// [SharedPreferences]-backed implementation of [GrowthRepositoryInterface].
///
/// Caches the latest [GrowthSnapshot] as JSON for fast app restart
/// and offline startup.
class LocalGrowthRepository implements GrowthRepositoryInterface {
  const LocalGrowthRepository();

  static const String _snapshotKey = 'phx_growth_snapshot';

  @override
  Future<void> cacheSnapshot(GrowthSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_snapshotKey, json.encode(snapshot.toMap()));
  }

  @override
  Future<GrowthSnapshot?> loadCachedSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_snapshotKey);
    if (raw == null) return null;
    try {
      return GrowthSnapshot.fromMap(
          json.decode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_snapshotKey);
  }
}
