import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/core/plugins/models/plugin_metadata.dart';

void main() {
  group('PluginMetadata', () {
    const builtIn = PluginMetadata(source: 'built-in');
    const marketplace = PluginMetadata(source: 'marketplace');
    final withDate = PluginMetadata(
      source: 'marketplace',
      installDate: DateTime(2026, 7, 13),
    );

    test('creates with default values', () {
      const defaultMeta = PluginMetadata();
      expect(defaultMeta.source, 'built-in');
      expect(defaultMeta.installDate, isNull);
    });

    test('copyWith replaces specified fields', () {
      final copy = builtIn.copyWith(source: 'local');
      expect(copy.source, 'local');
      expect(copy.installDate, isNull);
    });

    test('copyWith preserves unspecified fields', () {
      final copy = builtIn.copyWith();
      expect(copy, builtIn);
    });

    test('copyWith can add installDate', () {
      final date = DateTime(2026, 1, 1);
      final copy = builtIn.copyWith(installDate: date);
      expect(copy.installDate, date);
      expect(copy.source, 'built-in');
    });

    test('equality works correctly', () {
      const same = PluginMetadata(source: 'built-in');
      expect(builtIn, same);
      expect(builtIn, isNot(marketplace));
      expect(marketplace, isNot(withDate));
    });

    test('hashCode is consistent', () {
      const same = PluginMetadata(source: 'built-in');
      expect(builtIn.hashCode, same.hashCode);
    });

    test('toString returns readable representation', () {
      final str = builtIn.toString();
      expect(str, contains('PluginMetadata'));
      expect(str, contains('built-in'));
    });
  });
}
