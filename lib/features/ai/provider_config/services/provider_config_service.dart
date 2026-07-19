import '../../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../models/provider_config.dart';
import 'provider_config_repository.dart';
import 'secure_storage_service.dart';

/// Business logic layer for AI provider configuration.
///
/// Coordinates between [ProviderConfigurationRepository] and
/// [SecureStorageService]. Widgets must never access repositories
/// or storage services directly — always go through this service.
///
/// Responsibilities:
/// - Load and save provider configurations
/// - Enable/disable providers
/// - Set default provider
/// - Manage fallback order
/// - Coordinate API key storage with config
class ProviderConfigurationService {
  ProviderConfigurationService({
    ProviderConfigurationRepository? repository,
    SecureStorageService? secureStorage,
  })  : _repository = repository ?? ProviderConfigurationRepository(),
        _secureStorage =
            secureStorage ?? FlutterSecureStorageService();

  final ProviderConfigurationRepository _repository;
  final SecureStorageService _secureStorage;
  final PhoenixLogger _logger = PhoenixLogger.shared;

  List<ProviderConfiguration>? _cachedConfigs;

  // ── Load ─────────────────────────────────────────────────────────

  /// Loads all provider configurations.
  ///
  /// Results are cached in memory for the lifetime of the service.
  /// Call [refresh] to reload from storage.
  Future<List<ProviderConfiguration>> loadAll() async {
    if (_cachedConfigs != null) return _cachedConfigs!;
    return refresh();
  }

  /// Reloads all configurations from storage.
  Future<List<ProviderConfiguration>> refresh() async {
    _cachedConfigs = await _repository.loadAll();
    return _cachedConfigs!;
  }

  /// Loads a single provider configuration by ID, or `null` if not found.
  Future<ProviderConfiguration?> load(String providerId) async {
    final configs = await loadAll();
    return configs.cast<ProviderConfiguration?>().firstWhere(
          (c) => c!.providerId == providerId,
          orElse: () => null,
        );
  }

  // ── Save ─────────────────────────────────────────────────────────

  /// Saves or updates a provider configuration.
  Future<void> save(ProviderConfiguration config) async {
    await _repository.updateConfiguration(config);
    _cachedConfigs = await _repository.loadAll();
    _logger.info('Provider config saved: ${config.providerId}',
        category: LogCategory.config, source: 'ProviderConfigurationService');
  }

  // ── Enable / Disable ─────────────────────────────────────────────

  /// Enables a provider by setting [ProviderConfiguration.enabled] to true.
  Future<void> enableProvider(String providerId) async {
    final config = await load(providerId);
    if (config == null) return;
    await save(config.copyWith(enabled: true));
    _logger.info('Provider enabled: $providerId',
        category: LogCategory.config, source: 'ProviderConfigurationService');
  }

  /// Disables a provider by setting [ProviderConfiguration.enabled] to false.
  Future<void> disableProvider(String providerId) async {
    final config = await load(providerId);
    if (config == null) return;
    await save(config.copyWith(enabled: false));
    _logger.info('Provider disabled: $providerId',
        category: LogCategory.config, source: 'ProviderConfigurationService');
  }

  /// Whether a provider is enabled.
  Future<bool> isEnabled(String providerId) async {
    final config = await load(providerId);
    return config?.enabled ?? false;
  }

  // ── Default Provider ─────────────────────────────────────────────

  /// Sets a provider as the default.
  Future<void> setDefaultProvider(String providerId) async {
    final configs = await loadAll();
    for (final config in configs) {
      final updated = config.copyWith(
        isDefault: config.providerId == providerId,
      );
      await _repository.updateConfiguration(updated);
    }
    await _repository.saveDefaultProviderId(providerId);
    _cachedConfigs = await _repository.loadAll();
    _logger.info('Default provider set: $providerId',
        category: LogCategory.config, source: 'ProviderConfigurationService');
  }

  /// Returns the default provider ID, or `null` if none is set.
  Future<String?> getDefaultProviderId() async {
    return _repository.loadDefaultProviderId();
  }

  // ── Preferred Model ──────────────────────────────────────────────

  /// Sets the preferred model for a provider.
  Future<void> setPreferredModel(
      String providerId, String? model) async {
    final config = await load(providerId);
    if (config == null) return;
    await save(config.copyWith(preferredModel: model));
  }

  // ── Offline Mode ─────────────────────────────────────────────────

  /// Sets offline mode for a provider.
  Future<void> setOfflineMode(String providerId, bool offline) async {
    final config = await load(providerId);
    if (config == null) return;
    await save(config.copyWith(offlineMode: offline));
  }

  // ── Fallback Order ───────────────────────────────────────────────

  /// Saves the fallback provider order.
  Future<void> setFallbackOrder(List<String> providerIds) async {
    // Update fallbackPriority on each matching config
    for (var i = 0; i < providerIds.length; i++) {
      final config = await load(providerIds[i]);
      if (config != null) {
        await save(config.copyWith(fallbackPriority: i));
      }
    }
    await _repository.saveFallbackOrder(providerIds);
  }

  /// Returns the current fallback order, or an empty list.
  Future<List<String>> getFallbackOrder() async {
    return _repository.loadFallbackOrder();
  }

  // ── API Keys ─────────────────────────────────────────────────────

  /// Stores an encrypted API key for a provider.
  Future<void> storeApiKey(String providerId, String encryptedKey) async {
    await _secureStorage.storeApiKey(providerId, encryptedKey);
    _logger.info('API key stored for: $providerId',
        category: LogCategory.config, source: 'ProviderConfigurationService');
  }

  /// Reads the encrypted API key for a provider, or `null`.
  Future<String?> readApiKey(String providerId) async {
    return _secureStorage.readApiKey(providerId);
  }

  /// Deletes the API key for a provider.
  Future<void> deleteApiKey(String providerId) async {
    await _secureStorage.deleteApiKey(providerId);
    _logger.info('API key deleted for: $providerId',
        category: LogCategory.config, source: 'ProviderConfigurationService');
  }

  /// Whether a provider has a stored API key.
  Future<bool> hasApiKey(String providerId) async {
    return _secureStorage.hasApiKey(providerId);
  }

  /// Returns all providers that have configured API keys and are enabled.
  Future<List<ProviderConfiguration>> getConfiguredProviders() async {
    final configs = await loadAll();
    final result = <ProviderConfiguration>[];
    for (final config in configs) {
      if (config.enabled && await hasApiKey(config.providerId)) {
        result.add(config);
      }
    }
    return result;
  }

  // ── Health Status ────────────────────────────────────────────────

  /// Updates the health status for a provider.
  Future<void> updateHealthStatus(
    String providerId,
    ProviderHealthStatus status, {
    DateTime? timestamp,
  }) async {
    final config = await load(providerId);
    if (config == null) return;

    await save(config.copyWith(
      healthStatus: status,
      lastSuccessfulConnection:
          status == ProviderHealthStatus.healthy ? (timestamp ?? DateTime.now()) : config.lastSuccessfulConnection,
      lastFailure:
          status.isError ? (timestamp ?? DateTime.now()) : config.lastFailure,
    ));
  }

  // ── Utility ──────────────────────────────────────────────────────

  /// Returns only enabled providers.
  Future<List<ProviderConfiguration>> getEnabledProviders() async {
    final configs = await loadAll();
    return configs.where((c) => c.enabled).toList();
  }

  /// Bulk-initializes configurations for a list of known provider IDs.
  ///
  /// Creates default configurations for any providers not already
  /// persisted. Safe to call on every startup — existing configs
  /// are preserved.
  Future<void> initializeDefaults(List<ProviderConfigDefaults> defaults) async {
    final existing = await loadAll();
    final existingIds = existing.map((c) => c.providerId).toSet();

    for (final def in defaults) {
      if (!existingIds.contains(def.providerId)) {
        await _repository.updateConfiguration(ProviderConfiguration(
          providerId: def.providerId,
          providerName: def.providerName,
          enabled: def.enabledByDefault,
          isDefault: def.isDefault,
          preferredModel: def.defaultModel,
          offlineMode: def.supportsOffline,
          fallbackPriority: def.fallbackPriority,
        ));
      }
    }

    // Update default provider if not set
    final currentDefault = await _repository.loadDefaultProviderId();
    if (currentDefault == null) {
      final defaultDef =
          defaults.where((d) => d.isDefault).firstOrNull;
      if (defaultDef != null) {
        await _repository.saveDefaultProviderId(defaultDef.providerId);
      }
    }

    _cachedConfigs = await _repository.loadAll();
    _logger.info('Provider config defaults initialized',
        category: LogCategory.config, source: 'ProviderConfigurationService');
  }

  /// Resets all provider configuration data.
  Future<void> resetAll() async {
    _cachedConfigs = null;
    await _repository.clearAll();
    _logger.info('Provider config reset',
        category: LogCategory.config, source: 'ProviderConfigurationService');
  }
}

/// Default values for initializing a provider configuration.
class ProviderConfigDefaults {
  const ProviderConfigDefaults({
    required this.providerId,
    required this.providerName,
    this.enabledByDefault = true,
    this.isDefault = false,
    this.defaultModel,
    this.supportsOffline = false,
    this.fallbackPriority = 0,
  });

  final String providerId;
  final String providerName;
  final bool enabledByDefault;
  final bool isDefault;
  final String? defaultModel;
  final bool supportsOffline;
  final int fallbackPriority;
}
