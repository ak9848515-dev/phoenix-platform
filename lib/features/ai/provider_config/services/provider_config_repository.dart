import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/provider_config.dart';

/// Repository for persisting AI provider configurations.
///
/// Uses SharedPreferences with JSON serialization.
/// This is a data access layer only — no business logic.
/// All mutations go through [ProviderConfigurationService].
class ProviderConfigurationRepository {
  static const String _configsKey = 'phx_ai_provider_configs';
  static const String _defaultProviderKey = 'phx_ai_default_provider';
  static const String _fallbackOrderKey = 'phx_ai_fallback_order';

  // ── Load / Save All ──────────────────────────────────────────────

  /// Loads all provider configurations from storage.
  ///
  /// Returns an empty list if none are persisted.
  Future<List<ProviderConfiguration>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_configsKey);
    if (raw == null) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((item) => ProviderConfiguration.fromMap(
              Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Persists all provider configurations.
  Future<void> saveAll(List<ProviderConfiguration> configs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = json.encode(configs.map((c) => c.toMap()).toList());
    await prefs.setString(_configsKey, jsonData);
  }

  // ── Individual Operations ────────────────────────────────────────

  /// Updates a single provider configuration in the persisted list.
  Future<void> updateConfiguration(ProviderConfiguration config) async {
    final configs = await loadAll();
    final index = configs.indexWhere((c) => c.providerId == config.providerId);
    if (index >= 0) {
      final updated = List<ProviderConfiguration>.from(configs)
        ..[index] = config;
      await saveAll(updated);
    } else {
      final updated = List<ProviderConfiguration>.from(configs)..add(config);
      await saveAll(updated);
    }
  }

  /// Removes a provider configuration from persistence.
  Future<void> removeConfiguration(String providerId) async {
    final configs = await loadAll();
    configs.removeWhere((c) => c.providerId == providerId);
    await saveAll(configs);
  }

  // ── Default Provider ─────────────────────────────────────────────

  /// Loads the default provider ID from storage.
  Future<String?> loadDefaultProviderId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultProviderKey);
  }

  /// Persists the default provider ID.
  Future<void> saveDefaultProviderId(String providerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultProviderKey, providerId);
  }

  /// Clears the default provider setting.
  Future<void> clearDefaultProvider() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_defaultProviderKey);
  }

  // ── Fallback Order ───────────────────────────────────────────────

  /// Loads the ordered list of fallback provider IDs.
  Future<List<String>> loadFallbackOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_fallbackOrderKey);
    if (raw == null) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list.cast<String>();
    } catch (_) {
      return [];
    }
  }

  /// Persists the ordered fallback list.
  Future<void> saveFallbackOrder(List<String> providerIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fallbackOrderKey, json.encode(providerIds));
  }

  /// Clears the fallback order setting.
  Future<void> clearFallbackOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fallbackOrderKey);
  }

  // ── Clear All ────────────────────────────────────────────────────

  /// Removes all provider configuration data from storage.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_configsKey);
    await prefs.remove(_defaultProviderKey);
    await prefs.remove(_fallbackOrderKey);
  }
}
