# Phoenix System Architecture

Version: 1.0

Status: Active

---

# Overview

Phoenix is a Personal Growth Operating System.

The platform helps users transform from their current state to their desired identity through personalized journeys, missions, knowledge, decision making, and AI assistance.

Phoenix follows a layered architecture.

---

# Architecture Layers

```
Presentation Layer
        │
        ▼
Feature Layer
        │
        ▼
Service Layer
        │
        ▼
Repository Layer
        │
        ▼
Storage Layer
        │
        ▼
Phoenix Context
        │
        ▼
Decision Engine
        │
        ▼
OmniRoute
        │
        ▼
AI Providers
```

---

# Phoenix Core

Phoenix Core is responsible for platform capabilities.

Core modules never contain career-specific logic.

Core includes:

- Repository
- Storage
- Phoenix Context
- Decision Engine
- OmniRoute
- Authentication (Future)
- Sync (Future)
- Plugin Manager (Future)

---

# Feature Modules

Each feature is isolated.

Current modules:

- Dashboard
- Academy
- Identity
- Journey
- Mission
- Knowledge DNA
- Progress
- Memory
- Recommendation
- Daily Focus
- Decision
- Career

Each module contains:

```
feature/

models/

services/

presentation/

widgets/
```

---

# Repository Layer

Purpose:

Separate business logic from data sources.

Current implementation:

Repository

↓

SampleRepository

↓

LocalRepository

↓

StorageService

Future:

CloudRepository

CachedRepository

RemoteRepository

---

# Storage Layer

Current:

SharedPreferences

Future:

Hive

Isar

SQLite

Cloud

Storage must always remain behind StorageService.

---

# Phoenix Context

PhoenixContext represents the complete user state.

Contains:

- Identity
- Journey
- Current Stage
- Mission Progress
- Knowledge DNA
- Progress
- Memory
- Career
- Decision
- User Settings
- Generated Timestamp

AI never reads directly from feature services.

AI only receives PhoenixContext.

---

# Decision Engine

Purpose:

Determine the user's next highest-impact action.

Consumes:

Identity

Journey

Mission

Knowledge

Progress

Memory

Career

Recommendation

Produces:

Decision

---

# OmniRoute

Purpose:

Provider-independent AI routing.

Consumes:

PhoenixContext

+

AITask

Produces:

AIResponse

Responsibilities:

- Provider Selection
- Prompt Building
- Response Normalization
- Cost Tracking
- Retry Logic
- Fallback Strategy

---

# AI Providers

Supported:

- OpenAI
- Claude
- Gemini
- DeepSeek
- Local LLM

Providers are interchangeable.

Phoenix Core never depends on one provider.

---

# Plugin Architecture (Future)

Future identities become plugins.

Example:

Flutter Developer

SAP Consultant

Content Creator

Business Owner

Doctor

Lawyer

Finance

Health

Plugins contribute:

Identity

Journey

Missions

Knowledge

Career

AI Prompts

The Core remains unchanged.

---

# Data Flow

```
Identity

↓

Journey

↓

Mission

↓

Knowledge DNA

↓

Progress

↓

Memory

↓

Recommendation

↓

Decision

↓

Phoenix Context

↓

OmniRoute

↓

AI Provider

↓

Response

↓

User
```

---

# Engineering Principles

- Feature-first architecture
- Repository pattern
- Stateless presentation
- Constructor injection
- Immutable models
- Separation of concerns
- AI provider independence
- Plugin-first design

---

# Long-Term Goals

Phoenix should support:

- Unlimited careers
- Unlimited plugins
- Multiple AI providers
- Local-first architecture
- Cloud synchronization
- Enterprise deployment

without changing Phoenix Core.

---

# Rule

Every new feature must answer:

Does this strengthen Phoenix Core?

or

Is this a Plugin capability?

Nothing should exist outside those two categories.