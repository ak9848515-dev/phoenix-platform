import 'provider_config.dart';

/// A stored API key for an AI provider.
///
/// The key value is always encrypted before storage.
/// Never expose plain API keys outside [SecureStorageService].
///
/// Immutable. Use [copyWith] to produce modified instances.
class ApiKey {
  const ApiKey({
    required this.providerId,
    required this.encryptedKey,
    required this.createdDate,
    required this.modifiedDate,
    this.validationState = ApiKeyValidationState.unverified,
  });

  /// The provider this key belongs to.
  final String providerId;

  /// The encrypted API key value.
  ///
  /// Never contains the plain-text key outside of
  /// the [SecureStorageService] boundary.
  final String encryptedKey;

  /// When this key was first stored.
  final DateTime createdDate;

  /// When this key was last modified.
  final DateTime modifiedDate;

  /// Current validation state of this key.
  final ApiKeyValidationState validationState;

  /// Creates a copy with the given fields replaced.
  ApiKey copyWith({
    String? providerId,
    String? encryptedKey,
    DateTime? createdDate,
    DateTime? modifiedDate,
    ApiKeyValidationState? validationState,
  }) =>
      ApiKey(
        providerId: providerId ?? this.providerId,
        encryptedKey: encryptedKey ?? this.encryptedKey,
        createdDate: createdDate ?? this.createdDate,
        modifiedDate: modifiedDate ?? this.modifiedDate,
        validationState: validationState ?? this.validationState,
      );

  /// Serializes to a JSON-compatible map.
  ///
  /// The encrypted key is included in serialization since it is already
  /// encrypted. Only [SecureStorageService] handles the plain-text key.
  Map<String, dynamic> toMap() => {
        'providerId': providerId,
        'encryptedKey': encryptedKey,
        'createdDate': createdDate.toIso8601String(),
        'modifiedDate': modifiedDate.toIso8601String(),
        'validationState': validationState.name,
      };

  /// Deserializes from a JSON-compatible map.
  factory ApiKey.fromMap(Map<String, dynamic> map) => ApiKey(
        providerId: map['providerId'] as String,
        encryptedKey: map['encryptedKey'] as String,
        createdDate: DateTime.parse(map['createdDate'] as String),
        modifiedDate: DateTime.parse(map['modifiedDate'] as String),
        validationState: ApiKeyValidationState.values.firstWhere(
          (e) =>
              e.name == (map['validationState'] as String? ?? 'unverified'),
          orElse: () => ApiKeyValidationState.unverified,
        ),
      );

  @override
  String toString() =>
      'ApiKey(providerId: $providerId, '
      'validationState: ${validationState.name}, '
      'created: ${createdDate.toIso8601String()})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiKey &&
          runtimeType == other.runtimeType &&
          providerId == other.providerId;

  @override
  int get hashCode => providerId.hashCode;
}
