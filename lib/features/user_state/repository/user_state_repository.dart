import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_state.dart';

/// Dedicated persistence entry point for user state.
///
/// [UserStateRepository] is the ONLY persistence entry point for user
/// state data. No feature should read or write user state through any
/// other storage mechanism.
///
/// Reuses the existing `shared_preferences` architecture. Does NOT
/// introduce a new persistence solution.
///
/// All data is stored under the `phx_user_state_*` key prefix.
class UserStateRepository {
  static const String _stateKey = 'phx_user_state';
  static const String _cacheKey = 'phx_user_state_cache';

  // ── Full State ────────────────────────────────────────────────────

  /// Loads the persisted user state, or `null` if none exists.
  Future<UserState?> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_stateKey);
    if (raw == null) return null;
    try {
      return UserState.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  /// Persists the full user state (replaces existing).
  Future<void> saveState(UserState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_stateKey, state.toJson());
  }

  /// Clears all persisted user state.
  Future<void> clearState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_stateKey);
    await prefs.remove(_cacheKey);
  }

  // ── Cache ─────────────────────────────────────────────────────────

  /// Saves a cache snapshot for quick loading.
  Future<void> cacheState(UserState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, state.toJson());
  }

  /// Loads the cached state, or `null` if none.
  Future<UserState?> loadCachedState() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    try {
      return UserState.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  // ── Validation ────────────────────────────────────────────────────

  /// Checks whether persisted state exists.
  Future<bool> hasState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_stateKey);
  }

  /// Returns the size of the persisted state in bytes (approximate).
  Future<int> stateSizeBytes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_stateKey);
    return raw?.length ?? 0;
  }
}
