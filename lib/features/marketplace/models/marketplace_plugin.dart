import '../../../core/plugins/runtime/plugin.dart' as runtime;

/// A plugin as displayed in the marketplace.
///
/// Wraps the core runtime [Plugin] with marketplace-specific display
/// information such as rating, download count, and tags. No AI, no
/// persistence, no networking.
class MarketplacePlugin {
  const MarketplacePlugin({
    required this.plugin,
    this.rating = 4.5,
    this.downloadCount = 0,
    this.tags = const [],
  });

  /// The underlying runtime plugin instance.
  final runtime.Plugin plugin;

  /// Average user rating from 0.0 to 5.0. Sample value until real data.
  final double rating;

  /// Approximate number of downloads. Sample value until real data.
  final int downloadCount;

  /// Display tags for filtering and categorization.
  final List<String> tags;

  // ── Convenience getters ────────────────────────────────────────────

  /// Unique plugin identifier from the manifest.
  String get id => plugin.manifest.id;

  /// Human-readable plugin name from the manifest.
  String get name => plugin.manifest.name;

  /// Plugin version from the manifest.
  String get version => plugin.manifest.version;

  /// Plugin description from the manifest.
  String get description => plugin.manifest.description;

  /// Plugin category from the manifest.
  String get category => plugin.manifest.category;

  /// Plugin author from the manifest.
  String get author => plugin.manifest.author;

  /// Whether the plugin is installed in the current registry.
  bool get isInstalled =>
      plugin.state.index >= runtime.PluginLifecycleState.installed.index &&
      plugin.state != runtime.PluginLifecycleState.removed;

  /// Whether the plugin is currently active.
  bool get isActive => plugin.isActive;

  /// Whether the plugin is usable (loaded or active).
  bool get isUsable => plugin.isUsable;

  /// Current lifecycle state of the plugin.
  runtime.PluginLifecycleState get state => plugin.state;

  /// Minimum Phoenix version required by this plugin.
  String get minPhoenixVersion => plugin.manifest.minPhoenixVersion;

  /// Plugin API version this plugin targets.
  String get pluginApiVersion => plugin.manifest.pluginApiVersion;

  /// List of capabilities this plugin requires.
  List<String> get requiredCapabilities => plugin.manifest.requiredCapabilities;

  /// Formatted rating string (e.g. "4.5").
  String get formattedRating => rating.toStringAsFixed(1);

  /// Formatted download count (e.g. "1.2k").
  String get formattedDownloads {
    if (downloadCount >= 1000) {
      final k = downloadCount / 1000;
      return '${k.toStringAsFixed(k == k.roundToDouble() ? 0 : 1)}k';
    }
    return downloadCount.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MarketplacePlugin &&
        other.plugin == plugin &&
        other.rating == rating &&
        other.downloadCount == downloadCount &&
        _listEquals(other.tags, tags);
  }

  @override
  int get hashCode =>
      Object.hash(plugin, rating, downloadCount, Object.hashAll(tags));

  @override
  String toString() {
    return 'MarketplacePlugin($name, v$version, ${state.name})';
  }

  static bool _listEquals(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
