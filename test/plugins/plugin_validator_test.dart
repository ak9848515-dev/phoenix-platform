import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/core/plugins/models/plugin_manifest.dart';
import 'package:phoenix_platform/core/plugins/runtime/plugin_validator.dart';

void main() {
  group('PluginValidator', () {
    const validator = PluginValidator();

    const validManifest = PluginManifest(
      id: 'software_engineer',
      name: 'Software Engineer',
      version: '1.0.0',
      description: 'A software engineering career path.',
      minPhoenixVersion: '1.0.0',
      pluginApiVersion: '1.0.0',
      author: 'Phoenix',
      category: 'Technology',
      requiredCapabilities: ['identity', 'journey'],
    );

    test('validates a correct manifest', () {
      final result = validator.validate(validManifest);

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('rejects empty id', () {
      final manifest = validManifest.copyWith(id: '');
      final result = validator.validate(manifest);

      expect(result.isValid, isFalse);
      expect(result.errors, contains(contains('id')));
    });

    test('rejects empty name', () {
      final manifest = validManifest.copyWith(name: '');
      final result = validator.validate(manifest);

      expect(result.isValid, isFalse);
      expect(result.errors, contains(contains('name')));
    });

    test('rejects empty version', () {
      final manifest = validManifest.copyWith(version: '');
      final result = validator.validate(manifest);

      expect(result.isValid, isFalse);
      expect(result.errors, contains(contains('version')));
    });

    test('rejects empty minPhoenixVersion', () {
      final manifest = validManifest.copyWith(minPhoenixVersion: '');
      final result = validator.validate(manifest);

      expect(result.isValid, isFalse);
      expect(result.errors, contains(contains('minPhoenixVersion')));
    });

    test('rejects empty pluginApiVersion', () {
      final manifest = validManifest.copyWith(pluginApiVersion: '');
      final result = validator.validate(manifest);

      expect(result.isValid, isFalse);
      expect(result.errors, contains(contains('pluginApiVersion')));
    });

    test('rejects invalid version format', () {
      final manifest = validManifest.copyWith(version: 'abc');
      final result = validator.validate(manifest);

      expect(result.isValid, isFalse);
      expect(result.errors, contains(contains('semantic')));
    });

    test('rejects major.minor version (missing patch)', () {
      final manifest = validManifest.copyWith(version: '1.0');
      final result = validator.validate(manifest);

      expect(result.isValid, isFalse);
      expect(result.errors, contains(contains('semantic')));
    });

    test('rejects version with non-numeric part', () {
      final manifest = validManifest.copyWith(version: '1.0.x');
      final result = validator.validate(manifest);

      expect(result.isValid, isFalse);
      expect(result.errors, contains(contains('semantic')));
    });

    test('accepts valid semver variations', () {
      final v0 = validManifest.copyWith(version: '0.1.0');
      final v2 = validManifest.copyWith(version: '2.0.0');
      final v10 = validManifest.copyWith(version: '10.5.3');

      expect(validator.validate(v0).isValid, isTrue);
      expect(validator.validate(v2).isValid, isTrue);
      expect(validator.validate(v10).isValid, isTrue);
    });

    test('validates minPhoenixVersion format', () {
      final manifest = validManifest.copyWith(minPhoenixVersion: '1.0');
      final result = validator.validate(manifest);

      expect(result.isValid, isFalse);
      expect(result.errors, contains(contains('semantic')));
    });

    test('validates pluginApiVersion format', () {
      final manifest = validManifest.copyWith(pluginApiVersion: '1.0');
      final result = validator.validate(manifest);

      expect(result.isValid, isFalse);
      expect(result.errors, contains(contains('semantic')));
    });

    test('rejects empty requiredCapabilities', () {
      final manifest = validManifest.copyWith(requiredCapabilities: []);
      final result = validator.validate(manifest);

      expect(result.isValid, isFalse);
      expect(result.errors, contains(contains('capability')));
    });

    test('collects multiple errors', () {
      final manifest = validManifest.copyWith(
        id: '',
        name: '',
        version: '',
        minPhoenixVersion: '',
        pluginApiVersion: '',
        requiredCapabilities: [],
      );

      final result = validator.validate(manifest);

      expect(result.isValid, isFalse);
      expect(result.errors.length, greaterThanOrEqualTo(6));
    });

    test('ValidationResult is immutable', () {
      const valid = PluginValidationResult();
      const invalid = PluginValidationResult(
        isValid: false,
        errors: ['error 1', 'error 2'],
      );

      expect(valid.isValid, isTrue);
      expect(valid.errors, isEmpty);
      expect(invalid.isValid, isFalse);
      expect(invalid.errors.length, 2);
    });

    test('ValidationResult equality works', () {
      const valid1 = PluginValidationResult();
      const valid2 = PluginValidationResult();
      expect(valid1, valid2);

      const invalid1 = PluginValidationResult(isValid: false, errors: ['err']);
      const invalid2 = PluginValidationResult(isValid: false, errors: ['err']);
      expect(invalid1, invalid2);

      expect(valid1, isNot(invalid1));
    });
  });
}
