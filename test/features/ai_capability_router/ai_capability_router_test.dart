import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/ai_capability_router/adapters/ai_provider_interface.dart';
import 'package:phoenix_platform/features/ai_capability_router/adapters/mock_claude_adapter.dart';
import 'package:phoenix_platform/features/ai_capability_router/adapters/mock_deepseek_adapter.dart';
import 'package:phoenix_platform/features/ai_capability_router/adapters/mock_gemini_adapter.dart';
import 'package:phoenix_platform/features/ai_capability_router/adapters/mock_ollama_adapter.dart';
import 'package:phoenix_platform/features/ai_capability_router/adapters/mock_openai_adapter.dart';
import 'package:phoenix_platform/features/ai_capability_router/adapters/mock_openrouter_adapter.dart';
import 'package:phoenix_platform/features/ai_capability_router/models/ai_capability.dart';
import 'package:phoenix_platform/features/ai_capability_router/models/ai_provider.dart';
import 'package:phoenix_platform/features/ai_capability_router/models/ai_request.dart';
import 'package:phoenix_platform/features/ai_capability_router/models/ai_response.dart';
import 'package:phoenix_platform/features/ai_capability_router/models/ai_route.dart';
import 'package:phoenix_platform/features/ai_capability_router/models/ai_router_config.dart';
import 'package:phoenix_platform/features/ai_capability_router/registry/ai_provider_registry.dart';
import 'package:phoenix_platform/features/ai_capability_router/router/ai_capability_router.dart';

// ── Error-Throwing Mock Adapter ─────────────────────────────────────────────

/// A mock adapter that always throws, used to test fallback logic.
class _FailingAdapter implements AIProviderInterface {
  const _FailingAdapter(this._provider);

  final AIProvider _provider;

  @override
  AIProvider get provider => _provider;

  @override
  bool get isAvailable => true;

  @override
  bool get supportsOffline => false;

  @override
  Future<AIResponse> execute(AIRequest request) async {
    throw Exception('Simulated failure for ${_provider.name}');
  }

  @override
  String formatPrompt(AIRequest request) => 'failing';
}

// ── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('AIProviderRegistry', () {
    test('register and retrieve adapter', () {
      final registry = AIProviderRegistry();
      registry.register(const MockGeminiAdapter());
      expect(registry.isRegistered(AIProvider.gemini), isTrue);
      expect(registry.getAdapter(AIProvider.gemini), isA<MockGeminiAdapter>());
    });

    test('registerAll registers multiple adapters', () {
      final registry = AIProviderRegistry();
      registry.registerAll([
        const MockGeminiAdapter(),
        const MockDeepSeekAdapter(),
      ]);
      expect(registry.count, 2);
    });

    test('unregister removes adapter', () {
      final registry = AIProviderRegistry();
      registry.register(const MockGeminiAdapter());
      registry.unregister(AIProvider.gemini);
      expect(registry.isRegistered(AIProvider.gemini), isFalse);
    });

    test('clear removes all adapters', () {
      final registry = AIProviderRegistry();
      registry.registerAll([
        const MockGeminiAdapter(),
        const MockDeepSeekAdapter(),
      ]);
      registry.clear();
      expect(registry.count, 0);
    });
  });

  group('AIRouterConfig', () {
    test('default mappings assign providers', () {
      final config = const AIRouterConfig();
      expect(config.providerFor(AICapability.coding), AIProvider.claude);
      expect(config.providerFor(AICapability.learning), AIProvider.gemini);
      expect(config.providerFor(AICapability.career), AIProvider.gemini);
      expect(config.providerFor(AICapability.resume), AIProvider.gemini);
    });
    test('copyWith overrides mappings', () {
      final config = const AIRouterConfig();
      final custom = config.copyWith(
        defaultMappings: {
          AICapability.coding: AIProvider.gemini,
        },
      );
      expect(custom.providerFor(AICapability.coding), AIProvider.gemini);
      // Learning not in custom mapping, falls back to default fallbackProvider
      expect(custom.providerFor(AICapability.learning), AIProvider.openRouter);
    });
  });

  group('AICapabilityRouter', () {
    late AIProviderRegistry registry;
    late AICapabilityRouter router;

    setUp(() {
      registry = AIProviderRegistry();
      registry.registerAll([
        const MockGeminiAdapter(),
        const MockDeepSeekAdapter(),
        const MockOpenAIAdapter(),
        const MockClaudeAdapter(),
        const MockOllamaAdapter(),
        const MockOpenRouterAdapter(),
      ]);
      router = AICapabilityRouter(registry: registry);
    });

    test('routes coding to Claude by default', () {
      final route = router.determineRoute(AIRequest(
        capability: AICapability.coding, prompt: 'Write a function',
      ));
      expect(route.provider, AIProvider.claude);
      expect(route.confidence, 0.9);
    });

    test('routes learning to Gemini by default', () {
      final route = router.determineRoute(AIRequest(
        capability: AICapability.learning, prompt: 'Teach me Flutter',
      ));
      expect(route.provider, AIProvider.gemini);
    });

    test('routes career to Gemini by default', () {
      final route = router.determineRoute(AIRequest(
        capability: AICapability.career, prompt: 'Career advice',
      ));
      expect(route.provider, AIProvider.gemini);
    });

    test('respects preferred provider override', () {
      final route = router.determineRoute(AIRequest(
        capability: AICapability.coding, prompt: 'Write code',
        preferredProvider: AIProvider.claude,
      ));
      expect(route.provider, AIProvider.claude);
    });

    test('routes to offline provider when preferred', () {
      final route = router.determineRoute(AIRequest(
        capability: AICapability.coding, prompt: 'Write code',
        metadata: {'offline': true},
      ));
      expect(route.provider, AIProvider.ollama);
    });

    test('execute returns successful response', () async {
      final result = await router.route(AIRequest(
        capability: AICapability.coding,
        prompt: 'Hello',
      ));
      expect(result.isSuccess, isTrue);
      expect(result.response.provider, AIProvider.claude);
      expect(result.response.output, contains('Mock Claude Response'));
    });

    test('fallback works when primary fails', () async {
      // Replace Claude (primary for coding) with failing adapter
      registry.register(const _FailingAdapter(AIProvider.claude));

      final result = await router.route(AIRequest(
        capability: AICapability.coding,
        prompt: 'Hello',
      ));
      expect(result.isSuccess, isTrue);
      expect(result.fallbackUsed, isTrue);
      expect(result.route, isNot(AIProvider.claude));
    });

    test('returns error when all providers fail', () async {
      registry.clear();
      registry.register(const _FailingAdapter(AIProvider.gemini));
      registry.register(const _FailingAdapter(AIProvider.deepseek));
      registry.register(const _FailingAdapter(AIProvider.openAI));
      registry.register(const _FailingAdapter(AIProvider.claude));
      registry.register(const _FailingAdapter(AIProvider.ollama));
      registry.register(const _FailingAdapter(AIProvider.openRouter));

      final result = await router.route(AIRequest(
        capability: AICapability.coding,
        prompt: 'Hello',
      ));
      expect(result.isSuccess, isFalse);
      expect(result.response.error, isNotNull);
    });

    test('disables fallback when configured', () async {
      registry.register(const _FailingAdapter(AIProvider.claude));
      router.updateConfig(const AIRouterConfig(enableFallback: false));

      final result = await router.route(AIRequest(
        capability: AICapability.coding,
        prompt: 'Hello',
      ));
      expect(result.isSuccess, isFalse);
    });

    test('convenience methods route to correct provider', () async {
      final codingResult = await router.code(prompt: 'Write function');
      expect(codingResult, contains('Mock Claude Response'));

      final learnResult = await router.learn(prompt: 'Teach me');
      expect(learnResult, contains('Mock Gemini Response'));

      final careerResult = await router.career(prompt: 'Career advice');
      expect(careerResult, contains('Mock Gemini Response'));
    });
  });

  group('AIResponse', () {
    test('success factory creates successful response', () {
      final response = AIResponse.success(
        provider: AIProvider.gemini,
        capability: AICapability.coding,
        output: 'Hello',
      );
      expect(response.success, isTrue);
      expect(response.output, 'Hello');
    });

    test('error factory creates error response', () {
      final response = AIResponse.error(
        provider: AIProvider.gemini,
        capability: AICapability.coding,
        error: 'Something went wrong',
      );
      expect(response.success, isFalse);
      expect(response.error, 'Something went wrong');
    });
  });

  group('AIRoute', () {
    test('toString includes capability and provider', () {
      final route = AIRoute(
        capability: AICapability.coding,
        provider: AIProvider.claude,
      );
      expect(route.toString(), contains('coding'));
      expect(route.toString(), contains('claude'));
    });

    test('hasFallback is true when fallback configured', () {
      final route = AIRoute(
        capability: AICapability.coding,
        provider: AIProvider.claude,
        fallbackProvider: AIProvider.gemini,
      );
      expect(route.hasFallback, isTrue);
    });
  });
}
