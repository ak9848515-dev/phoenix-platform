import '../models/ai_provider.dart';
import '../models/ai_request.dart';
import '../models/ai_response.dart';
import 'ai_provider_interface.dart';

/// Mock adapter for OpenAI.
///
/// No real API calls. Returns simulated responses.
class MockOpenAIAdapter implements AIProviderInterface {
  const MockOpenAIAdapter();

  @override
  AIProvider get provider => AIProvider.openAI;

  @override
  bool get isAvailable => true;

  @override
  bool get supportsOffline => false;

  @override
  Future<AIResponse> execute(AIRequest request) async {
    await Future.delayed(const Duration(milliseconds: 80));

    return AIResponse.success(
      provider: AIProvider.openAI,
      capability: request.capability,
      output: '[Mock OpenAI Response] ${formatPrompt(request)}',
      latencyMs: 80,
      estimatedTokens: request.prompt.length ~/ 3,
    );
  }

  @override
  String formatPrompt(AIRequest request) {
    final buf = StringBuffer()
      ..writeln('<|system|>')
      ..writeln('You are a helpful assistant.')
      ..writeln('Capability: ${request.capability.displayName}')
      ..writeln('<|user|>')
      ..writeln(request.prompt)
      ..writeln('<|assistant|>');
    return buf.toString();
  }
}
