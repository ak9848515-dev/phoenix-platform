import 'usage_statistics.dart';

/// The health status of an AI provider.
///
/// Used by [HealthMonitor] and [ProviderConfiguration] to track
/// the current operational state of each provider.
enum ProviderHealthStatus {
  /// Provider is reachable and responding normally.
  healthy,

  /// Provider is unreachable or not responding.
  unavailable,

  /// Provider rejected the API key or authentication token.
  authenticationFailed,

  /// Provider returned a rate-limit response.
  rateLimited,

  /// Provider supports offline mode and is currently offline.
  offline,

  /// Health has not been checked yet.
  unknown;

  /// Human-readable label.
  String get displayName {
    switch (this) {
      case ProviderHealthStatus.healthy:
        return 'Healthy';
      case ProviderHealthStatus.unavailable:
        return 'Unavailable';
      case ProviderHealthStatus.authenticationFailed:
        return 'Authentication Failed';
      case ProviderHealthStatus.rateLimited:
        return 'Rate Limited';
      case ProviderHealthStatus.offline:
        return 'Offline';
      case ProviderHealthStatus.unknown:
        return 'Unknown';
    }
  }

  /// Whether this status is considered operational.
  bool get isOperational =>
      this == ProviderHealthStatus.healthy ||
      this == ProviderHealthStatus.offline;

  /// Whether this status indicates an error condition.
  bool get isError =>
      this == ProviderHealthStatus.unavailable ||
      this == ProviderHealthStatus.authenticationFailed ||
      this == ProviderHealthStatus.rateLimited;
}

/// The validation state of a stored API key.
enum ApiKeyValidationState {
  /// Key has not been tested against the provider.
  unverified,

  /// Key was successfully validated.
  valid,

  /// Key was rejected by the provider.
  invalid,

  /// Key has expired.
  expired,

  /// Key was revoked by the user or provider.
  revoked;

  /// Human-readable label.
  String get displayName {
    switch (this) {
      case ApiKeyValidationState.unverified:
        return 'Unverified';
      case ApiKeyValidationState.valid:
        return 'Valid';
      case ApiKeyValidationState.invalid:
        return 'Invalid';
      case ApiKeyValidationState.expired:
        return 'Expired';
      case ApiKeyValidationState.revoked:
        return 'Revoked';
    }
  }

  /// Whether the key is usable (valid only).
  bool get isUsable => this == ApiKeyValidationState.valid;
}

/// Configuration for a single AI provider.
///
/// Contains all settings that control how a provider behaves within
/// the Phoenix AI infrastructure. Each registered provider has one
/// [ProviderConfiguration] managed by the [ProviderConfigurationService].
///
/// Immutable. Use [copyWith] to produce modified instances.
class ProviderConfiguration {
  const ProviderConfiguration({
    required this.providerId,
    required this.providerName,
    this.enabled = true,
    this.isDefault = false,
    this.preferredModel,
    this.healthStatus = ProviderHealthStatus.unknown,
    this.lastSuccessfulConnection,
    this.lastFailure,
    this.offlineMode = false,
    this.fallbackPriority = 0,
    this.usageStatistics,
  });

  /// Unique provider identifier (matches [AIProvider] enum name).
  final String providerId;

  /// Human-readable provider name.
  final String providerName;

  /// Whether this provider is enabled for use.
  final bool enabled;

  /// Whether this is the default provider.
  final bool isDefault;

  /// The preferred model identifier (e.g. "gpt-4", "claude-3-opus").
  final String? preferredModel;

  /// Current health status of this provider.
  final ProviderHealthStatus healthStatus;

  /// Timestamp of the last successful connection.
  final DateTime? lastSuccessfulConnection;

  /// Timestamp of the last connection failure.
  final DateTime? lastFailure;

  /// Whether this provider should operate in offline mode.
  final bool offlineMode;

  /// Priority in the fallback chain (lower = tried first).
  final int fallbackPriority;

  /// Optional usage statistics.
  final UsageStatistics? usageStatistics;

  /// Creates a copy with the given fields replaced.
  ProviderConfiguration copyWith({
    String? providerId,
    String? providerName,
    bool? enabled,
    bool? isDefault,
    String? preferredModel,
    ProviderHealthStatus? healthStatus,
    DateTime? lastSuccessfulConnection,
    DateTime? lastFailure,
    bool? offlineMode,
    int? fallbackPriority,
    UsageStatistics? usageStatistics,
  }) =>
      ProviderConfiguration(
        providerId: providerId ?? this.providerId,
        providerName: providerName ?? this.providerName,
        enabled: enabled ?? this.enabled,
        isDefault: isDefault ?? this.isDefault,
        preferredModel: preferredModel ?? this.preferredModel,
        healthStatus: healthStatus ?? this.healthStatus,
        lastSuccessfulConnection:
            lastSuccessfulConnection ?? this.lastSuccessfulConnection,
        lastFailure: lastFailure ?? this.lastFailure,
        offlineMode: offlineMode ?? this.offlineMode,
        fallbackPriority: fallbackPriority ?? this.fallbackPriority,
        usageStatistics: usageStatistics ?? this.usageStatistics,
      );

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toMap() => {
        'providerId': providerId,
        'providerName': providerName,
        'enabled': enabled,
        'isDefault': isDefault,
        'preferredModel': preferredModel,
        'healthStatus': healthStatus.name,
        'lastSuccessfulConnection':
            lastSuccessfulConnection?.toIso8601String(),
        'lastFailure': lastFailure?.toIso8601String(),
        'offlineMode': offlineMode,
        'fallbackPriority': fallbackPriority,
        'usageStatistics': usageStatistics?.toMap(),
      };

  /// Deserializes from a JSON-compatible map.
  factory ProviderConfiguration.fromMap(Map<String, dynamic> map) =>
      ProviderConfiguration(
        providerId: map['providerId'] as String,
        providerName: map['providerName'] as String,
        enabled: map['enabled'] as bool? ?? true,
        isDefault: map['isDefault'] as bool? ?? false,
        preferredModel: map['preferredModel'] as String?,
        healthStatus: ProviderHealthStatus.values.firstWhere(
          (e) => e.name == (map['healthStatus'] as String? ?? 'unknown'),
          orElse: () => ProviderHealthStatus.unknown,
        ),
        lastSuccessfulConnection: map['lastSuccessfulConnection'] != null
            ? DateTime.parse(map['lastSuccessfulConnection'] as String)
            : null,
        lastFailure: map['lastFailure'] != null
            ? DateTime.parse(map['lastFailure'] as String)
            : null,
        offlineMode: map['offlineMode'] as bool? ?? false,
        fallbackPriority: map['fallbackPriority'] as int? ?? 0,
        usageStatistics: map['usageStatistics'] != null
            ? UsageStatistics.fromMap(
                Map<String, dynamic>.from(map['usageStatistics'] as Map))
            : null,
      );

  @override
  String toString() =>
      'ProviderConfiguration(providerId: $providerId, '
      'enabled: $enabled, health: ${healthStatus.name}, '
      'default: $isDefault, fallbackPriority: $fallbackPriority)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderConfiguration &&
          runtimeType == other.runtimeType &&
          providerId == other.providerId;

  @override
  int get hashCode => providerId.hashCode;
}
