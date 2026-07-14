import 'dart:async';

import 'speech_provider.dart';

/// A mock [SpeechProvider] for development and testing.
///
/// Simulates speech recognition and synthesis without requiring
/// platform-specific SDKs or hardware.
///
/// - `startListening` streams a configurable set of canned phrases
/// - `speak` logs the text and completes after a short delay
/// - All lifecycle methods complete immediately
class MockSpeechProvider implements SpeechProvider {
  MockSpeechProvider({
    this.recognitionDelay = const Duration(milliseconds: 500),
    this.synthesisDelay = const Duration(milliseconds: 300),
    this.cannedPhrases = _defaultPhrases,
    this.shouldFailOnInit = false,
    this.shouldFailOnListen = false,
    this.shouldFailOnSpeak = false,
  });

  /// Delay before simulated recognition results.
  final Duration recognitionDelay;

  /// Delay before simulated speech synthesis.
  final Duration synthesisDelay;

  /// Canned phrases to simulate recognition.
  final List<String> cannedPhrases;

  /// If true, [initialize] returns `false`.
  final bool shouldFailOnInit;

  /// If true, [startListening] throws an error.
  final bool shouldFailOnListen;

  /// If true, [speak] throws an error.
  final bool shouldFailOnSpeak;

  bool _initialized = false;
  StreamController<String>? _controller;

  static const List<String> _defaultPhrases = [
    'Open Dashboard',
    'Open Profile',
    'Continue Mission',
    'Improve Resume',
    'Practice Interview',
    'Show Portfolio',
    'Open AI Mentor',
    'Explore Opportunities',
  ];

  @override
  bool get isAvailable => _initialized;

  @override
  bool get supportsRecognition => true;

  @override
  bool get supportsSynthesis => true;

  @override
  String get name => 'Mock';

  @override
  Future<bool> initialize() async {
    if (shouldFailOnInit) return false;
    _initialized = true;
    return true;
  }

  @override
  Stream<String> startListening() {
    if (shouldFailOnListen) {
      throw StateError('Mock provider: listening failed as configured');
    }
    _controller = StreamController<String>.broadcast();
    _simulateRecognition();
    return _controller!.stream;
  }

  Future<void> _simulateRecognition() async {
    for (final phrase in cannedPhrases) {
      if (recognitionDelay > Duration.zero) {
        await Future.delayed(recognitionDelay);
      } else {
        // Use microtask to yield to event loop so listeners can attach
        await Future.microtask(() {});
      }
      if (_controller == null || _controller!.isClosed) return;
      _controller!.add(phrase);
    }
    // Final delay before closing
    if (recognitionDelay > Duration.zero) {
      await Future.delayed(recognitionDelay);
    }
    await _controller?.close();
    _controller = null;
  }

  @override
  Future<void> stopListening() async {
    await _controller?.close();
    _controller = null;
  }

  @override
  Future<void> speak(String text) async {
    if (shouldFailOnSpeak) {
      throw StateError('Mock provider: speech failed as configured');
    }
    await Future.delayed(synthesisDelay * (text.length / 10).ceil());
  }

  @override
  Future<void> stopSpeaking() async {
    // No-op for mock provider
  }

  @override
  Future<void> cancel() async {
    await stopListening();
    await stopSpeaking();
  }

  @override
  Future<void> dispose() async {
    await cancel();
    _initialized = false;
  }
}
