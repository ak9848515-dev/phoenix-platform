import '../models/ai_provider.dart';
import '../models/ai_request.dart';
import '../models/ai_response.dart';
import 'ai_provider_interface.dart';

/// Mock adapter for OpenRouter (multi-provider fallback).
///
/// Acts as the final fallback when all other providers are unavailable.
/// No real API calls. Returns simulated responses.
class MockOpenRouterAdapter implements AIProviderInterface {
  const MockOpenRouterAdapter();

  @override
  AIProvider get provider => AIProvider.openRouter;

  @override
  bool get isAvailable => true;

  @override
  bool get supportsOffline => false;

  @override
  Future<AIResponse> execute(AIRequest request) async {
    await Future.delayed(const Duration(milliseconds: 150));

    return AIResponse.success(
      provider: AIProvider.openRouter,
      capability: request.capability,
      output: '[Mock OpenRouter Fallback Response] ${formatPrompt(request)}',
      latencyMs: 150,
      estimatedTokens: request.prompt.length ~/ 4,
    );
  }

  @override
  String formatPrompt(AIRequest request) {
    final buf = StringBuffer()
      ..writeln('[OpenRouter Fallback]')
      ..writeln('Original capability: ${request.capability.displayName}')
      ..writeln('Prompt: ${request.prompt}');
    return buf.toString();
  }
}
