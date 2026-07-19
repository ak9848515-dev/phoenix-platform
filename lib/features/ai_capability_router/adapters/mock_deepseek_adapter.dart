import '../models/ai_provider.dart';
import '../models/ai_request.dart';
import '../models/ai_response.dart';
import 'ai_provider_interface.dart';

/// Mock adapter for DeepSeek.
///
/// No real API calls. Returns simulated responses.
class MockDeepSeekAdapter implements AIProviderInterface {
  const MockDeepSeekAdapter();

  @override
  AIProvider get provider => AIProvider.deepseek;

  @override
  bool get isAvailable => true;

  @override
  bool get supportsOffline => false;

  @override
  Future<AIResponse> execute(AIRequest request) async {
    await Future.delayed(const Duration(milliseconds: 30));

    return AIResponse.success(
      provider: AIProvider.deepseek,
      capability: request.capability,
      output: '[Mock DeepSeek Response] ${formatPrompt(request)}',
      latencyMs: 30,
      estimatedTokens: request.prompt.length ~/ 4,
    );
  }

  @override
  String formatPrompt(AIRequest request) {
    final buf = StringBuffer()
      ..writeln('User request: ${request.prompt}')
      ..writeln('Code/math mode enabled');
    if (request.context.isNotEmpty) {
      buf.writeln('Context keys: ${request.context.keys.join(", ")}');
    }
    return buf.toString();
  }
}
