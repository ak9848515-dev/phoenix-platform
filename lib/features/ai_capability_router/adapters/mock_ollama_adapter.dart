import '../models/ai_provider.dart';
import '../models/ai_request.dart';
import '../models/ai_response.dart';
import 'ai_provider_interface.dart';

/// Mock adapter for Ollama (local LLM).
///
/// Represents the offline provider capability.
/// No real API calls. Returns simulated responses.
class MockOllamaAdapter implements AIProviderInterface {
  const MockOllamaAdapter();

  @override
  AIProvider get provider => AIProvider.ollama;

  @override
  bool get isAvailable => true;

  @override
  bool get supportsOffline => true;

  @override
  Future<AIResponse> execute(AIRequest request) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return AIResponse.success(
      provider: AIProvider.ollama,
      capability: request.capability,
      output: '[Mock Ollama (Offline) Response] ${formatPrompt(request)}',
      latencyMs: 200,
      estimatedTokens: request.prompt.length ~/ 4,
    );
  }

  @override
  String formatPrompt(AIRequest request) {
    final buf = StringBuffer()
      ..writeln('[Offline Mode]')
      ..writeln('Prompt: ${request.prompt}')
      ..writeln('Model: llama3.2 (local)')
      ..writeln('Temperature: ${request.temperature}');
    return buf.toString();
  }
}
