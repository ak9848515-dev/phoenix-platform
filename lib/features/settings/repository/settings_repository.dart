import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

/// Repository for persisting application settings.
///
/// Uses SharedPreferences with JSON serialization.
/// Data access only — no business logic, no validation.
///
/// Responsibilities:
/// - Load settings from storage
/// - Save settings to storage
/// - Reset to defaults
/// - Import/export for backup
class SettingsRepository {
  static const String _settingsKey = 'phx_app_settings_v2';

  // ── Load / Save ──────────────────────────────────────────────────

  /// Loads settings from storage, or `null` if none persisted.
  Future<AppSettings?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null) return null;
    try {
      return AppSettings.fromMap(
        Map<String, dynamic>.from(json.decode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  /// Persists settings to storage.
  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, json.encode(settings.toMap()));
  }

  /// Removes all persisted settings from storage.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_settingsKey);
  }

  // ── Import / Export ──────────────────────────────────────────────

  /// Exports settings as a JSON string for backup.
  Future<String> exportJson() async {
    final settings = await load();
    return json.encode(settings?.toMap() ?? const AppSettings().toMap());
  }

  /// Imports settings from a JSON string (from backup).
  ///
  /// Returns `true` if the JSON was valid and imported successfully.
  Future<bool> importJson(String jsonString) async {
    try {
      final map = json.decode(jsonString) as Map<String, dynamic>;
      final settings = AppSettings.fromMap(map);
      await save(settings);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Defaults ─────────────────────────────────────────────────────

  /// Returns the default settings.
  static const AppSettings defaults = AppSettings();
}
