# Phoenix OS Architecture

**Version:** 2.0
**Status:** Release Candidate
**Last Updated:** PHX-083

---

# Architecture Overview

Phoenix follows a strict layered architecture:

```
Services → Engines → Snapshots → Widgets
```

Every layer has a single responsibility. Data flows downward through repositories and engines, then upward through snapshots to widgets. Business logic never exists in widgets.

---

# Layer Responsibilities

## 1. Repository Layer

**Purpose:** Abstract data access and persistence behind an interface.

**Rules:**
- Every data source has a repository interface
- Local implementations use SharedPreferences
- Cloud implementations use Firestore
- Engines never access storage directly
- Widgets never access repositories directly

**Current Implementations:**
- `DailyBriefRepositoryInterface` → `LocalDailyBriefRepository`
- `CareerRepositoryInterface` → `LocalCareerRepository`
- `PortfolioRepositoryInterface` → `LocalPortfolioRepository`
- `MemoryRepositoryInterface` → `LocalMemoryRepository`
- `IdentityRepositoryInterface` → `LocalIdentityRepository`
- `GrowthRepositoryInterface` → `LocalGrowthRepository`
- `MissionIntelligenceRepositoryInterface` → `LocalMissionIntelligenceRepository`
- `RecommendationRepositoryInterface` → `LocalRecommendationRepository`
- `AchievementRepositoryInterface` → `LocalAchievementRepository`
- `InterviewIntelligenceRepositoryInterface` → `LocalInterviewIntelligenceRepository`
- `OpportunityIntelligenceRepositoryInterface` → `LocalOpportunityIntelligenceRepository`
- `JourneyRepositoryInterface` → `LocalJourneyRepository`

---

## 2. Engine Layer

**Purpose:** Business logic, intelligence, scoring, and decision-making.

**Rules:**
- Engines produce immutable **Snapshots**
- Engines consume from repositories and other engines
- Engines extend `ChangeNotifier` and notify listeners on state change
- Engines are deterministic — same inputs produce same outputs
- Engines never depend on widgets

**Engine Architecture Pattern:**
```dart
class SomeEngine extends ChangeNotifier {
  SomeEngine({required this.repository, ...});

  final RepositoryInterface repository;
  SomeSnapshot? _snapshot;

  SomeSnapshot? get snapshot => _snapshot;

  Future<void> init() async {
    _snapshot = await repository.load();
    registerEngineListeners();
    notifyListeners();
  }

  Future<void> rebuild() async {
    _snapshot = _buildSnapshot();
    await repository.save(_snapshot!);
    notifyListeners();
  }
}
```

**All Engines:**

| Engine | Snapshot | Purpose |
|--------|----------|---------|
| IdentityEngine | IdentitySnapshot | User identity, goals, preferences |
| GrowthIndexEngine | GrowthSnapshot | 9-dimension growth measurement |
| MissionIntelligenceEngine | MissionSnapshot | What to do next |
| RecommendationEngine | RecommendationSnapshot | How to present recommendations |
| DailyBriefEngine | DailyBriefSnapshot | Daily plan orchestration |
| ContinueJourneyEngine | JourneySnapshot | Resume interrupted journeys |
| MemoryEngine | MemorySnapshot | Durable knowledge storage |
| DecisionEngine | DecisionSnapshot | Highest-value action selection |
| CareerEngine | CareerSnapshot | Career readiness, goals |
| PortfolioEngine | PortfolioSnapshot | Project portfolio |
| KnowledgeEngine | KnowledgeSnapshot | Skills and knowledge profile |
| AchievementEngine | AchievementSnapshot | Gamification progress |
| ResumeIntelligenceEngine | ResumeSnapshot | Resume optimization |
| InterviewIntelligenceEngine | InterviewSnapshot | Interview readiness |
| OpportunityIntelligenceEngine | OpportunitySnapshot | Opportunity matching |
| NotificationEngine | NotificationSnapshot | Notification generation |
| SettingsEngine | SettingsSnapshot | App settings |

---

## 3. Snapshot Layer

**Purpose:** Immutable, serializable state containers for widget consumption.

**Rules:**
- All fields are `final`
- Constructors are `const`
- No methods with side effects
- `toString()` for debugging
- Produced by engines, consumed by widgets

---

## 4. Widget Layer

**Purpose:** Presentation only — rendering snapshots as UI.

**Rules:**
- NO business logic
- NO data access
- NO engine manipulation
- Read snapshots via `AppBootstrap.maybeXxx`
- Call engine methods (never repository methods)
- Use shared widgets for consistency

---

# AI Pipeline

The AI Pipeline is LOCKED. Every AI request flows through an unbroken chain:

```
Feature
  ↓ (request)
AI Context Engine
  ↓ (context snapshot)
Prompt Builder
  ↓ (prompt specification)
AI Capability Router
  ↓ (capability + provider route)
Provider Adapter (Gemini / OpenRouter / etc.)
  ↓ (raw response)
AI Response Gateway
  ↓ (validated domain map)
Feature / Engine
```

## Pipeline Components

### AI Context Engine
Assembles a complete context snapshot from all intelligence engines:
- Identity, Growth, Mission, Career, Portfolio, Knowledge, Journey, Memory, Recommendations, Achievements, Daily Brief, Settings

### Prompt Builder
Transforms context snapshots into provider-neutral prompt specifications:
- Selects template from registry
- Extracts focused context via `ContextBuilders`
- Injects context into template
- Returns `PromptSpecification` (no provider formatting)

### AI Capability Router
Routes capabilities to the best available provider:
- 15 capabilities → 6 providers
- 5 routing strategies (preferred, offline, default, fallback chain, ultimate)
- Fallback logic with retry
- Offline-first preference

### Provider Adapters
Each adapter implements `AIProviderInterface`:
- `GeminiAdapter` — Production (real HTTP calls, API key, retry, timeout)
- `MockGeminiAdapter` — Test fallback
- `MockDeepSeekAdapter`, `MockOpenAIAdapter`, `MockClaudeAdapter`, `MockOllamaAdapter`, `MockOpenRouterAdapter` — Development/testing

### AI Response Gateway
Validates and normalizes raw provider responses:
- JSON parsing
- Schema validation against registered schemas
- Field-level validation (type, range, enum, length)
- Snake_case → camelCase normalization
- Error classification (retryable vs non-retryable)

---

# Synchronization Pipeline

```
Local Engine
  ↓ (change event)
FirestoreSyncAdapter
  ↓ (serialize)
Firebase Firestore
  ↓ (conflict resolution)
Local Engine (confirmed)
```

**Sync Architecture:**
- Offline-first: local writes always succeed immediately
- Background sync: changes pushed when connectivity is available
- Conflict resolution: last-write-wins with timestamp tracking
- Incremental: only changed data is synced
- Diagnostic: sync status, pending queue, last sync time

---

# Decision Pipeline

```
All Intelligence Engines
  ↓ (snapshots)
DecisionIntelligenceOrchestrator
  ↓ (evaluates all recommendations)
Scored Actions
  ↓ (ranking)
Next Best Action → Dashboard → Daily Journey
```

**Scoring Factors:**
| Factor | Weight |
|--------|--------|
| Career Impact | High |
| Learning Dependency | Medium |
| Deadline | High |
| Difficulty | Low |
| ROI | Medium |
| Skill Gap | Medium |
| Momentum | Low |
| Recent Activity | Medium |
| User Goals | High |

---

# Cache Architecture

```
Engine
  ↓ (cache write)
CacheService (in-memory, TTL-based)
  ↓ (cache read)
Consumer (Engine, Widget)
```

**Cache Domains with TTL:**
| Domain | TTL | Purpose |
|--------|-----|---------|
| journey | 5 min | Daily Brief, Daily Journey |
| portfolio | 10 min | Portfolio Intelligence |
| career | 10 min | Career Intelligence |
| interview | 5 min | Interview Intelligence |
| opportunity | 10 min | Opportunity Intelligence |
| knowledge | 15 min | Knowledge Engine |
| memory | 15 min | Memory Engine |
| review | 10 min | Review Engine |
| notification | 2 min | Notification Engine |
| identity | 20 min | Identity Engine |
| sync | 30 sec | Sync Coordinator |
| academy | 10 min | Academy Content |
| habits | 5 min | Habit Engine |
| progress | 10 min | Progress Engine |
| recommendations | 5 min | Recommendation Engine |

---

# Authentication Architecture

```
App Launch
  ↓
Firebase Authentication
  ↓
Session Restoration (Secure Storage)
  ↓
Identity Engine
  ↓
Daily Journey (first experience) or Dashboard (returning)
```

**Auth Methods:**
- Email/Password
- Google Sign-In (via Firebase)
- Anonymous (offline-first fallback)

**Session:**
- Stored in `flutter_secure_storage`
- Auto-restored on cold start
- Silent refresh on token expiry

---

# Architecture Rules (MANDATORY)

1. **Architecture is LOCKED.** No redesign permitted.
2. **Navigation is LOCKED.** No tab/route architecture changes.
3. **AI Pipeline is LOCKED.** Context → Prompt → Router → Gateway.
4. **Services → Engines → Snapshots → Widgets** is mandatory.
5. **No business logic in widgets.** Ever.
6. **No duplicate engines.** Each domain has exactly one engine.
7. **No duplicate models.** Reuse existing models across features.
8. **No duplicate repositories.** One repository per data source.
9. **Engines never access storage directly.** Use repositories.
10. **Widgets never access repositories directly.** Use engines via snapshots.
11. **AI calls always go through the router.** Never direct provider calls.
12. **Every PR must pass:** `flutter analyze`, `flutter test`, `flutter build apk --release`, `flutter build appbundle --release`.
