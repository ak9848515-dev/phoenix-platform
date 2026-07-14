/// Abstract interface for all speech providers in Phoenix OS.
///
/// Every voice provider (Android Speech, iOS Speech, Whisper, Azure,
/// Google, offline, etc.) must implement this interface. No widget
/// or service should depend on a concrete provider — only on this
/// abstraction.
///
/// The [VoiceService] orchestrates provider lifecycle. Providers are
/// lazily initialised and replaceable at runtime.
abstract class SpeechProvider {
  /// Initialises the provider. Must be called before any other method.
  /// Returns `true` if initialisation succeeded.
  Future<bool> initialize();

  /// Starts listening for speech. Returns a stream of recognised text
  /// fragments. The stream completes when [stopListening] is called.
  Stream<String> startListening();

  /// Stops listening and closes the recognition stream.
  Future<void> stopListening();

  /// Speaks the given text. Returns when speaking completes.
  Future<void> speak(String text);

  /// Stops any current speech output.
  Future<void> stopSpeaking();

  /// Cancels any in-progress operation (listening or speaking).
  Future<void> cancel();

  /// Releases all resources held by this provider.
  Future<void> dispose();

  /// Whether the provider is currently available (initialised and ready).
  bool get isAvailable;

  /// Whether the provider supports speech recognition.
  bool get supportsRecognition;

  /// Whether the provider supports speech synthesis.
  bool get supportsSynthesis;

  /// Human-readable name of this provider (e.g. "Mock", "Android").
  String get name;
}
