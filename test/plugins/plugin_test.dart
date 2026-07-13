import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/core/plugins/models/plugin_manifest.dart';
import 'package:phoenix_platform/core/plugins/models/plugin_metadata.dart';
import 'package:phoenix_platform/core/plugins/runtime/plugin.dart';

void main() {
  group('PluginLifecycleState', () {
    test('has all required states', () {
      expect(PluginLifecycleState.values.length, 7);
      expect(
        PluginLifecycleState.values,
        contains(PluginLifecycleState.installed),
      );
      expect(
        PluginLifecycleState.values,
        contains(PluginLifecycleState.validated),
      );
      expect(
        PluginLifecycleState.values,
        contains(PluginLifecycleState.registered),
      );
      expect(
        PluginLifecycleState.values,
        contains(PluginLifecycleState.loaded),
      );
      expect(
        PluginLifecycleState.values,
        contains(PluginLifecycleState.active),
      );
      expect(
        PluginLifecycleState.values,
        contains(PluginLifecycleState.deactivated),
      );
      expect(
        PluginLifecycleState.values,
        contains(PluginLifecycleState.removed),
      );
    });
  });

  group('Plugin', () {
    const manifest = PluginManifest(
      id: 'test_plugin',
      name: 'Test Plugin',
      version: '1.0.0',
      description: 'A test plugin.',
      minPhoenixVersion: '1.0.0',
      pluginApiVersion: '1.0.0',
    );

    const plugin = Plugin(manifest: manifest);

    test('creates with default state', () {
      expect(plugin.state, PluginLifecycleState.installed);
      expect(plugin.manifest, manifest);
      expect(plugin.metadata.source, 'built-in');
    });

    test('creates with explicit metadata and state', () {
      const customMetadata = PluginMetadata(source: 'marketplace');
      const custom = Plugin(
        manifest: manifest,
        metadata: customMetadata,
        state: PluginLifecycleState.active,
      );

      expect(custom.metadata.source, 'marketplace');
      expect(custom.state, PluginLifecycleState.active);
    });

    test('transitionTo returns new instance', () {
      final activated = plugin.transitionTo(PluginLifecycleState.active);
      expect(activated.state, PluginLifecycleState.active);
      expect(plugin.state, PluginLifecycleState.installed);
      expect(identical(plugin, activated), isFalse);
    });

    test('isActive returns true only for active state', () {
      expect(
        const Plugin(
          manifest: manifest,
          state: PluginLifecycleState.active,
        ).isActive,
        isTrue,
      );
      expect(
        const Plugin(
          manifest: manifest,
          state: PluginLifecycleState.loaded,
        ).isActive,
        isFalse,
      );
      expect(
        const Plugin(
          manifest: manifest,
          state: PluginLifecycleState.installed,
        ).isActive,
        isFalse,
      );
    });

    test('isUsable returns true for loaded and active states', () {
      expect(
        const Plugin(
          manifest: manifest,
          state: PluginLifecycleState.loaded,
        ).isUsable,
        isTrue,
      );
      expect(
        const Plugin(
          manifest: manifest,
          state: PluginLifecycleState.active,
        ).isUsable,
        isTrue,
      );
      expect(
        const Plugin(
          manifest: manifest,
          state: PluginLifecycleState.installed,
        ).isUsable,
        isFalse,
      );
      expect(
        const Plugin(
          manifest: manifest,
          state: PluginLifecycleState.deactivated,
        ).isUsable,
        isFalse,
      );
    });

    test('isRemoved returns true only for removed state', () {
      expect(
        const Plugin(
          manifest: manifest,
          state: PluginLifecycleState.removed,
        ).isRemoved,
        isTrue,
      );
      expect(
        const Plugin(
          manifest: manifest,
          state: PluginLifecycleState.active,
        ).isRemoved,
        isFalse,
      );
    });

    test('copyWith replaces specified fields', () {
      final newManifest = manifest.copyWith(id: 'updated');
      final copy = plugin.copyWith(manifest: newManifest);
      expect(copy.manifest.id, 'updated');
      expect(copy.state, plugin.state);
    });

    test('copyWith preserves unspecified fields', () {
      final copy = plugin.copyWith();
      expect(copy, plugin);
    });

    test('equals works correctly', () {
      const same = Plugin(manifest: manifest);
      expect(plugin, same);

      const different = Plugin(
        manifest: manifest,
        state: PluginLifecycleState.active,
      );
      expect(plugin, isNot(different));
    });

    test('toString returns readable representation', () {
      final str = plugin.toString();
      expect(str, contains('test_plugin'));
      expect(str, contains('installed'));
    });
  });
}
