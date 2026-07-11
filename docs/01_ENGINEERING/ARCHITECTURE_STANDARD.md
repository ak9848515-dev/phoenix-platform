# Phoenix Architecture Standard

**Document ID:** PES-002

**Version:** 1.0.0

**Status:** Approved

**Owner:** Chief Software Architect

---

# 1. Purpose

This document defines the architectural rules that govern the Phoenix Platform.

It specifies how the application is structured, how modules interact, dependency rules, and architectural boundaries.

This document supplements `MASTER_CONTEXT.md` by defining implementation-level architecture.

---

# 2. Architecture Philosophy

Phoenix follows these principles:

* Modular Architecture
* Feature-first organization
* Separation of Concerns
* Clean Layering
* Explicit Dependencies
* Reusable Components
* Low Coupling
* High Cohesion
* Incremental Evolution

---

# 3. Architecture Layers

```text
Presentation
      │
      ▼
Application
      │
      ▼
Domain
      │
      ▼
Infrastructure
```

Each layer has a single responsibility.

Dependencies only move downward.

---

# 4. Folder Responsibilities

## core/

Application-wide infrastructure.

Contains:

* routes
* theme
* configuration
* shared utilities

Must never contain feature-specific business logic.

---

## features/

Each feature owns its UI.

Example:

```text
features/
    dashboard/
    academy/
    mission_center/
    knowledge_dna/
```

Each feature should be independently understandable.

---

## shared/

Reusable UI and utilities.

Examples:

* cards
* buttons
* dialogs
* common widgets

Shared code must never depend on a feature.

---

## services/

Integration layer.

Examples:

* APIs
* Local storage
* AI services
* Authentication

Services must never contain UI.

---

## models/

Shared immutable data models.

Feature-specific models belong inside their respective feature.

---

# 5. Dependency Rules

Allowed:

```text
Presentation
    ↓
Shared
    ↓
Services
    ↓
Models
```

Forbidden:

* Feature A importing Feature B UI
* Services importing Widgets
* Models importing Flutter UI
* Shared importing Feature modules

---

# 6. Feature Isolation

Every feature must own:

* Screens
* Widgets
* Models (feature-specific)
* Helpers

Features communicate only through:

* Routes
* Services
* Shared models

---

# 7. Routing Architecture

Phoenix uses:

* MaterialApp
* AppRoutes
* RouteGenerator

Current routing is centralized.

Do not introduce:

* MaterialApp.router
* GoRouter
* AutoRoute
* Beamer
* Navigator 2.0

without explicit architectural approval.

---

# 8. Widget Hierarchy

Preferred structure:

```text
Screen
    │
    ├── Sections
    │
    ├── Cards
    │
    ├── Components
    │
    └── Shared Widgets
```

Large screens should be composed from smaller widgets.

---

# 9. State Management

Current policy:

Presentation-first architecture.

No global state-management framework.

Do not introduce:

* Provider
* Riverpod
* Bloc
* GetX
* MobX

without an Architecture Decision Record (ADR).

---

# 10. Theme Architecture

Theme values must come from the centralized theme system.

Avoid hardcoded:

* colors
* spacing
* typography
* radius

Material 3 is the default design system.

---

# 11. Shared Component Policy

Before creating a widget:

1. Search shared/.
2. Search feature widgets.
3. Reuse if possible.

Only create a new shared widget if it has a clear reuse case.

---

# 12. Performance Principles

Prefer:

* const constructors
* StatelessWidget where possible
* Widget composition
* Lazy building
* Immutable models

Avoid:

* unnecessary rebuilds
* deep widget trees
* duplicated UI

---

# 13. Error Handling

UI should display errors.

Services should handle integration failures.

Business rules should not be embedded in widgets.

---

# 14. Future Expansion

Architecture must support:

* Authentication
* AI Router
* Plugin System
* Team Workspaces
* Offline Mode
* Sync
* Analytics

Future additions must extend the architecture rather than replace it.

---

# 15. Architectural Constraints

Implementation engineers must not:

* redesign folder structure
* move modules across layers
* introduce new frameworks
* bypass shared components
* duplicate business logic

---

# 16. Architecture Review Checklist

Every feature review verifies:

* Layer separation
* Dependency direction
* Feature isolation
* Widget composition
* Shared component usage
* Theme consistency
* Route consistency
* Scalability

---

# 17. Architecture Decision Records (ADR)

Major architectural changes require an ADR.

Each ADR must include:

* ID
* Title
* Context
* Decision
* Consequences
* Status
* Date

No architectural change is complete without an ADR.

---

# 18. Revision History

| Version | Description                   |
| ------- | ----------------------------- |
| 1.0.0   | Initial Architecture Standard |
