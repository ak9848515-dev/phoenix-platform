import '../../../core/plugins/runtime/plugin.dart' as runtime;
import '../../../core/plugins/runtime/plugin_registry.dart';
import '../../../core/plugins/services/plugin_service.dart';
import '../../../core/repository.dart';
import '../../../core/sample_repository.dart';
import '../models/marketplace_plugin.dart';
import '../models/plugin_installation.dart';

/// Orchestrates the Marketplace — the local plugin management layer.
///
/// This is NOT an online store. It manages installed and available plugins
/// using the existing Plugin lifecycle (PluginService, PluginRegistry,
/// PluginManager).
///
/// No AI, no networking, no persistence, no purchases, no authentication.
///
/// Reuses:
///   - PluginService
///   - PluginRegistry
///   - PluginManager (via PluginService)
///   - Repository
class MarketplaceService {
  MarketplaceService({Repository? repository, PluginService? pluginService})
    : repository = repository ?? const SampleRepository(),
      _pluginService = pluginService ?? const PluginService() {
    _initializeRegistry();
  }

  final Repository repository;
  final PluginService _pluginService;

  // ── Registry ───────────────────────────────────────────────────────

  PluginRegistry _registry = const PluginRegistry();

  /// Initializes the registry with all built-in plugins installed.
  ///
  /// Activates the plugin matching the user's selected identity so that
  /// their current identity appears as an active plugin.
  void _initializeRegistry() {
    // Install all built-in plugins
    final installResult = _pluginService.installBuiltInPlugins(_registry);
    if (!installResult.success) return;

    var current = installResult.registry;

    // Activate the plugin that matches the user's selected identity
    final identityTitle = repository.selectedIdentity.title;
    final identityPlugin = _findMatchingPlugin(current, identityTitle);

    if (identityPlugin != null) {
      // Run full lifecycle for the matching plugin
      final lifecycleResult = _pluginService.runFullLifecycle(
        registry: current,
        pluginId: identityPlugin.manifest.id,
      );
      if (lifecycleResult.success) {
        current = lifecycleResult.registry;
      }
    }

    _registry = current;
  }

  /// Finds the plugin whose name most closely matches [identityTitle].
  runtime.Plugin? _findMatchingPlugin(
    PluginRegistry registry,
    String identityTitle,
  ) {
    final lower = identityTitle.toLowerCase();
    // Try exact match first
    for (final plugin in registry.all) {
      if (plugin.manifest.name.toLowerCase() == lower) return plugin;
    }
    // Try contains match
    for (final plugin in registry.all) {
      if (lower.contains(plugin.manifest.name.toLowerCase()) ||
          plugin.manifest.name.toLowerCase().contains(lower)) {
        return plugin;
      }
    }
    return null;
  }

  // ── Public API ─────────────────────────────────────────────────────

  /// Returns all plugins in the marketplace (installed + available).
  List<MarketplacePlugin> getAllPlugins() {
    return _registry.all.map(_toMarketplacePlugin).toList();
  }

  /// Returns currently installed (and active) plugins.
  List<MarketplacePlugin> getInstalledPlugins() {
    return _registry.usable.map(_toMarketplacePlugin).toList();
  }

  /// Returns plugins available for activation (installed but not active).
  List<MarketplacePlugin> getAvailablePlugins() {
    return _registry.all
        .where(
          (p) =>
              p.state != runtime.PluginLifecycleState.active &&
              p.state != runtime.PluginLifecycleState.removed,
        )
        .toList()
        .map(_toMarketplacePlugin)
        .toList();
  }

  /// Returns details for a specific plugin by [pluginId].
  MarketplacePlugin? getPluginDetails(String pluginId) {
    final plugin = _registry.getById(pluginId);
    if (plugin == null) return null;
    return _toMarketplacePlugin(plugin);
  }

  /// Activates the plugin with the given [pluginId].
  ///
  /// Runs the full lifecycle (validate → register → load → activate)
  /// for plugins in the [installed] state. Returns a [PluginInstallation]
  /// with the result.
  PluginInstallation activatePlugin(String pluginId) {
    final plugin = _registry.getById(pluginId);
    if (plugin == null) {
      return PluginInstallation(
        pluginId: pluginId,
        pluginName: pluginId,
        status: InstallStatus.error,
        error: 'Plugin not found.',
      );
    }

    final result = _pluginService.runFullLifecycle(
      registry: _registry,
      pluginId: pluginId,
    );

    if (result.success) {
      _registry = result.registry;
      return PluginInstallation(
        pluginId: pluginId,
        pluginName: plugin.manifest.name,
        status: InstallStatus.active,
        installedAt: DateTime.now(),
      );
    }

    return PluginInstallation(
      pluginId: pluginId,
      pluginName: plugin.manifest.name,
      status: InstallStatus.error,
      error: result.error,
    );
  }

  /// Deactivates the plugin with the given [pluginId].
  ///
  /// Returns a [PluginInstallation] with the result.
  PluginInstallation deactivatePlugin(String pluginId) {
    final plugin = _registry.getById(pluginId);
    if (plugin == null) {
      return PluginInstallation(
        pluginId: pluginId,
        pluginName: pluginId,
        status: InstallStatus.error,
        error: 'Plugin not found.',
      );
    }

    final result = _pluginService.deactivate(
      registry: _registry,
      pluginId: pluginId,
    );

    if (result.success) {
      _registry = result.registry;
      return PluginInstallation(
        pluginId: pluginId,
        pluginName: plugin.manifest.name,
        status: InstallStatus.installed,
      );
    }

    return PluginInstallation(
      pluginId: pluginId,
      pluginName: plugin.manifest.name,
      status: InstallStatus.error,
      error: result.error,
    );
  }

  /// Removes the plugin with the given [pluginId] from the registry.
  ///
  /// Returns a [PluginInstallation] with the result.
  PluginInstallation removePlugin(String pluginId) {
    final plugin = _registry.getById(pluginId);
    if (plugin == null) {
      return PluginInstallation(
        pluginId: pluginId,
        pluginName: pluginId,
        status: InstallStatus.error,
        error: 'Plugin not found.',
      );
    }

    final result = _pluginService.remove(
      registry: _registry,
      pluginId: pluginId,
    );

    if (result.success) {
      _registry = result.registry;
      return PluginInstallation(
        pluginId: pluginId,
        pluginName: plugin.manifest.name,
        status: InstallStatus.removed,
      );
    }

    return PluginInstallation(
      pluginId: pluginId,
      pluginName: plugin.manifest.name,
      status: InstallStatus.error,
      error: result.error,
    );
  }

  // ── Statistics ─────────────────────────────────────────────────────

  /// Total number of plugins in the marketplace.
  int get pluginCount => _registry.count;

  /// Number of active plugins.
  int get activeCount => _registry.active.length;

  /// Number of available (non-active, non-removed) plugins.
  int get availableCount => getAvailablePlugins().length;

  /// Returns a summary of all plugin states.
  Map<String, int> get stateSummary {
    final summary = <String, int>{};
    for (final plugin in _registry.all) {
      summary.update(
        plugin.state.name,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    return summary;
  }

  // ── Helpers ────────────────────────────────────────────────────────

  MarketplacePlugin _toMarketplacePlugin(runtime.Plugin plugin) {
    return MarketplacePlugin(
      plugin: plugin,
      rating: 4.5,
      downloadCount: plugin.isActive ? 1200 : 800,
      tags: _deriveTags(plugin),
    );
  }

  List<String> _deriveTags(runtime.Plugin p) {
    final tags = <String>[p.manifest.category];
    if (p.isActive) tags.add('Active');
    if (versionIsStable(p.manifest.version)) tags.add('Stable');
    return tags;
  }

  /// Simple check: versions starting with '1.' or higher are considered stable.
  static bool versionIsStable(String version) {
    final parts = version.split('.');
    if (parts.isEmpty) return false;
    final major = int.tryParse(parts[0]);
    return major != null && major >= 1;
  }
}
