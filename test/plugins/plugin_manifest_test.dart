import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/core/plugins/models/plugin_manifest.dart';

void main() {
  group('PluginManifest', () {
    const manifest = PluginManifest(
      id: 'test_plugin',
      name: 'Test Plugin',
      version: '1.0.0',
      description: 'A test plugin.',
      minPhoenixVersion: '1.0.0',
      pluginApiVersion: '1.0.0',
      author: 'Phoenix',
      category: 'Technology',
      requiredCapabilities: ['identity', 'journey'],
    );

    test('creates with required fields', () {
      const minimal = PluginManifest(
        id: 'minimal',
        name: 'Minimal',
        version: '1.0.0',
        description: 'A minimal plugin.',
        minPhoenixVersion: '1.0.0',
        pluginApiVersion: '1.0.0',
      );

      expect(minimal.id, 'minimal');
      expect(minimal.author, 'Phoenix');
      expect(minimal.category, 'General');
      expect(minimal.requiredCapabilities, isEmpty);
    });

    test('uses default values for optional fields', () {
      expect(manifest.author, 'Phoenix');
      expect(manifest.category, 'Technology');
      expect(manifest.requiredCapabilities, ['identity', 'journey']);
    });

    test('copyWith replaces specified fields', () {
      final copy = manifest.copyWith(name: 'Updated Plugin');
      expect(copy.name, 'Updated Plugin');
      expect(copy.id, manifest.id);
      expect(copy.version, manifest.version);
    });

    test('copyWith preserves unspecified fields', () {
      final copy = manifest.copyWith();
      expect(copy, manifest);
    });

    test('equality works correctly', () {
      const same = PluginManifest(
        id: 'test_plugin',
        name: 'Test Plugin',
        version: '1.0.0',
        description: 'A test plugin.',
        minPhoenixVersion: '1.0.0',
        pluginApiVersion: '1.0.0',
        author: 'Phoenix',
        category: 'Technology',
        requiredCapabilities: ['identity', 'journey'],
      );

      expect(manifest, same);

      const different = PluginManifest(
        id: 'other',
        name: 'Other',
        version: '2.0.0',
        description: 'Another plugin.',
        minPhoenixVersion: '2.0.0',
        pluginApiVersion: '2.0.0',
      );

      expect(manifest, isNot(different));
    });

    test('hashCode is consistent', () {
      const same = PluginManifest(
        id: 'test_plugin',
        name: 'Test Plugin',
        version: '1.0.0',
        description: 'A test plugin.',
        minPhoenixVersion: '1.0.0',
        pluginApiVersion: '1.0.0',
        author: 'Phoenix',
        category: 'Technology',
        requiredCapabilities: ['identity', 'journey'],
      );

      expect(manifest.hashCode, same.hashCode);
    });

    test('toString returns readable representation', () {
      final str = manifest.toString();
      expect(str, contains('PluginManifest'));
      expect(str, contains('test_plugin'));
      expect(str, contains('1.0.0'));
    });
  });
}
