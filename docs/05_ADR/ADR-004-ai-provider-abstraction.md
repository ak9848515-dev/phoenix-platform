# ADR-004: AI Provider Abstraction Architecture

**Status:** Draft — Architecture Review
**Date:** July 15, 2026
**Author:** Phoenix Platform Architecture Team
**Sprint:** PHX-068 — AI Integration Platform

---

## Context

Phoenix Platform currently has a fully deterministic intelligence layer (PHX-063) consisting of four pure-computation engines and six orchestration services. The platform needs optional multi-provider AI integration while preserving the existing offline-first deterministic intelligence.

### Current Architecture

```
Presentation Layer
        ↓
AI Services (PhoenixAIService, IntelligenceMentorService,
            AIMentorService, ConversationService)
        ↓
Engines (DailyBriefEngine, CrossFeatureReasoner,
        ConversationEngine, ExplanationEngine)
        ↓
Platform Services (Academy, Habit, Timeline, Knowledge, Decision, Memory)
        ↓
Repository Layer (Frozen)
```

### Key Constraints

1. **AI is OPTIONAL** — Phoenix must function completely offline without any AI provider
2. **Deterministic intelligence is PRESERVED** — Existing engines remain the primary response layer
3. **Architecture is FROZEN** — No changes to Repository, Engine, or Service layers
4. **AI adds enrichment only** — Responses are enhanced, not replaced
5. **Provider-swappable** — Users can choose which AI provider to use

---

## Decision

Implement a **pluggable AI Provider Abstraction** beneath the existing intelligence layer. AI providers sit parallel to the deterministic engines, and a new `AIContextBuilder` + `AIRouter` orchestrates between them.

### High-Level Architecture

```
Presentation Layer
        ↓
AI Services (UNCHANGED)
        ↓
┌─────────────────────────────────────────────────────┐
│                AI Orchestration Layer (NEW)          │
│                                                      │
│  ┌──────────────┐    ┌──────────────┐               │
│  │ AI Router    │───▶│ AI Context   │               │
│  │ (routes to   │    │ Builder      │               │
│  │ provider or  │    │ (builds      │               │
│  │ deterministic)│   │  context)    │               │
│  └──────┬───────┘    └──────────────┘               │
│         │                                            │
│         ▼                                            │
│  ┌────────────────────────────────────────────────┐  │
│  │           AI Provider Abstraction              │  │
│  │                                                │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐       │  │
│  │  │ OpenAI   │ │ Claude   │ │ Gemini   │ ...   │  │
│  │  │ Provider │ │ Provider │ │ Provider │       │  │
│  │  └──────────┘ └──────────┘ └──────────┘       │  │
│  │                                                │  │
│  │  ┌──────────────────────┐                      │  │
│  │  │ Local LLM Provider   │                      │  │
│  │  │ (Ollama/LM Studio)   │                      │  │
│  │  └──────────────────────┘                      │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│  ┌──────────────┐    ┌──────────────┐               │
│  │ Prompt       │    │ Tool         │               │
│  │ Library      │    │ Registry     │               │
│  └──────────────┘    └──────────────┘               │
│                                                      │
│  ┌──────────────┐    ┌──────────────┐               │
│  │ Conversation │    │ Safety       │               │
│  │ Memory       │    │ Layer        │               │
│  └──────────────┘    └──────────────┘               │
└─────────────────────────────────────────────────────┘
        ↓
Engines (UNCHANGED — deterministic fallback)
        ↓
Platform Services (UNCHANGED)
```

---

## Component Design

### 1. Abstract AI Provider Interface

```dart
/// Abstract interface for all AI providers.
///
/// Each provider implements this interface to expose its capabilities.
/// Providers are OPTIONAL — Phoenix works without any provider configured.
abstract class AIProvider {
  /// The display name of this provider (e.g. "OpenAI GPT-4o").
  String get displayName;

  /// The unique identifier for this provider (e.g. "openai").
  String get providerId;

  /// Whether this provider is currently available/configured.
  bool get isAvailable;

  /// The capabilities this provider supports.
  Set<AICapability> get capabilities;

  /// Sends a chat completion request and returns the response.
  Future<AIProviderResponse> chat({
    required List<AIChatMessage> messages,
    AIChatConfig? config,
    CancelToken? cancelToken,
  });

  /// Sends a streaming chat completion request.
  Stream<AIProviderChunk> chatStreaming({
    required List<AIChatMessage> messages,
    AIChatConfig? config,
    CancelToken? cancelToken,
  });

  /// Generates structured content (e.g. course outline, quiz).
  Future<AIProviderResponse> generate({
    required String prompt,
    AIGenerationConfig? config,
  });

  /// Embeds text for semantic search (if supported).
  Future<List<double>> embed(String text);
}

/// Capabilities a provider can support.
enum AICapability {
  chat,           /// Conversational responses
  streaming,      /// Streaming token-by-token responses
  embeddings,     /// Text embedding generation
  toolCalling,    /// Function/tool calling
  vision,         /// Image understanding
  structured,     /// Structured output (JSON mode)
}
```

### 2. Provider Implementations

Each provider is a separate file in `lib/features/ai/providers/`:

| Provider | File | Package | Configuration |
|----------|------|---------|---------------|
| OpenAI | `openai_provider.dart` | `openai_dart` or `dart_openai` | API key from secure storage |
| Anthropic Claude | `claude_provider.dart` | `anthropic_sdk_dart` | API key from secure storage |
| Google Gemini | `gemini_provider.dart` | `google_generative_ai` | API key from secure storage |
| Local LLM (Ollama) | `ollama_provider.dart` | None (HTTP client) | Host URL from settings |
| Local LLM (LM Studio) | `lm_studio_provider.dart` | None (HTTP client) | Host URL from settings |

**Provider base pattern:**

```dart
class OpenAIProvider extends AIProvider {
  OpenAIProvider({required String apiKey, this.model = 'gpt-4o-mini'});

  @override
  String get displayName => 'OpenAI GPT-4o';

  @override
  String get providerId => 'openai';

  @override
  bool get isAvailable => _apiKey != null && _apiKey!.isNotEmpty;

  @override
  Set<AICapability> get capabilities => {
    AICapability.chat,
    AICapability.streaming,
    AICapability.embeddings,
    AICapability.toolCalling,
  };

  // ... implementation
}
```

### 3. AI Router

The router decides which provider to use for each request, or falls back to deterministic intelligence.

```dart
/// Routes AI requests to the appropriate provider or falls back to
/// the deterministic intelligence layer.
///
/// Decision flow:
/// 1. If a preferred provider is configured and available, use it
/// 2. If the preferred provider is unavailable, try next available
/// 3. If no provider is available, return deterministic fallback
/// 4. If AI is disabled entirely, always use deterministic fallback
class AIRouter {
  AIRouter({
    required this.deterministicEngine,
    List<AIProvider> providers = const [],
    this.preferredProviderId,
    this.fallbackStrategy = AIFallbackStrategy.deterministic,
  });

  final DailyBriefEngine deterministicEngine;
  final List<AIProvider> providers;
  String? preferredProviderId;
  AIFallbackStrategy fallbackStrategy;

  /// Routes a chat request to the appropriate handler.
  Future<AIResponse> routeChat(AIChatRequest request) async {
    final provider = _selectBestProvider(request.requiredCapabilities);

    if (provider != null) {
      try {
        return await _executeWithProvider(provider, request);
      } on AIProviderException {
        // Provider failed — fall back
        return _executeDeterministic(request);
      }
    }

    return _executeDeterministic(request);
  }

  /// Routes a streaming request.
  Stream<AIChunk> routeChatStreaming(AIChatRequest request) async* {
    final provider = _selectBestProvider(request.requiredCapabilities);

    if (provider != null) {
      try {
        yield* _executeStreamingWithProvider(provider, request);
        return;
      } on AIProviderException {
        // Fall through to deterministic
      }
    }

    yield AIChunk(text: _deterministicResponse(request));
  }

  AIProvider? _selectBestProvider(Set<AICapability> required) {
    // First check preferred provider
    if (preferredProviderId != null) {
      final candidates = providers.where(
        (p) => p.providerId == preferredProviderId && p.isAvailable,
      ).toList();
      if (candidates.isNotEmpty && _hasCapabilities(candidates.first, required)) {
        return candidates.first;
      }
    }

    // Fall back to first available with required capabilities
    final available = providers.where(
      (p) => p.isAvailable && _hasCapabilities(p, required),
    ).toList();
    return available.isNotEmpty ? available.first : null;
  }
}

enum AIFallbackStrategy {
  deterministic,  // Fall back to existing deterministic engines
  nextAvailable,  // Try the next available provider
  error,          // Return an error (user must configure AI)
}
```

### 4. AI Context Builder

Builds rich context from the six platform services for injection into AI prompts.

```dart
/// Builds a structured context snapshot for AI provider consumption.
///
/// The context includes:
/// - User identity and journey stage
/// - Current missions and progress
/// - Active habits and streaks
/// - Learning path and lesson state
/// - Knowledge graph and insights
/// - Timeline and recent activity
/// - Decision history and pending outcomes
/// - Memory graph connections and clusters
///
/// All data is read-only. No mutations.
class AIContextBuilder {
  AIContextBuilder({
    required UserStateService userStateService,
    required AcademyService academyService,
    required HabitService habitService,
    required TimelineService timelineService,
    required KnowledgeService knowledgeService,
    required DecisionIntelligenceService decisionService,
    required MemoryGraphService memoryGraphService,
  });

  /// Builds a complete context snapshot for AI consumption.
  Future<AIContext> buildContext({AIContextScope scope = AIContextScope.full}) async {
    return AIContext(
      scope: scope,
      identity: _buildIdentityContext(),
      missions: _buildMissionContext(),
      habits: _buildHabitContext(),
      learning: _buildLearningContext(),
      knowledge: _buildKnowledgeContext(),
      timeline: _buildTimelineContext(),
      decisions: _buildDecisionContext(),
      memory: _buildMemoryContext(),
      builtAt: DateTime.now(),
    );
  }

  /// Serializes context to a prompt-friendly format.
  String toPromptString(AIContext context) {
    // Format context as structured text for injection into system prompts
  }
}

/// Scopes control how much context is included.
enum AIContextScope {
  mini,     /// Just identity and today's focus
  summary,  /// Key stats and current state
  full,     /// Complete platform context
}
```

### 5. Prompt Library

A centralized registry of system prompts organized by use case.

```dart
/// Centralized registry of system prompts for AI providers.
///
/// Each prompt is versioned and tagged with its required capabilities.
/// Prompts are deterministic templates — no AI generation involved.
class PromptLibrary {
  static final Map<String, PromptTemplate> _templates = {
    'mentor-general': PromptTemplate(
      id: 'mentor-general',
      version: '1.0.0',
      requiredCapabilities: {AICapability.chat},
      systemPrompt: _mentorGeneral,
    ),
    'tutor-lesson': PromptTemplate(
      id: 'tutor-lesson',
      version: '1.0.0',
      requiredCapabilities: {AICapability.chat, AICapability.structured},
      systemPrompt: _tutorLesson,
    ),
    'course-generator': PromptTemplate(
      id: 'course-generator',
      version: '1.0.0',
      requiredCapabilities: {AICapability.structured},
      systemPrompt: _courseGenerator,
    ),
    'quiz-generator': PromptTemplate(
      id: 'quiz-generator',
      version: '1.0.0',
      requiredCapabilities: {AICapability.structured},
      systemPrompt: _quizGenerator,
    ),
  };

  static const String _mentorGeneral = '''
You are an AI Mentor for the Phoenix Platform, a personal growth operating system.

Your role is to help users grow by providing:
1. Clear, actionable advice based on their current platform data
2. Encouragement that acknowledges their progress
3. Specific next steps they can take

IMPORTANT RULES:
- Always base your advice on the user's actual platform data provided in context
- Never make up statistics or achievements
- Be encouraging but honest
- Keep responses concise and actionable
- If you don't have enough data, say so and suggest what to do next

User context:
{{context}}
''';

  static const String _tutorLesson = '''
You are a subject matter tutor for the Phoenix Platform.
Your role is to explain concepts, answer questions, and help the user understand lesson material.

STRUCTURED OUTPUT FORMAT:
```json
{
  "explanation": "clear, thorough explanation",
  "keyPoints": ["point 1", "point 2"],
  "example": "relevant example",
  "followUpQuestion": "question to check understanding"
}
```
''';

  static const String _courseGenerator = '''
You are a course designer for the Phoenix Platform.
Generate structured learning path content based on the user's goals and current knowledge level.
''';

  static const String _quizGenerator = '''
You are a quiz creator for the Phoenix Platform.
Generate quiz questions that test understanding of the given lesson content.
''';

  /// Retrieves a prompt template by ID.
  static PromptTemplate? get(String id) => _templates[id];

  /// Registers a new prompt template at runtime.
  static void register(PromptTemplate template) {
    _templates[template.id] = template;
  }
}

class PromptTemplate {
  const PromptTemplate({
    required this.id,
    required this.version,
    required this.requiredCapabilities,
    required this.systemPrompt,
    this.userPromptTemplate,
    this.maxTokens = 2048,
    this.temperature = 0.7,
  });

  final String id;
  final String version;
  final Set<AICapability> requiredCapabilities;
  final String systemPrompt;
  final String? userPromptTemplate;
  final int maxTokens;
  final double temperature;

  /// Renders the system prompt with given context variables.
  String renderSystem(Map<String, String> variables) {
    var rendered = systemPrompt;
    for (final entry in variables.entries) {
      rendered = rendered.replaceAll('{{${entry.key}}}', entry.value);
    }
    return rendered;
  }

  /// Renders the user prompt template with given variables.
  String? renderUser(Map<String, String> variables) {
    if (userPromptTemplate == null) return null;
    var rendered = userPromptTemplate!;
    for (final entry in variables.entries) {
      rendered = rendered.replaceAll('{{${entry.key}}}', entry.value);
    }
    return rendered;
  }
}
```

### 6. Tool Registry

Allows AI providers to call Phoenix platform functions.

```dart
/// Registry of callable tools that AI providers can invoke.
///
/// This enables AI to perform actions on behalf of users:
/// - Querying platform services for real-time data
/// - Creating/updating missions, habits, goals
/// - Starting lessons, tracking progress
/// - Searching knowledge and memory
class ToolRegistry {
  final Map<String, AITool> _tools = {};

  void register(AITool tool) {
    _tools[tool.id] = tool;
  }

  AITool? get(String id) => _tools[id];

  /// Returns all tools as a list of function declarations for the AI provider.
  List<ToolDeclaration> toDeclarations() {
    return _tools.values.map((t) => t.toDeclaration()).toList();
  }

  /// Executes a tool call from the AI provider.
  Future<AIToolResult> execute(String toolId, Map<String, dynamic> args) async {
    final tool = _tools[toolId];
    if (tool == null) {
      return AIToolResult.error('Tool $toolId not found');
    }
    return tool.execute(args);
  }
}

abstract class AITool {
  String get id;
  String get description;
  Map<String, AIParameter> get parameters;
  Future<AIToolResult> execute(Map<String, dynamic> args);
  ToolDeclaration toDeclaration();
}
```

### 7. Conversation Memory

Persists conversation history for context across sessions.

```dart
/// Manages conversation memory across AI sessions.
///
/// Uses existing StorageService for persistence (no new dependencies).
/// Memory is stored as a structured conversation log with metadata.
class ConversationMemory {
  ConversationMemory({required StorageService storage});

  /// Saves a conversation turn.
  Future<void> saveTurn(ConversationTurn turn);

  /// Loads recent conversation history for context window.
  Future<List<ConversationTurn>> loadHistory({
    int maxTurns = 20,
    Duration maxAge = const Duration(days: 7),
  });

  /// Summarizes old conversation turns for long-term memory.
  Future<ConversationSummary> summarize(String sessionId);

  /// Clears conversation history.
  Future<void> clear();
}

class ConversationTurn {
  final String role;      // 'user' | 'assistant' | 'system'
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
}
```

### 8. Safety Layer

Guards against harmful or inappropriate AI responses.

```dart
/// Safety layer that validates AI inputs and outputs.
///
/// Provides:
/// - Input sanitization (PII detection, prompt injection prevention)
/// - Output validation (content filtering, confidence thresholds)
/// - Rate limiting (prevent abuse)
/// - Offline guard (ensure deterministic fallback is always available)
class AISafetyLayer {
  /// Validates user input before sending to AI provider.
  AISafetyResult validateInput(String input);

  /// Validates AI output before returning to user.
  AISafetyResult validateOutput(String output);

  /// Checks if the request should be rate-limited.
  bool isRateLimited(String userId);

  /// Returns the safety status for a given provider.
  SafetyStatus checkProviderSafety(AIProvider provider);
}
```

### 9. AI Settings

User-accessible settings for AI provider configuration.

```dart
/// User-configurable AI settings.
///
/// Persisted through existing UserSettings model — no new persistence layer.
class AISettings {
  /// Whether AI features are enabled at all.
  final bool enabled;

  /// The preferred AI provider ID.
  final String preferredProvider;

  /// Provider-specific configuration (API keys, model names, etc.).
  final Map<String, ProviderConfig> providerConfigs;

  /// Maximum tokens per response.
  final int maxTokens;

  /// Temperature for chat responses (0.0 = deterministic, 1.0 = creative).
  final double temperature;

  /// Whether the user has been warned about AI limitations.
  final bool hasSeenAIDisclaimer;

  /// Features enabled per provider.
  final Set<AIFeature> enabledFeatures;
}
```

---

## Integration with Existing Architecture

### How AI Services Use the New Layer

The existing `AIMentorService`, `ConversationService`, and `IntelligenceMentorService` will reference the `AIRouter` as an optional dependency:

```dart
class AIMentorService {
  AIMentorService({
    required Repository repository,
    this.aiRouter,  // OPTIONAL — null means deterministic only
  });

  final AIRouter? aiRouter;

  Future<AIResponse> chat(String userMessage) async {
    // Step 1: Build deterministic context (existing flow)
    final context = _contextService.buildContext();

    // Step 2: If AI is available, try AI-enhanced response
    if (aiRouter != null) {
      try {
        return await aiRouter!.routeChat(
          AIChatRequest(
            messages: [AIChatMessage.user(userMessage)],
            context: _buildAIContext(context),
          ),
        );
      } on AIUnavailableException {
        // Fall through to deterministic
      }
    }

    // Step 3: Deterministic fallback (existing flow — unchanged)
    return _buildDeterministicResponse(userMessage, context);
  }
}
```

### Feature Gates

Each AI feature should be gated by availability:

```dart
/// Whether AI-enhanced features are available.
bool get isAIEnabled => aiRouter != null &&
    aiRouter!.providers.any((p) => p.isAvailable) &&
    settings.aiEnabled;
```

---

## File Structure

```
lib/features/ai/
├── providers/
│   ├── ai_provider.dart              # Abstract AIProvider interface
│   ├── openai_provider.dart          # OpenAI implementation
│   ├── claude_provider.dart          # Anthropic Claude implementation
│   ├── gemini_provider.dart          # Google Gemini implementation
│   ├── ollama_provider.dart          # Local Ollama implementation
│   └── lm_studio_provider.dart       # Local LM Studio implementation
├── router/
│   ├── ai_router.dart                # Routes requests to providers
│   └── ai_router_config.dart         # Router configuration
├── context/
│   ├── ai_context_builder.dart       # Builds context for AI prompts
│   └── models/
│       ├── ai_context.dart           # Context model
│       └── ai_context_scope.dart     # Context scope enum
├── prompts/
│   ├── prompt_library.dart           # Central prompt registry
│   └── templates/                    # Individual prompt templates
│       ├── mentor_general.txt
│       ├── tutor_lesson.txt
│       └── course_generator.txt
├── memory/
│   ├── conversation_memory.dart      # Persistent conversation memory
│   └── models/
│       ├── conversation_turn.dart
│       └── conversation_summary.dart
├── tools/
│   ├── tool_registry.dart            # Registry of callable tools
│   ├── tools/
│   │   ├── search_knowledge_tool.dart
│   │   ├── get_mission_tool.dart
│   │   ├── create_habit_tool.dart
│   │   └── ... (one file per tool)
│   └── models/
│       ├── ai_tool.dart              # Tool interface
│       ├── tool_declaration.dart     # Function declaration for API
│       └── tool_result.dart          # Tool execution result
├── safety/
│   ├── ai_safety_layer.dart          # Input/output validation
│   └── models/
│       ├── safety_result.dart
│       └── rate_limiter.dart
├── settings/
│   ├── ai_settings.dart              # User-configurable AI settings
│   └── ai_settings_screen.dart       # Settings UI
└── models/
    ├── ai_provider_response.dart     # Response model
    ├── ai_provider_chunk.dart        # Streaming chunk model
    ├── ai_chat_message.dart          # Chat message for providers
    ├── ai_chat_config.dart           # Chat configuration
    └── ai_feature.dart               # Feature flags
```

---

## Data Flow

### Chat Flow (AI Available)

```
User Message
    │
    ▼
AIMentorService.chat()
    │
    ├──▶ Build context from platform services (UNCHANGED)
    │
    ├──▶ AIRouter.routeChat()
    │       │
    │       ├──▶ AIContextBuilder.buildContext() → Rich AI context
    │       │
    │       ├──▶ PromptLibrary.get('mentor-general') → System prompt
    │       │
    │       ├──▶ _selectBestProvider() → Choose AI provider
    │       │       │
    │       │       ├──▶ OpenAIProvider.chat() (if available)
    │       │       ├──▶ ClaudeProvider.chat() (if preferred)
    │       │       └──▶ LocalLLMProvider.chat() (if offline)
    │       │               │
    │       │               ├──▶ ToolRegistry (if AI calls tools)
    │       │               └──▶ SafetyLayer (validate output)
    │       │
    │       └──▶ Return AIProviderResponse
    │
    └──▶ Return AIResponse (enriched or deterministic)
```

### Chat Flow (AI Unavailable)

```
User Message
    │
    ▼
AIMentorService.chat()
    │
    ├──▶ Build context from platform services (UNCHANGED)
    │
    ├──▶ AIRouter.routeChat() → AIUnavailableException
    │
    └──▶ _buildDeterministicResponse() (UNCHANGED — existing flow)
            │
            └──▶ ConversationEngine.buildResponse()
                    │
                    └──▶ Return deterministic response
```

---

## Configuration

### Environment Variables / Settings

Each provider needs its API key stored in **secure storage** (existing `SecureStorageService`):

```dart
// Secure storage keys
const _openaiKey = 'phx_ai_openai_key';
const _claudeKey = 'phx_ai_claude_key';
const _geminiKey = 'phx_ai_gemini_key';
// Local providers don't need API keys — just host URL
const _ollamaHost = 'phx_ai_ollama_host';  // Default: http://localhost:11434
```

### Provider Selection UI

Users configure their AI provider in a new AI Settings section:

```
Settings → AI
├── Enable AI [Toggle]
├── Preferred Provider [Dropdown]
│   ├── OpenAI (requires API key)
│   ├── Claude (requires API key)
│   └── Local LLM (no API key needed)
├── API Key [Secure text field]
├── Model [Dropdown] (depends on provider)
├── Temperature [Slider]
└── Max Tokens [Slider]
```

---

## Fallback Behavior Matrix

| Scenario | Behavior |
|----------|----------|
| No providers configured | Deterministic only — no AI features |
| Provider unreachable | Try next available, then deterministic |
| Provider returns error | Retry once, then deterministic |
| Network timeout | Deterministic (offline-first) |
| Rate limited | Deterministic until rate limit resets |
| API key invalid | Show error, fall back to deterministic |
| Content safety violation | Return safe default, log for review |

---

## Testing Strategy

### Unit Tests

| Test | Scope |
|------|-------|
| `AIRouter.selectsPreferredProvider()` | Router prioritization |
| `AIRouter.fallsBackToDeterministic()` | Fallback on provider failure |
| `AIContextBuilder.buildsFullContext()` | Context completeness |
| `PromptLibrary.rendersTemplate()` | Template rendering |
| `ToolRegistry.registersAndExecutes()` | Tool execution |
| `ConversationMemory.persistsAndLoads()` | Memory persistence |

### Integration Tests

| Test | Scope |
|------|-------|
| `AIMentorService.withAIProvider()` | Full chat flow with mock provider |
| `AIMentorService.withoutAIProvider()` | Deterministic fallback preserved |
| `ConversationService.withStreaming()` | Streaming response handling |

### Mock Provider

```dart
class MockAIProvider implements AIProvider {
  @override
  String get displayName => 'Mock Provider';

  @override
  bool get isAvailable => true;

  @override
  Set<AICapability> get capabilities => {
    AICapability.chat,
    AICapability.streaming,
    AICapability.toolCalling,
  };

  @override
  Future<AIProviderResponse> chat({...}) async {
    return AIProviderResponse(content: 'Mock response', ...);
  }
}
```

---

## Dependencies

| Package | Purpose | Provider | Required |
|---------|---------|----------|----------|
| `dart_openai` | OpenAI API client | OpenAI | Optional |
| `anthropic_sdk_dart` | Anthropic API client | Claude | Optional |
| `google_generative_ai` | Gemini API client | Gemini | Optional |
| `http` | HTTP client for local LLMs | Ollama/LM Studio | Optional (may already exist) |

All packages are **optional runtime dependencies** — the app compiles and works without them. Each provider package is imported only by its implementation file.

---

## Migration Path

### Phase 1: Foundation (PHX-068.1)
- Create abstract `AIProvider` interface and response models
- Create `AIRouter` with deterministic fallback
- Create `AIContextBuilder` (reuses existing service data)
- Create `PromptLibrary` with initial templates
- Add `AISettings` model and secure storage
- **Result:** Architecture in place, no functional change yet

### Phase 2: First Provider (PHX-068.2)
- Implement `OpenAIProvider` as the first reference implementation
- Wire `AIMentorService.chat()` to use `AIRouter`
- Add streaming support
- **Result:** AI-enhanced mentor responses when OpenAI configured

### Phase 3: Additional Providers (PHX-068.3)
- Implement `ClaudeProvider`
- Implement `GeminiProvider`
- Implement `OllamaProvider` (local LLM)
- Add provider auto-detection
- **Result:** Multi-provider support with user choice

### Phase 4: Tools & Safety (PHX-068.4)
- Implement `ToolRegistry` with initial Phoenix tools
- Implement `AISafetyLayer`
- Implement `ConversationMemory`
- **Result:** AI can query platform data and call actions

### Phase 5: Advanced Features (PHX-068.5)
- AI Tutor (lesson explanations, Q&A)
- Course Generator (learning path creation from goals)
- Quiz Generator (automatic quiz creation)
- AI Settings UI
- **Result:** Full AI-enhanced platform experience

---

## Architecture Rules

1. **AI is always OPTIONAL** — Phoenix must function without any provider
2. **Deterministic layer is the baseline** — AI only enriches, never replaces
3. **No architectural changes** — New components sit beneath existing services
4. **Providers are swappable** — User can change provider at any time
5. **Context is read-only** — AIContextBuilder never mutates platform data
6. **Prompts are deterministic** — No AI-generated prompts (that would create recursion)
7. **Safety first** — All AI outputs validated before reaching the user
8. **Privacy by design** — Local LLM option for sensitive data

---

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Vendor lock-in | Provider abstraction makes switching trivial |
| Cost overruns | Local LLM option, token limits, user-controlled temperature |
| Privacy concerns | Local LLM option, no data leaves device |
| Offline breakage | Deterministic fallback always available |
| Quality degradation | AI enriches only — deterministic baseline is quality floor |
| Latency impact | Streaming support, timeout config, cancellable requests |
| API key security | SecureStorageService for all credentials |

---

## Open Questions

1. **Should tool calling be synchronous or event-driven?**
   - Sync is simpler but blocks; events add complexity but enable progress indicators
   - **Proposal:** Start with sync, add streaming events in Phase 4

2. **How should errors surface to the user?**
   - Provider errors should show a brief non-blocking message
   - The deterministic response should still display
   - **Proposal:** Use existing `PhoenixErrorState` pattern for AI errors

3. **Should the Safety Layer use external or built-in content moderation?**
   - External adds latency/cost; built-in reduces coverage
   - **Proposal:** Built-in keyword/regex filtering first, provider-native moderation as enhancement

4. **How should conversation memory handle context windows?**
   - Providers have different context limits (4K-200K tokens)
   - **Proposal:** Summarize old turns when approaching limit, store summaries as memory

---

## Consequences

### Positive

1. **Vendor independence** — The provider abstraction prevents lock-in to any single AI vendor. Users can switch between OpenAI, Claude, Gemini, and local models without application changes.

2. **Privacy by design** — The local LLM option (Ollama/LM Studio) allows users with sensitive data to run AI entirely on-device with no external API calls.

3. **Deterministic baseline** — The existing intelligence layer remains the quality floor. AI enrichment can only improve responses, never degrade below the deterministic baseline.

4. **Progressive enhancement** — Users can start with zero AI configuration (deterministic only) and enable AI features incrementally as their needs grow.

5. **Frozen architecture preserved** — All new components sit beneath existing services. No changes to Repository, Engine, or Service layers.

### Negative

1. **Increased code complexity** — 4+ provider implementations, each with its own API semantics, error handling, and rate limiting. Estimated: ~500 lines per provider.

2. **Package dependency bloat** — Each provider adds an optional package dependency. Even though optional, they increase the Dart analysis surface and CI pipeline complexity.

3. **Maintenance burden** — Provider APIs evolve independently (e.g., OpenAI model deprecations, Anthropic SDK breaking changes). Each provider requires dedicated maintenance.

4. **Cost variability** — AI API costs vary by provider, model, and usage pattern. Users may encounter unexpected costs if not properly configured with token limits.

5. **Testing complexity** — The router's fallback chain (preferred → next available → deterministic) creates 3^n combinatorial test scenarios for n providers.

### Trade-offs

| Decision | Trade-off |
|----------|-----------|
| AI is optional | No AI features without configuration, but offline/power users unaffected |
| Deterministic fallback | Users never see "AI unavailable" errors, but may not realize AI is offline |
| Provider abstraction | Clean separation, but ~500 extra lines per provider |
| Context built from 6 services | Rich AI prompts, but 100ms+ overhead per request |
| Tool calling with confirmation | Safe mutations, but adds UX friction |
| Secure storage for API keys | Protected credentials, but requires key re-entry on app reinstall |

---

## Streaming Integration Design

### Provider Stream Contract

```dart
Stream<AIProviderChunk> chatStreaming({...});

class AIProviderChunk {
  final String text;            // Partial token text
  final bool isComplete;        // True for the final chunk
  final String? finishReason;   // 'stop', 'length', 'error', or null
  final int? inputTokens;       // Input token count (final chunk only)
  final int? outputTokens;      // Output token count (final chunk only)
}
```

### UI Integration with ChatConversation

The existing `ChatConversation` widget (in `lib/features/ai/widgets/chat_conversation.dart`) displays messages from a `List<ChatMessage>`. To support streaming:

1. **Streaming message placeholder** — When streaming starts, add a placeholder `ChatMessage(role: 'assistant', content: '', isLoading: true)` to the messages list.
2. **Incremental content updates** — As `AIProviderChunk` objects arrive, append their `text` to the placeholder message's content. The existing `ListView.builder` auto-scrolls to bottom on message count change.
3. **Stream-complete signal** — On `isComplete: true`, mark the message as `isLoading: false`. The existing typing indicator stops.
4. **Error handling** — If the stream errors, the placeholder message gets `content: '[Error] Response interrupted.'` and the `ChatConversation` error banner displays with a retry option.

### Controller Pattern

```dart
class AIStreamController {
  final StreamController<AIProviderChunk> _controller;
  String _accumulated = '';

  Stream<AIProviderChunk> get stream => _controller.stream;

  void append(AIProviderChunk chunk) {
    _accumulated += chunk.text;
    _controller.add(chunk);
  }

  void complete(String finishReason) {
    _controller.add(AIProviderChunk(
      text: '',
      isComplete: true,
      finishReason: finishReason,
    ));
    _controller.close();
  }

  void error(Object e) {
    _controller.addError(e);
    _controller.close();
  }

  String get accumulated => _accumulated;
}
```

---

## Tool Calling Authorization

All tools that mutate user data require explicit user confirmation before execution.

### Authorization Flow

```
AI Provider requests tool call
        │
        ▼
AIRouter captures tool declaration
        │
        ▼
Tool is classified as READ or WRITE
        │
        ├── READ (query/search)
        │       └── Execute immediately, return results to AI
        │
        └── WRITE (create/update/delete)
                │
                ▼
        Show confirmation dialog to user:
        "Phoenix AI wants to create a new habit:
         • Morning Run — Daily — 1 time per day
         [Allow] [Deny] [Always Allow for this session]"
                │
                ├── Allow → Execute tool, return result to AI
                ├── Deny → Return "Action denied by user" to AI
                └── Always Allow → Cache permission for session
```

### Tool Classification

```dart
enum AIToolAccess { read, write }

abstract class AITool {
  String get id;
  String get description;
  AIToolAccess get access;  // READ or WRITE
  Map<String, AIParameter> get parameters;
  Future<AIToolResult> execute(Map<String, dynamic> args);
  ToolDeclaration toDeclaration();
}
```

### Initial Tool List

| Tool | Access | Phase | Description |
|------|--------|-------|-------------|
| `search_knowledge` | READ | 4 | Search knowledge graph nodes |
| `get_missions` | READ | 4 | Get current active missions |
| `get_habits` | READ | 4 | Get habit data and stats |
| `get_lessons` | READ | 4 | Get current lessons and paths |
| `get_timeline` | READ | 4 | Get timeline events |
| `create_habit` | WRITE | 4 | Create a new habit |
| `create_mission` | WRITE | 5 | Create a new mission |
| `start_lesson` | WRITE | 5 | Start/resume a lesson |
| `track_progress` | WRITE | 5 | Record progress on an activity |

---

## Appendices

### A. Existing Deterministic Intelligence Architecture

For reference, the existing deterministic layer (PHX-063) that must be preserved:

```
PhoenixAIService
├── DailyBriefEngine — collects/scored/ranked recommendations
│   ├── Academy (resume lesson, next lesson, path recommendations)
│   ├── Habits (insights, pending completions, streaks)
│   ├── Timeline (today's events, milestones, weekly summary)
│   ├── Knowledge (insights, domain coverage, gaps)
│   ├── Decisions (follow-ups, reflections, outcomes)
│   └── Memory Graph (insights, entity stats)
│
├── CrossFeatureReasoner — cross-domain patterns
│   ├── Learning × Habit synergy
│   ├── Decision × Knowledge patterns
│   ├── Timeline × Decision urgency
│   └── Graph × Timeline connections
│
├── ConversationEngine — intent detection
│   ├── 13 intent categories with keyword matching
│   ├── Context-aware follow-up suggestions
│   └── Response templates for each intent
│
└── ExplanationEngine — explainable recommendations
    ├── Reason chains with evidence
    ├── Confidence scoring
    └── Cross-domain signal correlation
```

### B. Existing Service Dependencies

```
AIMentorService depends on: MissionService, ProgressService, KnowledgeDNAService,
    PortfolioService, ResumeService, CareerService, InterviewService,
    RecommendationService, OmniRouteService, ContextService

ConversationService depends on: DailyBriefEngine, CrossFeatureReasoner,
    ExplanationEngine, AcademyService, HabitService, TimelineService,
    KnowledgeService, DecisionService, MemoryGraphService

IntelligenceMentorService depends on: PhoenixAIService, AcademyService,
    HabitService, TimelineService, KnowledgeService, DecisionService,
    MemoryGraphService
```

### C. Existing Bootstrap Initialization Order

```
1. StorageService.init()
2. AuthService.init()
3. UserStateService.init()
4. VoiceService.initialize()
5. AcademyService (with AI Mentor)
6. DecisionIntelligenceService
7. TimelineService
8. HabitService
9. MemoryGraphService
10. KnowledgeService
11. Seed graphs in parallel (non-fatal)
```

AI Provider initialization should be added at step 3.5 (after auth, before feature services):

```
3.5. AISettings.loadFromStorage()
3.6. AIProviderFactory.createFromSettings()
3.7. AIRouter.initialize(providers)
```

---

*End of ADR-004*
