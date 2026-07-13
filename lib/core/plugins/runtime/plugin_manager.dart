import '../models/plugin_manifest.dart';
import 'plugin.dart';
import 'plugin_loader.dart';
import 'plugin_registry.dart';
import 'plugin_validator.dart';

/// Orchestrates the full plugin lifecycle.
///
/// Lifecycle flow:
///   install → validate → register → load → activate
///                                      ↓
///                                 deactivate
///                                      ↓
///                                    remove
///
/// Each method is pure and returns a result object that contains the new
/// registry state, any error information, and the affected plugin.
///
/// No state management. No persistence. No networking. No AI.
class PluginManager {
  const PluginManager({PluginValidator? validator, PluginLoader? loader})
    : _validator = validator ?? const PluginValidator(),
      _loader = loader ?? const PluginLoader();

  final PluginValidator _validator;
  final PluginLoader _loader;

  /// Installs all built-in plugins into the given [registry].
  ///
  /// Returns a [PluginManagerResult] with the updated registry containing
  /// all built-in plugins in the [PluginLifecycleState.installed] state.
  PluginManagerResult installBuiltInPlugins(PluginRegistry registry) {
    final builtInPlugins = _loader.loadBuiltInPlugins();
    var updated = registry;

    for (final plugin in builtInPlugins) {
      if (!updated.contains(plugin.manifest.id)) {
        updated = updated.add(plugin);
      }
    }

    return PluginManagerResult(
      registry: updated,
      plugin: builtInPlugins.isNotEmpty ? builtInPlugins.last : null,
      success: true,
    );
  }

  /// Installs a single plugin with the given [manifest] and [metadata] into
  /// the given [registry].
  ///
  /// Returns a [PluginManagerResult] with the plugin in the
  /// [PluginLifecycleState.installed] state.
  PluginManagerResult install({
    required PluginRegistry registry,
    required PluginManifest manifest,
    required Plugin plugin,
  }) {
    if (registry.contains(manifest.id)) {
      return PluginManagerResult(
        registry: registry,
        plugin: plugin,
        success: false,
        error: 'Plugin "${manifest.id}" is already installed.',
      );
    }

    final installed = plugin.transitionTo(PluginLifecycleState.installed);
    final updated = registry.add(installed);

    return PluginManagerResult(
      registry: updated,
      plugin: installed,
      success: true,
    );
  }

  /// Validates the plugin with the given [id] in the [registry].
  ///
  /// Returns a [PluginManagerResult] with the plugin transitioned to
  /// [PluginLifecycleState.validated] if validation succeeds, or an error
  /// result with validation failure details.
  PluginManagerResult validate({
    required PluginRegistry registry,
    required String pluginId,
  }) {
    final plugin = registry.getById(pluginId);
    if (plugin == null) {
      return PluginManagerResult(
        registry: registry,
        success: false,
        error: 'Plugin "$pluginId" not found in registry.',
      );
    }

    if (plugin.state != PluginLifecycleState.installed) {
      return PluginManagerResult(
        registry: registry,
        plugin: plugin,
        success: false,
        error:
            'Cannot validate plugin "$pluginId" in state "${plugin.state.name}". '
            'Expected state: installed.',
      );
    }

    final result = _validator.validate(plugin.manifest);
    if (!result.isValid) {
      return PluginManagerResult(
        registry: registry,
        plugin: plugin,
        success: false,
        error: 'Plugin "$pluginId" validation failed.',
        validationErrors: result.errors,
      );
    }

    final validated = plugin.transitionTo(PluginLifecycleState.validated);
    final updated = registry.add(validated);

    return PluginManagerResult(
      registry: updated,
      plugin: validated,
      success: true,
    );
  }

  /// Registers the plugin with the given [id] in the [registry].
  ///
  /// Transitions the plugin from [PluginLifecycleState.validated] to
  /// [PluginLifecycleState.registered].
  PluginManagerResult register({
    required PluginRegistry registry,
    required String pluginId,
  }) {
    final plugin = registry.getById(pluginId);
    if (plugin == null) {
      return PluginManagerResult(
        registry: registry,
        success: false,
        error: 'Plugin "$pluginId" not found in registry.',
      );
    }

    if (plugin.state != PluginLifecycleState.validated) {
      return PluginManagerResult(
        registry: registry,
        plugin: plugin,
        success: false,
        error:
            'Cannot register plugin "$pluginId" in state "${plugin.state.name}". '
            'Expected state: validated.',
      );
    }

    final registered = plugin.transitionTo(PluginLifecycleState.registered);
    final updated = registry.add(registered);

    return PluginManagerResult(
      registry: updated,
      plugin: registered,
      success: true,
    );
  }

  /// Loads the plugin with the given [id] in the [registry].
  ///
  /// Transitions the plugin from [PluginLifecycleState.registered] to
  /// [PluginLifecycleState.loaded].
  PluginManagerResult load({
    required PluginRegistry registry,
    required String pluginId,
  }) {
    final plugin = registry.getById(pluginId);
    if (plugin == null) {
      return PluginManagerResult(
        registry: registry,
        success: false,
        error: 'Plugin "$pluginId" not found in registry.',
      );
    }

    if (plugin.state != PluginLifecycleState.registered) {
      return PluginManagerResult(
        registry: registry,
        plugin: plugin,
        success: false,
        error:
            'Cannot load plugin "$pluginId" in state "${plugin.state.name}". '
            'Expected state: registered.',
      );
    }

    final loaded = plugin.transitionTo(PluginLifecycleState.loaded);
    final updated = registry.add(loaded);

    return PluginManagerResult(
      registry: updated,
      plugin: loaded,
      success: true,
    );
  }

  /// Activates the plugin with the given [id] in the [registry].
  ///
  /// Transitions the plugin from [PluginLifecycleState.loaded] to
  /// [PluginLifecycleState.active].
  PluginManagerResult activate({
    required PluginRegistry registry,
    required String pluginId,
  }) {
    final plugin = registry.getById(pluginId);
    if (plugin == null) {
      return PluginManagerResult(
        registry: registry,
        success: false,
        error: 'Plugin "$pluginId" not found in registry.',
      );
    }

    if (plugin.state != PluginLifecycleState.loaded) {
      return PluginManagerResult(
        registry: registry,
        plugin: plugin,
        success: false,
        error:
            'Cannot activate plugin "$pluginId" in state "${plugin.state.name}". '
            'Expected state: loaded.',
      );
    }

    final activated = plugin.transitionTo(PluginLifecycleState.active);
    final updated = registry.add(activated);

    return PluginManagerResult(
      registry: updated,
      plugin: activated,
      success: true,
    );
  }

  /// Deactivates the plugin with the given [id] in the [registry].
  ///
  /// Transitions the plugin from [PluginLifecycleState.active] to
  /// [PluginLifecycleState.deactivated].
  PluginManagerResult deactivate({
    required PluginRegistry registry,
    required String pluginId,
  }) {
    final plugin = registry.getById(pluginId);
    if (plugin == null) {
      return PluginManagerResult(
        registry: registry,
        success: false,
        error: 'Plugin "$pluginId" not found in registry.',
      );
    }

    if (plugin.state != PluginLifecycleState.active &&
        plugin.state != PluginLifecycleState.loaded) {
      return PluginManagerResult(
        registry: registry,
        plugin: plugin,
        success: false,
        error:
            'Cannot deactivate plugin "$pluginId" in state "${plugin.state.name}". '
            'Expected state: active or loaded.',
      );
    }

    final deactivated = plugin.transitionTo(PluginLifecycleState.deactivated);
    final updated = registry.add(deactivated);

    return PluginManagerResult(
      registry: updated,
      plugin: deactivated,
      success: true,
    );
  }

  /// Removes the plugin with the given [id] from the [registry].
  ///
  /// Returns a [PluginManagerResult] with the plugin transitioned to
  /// [PluginLifecycleState.removed] and removed from the registry.
  PluginManagerResult remove({
    required PluginRegistry registry,
    required String pluginId,
  }) {
    final plugin = registry.getById(pluginId);
    if (plugin == null) {
      return PluginManagerResult(
        registry: registry,
        success: false,
        error: 'Plugin "$pluginId" not found in registry.',
      );
    }

    final removed = plugin.transitionTo(PluginLifecycleState.removed);
    final updated = registry.remove(pluginId);

    return PluginManagerResult(
      registry: updated,
      plugin: removed,
      success: true,
    );
  }

  /// Runs the full lifecycle for a plugin: install → validate → register →
  /// load → activate.
  ///
  /// Returns a [PluginManagerResult] indicating success or the first failure.
  PluginManagerResult fullLifecycle({
    required PluginRegistry registry,
    required String pluginId,
  }) {
    // Check plugin exists in registry
    var current = registry;
    var plugin = current.getById(pluginId);
    if (plugin == null) {
      return PluginManagerResult(
        registry: current,
        success: false,
        error: 'Plugin "$pluginId" not found in registry.',
      );
    }

    // Validate
    final validationResult = validate(registry: current, pluginId: pluginId);
    if (!validationResult.success) return validationResult;

    current = validationResult.registry;
    plugin = validationResult.plugin;

    // Register
    final registerResult = register(registry: current, pluginId: pluginId);
    if (!registerResult.success) return registerResult;

    current = registerResult.registry;
    plugin = registerResult.plugin;

    // Load
    final loadResult = load(registry: current, pluginId: pluginId);
    if (!loadResult.success) return loadResult;

    current = loadResult.registry;
    plugin = loadResult.plugin;

    // Activate
    final activateResult = activate(registry: current, pluginId: pluginId);
    if (!activateResult.success) return activateResult;

    return activateResult;
  }
}

/// Result of a plugin lifecycle operation.
///
/// Contains the updated [registry], the affected [plugin], whether the
/// operation [success]fully completed, and any [error] or
/// [validationErrors] details.
class PluginManagerResult {
  const PluginManagerResult({
    required this.registry,
    this.plugin,
    required this.success,
    this.error,
    this.validationErrors,
  });

  /// The registry after the operation.
  final PluginRegistry registry;

  /// The plugin affected by the operation, if applicable.
  final Plugin? plugin;

  /// Whether the operation completed successfully.
  final bool success;

  /// Error message if the operation failed.
  final String? error;

  /// Validation error details if validation failed.
  final List<String>? validationErrors;

  /// Combined list of [error] and [validationErrors].
  List<String> get allErrors {
    final list = <String>[];
    if (error != null) list.add(error!);
    if (validationErrors != null) list.addAll(validationErrors!);
    return list;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PluginManagerResult &&
        other.registry == registry &&
        other.plugin == plugin &&
        other.success == success &&
        other.error == error &&
        _listEquals(other.validationErrors ?? [], validationErrors ?? []);
  }

  @override
  int get hashCode => Object.hash(
    registry,
    plugin,
    success,
    error,
    Object.hashAll(validationErrors ?? []),
  );

  @override
  String toString() {
    if (success) {
      return 'PluginManagerResult(success, plugin: ${plugin?.manifest.id ?? "none"})';
    }
    return 'PluginManagerResult(failure, error: $error)';
  }

  static bool _listEquals(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
