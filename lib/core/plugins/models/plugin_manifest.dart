/// Immutable representation of a plugin's manifest definition.
///
/// Contains all metadata required to identify, validate, and load a plugin.
/// Every plugin must have a valid manifest before it can be registered.
///
/// Follows the same immutable pattern as [Academy], [Mission], and other
/// Phoenix domain models.
class PluginManifest {
  const PluginManifest({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.minPhoenixVersion,
    required this.pluginApiVersion,
    this.author = 'Phoenix',
    this.category = 'General',
    this.requiredCapabilities = const [],
  });

  /// Unique plugin identifier (e.g. 'software_engineer').
  final String id;

  /// Human-readable plugin name (e.g. 'Software Engineer').
  final String name;

  /// Semantic version of the plugin (e.g. '1.0.0').
  final String version;

  /// Short description of what the plugin provides.
  final String description;

  /// Author of the plugin. Defaults to 'Phoenix' for built-in plugins.
  final String author;

  /// Category of the plugin (e.g. 'Technology', 'Business', 'Health').
  final String category;

  /// Minimum Phoenix version required by this plugin (e.g. '1.0.0').
  final String minPhoenixVersion;

  /// Version of the Plugin API this plugin targets (e.g. '1.0.0').
  final String pluginApiVersion;

  /// List of capabilities this plugin requires from the runtime.
  ///
  /// Examples: 'identity', 'journey', 'missions', 'knowledge_dna',
  /// 'academy', 'career', 'ai_prompts'.
  final List<String> requiredCapabilities;

  /// Creates a copy of this manifest with the given fields replaced.
  PluginManifest copyWith({
    String? id,
    String? name,
    String? version,
    String? description,
    String? author,
    String? category,
    String? minPhoenixVersion,
    String? pluginApiVersion,
    List<String>? requiredCapabilities,
  }) {
    return PluginManifest(
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      description: description ?? this.description,
      author: author ?? this.author,
      category: category ?? this.category,
      minPhoenixVersion: minPhoenixVersion ?? this.minPhoenixVersion,
      pluginApiVersion: pluginApiVersion ?? this.pluginApiVersion,
      requiredCapabilities: requiredCapabilities ?? this.requiredCapabilities,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PluginManifest &&
        other.id == id &&
        other.name == name &&
        other.version == version &&
        other.description == description &&
        other.author == author &&
        other.category == category &&
        other.minPhoenixVersion == minPhoenixVersion &&
        other.pluginApiVersion == pluginApiVersion &&
        _listEquals(other.requiredCapabilities, requiredCapabilities);
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    version,
    description,
    author,
    category,
    minPhoenixVersion,
    pluginApiVersion,
    Object.hashAll(requiredCapabilities),
  );

  @override
  String toString() {
    return 'PluginManifest(id: $id, name: $name, version: $version, '
        'minPhoenixVersion: $minPhoenixVersion, '
        'pluginApiVersion: $pluginApiVersion)';
  }

  /// Compares two lists for equality by element.
  static bool _listEquals(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
