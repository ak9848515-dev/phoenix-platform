# PHX-068 — Intelligence Engine Platform

**Release v2.6.0**

**Date:** July 15, 2026

**Branch:** `release/phoenix-v2`

---

## Overview

PHX-068 establishes the Phoenix Intelligence Engine Platform — a complete deterministic intelligence layer that powers every user-facing feature. Eight independent engines form a pipeline from identity through to AI capability routing.

Every engine is:

- **Deterministic** — same inputs always produce same outputs
- **Offline-first** — all data persisted via SharedPreferences
- **Observer-pattern** — engines auto-recalculate when dependencies change
- **Cached** — snapshots load instantly on app restart
- **AI-free** — no LLM, no embeddings, no vector databases

---

## Architecture

```
IdentityEngine
     ↓
GrowthIndexEngine
     ↓
MissionIntelligenceEngine
     ↓
RecommendationEngine
     ↓
DailyBriefEngine
     ↓
ContinueJourneyEngine
     ↓
LongTermMemoryEngine
     ↓
AICapabilityRouter → [ Mock Adapters ]
```

### Engine Dependency Chain

```
User Data Layer
     ↓
IdentityEngine           — Who is the user? Who are they becoming?
     ↓
GrowthIndexEngine       — How much have they grown across all domains?
     ↓
MissionIntelligenceEngine — What should they do next? (5 rules)
     ↓
RecommendationEngine    — How should it be presented? (4 rules)
     ↓
DailyBriefEngine        — What should they do today? (scheduling + insights)
     ↓
ContinueJourneyEngine   — What were they doing? Resume prioritisation
     ↓
LongTermMemoryEngine    — What should Phoenix remember? (graph + search)
     ↓
AICapabilityRouter      — Which AI provider should handle this request?
```

---

## Engine Details

### 1. IdentityEngine

| Aspect | Detail |
|--------|--------|
| **Files** | 6 (3 models, 1 engine, 1 repository, 1 interface) |
| **Tests** | From PHX-068.1 |
| **Purpose** | Single source of truth for user identity, goals, experience, preferences |
| **Consumers** | All downstream engines + Dashboard |

### 2. GrowthIndexEngine

| Aspect | Detail |
|--------|--------|
| **Files** | 9 (5 models/calculators, 1 engine, 1 repository, 1 interface) |
| **Tests** | From PHX-068.2 |
| **Purpose** | Calculate progress across knowledge, skills, career, habits, interview readiness, mission completion, portfolio, learning consistency |
| **Trends** | Improving, Stable, Declining per dimension |

### 3. MissionIntelligenceEngine

| Aspect | Detail |
|--------|--------|
| **Files** | 10 (6 models, 1 rules, 1 engine, 1 repository, 1 interface) |
| **Tests** | From PHX-068.3 |
| **Purpose** | Determines what the user should do next using 5 mission rules (LowKnowledge, EmptyPortfolio, CareerUndefined, WeakLearningConsistency, LowInterviewReadiness) |
| **Output** | Top mission + 3 alternatives + rejected rules + confidence scores |

### 4. RecommendationEngine

| Aspect | Detail |
|--------|--------|
| **Files** | 11 (7 models, 1 rules, 1 engine, 1 repository, 1 interface) |
| **Tests** | From PHX-068.4 |
| **Purpose** | Transforms mission intelligence into actionable, explainable recommendations with priority, urgency, and estimated benefit |
| **Output** | Primary + 5 ranked alternatives + explanation templates |

### 5. DailyBriefEngine

| Aspect | Detail |
|--------|--------|
| **Files** | 12 (8 models, 1 engine, 1 repository, 1 interface) |
| **Tests** | From PHX-068.5 |
| **Purpose** | Creates the user's daily action plan: focus, 6 task categories, 4 insight types, morning/afternoon/evening/flexible scheduling |
| **Output** | DailyBriefSnapshot with plan + insights + progress + history |

### 6. ContinueJourneyEngine

| Aspect | Detail |
|--------|--------|
| **Files** | 9 (5 models, 1 engine, 1 repository, 1 interface) |
| **Tests** | From PHX-068.6 |
| **Purpose** | Restores the user's journey intelligently — determines current journey, resume point, and prioritises continuation candidates |
| **Resume Types** | lesson, mission, project, interview, habit, assessment, learningPath |

### 7. LongTermMemoryEngine

| Aspect | Detail |
|--------|--------|
| **Files** | 12 (8 models, 1 engine, 1 repository, 1 interface) |
| **Tests** | From PHX-068.8 |
| **Purpose** | Stores and retrieves durable user knowledge: facts, decisions, achievements, preferences. Graph-based relationships with keyword + tag + category search |
| **Categories** | 14 (identity, goals, career, learning, projects, skills, achievements, habits, interviews, portfolio, decisions, preferences, milestones, custom) |

### 8. AICapabilityRouter

| Aspect | Detail |
|--------|--------|
| **Files** | 17 (7 models, 6 mock adapters, 1 interface, 1 registry, 1 router) |
| **Tests** | From PHX-068.7 |
| **Purpose** | Routes AI capabilities to the best provider with fallback logic. Phoenix never talks to AI providers directly |
| **Providers** | Gemini, DeepSeek, OpenAI, Claude, Ollama (offline), OpenRouter (fallback) |
| **Capabilities** | 15 (coding, learning, career, resume, interview, research, writing, reasoning, planning, image, vision, speech, translation, summarization, generalChat) |
| **Routing** | Preferred → Offline → Default mapping → Fallback chain → Ultimate fallback |

---

## Release Metrics

### Quality Gates

| Gate | Result |
|------|--------|
| `flutter analyze` | **0 issues** ✅ |
| `flutter test` | **801 passing** ✅ |
| No dead code | ✅ |
| No TODO placeholders | ✅ |
| No deprecated APIs | ✅ |
| Architecture frozen | ✅ (no repository/engine/service redesigns) |

### Test Distribution

| Component | Tests |
|-----------|-------|
| Identity Engine | ~30 |
| Growth Index Engine | ~25 |
| Mission Intelligence Engine | ~17 |
| Recommendation Engine | ~16 |
| Daily Brief Engine | ~13 |
| Continue Journey Engine | ~16 |
| Long-Term Memory Engine | ~20 |
| AI Capability Router | ~20 |
| Pre-existing platform tests | ~644 |
| **Total** | **801** |

### File Counts

| Engine | Files |
|--------|-------|
| Identity Engine | 6 |
| Growth Index Engine | 9 |
| Mission Intelligence Engine | 10 |
| Recommendation Engine | 11 |
| Daily Brief Engine | 12 |
| Continue Journey Engine | 9 |
| Long-Term Memory Engine | 12 |
| AI Capability Router | 17 |
| **Total new files** | **86** |

### Total Engines Created

| Status | Engine |
|--------|--------|
| ✅ | IdentityEngine |
| ✅ | GrowthIndexEngine |
| ✅ | MissionIntelligenceEngine |
| ✅ | RecommendationEngine |
| ✅ | DailyBriefEngine |
| ✅ | ContinueJourneyEngine |
| ✅ | LongTermMemoryEngine |
| ✅ | AICapabilityRouter |

---

## Architecture Compliance

- **Repository layer**: Frozen — no modifications
- **Engine layer**: Frozen — no redesign, additions only
- **Service layer**: Frozen — no modifications
- **UI layer**: Frozen — no new screens
- **AI layer**: Mock-only — no real API calls, no networking, no API keys
- **Offline-first**: All engines persist via SharedPreferences
- **No architecture violations**: Verified by code review

---

## Known Limitations

1. **Dashboard integration** — Engines are wired into `AppBootstrap` but no dashboard screen reads from the new engine snapshots yet. Dashboard still computes directly from services.
2. **Observer pattern gaps** — Some engines subscribe only to engine-level listeners; fine-grained triggers (lesson completed, project completed) aren't directly wired.
3. **Memory engine observer inert** — `_onEngineChanged` fires but `_buildSnapshot` doesn't consume Identity/Growth/Mission data. Subscriptions have no runtime effect currently.
4. **AI CapabilityRouter is mock-only** — No real API credentials, networking, or provider SDKs are integrated. Ready for real adapter implementations.
5. **No `CapabilityStrategy` model** — AI Router spec called for a separate CapabilityStrategy; routing logic is embedded in the router itself.

---

## Technical Debt

| Priority | Item |
|----------|------|
| P2 | Wire engines into Dashboard CommandCenterScreen |
| P2 | Auto-create MemoryEngine entries from engine change events |
| P2 | Implement real AI provider adapters (API keys + networking) |
| P3 | Create CapabilityStrategy as pluggable routing abstraction |
| P3 | Add fine-grained observer triggers for lesson/project/habit events |

---

## Next Epic

# PHX-069 — Content Generation Platform

The next phase focuses on:

- **Course Generator** — Generate learning content from academy paths
- **Project Generator** — Auto-create projects from career goals
- **Portfolio Generator** — Build portfolio entries from achievements
- **Resume Generator** — Generate resumes from portfolio + career data
- **Interview Question Generator** — Generate practice questions from skill gaps
- **Mission Generator v2** — Enhanced mission generation using all 8 engines

All generators will consume intelligence engines via the existing pipeline.
No architecture redesign required.

---

## Credits

- **Sprint**: PHX-068.1 through PHX-068.9
- **Engines**: 8 deterministic intelligence engines
- **Total new files**: 86
- **Test growth**: 644 → 801 (+157 tests)
- **Architecture**: Phoenix Intelligence Engine Platform
