import '../models/plugin_manifest.dart';
import '../runtime/plugin.dart';
import '../runtime/plugin_manager.dart';
import '../runtime/plugin_registry.dart';

/// Public API for the Phoenix Plugin System.
///
/// Provides high-level operations for managing plugins throughout their
/// lifecycle. All methods accept a [PluginRegistry] and return a
/// [PluginManagerResult] containing the updated registry.
///
/// Constructor injection is used for the [PluginManager] dependency.
/// No state management, no persistence, no networking, no AI.
///
/// Usage:
/// ```dart
/// final service = PluginService();
/// var registry = const PluginRegistry();
///
/// // Install and activate all built-in plugins
/// final result = service.installAndActivateBuiltIns(registry);
/// registry = result.registry;
/// ```
class PluginService {
  const PluginService({PluginManager? pluginManager})
    : _pluginManager = pluginManager ?? const PluginManager();

  final PluginManager _pluginManager;

  // ─────────────────────────────────────────────────────────────────────
  // Bulk operations
  // ─────────────────────────────────────────────────────────────────────

  /// Installs all built-in plugins into [registry].
  PluginManagerResult installBuiltInPlugins(PluginRegistry registry) {
    return _pluginManager.installBuiltInPlugins(registry);
  }

  /// Runs the full lifecycle (install → validate → register → load →
  /// activate) for all built-in plugins in [registry].
  ///
  /// Built-in plugins are installed first, then each one goes through the
  /// full lifecycle. Skips plugins that fail at any step and records errors.
  PluginManagerResult installAndActivateBuiltIns(PluginRegistry registry) {
    // First, install all built-in plugins
    final installResult = _pluginManager.installBuiltInPlugins(registry);
    if (!installResult.success) return installResult;

    var current = installResult.registry;

    // Run full lifecycle for each built-in plugin
    for (final plugin in current.all) {
      final lifecycleResult = _pluginManager.fullLifecycle(
        registry: current,
        pluginId: plugin.manifest.id,
      );
      if (!lifecycleResult.success) return lifecycleResult;
      current = lifecycleResult.registry;
    }

    return PluginManagerResult(registry: current, success: true);
  }

  // ─────────────────────────────────────────────────────────────────────
  // Single plugin operations
  // ─────────────────────────────────────────────────────────────────────

  /// Installs a new plugin with the given [manifest] and optional [metadata]
  /// into [registry].
  PluginManagerResult install({
    required PluginRegistry registry,
    required PluginManifest manifest,
    required Plugin plugin,
  }) {
    return _pluginManager.install(
      registry: registry,
      manifest: manifest,
      plugin: plugin,
    );
  }

  /// Validates the plugin with [pluginId] in [registry].
  PluginManagerResult validate({
    required PluginRegistry registry,
    required String pluginId,
  }) {
    return _pluginManager.validate(registry: registry, pluginId: pluginId);
  }

  /// Registers the plugin with [pluginId] in [registry].
  PluginManagerResult register({
    required PluginRegistry registry,
    required String pluginId,
  }) {
    return _pluginManager.register(registry: registry, pluginId: pluginId);
  }

  /// Loads the plugin with [pluginId] in [registry].
  PluginManagerResult load({
    required PluginRegistry registry,
    required String pluginId,
  }) {
    return _pluginManager.load(registry: registry, pluginId: pluginId);
  }

  /// Activates the plugin with [pluginId] in [registry].
  PluginManagerResult activate({
    required PluginRegistry registry,
    required String pluginId,
  }) {
    return _pluginManager.activate(registry: registry, pluginId: pluginId);
  }

  /// Deactivates the plugin with [pluginId] in [registry].
  PluginManagerResult deactivate({
    required PluginRegistry registry,
    required String pluginId,
  }) {
    return _pluginManager.deactivate(registry: registry, pluginId: pluginId);
  }

  /// Removes the plugin with [pluginId] from [registry].
  PluginManagerResult remove({
    required PluginRegistry registry,
    required String pluginId,
  }) {
    return _pluginManager.remove(registry: registry, pluginId: pluginId);
  }

  /// Runs the full lifecycle for the plugin with [pluginId] in [registry].
  PluginManagerResult runFullLifecycle({
    required PluginRegistry registry,
    required String pluginId,
  }) {
    return _pluginManager.fullLifecycle(registry: registry, pluginId: pluginId);
  }

  // ─────────────────────────────────────────────────────────────────────
  // Query operations
  // ─────────────────────────────────────────────────────────────────────

  /// Returns all plugins in [registry].
  List<Plugin> getAll(PluginRegistry registry) => registry.all;

  /// Returns the plugin with [pluginId] from [registry].
  Plugin? getById(PluginRegistry registry, String pluginId) =>
      registry.getById(pluginId);

  /// Returns all active plugins in [registry].
  List<Plugin> getActive(PluginRegistry registry) => registry.active;

  /// Returns all usable plugins (loaded or active) in [registry].
  List<Plugin> getUsable(PluginRegistry registry) => registry.usable;
}
