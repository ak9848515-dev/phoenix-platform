import 'voice_state.dart';

/// Immutable data model for the current voice session.
///
/// Tracks session state, transcript, recognised command, and error
/// information. Created by [VoiceSessionManager] and consumed by
/// [VoiceService] and UI components.
class VoiceSession {
  const VoiceSession({
    this.state = VoiceSessionState.idle,
    this.transcript,
    this.errorMessage,
    this.durationMs = 0,
    this.startedAt,
  });

  /// Current state of the voice session.
  final VoiceSessionState state;

  /// The recognised spoken text (null if none yet).
  final String? transcript;

  /// Error message if [state] is [VoiceSessionState.error].
  final String? errorMessage;

  /// Session duration in milliseconds.
  final int durationMs;

  /// When the session started.
  final DateTime? startedAt;

  /// Whether the session is in an active state (not idle).
  bool get isActive =>
      state == VoiceSessionState.listening ||
      state == VoiceSessionState.processing ||
      state == VoiceSessionState.speaking;

  /// Creates a copy with the given fields replaced.
  VoiceSession copyWith({
    VoiceSessionState? state,
    String? transcript,
    String? errorMessage,
    int? durationMs,
    DateTime? startedAt,
    bool clearTranscript = false,
    bool clearError = false,
  }) {
    return VoiceSession(
      state: state ?? this.state,
      transcript: clearTranscript ? null : (transcript ?? this.transcript),
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
      durationMs: durationMs ?? this.durationMs,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  @override
  String toString() =>
      'VoiceSession(state: $state, transcript: $transcript, '
      'duration: ${durationMs}ms)';
}
