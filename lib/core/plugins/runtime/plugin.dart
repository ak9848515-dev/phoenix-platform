import '../models/plugin_manifest.dart';
import '../models/plugin_metadata.dart';

/// Represents the current lifecycle phase of a plugin.
///
/// Plugins progress through these states in order:
/// installed → validated → registered → loaded → active
///
/// Deactivation and removal can occur from active or loaded states.
enum PluginLifecycleState {
  /// Plugin has been installed but not yet validated.
  installed,

  /// Plugin manifest has passed validation.
  validated,

  /// Plugin has been added to the registry.
  registered,

  /// Plugin content has been loaded into memory.
  loaded,

  /// Plugin is actively providing data and capabilities.
  active,

  /// Plugin has been deactivated and is no longer providing capabilities.
  deactivated,

  /// Plugin has been removed from the system.
  removed,
}

/// Immutable runtime representation of a plugin instance.
///
/// Combines the plugin's [PluginManifest] (identity and definition),
/// [PluginMetadata] (installation information), and current [PluginLifecycleState].
///
/// Every lifecycle transition produces a new [Plugin] instance rather than
/// mutating the existing one, preserving immutability.
class Plugin {
  const Plugin({
    required this.manifest,
    this.metadata = const PluginMetadata(),
    this.state = PluginLifecycleState.installed,
  });

  /// The plugin's manifest defining its identity and requirements.
  final PluginManifest manifest;

  /// Runtime metadata about this plugin instance.
  final PluginMetadata metadata;

  /// Current lifecycle phase of this plugin.
  final PluginLifecycleState state;

  /// Creates a copy of this plugin with the given fields replaced.
  Plugin copyWith({
    PluginManifest? manifest,
    PluginMetadata? metadata,
    PluginLifecycleState? state,
  }) {
    return Plugin(
      manifest: manifest ?? this.manifest,
      metadata: metadata ?? this.metadata,
      state: state ?? this.state,
    );
  }

  /// Advances the plugin to the given lifecycle state.
  ///
  /// Returns a new [Plugin] instance with the updated state.
  Plugin transitionTo(PluginLifecycleState newState) {
    return copyWith(state: newState);
  }

  /// Whether the plugin is currently active.
  bool get isActive => state == PluginLifecycleState.active;

  /// Whether the plugin is in a usable state (loaded or active).
  bool get isUsable =>
      state == PluginLifecycleState.loaded ||
      state == PluginLifecycleState.active;

  /// Whether the plugin has been removed.
  bool get isRemoved => state == PluginLifecycleState.removed;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Plugin &&
        other.manifest == manifest &&
        other.metadata == metadata &&
        other.state == state;
  }

  @override
  int get hashCode => Object.hash(manifest, metadata, state);

  @override
  String toString() {
    return 'Plugin(${manifest.id}, state: ${state.name})';
  }
}
