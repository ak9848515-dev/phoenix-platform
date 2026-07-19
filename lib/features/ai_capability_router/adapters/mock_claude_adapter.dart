import '../models/ai_provider.dart';
import '../models/ai_request.dart';
import '../models/ai_response.dart';
import 'ai_provider_interface.dart';

/// Mock adapter for Anthropic Claude.
///
/// No real API calls. Returns simulated responses.
class MockClaudeAdapter implements AIProviderInterface {
  const MockClaudeAdapter();

  @override
  AIProvider get provider => AIProvider.claude;

  @override
  bool get isAvailable => true;

  @override
  bool get supportsOffline => false;

  @override
  Future<AIResponse> execute(AIRequest request) async {
    await Future.delayed(const Duration(milliseconds: 100));

    return AIResponse.success(
      provider: AIProvider.claude,
      capability: request.capability,
      output: '[Mock Claude Response] ${formatPrompt(request)}',
      latencyMs: 100,
      estimatedTokens: request.prompt.length ~/ 5,
    );
  }

  @override
  String formatPrompt(AIRequest request) {
    final buf = StringBuffer()
      ..writeln('Human: ${request.prompt}')
      ..writeln('\nPlease respond as a helpful career and learning advisor.')
      ..writeln('Assistant:');
    return buf.toString();
  }
}
