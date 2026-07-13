import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/career/models/career_profile.dart';
import '../features/identity/models/identity.dart';
import '../features/journey/models/journey.dart';
import '../features/memory/models/memory_entry.dart';
import '../models/user_settings.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Storage keys
// ─────────────────────────────────────────────────────────────────────────────

abstract final class _StorageKeys {
  static const selectedIdentity = 'phx_selected_identity';
  static const journey = 'phx_journey';
  static const progress = 'phx_progress';
  static const memories = 'phx_memories';
  static const careerProfile = 'phx_career_profile';
  static const userSettings = 'phx_user_settings';
}

// ─────────────────────────────────────────────────────────────────────────────
// StorageService
// ─────────────────────────────────────────────────────────────────────────────

/// Abstract local persistence boundary for the Phoenix platform.
///
/// Provides typed read/write access for all domain models that need
/// to survive application restarts. The current implementation is
/// [SharedPreferencesStorageService], backed by `shared_preferences`.
///
/// No cloud sync, no networking, no AI.
abstract class StorageService {
  // ── Lifecycle ────────────────────────────────────────────────────────

  /// Initialize the storage backend. Must be called once before any
  /// read or write operation.
  Future<void> init();

  // ── Identity ─────────────────────────────────────────────────────────

  /// Persists the user's selected identity.
  Future<void> saveSelectedIdentity(Identity identity);

  /// Reads the previously persisted selected identity, or `null` if none.
  Identity? readSelectedIdentity();

  // ── Journey ──────────────────────────────────────────────────────────

  /// Persists the user's journey.
  Future<void> saveJourney(Journey journey);

  /// Reads the previously persisted journey, or `null` if none.
  Journey? readJourney();

  // ── Progress ─────────────────────────────────────────────────────────

  /// Persists the progress JSON blob.
  Future<void> saveProgress(String progressJson);

  /// Reads the previously persisted progress JSON, or `null` if none.
  String? readProgress();

  // ── Memories ─────────────────────────────────────────────────────────

  /// Persists a list of memory entries.
  Future<void> saveMemories(List<MemoryEntry> memories);

  /// Reads the previously persisted memory entries, or an empty list.
  List<MemoryEntry> readMemories();

  // ── Career Profile ───────────────────────────────────────────────────

  /// Persists the user's career profile.
  Future<void> saveCareerProfile(CareerProfile profile);

  /// Reads the previously persisted career profile, or `null` if none.
  CareerProfile? readCareerProfile();

  // ── User Settings ────────────────────────────────────────────────────

  /// Persists user settings.
  Future<void> saveUserSettings(UserSettings settings);

  /// Reads the previously persisted user settings, or defaults.
  UserSettings readUserSettings();
}

// ─────────────────────────────────────────────────────────────────────────────
// SharedPreferencesStorageService
// ─────────────────────────────────────────────────────────────────────────────

/// [StorageService] implementation backed by `shared_preferences`.
///
/// All data is stored as JSON strings under well-known keys.
class SharedPreferencesStorageService implements StorageService {
  SharedPreferencesStorageService();

  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _sharedPrefs {
    final p = _prefs;
    assert(p != null, 'StorageService not initialized. Call init() first.');
    return p!;
  }

  // ── Identity ─────────────────────────────────────────────────────────

  @override
  Future<void> saveSelectedIdentity(Identity identity) async {
    await _sharedPrefs.setString(
      _StorageKeys.selectedIdentity,
      identity.toJson(),
    );
  }

  @override
  Identity? readSelectedIdentity() {
    final raw = _sharedPrefs.getString(_StorageKeys.selectedIdentity);
    if (raw == null) return null;
    try {
      return Identity.fromJson(raw);
    } catch (e) {
      debugPrint('StorageService: failed to parse Identity: $e');
      return null;
    }
  }

  // ── Journey ──────────────────────────────────────────────────────────

  @override
  Future<void> saveJourney(Journey journey) async {
    await _sharedPrefs.setString(_StorageKeys.journey, journey.toJson());
  }

  @override
  Journey? readJourney() {
    final raw = _sharedPrefs.getString(_StorageKeys.journey);
    if (raw == null) return null;
    try {
      return Journey.fromJson(raw);
    } catch (e) {
      debugPrint('StorageService: failed to parse Journey: $e');
      return null;
    }
  }

  // ── Progress ─────────────────────────────────────────────────────────

  @override
  Future<void> saveProgress(String progressJson) async {
    await _sharedPrefs.setString(_StorageKeys.progress, progressJson);
  }

  @override
  String? readProgress() {
    return _sharedPrefs.getString(_StorageKeys.progress);
  }

  // ── Memories ─────────────────────────────────────────────────────────

  @override
  Future<void> saveMemories(List<MemoryEntry> memories) async {
    final jsonList = memories.map((m) => m.toMap()).toList();
    await _sharedPrefs.setString(_StorageKeys.memories, json.encode(jsonList));
  }

  @override
  List<MemoryEntry> readMemories() {
    final raw = _sharedPrefs.getString(_StorageKeys.memories);
    if (raw == null) return const [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map(
            (item) =>
                MemoryEntry.fromMap(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (e) {
      debugPrint('StorageService: failed to parse Memories: $e');
      return const [];
    }
  }

  // ── Career Profile ───────────────────────────────────────────────────

  @override
  Future<void> saveCareerProfile(CareerProfile profile) async {
    await _sharedPrefs.setString(_StorageKeys.careerProfile, profile.toJson());
  }

  @override
  CareerProfile? readCareerProfile() {
    final raw = _sharedPrefs.getString(_StorageKeys.careerProfile);
    if (raw == null) return null;
    try {
      return CareerProfile.fromJson(raw);
    } catch (e) {
      debugPrint('StorageService: failed to parse CareerProfile: $e');
      return null;
    }
  }

  // ── User Settings ────────────────────────────────────────────────────

  @override
  Future<void> saveUserSettings(UserSettings settings) async {
    await _sharedPrefs.setString(_StorageKeys.userSettings, settings.toJson());
  }

  @override
  UserSettings readUserSettings() {
    final raw = _sharedPrefs.getString(_StorageKeys.userSettings);
    if (raw == null) return const UserSettings();
    try {
      return UserSettings.fromJson(raw);
    } catch (e) {
      debugPrint('StorageService: failed to parse UserSettings: $e');
      return const UserSettings();
    }
  }
}
