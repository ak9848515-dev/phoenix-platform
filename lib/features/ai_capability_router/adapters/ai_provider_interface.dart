import '../models/ai_provider.dart';
import '../models/ai_request.dart';
import '../models/ai_response.dart';

/// Abstract interface that every AI provider adapter must implement.
///
/// Phoenix never talks directly to any AI provider.
/// All communication goes through adapters implementing this interface.
///
/// Adapters are mock-only — no real API calls.
abstract class AIProviderInterface {
  /// The provider this adapter represents.
  AIProvider get provider;

  /// Whether this provider is available (mock: always true).
  bool get isAvailable;

  /// Whether this provider supports offline operation.
  bool get supportsOffline;

  /// Executes an AI capability and returns a response.
  ///
  /// [request] contains the capability, prompt, context and configuration.
  ///
  /// Returns an [AIResponse] that may be successful or contain an error.
  Future<AIResponse> execute(AIRequest request);

  /// Generates a capability-appropriate prompt from the request.
  ///
  /// Each adapter may format prompts differently per provider conventions.
  String formatPrompt(AIRequest request);
}
