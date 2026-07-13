import 'plugin.dart';

/// Manages the collection of registered plugins.
///
/// Provides methods for adding, removing, and querying plugins. This is a
/// simple in-memory collection — no persistence, no networking, no state
/// management framework.
///
/// Every operation returns a new [PluginRegistry] instance, preserving
/// immutability at the registry level.
class PluginRegistry {
  const PluginRegistry({List<Plugin>? plugins})
    : _plugins = plugins ?? const [];

  final List<Plugin> _plugins;

  /// Returns an unmodifiable view of all registered plugins.
  List<Plugin> get all => List.unmodifiable(_plugins);

  /// Returns the number of registered plugins.
  int get count => _plugins.length;

  /// Whether the registry contains a plugin with the given [id].
  bool contains(String id) => _plugins.any((p) => p.manifest.id == id);

  /// Returns the plugin with the given [id], or null if not found.
  Plugin? getById(String id) {
    try {
      return _plugins.firstWhere((p) => p.manifest.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns plugins in the given lifecycle [state].
  List<Plugin> getByState(PluginLifecycleState state) {
    return _plugins.where((p) => p.state == state).toList();
  }

  /// Returns all active plugins.
  List<Plugin> get active => getByState(PluginLifecycleState.active);

  /// Returns all usable plugins (loaded or active).
  List<Plugin> get usable => _plugins
      .where(
        (p) =>
            p.state == PluginLifecycleState.loaded ||
            p.state == PluginLifecycleState.active,
      )
      .toList();

  /// Adds a plugin to the registry.
  ///
  /// Returns a new [PluginRegistry] containing the added plugin.
  /// If a plugin with the same id already exists, it is replaced.
  PluginRegistry add(Plugin plugin) {
    final updated = List<Plugin>.from(_plugins);
    final index = updated.indexWhere(
      (p) => p.manifest.id == plugin.manifest.id,
    );

    if (index >= 0) {
      updated[index] = plugin;
    } else {
      updated.add(plugin);
    }

    return PluginRegistry(plugins: updated);
  }

  /// Removes the plugin with the given [id] from the registry.
  ///
  /// Returns a new [PluginRegistry] without the plugin.
  /// If no plugin with the given id exists, returns the same instance.
  PluginRegistry remove(String id) {
    if (!contains(id)) return this;

    return PluginRegistry(
      plugins: _plugins.where((p) => p.manifest.id != id).toList(),
    );
  }

  /// Removes all plugins from the registry.
  ///
  /// Returns an empty [PluginRegistry].
  PluginRegistry clear() => const PluginRegistry();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PluginRegistry &&
        other._plugins.length == _plugins.length &&
        _listEquals(other._plugins, _plugins);
  }

  @override
  int get hashCode => Object.hashAll(_plugins);

  @override
  String toString() {
    return 'PluginRegistry(count: $count)';
  }

  static bool _listEquals(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
