import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/core/plugins/runtime/plugin.dart';
import 'package:phoenix_platform/core/plugins/runtime/plugin_loader.dart';

void main() {
  group('PluginLoader', () {
    const loader = PluginLoader();

    test('loads all built-in plugins', () {
      final plugins = loader.loadBuiltInPlugins();

      expect(plugins, isNotEmpty);
    });

    test('includes Software Engineer plugin', () {
      final plugins = loader.loadBuiltInPlugins();

      final sePlugin = plugins.firstWhere(
        (p) => p.manifest.id == 'software_engineer',
      );

      expect(sePlugin, isNotNull);
      expect(sePlugin.manifest.name, 'Software Engineer');
      expect(sePlugin.manifest.version, '1.0.0');
      expect(sePlugin.manifest.author, 'Phoenix');
      expect(sePlugin.manifest.category, 'Technology');
      expect(sePlugin.manifest.minPhoenixVersion, '1.0.0');
      expect(sePlugin.manifest.pluginApiVersion, '1.0.0');
      expect(sePlugin.metadata.source, 'built-in');
      expect(sePlugin.state, PluginLifecycleState.installed);
    });

    test('Software Engineer plugin has required capabilities', () {
      final plugins = loader.loadBuiltInPlugins();
      final sePlugin = plugins.firstWhere(
        (p) => p.manifest.id == 'software_engineer',
      );

      final capabilities = sePlugin.manifest.requiredCapabilities;
      expect(capabilities, contains('identity'));
      expect(capabilities, contains('journey'));
      expect(capabilities, contains('missions'));
      expect(capabilities, contains('knowledge_dna'));
      expect(capabilities, contains('academy'));
      expect(capabilities, contains('career'));
      expect(capabilities, contains('ai_prompts'));
    });

    test('loadBuiltInPlugin returns specific plugin by id', () {
      final plugin = loader.loadBuiltInPlugin('software_engineer');

      expect(plugin, isNotNull);
      expect(plugin?.manifest.id, 'software_engineer');
    });

    test('loadBuiltInPlugin returns null for unknown id', () {
      final plugin = loader.loadBuiltInPlugin('nonexistent');

      expect(plugin, isNull);
    });

    test('all built-in plugins have valid manifests', () {
      final plugins = loader.loadBuiltInPlugins();
      const validator = _ManifestValidator();

      for (final plugin in plugins) {
        final errors = validator.validate(plugin.manifest);
        expect(
          errors,
          isEmpty,
          reason:
              'Plugin "${plugin.manifest.id}" has invalid manifest: $errors',
        );
      }
    });
  });
}

/// Simple inline validator to verify built-in plugin manifests.
class _ManifestValidator {
  const _ManifestValidator();

  List<String> validate(dynamic manifest) {
    final errors = <String>[];
    if (manifest.id.isEmpty) errors.add('id is empty');
    if (manifest.name.isEmpty) errors.add('name is empty');
    if (manifest.version.isEmpty) errors.add('version is empty');
    if (manifest.minPhoenixVersion.isEmpty) {
      errors.add('minPhoenixVersion is empty');
    }
    if (manifest.pluginApiVersion.isEmpty) {
      errors.add('pluginApiVersion is empty');
    }
    if (manifest.requiredCapabilities.isEmpty) {
      errors.add('requiredCapabilities is empty');
    }
    return errors;
  }
}
