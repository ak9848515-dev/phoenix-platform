import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/voice_command.dart';
import '../models/voice_session.dart';
import '../models/voice_state.dart';
import '../providers/speech_provider.dart';
import 'voice_command_router.dart';
import 'voice_session_manager.dart';

/// Public API for the Phoenix Voice Framework.
///
/// [VoiceService] is the ONLY entry point for voice functionality.
/// Widgets call [startListening], [speak], etc. — they never interact
/// with [SpeechProvider] or [VoiceSessionManager] directly.
///
/// Responsibilities:
/// - Provider lifecycle management
/// - Session orchestration
/// - Command recognition and routing
/// - AI voice integration
/// - Accessibility support
///
/// The service is provider-independent. Swap providers without changing
/// any widget code.
class VoiceService {
  VoiceService({
    required this._provider,
    VoiceSessionManager? sessionManager,
    VoiceCommandRouter? commandRouter,
  })  : _sessionManager = sessionManager ?? VoiceSessionManager(),
        _commandRouter = commandRouter ?? VoiceCommandRouter();

  final SpeechProvider _provider;
  final VoiceSessionManager _sessionManager;
  final VoiceCommandRouter _commandRouter;

  StreamSubscription<String>? _recognitionSubscription;
  bool _initialized = false;

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Initialises the voice provider. Must be called once before
  /// any other method. Returns `true` if initialisation succeeded.
  Future<bool> initialize() async {
    if (_initialized) return true;
    final success = await _provider.initialize();
    _initialized = success;
    return success;
  }

  /// Releases all resources. Call when the app is disposed.
  Future<void> dispose() async {
    await cancel();
    await _provider.dispose();
    _initialized = false;
  }

  // ── Session Access ────────────────────────────────────────────────

  /// The current voice session (immutable).
  VoiceSession get currentSession => _sessionManager.currentSession;

  /// Whether the voice system is available (initialised and ready).
  bool get isAvailable => _initialized && _provider.isAvailable;

  /// Whether a voice session is currently active.
  bool get isActive => _sessionManager.isActive;

  /// The current voice session state.
  VoiceSessionState get state => _sessionManager.state;

  // ── Listening ─────────────────────────────────────────────────────

  /// Starts listening for voice commands.
  ///
  /// Transitions the session to [VoiceSessionState.listening].
  /// Recognised text is piped through [VoiceCommandRouter].
  /// Handlers are optional — set [onCommand] to receive parsed commands.
  void startListening({
    ValueChanged<VoiceCommand>? onCommand,
    VoidCallback? onListeningStarted,
    VoidCallback? onListeningStopped,
  }) {
    if (!isAvailable) return;
    if (isActive) return;

    _sessionManager.startListening();
    onListeningStarted?.call();

    try {
      final stream = _provider.startListening();

      _recognitionSubscription = stream.listen(
        (text) {
          _sessionManager.startProcessing(text);

          // Parse and route command from the latest transcription
          final command = _commandRouter.parse(text);
          if (command.isValid) {
            onCommand?.call(command);
          }
        },
        onDone: () {
          _sessionManager.finish();
          onListeningStopped?.call();
        },
        onError: (error) {
          _sessionManager.fail(error.toString());
          onListeningStopped?.call();
        },
      );
    } catch (e) {
      _sessionManager.fail(e.toString());
      onListeningStopped?.call();
    }
  }

  /// Stops listening for voice commands.
  Future<void> stopListening() async {
    await _recognitionSubscription?.cancel();
    _recognitionSubscription = null;
    await _provider.stopListening();
    _sessionManager.finish();
  }

  // ── Speaking ──────────────────────────────────────────────────────

  /// Speaks the given text using text-to-speech.
  ///
  /// Transitions the session to [VoiceSessionState.speaking].
  /// Automatically returns to idle when speaking completes.
  Future<void> speak(String text) async {
    if (!isAvailable) return;
    if (_sessionManager.state == VoiceSessionState.speaking) return;

    _sessionManager.startSpeaking();
    try {
      await _provider.speak(text);
    } catch (e) {
      _sessionManager.fail(e.toString());
      return;
    }
    _sessionManager.finish();
  }

  /// Stops any current speech output.
  Future<void> stopSpeaking() async {
    await _provider.stopSpeaking();
    if (_sessionManager.state == VoiceSessionState.speaking) {
      _sessionManager.finish();
    }
  }

  // ── Cancel ────────────────────────────────────────────────────────

  /// Cancels any in-progress voice operation (listening or speaking)
  /// and resets the session to idle.
  Future<void> cancel() async {
    await _recognitionSubscription?.cancel();
    _recognitionSubscription = null;
    await _provider.cancel();
    _sessionManager.cancel();
  }

  // ── Listeners ─────────────────────────────────────────────────────

  /// Registers a session change listener. Returns a dispose function.
  VoidCallback addListener(VoidCallback listener) =>
      _sessionManager.addListener(listener);

  /// Removes a listener.
  void removeListener(VoidCallback listener) =>
      _sessionManager.removeListener(listener);

  // ── Diagnostics ───────────────────────────────────────────────────

  /// Returns diagnostic information about the voice framework.
  Map<String, dynamic> diagnostics() {
    return {
      'initialized': _initialized,
      'available': isAvailable,
      'provider': _provider.name,
      'session': _sessionManager.diagnostics(),
    };
  }
}
