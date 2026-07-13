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
    return [
      _softwareEngineerPlugin(),
      _flutterDeveloperPlugin(),
      _sapConsultantPlugin(),
      _contentCreatorPlugin(),
      _businessOwnerPlugin(),
      _entrepreneurPlugin(),
      _studentPlugin(),
    ];
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

  /// Creates the built-in Flutter Developer plugin.
  Plugin _flutterDeveloperPlugin() {
    return Plugin(
      manifest: const PluginManifest(
        id: 'flutter_developer',
        name: 'Flutter Developer',
        version: '1.0.0',
        description:
            'Complete Flutter development career path covering Dart, '
            'widgets, state management, animations, platform channels, '
            'and app store deployment.',
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

  /// Creates the built-in SAP Consultant plugin.
  Plugin _sapConsultantPlugin() {
    return Plugin(
      manifest: const PluginManifest(
        id: 'sap_consultant',
        name: 'SAP Consultant',
        version: '1.0.0',
        description:
            'Complete SAP consulting career path covering SAP modules, '
            'implementation methodologies, configuration, ABAP, '
            'and project management.',
        author: 'Phoenix',
        category: 'Business',
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

  /// Creates the built-in Content Creator plugin.
  Plugin _contentCreatorPlugin() {
    return Plugin(
      manifest: const PluginManifest(
        id: 'content_creator',
        name: 'Content Creator',
        version: '1.0.0',
        description:
            'Complete content creation career path covering video '
            'production, audience growth, monetization, branding, '
            'and platform strategy.',
        author: 'Phoenix',
        category: 'Creative',
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

  /// Creates the built-in Business Owner plugin.
  Plugin _businessOwnerPlugin() {
    return Plugin(
      manifest: const PluginManifest(
        id: 'business_owner',
        name: 'Business Owner',
        version: '1.0.0',
        description:
            'Complete business ownership path covering business planning, '
            'operations, finance, marketing, team management, '
            'and growth strategy.',
        author: 'Phoenix',
        category: 'Business',
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

  /// Creates the built-in Entrepreneur plugin.
  Plugin _entrepreneurPlugin() {
    return Plugin(
      manifest: const PluginManifest(
        id: 'entrepreneur',
        name: 'Entrepreneur',
        version: '1.0.0',
        description:
            'Complete entrepreneurship path covering startup ideation, '
            'product development, fundraising, scaling, '
            'and leadership.',
        author: 'Phoenix',
        category: 'Business',
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

  /// Creates the built-in Student plugin.
  Plugin _studentPlugin() {
    return Plugin(
      manifest: const PluginManifest(
        id: 'student',
        name: 'Student',
        version: '1.0.0',
        description:
            'Complete student growth path covering study techniques, '
            'time management, exam preparation, skill building, '
            'and career exploration.',
        author: 'Phoenix',
        category: 'Education',
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
