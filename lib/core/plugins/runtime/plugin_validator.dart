import '../models/plugin_manifest.dart';

/// Result of a plugin validation operation.
///
/// Contains whether the plugin is valid and a list of human-readable
/// error messages describing any validation failures.
class PluginValidationResult {
  const PluginValidationResult({this.isValid = true, this.errors = const []});

  /// Whether the plugin passed all validation checks.
  final bool isValid;

  /// Human-readable error messages describing validation failures.
  ///
  /// Empty when [isValid] is true.
  final List<String> errors;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PluginValidationResult &&
        other.isValid == isValid &&
        _listEquals(other.errors, errors);
  }

  @override
  int get hashCode => Object.hash(isValid, Object.hashAll(errors));

  @override
  String toString() {
    if (isValid) return 'PluginValidationResult(valid)';
    return 'PluginValidationResult(invalid: ${errors.length} errors)';
  }

  static bool _listEquals(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Validates [PluginManifest] instances against platform requirements.
///
/// This is a stateless, immutable validator. It performs structural
/// and content validation on plugin manifests to ensure they meet
/// minimum requirements for registration and loading.
///
/// Validation checks:
///   - Required fields are non-empty
///   - Version strings follow semantic versioning (x.y.z)
///   - Required capabilities are non-empty
///
/// No networking, no persistence, no AI.
class PluginValidator {
  const PluginValidator();

  /// Validates the given [manifest] and returns a [PluginValidationResult].
  PluginValidationResult validate(PluginManifest manifest) {
    final errors = <String>[];

    // Required fields
    if (manifest.id.trim().isEmpty) {
      errors.add('Plugin id is required and must not be empty.');
    }

    if (manifest.name.trim().isEmpty) {
      errors.add('Plugin name is required and must not be empty.');
    }

    if (manifest.version.trim().isEmpty) {
      errors.add('Plugin version is required and must not be empty.');
    }

    if (manifest.minPhoenixVersion.trim().isEmpty) {
      errors.add('Plugin minPhoenixVersion is required and must not be empty.');
    }

    if (manifest.pluginApiVersion.trim().isEmpty) {
      errors.add('Plugin pluginApiVersion is required and must not be empty.');
    }

    // Semantic version validation
    if (manifest.version.isNotEmpty && !_isValidSemver(manifest.version)) {
      errors.add(
        'Plugin version "${manifest.version}" is not a valid semantic '
        'version. Expected format: major.minor.patch (e.g. 1.0.0).',
      );
    }

    if (manifest.minPhoenixVersion.isNotEmpty &&
        !_isValidSemver(manifest.minPhoenixVersion)) {
      errors.add(
        'Plugin minPhoenixVersion "${manifest.minPhoenixVersion}" is not a '
        'valid semantic version. Expected format: major.minor.patch.',
      );
    }

    if (manifest.pluginApiVersion.isNotEmpty &&
        !_isValidSemver(manifest.pluginApiVersion)) {
      errors.add(
        'Plugin pluginApiVersion "${manifest.pluginApiVersion}" is not a '
        'valid semantic version. Expected format: major.minor.patch.',
      );
    }

    // Required capabilities
    if (manifest.requiredCapabilities.isEmpty) {
      errors.add('Plugin must declare at least one required capability.');
    }

    return PluginValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Validates that the version string follows semantic versioning (x.y.z).
  bool _isValidSemver(String version) {
    final parts = version.split('.');
    if (parts.length != 3) return false;

    for (final part in parts) {
      final n = int.tryParse(part);
      if (n == null || n < 0) return false;
    }

    return true;
  }
}
