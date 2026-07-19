import '../models/ai_provider.dart';
import '../models/ai_request.dart';
import '../models/ai_response.dart';
import 'ai_provider_interface.dart';

/// Mock adapter for Google Gemini.
///
/// No real API calls. Returns simulated responses.
class MockGeminiAdapter implements AIProviderInterface {
  const MockGeminiAdapter();

  @override
  AIProvider get provider => AIProvider.gemini;

  @override
  bool get isAvailable => true;

  @override
  bool get supportsOffline => false;

  @override
  Future<AIResponse> execute(AIRequest request) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 50));

    return AIResponse.success(
      provider: AIProvider.gemini,
      capability: request.capability,
      output: '[Mock Gemini Response] ${formatPrompt(request)}',
      latencyMs: 50,
      estimatedTokens: request.prompt.length ~/ 4,
    );
  }

  @override
  String formatPrompt(AIRequest request) {
    final context = request.context;
    final buf = StringBuffer()
      ..writeln('Prompt: ${request.prompt}')
      ..writeln('Temperature: ${request.temperature}')
      ..writeln('Max tokens: ${request.maxTokens}');

    if (context.isNotEmpty) {
      buf.writeln('Context: $context');
    }
    return buf.toString();
  }
}
