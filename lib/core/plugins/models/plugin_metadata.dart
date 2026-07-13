/// Immutable metadata associated with a plugin instance at runtime.
///
/// Tracks installation source and timing. This is separate from
/// [PluginManifest] which defines the plugin's identity, because metadata
/// is generated at install-time rather than packaged with the plugin definition.
class PluginMetadata {
  const PluginMetadata({this.installDate, this.source = 'built-in'});

  /// When the plugin was installed. Null for built-in plugins.
  final DateTime? installDate;

  /// How the plugin was obtained (e.g. 'built-in', 'marketplace', 'local').
  ///
  /// Built-in plugins ship with the platform. Marketplace and local plugins
  /// are future capabilities.
  final String source;

  /// Creates a copy of this metadata with the given fields replaced.
  PluginMetadata copyWith({DateTime? installDate, String? source}) {
    return PluginMetadata(
      installDate: installDate ?? this.installDate,
      source: source ?? this.source,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PluginMetadata &&
        other.installDate == installDate &&
        other.source == source;
  }

  @override
  int get hashCode => Object.hash(installDate, source);

  @override
  String toString() {
    return 'PluginMetadata(source: $source, installDate: $installDate)';
  }
}
