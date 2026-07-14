/// Possible states of a voice session.
///
/// Only one active session is allowed at any time.
/// Transitions follow: idle → listening → processing → speaking → idle.
/// Errors may transition from any active state back to idle.
enum VoiceSessionState {
  /// No active voice session.
  idle,

  /// Microphone is active, capturing audio.
  listening,

  /// Audio is being processed (speech-to-text).
  processing,

  /// System is speaking a response (text-to-speech).
  speaking,

  /// An error occurred during the session.
  error,
}
