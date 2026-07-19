import '../../../core/bootstrap.dart';
import '../../../features/ai_capability_router/models/ai_router_config.dart';
import '../../../features/ai_capability_router/registry/ai_provider_registry.dart';
import '../logging/phoenix_logger.dart';

/// Result of a single configuration validation check.
class ValidationResult {
  const ValidationResult({
    required this.name,
    required this.passed,
    this.message = '',
  });

  final String name;
  final bool passed;
  final String message;
}

/// Report of all configuration validation checks.
class ValidationReport {
  const ValidationReport({
    required this.valid,
    required this.results,
    this.timestamp,
  });

  final bool valid;
  final List<ValidationResult> results;
  final DateTime? timestamp;

  List<ValidationResult> get failures =>
      results.where((r) => !r.passed).toList();

  int get passedCount => results.where((r) => r.passed).length;
  int get failedCount => results.where((r) => !r.passed).length;

  String get summary =>
      'Config: ${valid ? "VALID" : "INVALID"} '
      '($passedCount/${results.length} checks passed)';
}

/// Validates application configuration at startup.
///
/// Checks all critical infrastructure is properly configured
/// before the application begins normal operation.
class ConfigurationValidator {
  final PhoenixLogger _logger = PhoenixLogger.shared;

  /// Validates all application configuration.
  Future<ValidationReport> validate({
    AIProviderRegistry? registry,
    AIRouterConfig? routerConfig,
  }) async {
    final results = <ValidationResult>[];

    // Storage
    results.add(_check(
      'StorageService',
      AppBootstrap.maybeStorageService != null,
      'Storage service initialized',
      'Storage service not initialized',
    ));

    // Auth
    results.add(_check(
      'AuthenticationService',
      AppBootstrap.maybeAuthenticationService != null,
      'Authentication service initialized',
      'Authentication service not initialized',
    ));

    // Core services
    results.add(_check(
      'UserStateService',
      AppBootstrap.maybeUserStateService != null,
      'User state service initialized',
      'User state service not initialized',
    ));

    // Engines
    final engines = {
      'IdentityEngine': AppBootstrap.maybeIdentityEngine?.isInitialized ?? false,
      'GrowthIndexEngine': AppBootstrap.maybeGrowthEngine?.isInitialized ?? false,
      'MissionIntelligenceEngine': AppBootstrap.maybeMissionIntelligenceEngine?.isInitialized ?? false,
      'RecommendationEngine': AppBootstrap.maybeRecommendationEngine?.isInitialized ?? false,
      'DailyBriefEngine': AppBootstrap.maybeDailyBriefEngine?.isInitialized ?? false,
      'ContinueJourneyEngine': AppBootstrap.maybeContinueJourneyEngine?.isInitialized ?? false,
      'MemoryEngine': null, // Will be checked separately
    };

    for (final entry in engines.entries) {
      final initialized = entry.value ?? false;
      final name = entry.key;
      results.add(_check(
        name,
        initialized,
        '$name initialized',
        '$name not initialized',
      ));
    }

    // AI Router config
    if (registry != null) {
      results.add(_check(
        'AIProviderRegistry',
        registry.registeredProviders.isNotEmpty,
        '${registry.count} providers registered',
        'No AI providers registered',
      ));
    }

    if (routerConfig != null) {
      results.add(_check(
        'AIRouterConfig',
        routerConfig.defaultMappings.isNotEmpty,
        '${routerConfig.defaultMappings.length} capability mappings configured',
        'No capability mappings configured',
      ));
    }

    final valid = results.every((r) => r.passed);
    final report = ValidationReport(
      valid: valid,
      results: results,
      timestamp: DateTime.now(),
    );

    _logger.info('Configuration validation completed',
        category: LogCategory.config,
        metadata: {'valid': valid, 'passed': results.where((r) => r.passed).length, 'total': results.length});

    return report;
  }

  ValidationResult _check(String name, bool condition, String passMsg, String failMsg) {
    return ValidationResult(
      name: name,
      passed: condition,
      message: condition ? passMsg : failMsg,
    );
  }
}
