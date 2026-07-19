/// Possible states of the Identity Engine lifecycle.
///
/// Consumers can check [IdentityEngine.identityState] to determine
/// whether identity data is ready, being loaded, or unavailable.
enum IdentityState {
  /// The engine has not been initialized yet.
  uninitialized,

  /// Identity data is loading from persistence.
  loading,

  /// Identity data is ready for consumption.
  ready,

  /// An error occurred during initialization.
  error,

  /// Identity data has been explicitly reset.
  reset,
}
