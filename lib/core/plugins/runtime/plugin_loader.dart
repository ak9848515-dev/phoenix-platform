import '../models/plugin_manifest.dart';
import '../models/plugin_metadata.dart';
import 'plugin.dart';

/// Loads plugin definitions from built-in sources.
///
/// Currently supports only built-in plugins that ship with the platform.
/// Future implementations may support loading from local files, marketplace
/// downloads, or remote sources.
///
/// No networking, no persistence, no AI.
class PluginLoader {
  const PluginLoader();

  /// Returns all built-in plugins that ship with the platform.
  ///
  /// Built-in plugins are hardcoded and available without installation.
  /// They are returned with [PluginLifecycleState.installed] and
  /// [PluginMetadata.source] set to 'built-in'.
  List<Plugin> loadBuiltInPlugins() {
    return [_softwareEngineerPlugin()];
  }

  /// Loads a specific built-in plugin by [id].
  ///
  /// Returns null if no built-in plugin with the given [id] exists.
  Plugin? loadBuiltInPlugin(String id) {
    final plugins = loadBuiltInPlugins();
    try {
      return plugins.firstWhere((p) => p.manifest.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Creates the built-in Software Engineer plugin.
  ///
  /// This is the first career plugin shipped with Phoenix. It provides
  /// identity, journey, missions, knowledge DNA, academy, career metrics,
  /// and AI prompt templates for the Software Engineering path.
  Plugin _softwareEngineerPlugin() {
    return Plugin(
      manifest: const PluginManifest(
        id: 'software_engineer',
        name: 'Software Engineer',
        version: '1.0.0',
        description:
            'Complete software engineering career path covering '
            'fundamentals, data structures, algorithms, system design, '
            'and professional development.',
        author: 'Phoenix',
        category: 'Technology',
        minPhoenixVersion: '1.0.0',
        pluginApiVersion: '1.0.0',
        requiredCapabilities: [
          'identity',
          'journey',
          'missions',
          'knowledge_dna',
          'academy',
          'career',
          'ai_prompts',
        ],
      ),
      metadata: const PluginMetadata(source: 'built-in'),
      state: PluginLifecycleState.installed,
    );
  }
}
