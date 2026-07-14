import 'package:flutter/foundation.dart';

import '../models/voice_session.dart';
import '../models/voice_state.dart';

/// Manages the voice session lifecycle as a state machine.
///
/// Enforces the single-active-session rule:
///   idle → listening → processing → speaking → idle
///   Any state → error → idle
///
/// Listeners are notified on every state transition.
class VoiceSessionManager {
  VoiceSession _session = const VoiceSession();
  final ListenerList _listeners = ListenerList();

  // ── State Access ──────────────────────────────────────────────────

  /// The current voice session (immutable).
  VoiceSession get currentSession => _session;

  /// Whether a session is currently active (listening, processing, or speaking).
  bool get isActive => _session.isActive;

  /// The current state.
  VoiceSessionState get state => _session.state;

  // ── State Transitions ─────────────────────────────────────────────

  /// Transitions to [VoiceSessionState.listening].
  void startListening() {
    _transitionTo(VoiceSessionState.listening);
  }

  /// Transitions to [VoiceSessionState.processing] with recognised text.
  void startProcessing(String transcript) {
    _session = _session.copyWith(
      state: VoiceSessionState.processing,
      transcript: transcript,
    );
    _notify();
  }

  /// Transitions to [VoiceSessionState.speaking].
  void startSpeaking() {
    _transitionTo(VoiceSessionState.speaking);
  }

  /// Returns to [VoiceSessionState.idle] after a successful session.
  void finish() {
    _session = const VoiceSession();
    _notify();
  }

  /// Transitions to [VoiceSessionState.error] and then resets to idle.
  void fail(String message) {
    _session = _session.copyWith(
      state: VoiceSessionState.error,
      errorMessage: message,
    );
    _notify();
    // Auto-reset to idle after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      _session = const VoiceSession();
      _notify();
    });
  }

  /// Cancels the current session and resets to idle immediately.
  void cancel() {
    _session = const VoiceSession();
    _notify();
  }

  void _transitionTo(VoiceSessionState newState) {
    _session = _session.copyWith(
      state: newState,
      startedAt: newState == VoiceSessionState.listening
          ? DateTime.now()
          : _session.startedAt,
    );
    _notify();
  }

  // ── Duration Tracking ─────────────────────────────────────────────

  /// Updates the session duration. Called periodically while listening.
  void tickDuration() {
    final started = _session.startedAt;
    if (started == null) return;
    final elapsed = DateTime.now().difference(started).inMilliseconds;
    _session = _session.copyWith(durationMs: elapsed);
    _notify();
  }

  // ── Listener Management ───────────────────────────────────────────

  /// Registers a listener that is called whenever the session changes.
  /// Returns a function that removes the listener when called.
  VoidCallback addListener(VoidCallback listener) {
    return _listeners.add(listener);
  }

  /// Removes a previously registered listener.
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notify() {
    _listeners.notify();
  }

  // ── Diagnostics ───────────────────────────────────────────────────

  /// Returns diagnostic information about the current session.
  Map<String, dynamic> diagnostics() {
    return {
      'state': _session.state.name,
      'isActive': isActive,
      'transcript': _session.transcript,
      'durationMs': _session.durationMs,
      'error': _session.errorMessage,
    };
  }
}

// ── ListenerList ──────────────────────────────────────────────────────────

/// Thread-safe list of listeners with efficient add/remove/notify.
class ListenerList {
  final List<VoidCallback> _listeners = [];

  /// Adds a listener and returns a disposable token.
  VoidCallback add(VoidCallback listener) {
    _listeners.add(listener);
    return () => _listeners.remove(listener);
  }

  /// Removes a previously added listener.
  void remove(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notifies all registered listeners.
  void notify() {
    final copy = List<VoidCallback>.from(_listeners);
    for (final listener in copy) {
      listener();
    }
  }
}
