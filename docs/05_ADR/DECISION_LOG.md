# Phoenix Decision Log

**Project:** Phoenix Platform

**Purpose:** Record all major architectural, product, and engineering decisions made throughout the lifecycle of Phoenix.

---

# Decision Format

Every decision should include:

- Date
- ID
- Category
- Decision
- Reason
- Alternatives Considered
- Impact
- Status

---

# Decisions

---

## DEC-001

**Date:** 2026-07-12

**Category:** Architecture

### Decision

Phoenix adopts a modular feature-based architecture.

### Reason

Separate features into independent modules to improve maintainability,
testability, and scalability.

### Alternatives Considered

- Feature folders
- Layer-first architecture

### Impact

All future features must follow the modular structure.

### Status

✅ Accepted

---

## DEC-002

**Date:** 2026-07-12

**Category:** Product

### Decision

Phoenix is an Identity-first platform rather than a Course-first platform.

### Reason

Users pursue outcomes, not courses.

Identity creates long-term engagement and allows personalized journeys.

### Alternatives Considered

Traditional learning platform.

### Impact

Identity became the entry point for Journey, Mission, Recommendation,
Career, and Decision systems.

### Status

✅ Accepted

---

## DEC-003

**Date:** 2026-07-12

**Category:** Architecture

### Decision

Journey drives Mission progression.

### Reason

Users should progress through a structured roadmap instead of isolated lessons.

### Alternatives Considered

Independent mission system.

### Impact

Mission Engine depends on Journey state.

### Status

✅ Accepted

---

## DEC-004

**Date:** 2026-07-12

**Category:** Architecture

### Decision

Recommendation Engine suggests the highest-impact action instead of displaying many equal options.

### Reason

Reduce decision fatigue.

Users should always know the next best action.

### Alternatives Considered

Traditional recommendation lists.

### Impact

Daily Focus and Decision Engine consume Recommendation outputs.

### Status

✅ Accepted

---

## DEC-005

**Date:** 2026-07-12

**Category:** Architecture

### Decision

Decision Engine aggregates all Phoenix modules before recommending actions.

### Reason

A recommendation should consider the complete user context instead of one feature.

### Alternatives Considered

Recommendation-only system.

### Impact

Decision Engine became the central intelligence layer.

### Status

✅ Accepted

---

## DEC-006

**Date:** 2026-07-12

**Category:** Architecture

### Decision

Introduce the Repository Pattern.

### Reason

Decouple feature services from storage implementation.

Enable LocalRepository, CloudRepository, and future providers without changing feature services.

### Alternatives Considered

Direct service-to-storage access.

### Impact

Repository became the abstraction layer for all data access.

### Status

✅ Accepted

---

## DEC-007

**Date:** 2026-07-12

**Category:** Architecture

### Decision

Local persistence introduced through StorageService.

### Reason

Allow Phoenix to remember user progress across app launches.

### Alternatives Considered

Sample data only.

### Impact

StorageService and LocalRepository added.

### Status

✅ Accepted

---

## DEC-008

**Date:** 2026-07-12

**Category:** Architecture

### Decision

PhoenixContext becomes the single object shared with AI providers.

### Reason

Maintain provider independence and ensure all AI models receive identical user context.

### Alternatives Considered

Passing individual services directly.

### Impact

Phoenix Context Builder introduced.

### Status

✅ Accepted

---

## DEC-009

**Date:** 2026-07-12

**Category:** AI

### Decision

OmniRoute acts as the AI routing layer.

### Reason

Separate Phoenix intelligence from external AI providers.

Allow routing based on task capabilities instead of hardcoded providers.

### Alternatives Considered

Direct provider integrations.

### Impact

OmniRoute introduced with Provider Strategy and Prompt Builder.

### Status

✅ Accepted

---

## DEC-010

**Date:** 2026-07-12

**Category:** Product

### Decision

Phoenix Core and Plugins are separate architectural concepts.

### Reason

Support unlimited careers and life paths while keeping the Core stable.

### Alternatives Considered

Embedding all careers directly into the application.

### Impact

Future careers become installable plugins.

### Status

🟡 Proposed

---

## DEC-011

**Date:** 2026-07-12

**Category:** Philosophy

### Decision

AI is an assistant, not the product.

### Reason

Phoenix owns the user journey.

AI provides explanations and assistance.

The platform must remain independent of any single AI provider.

### Alternatives Considered

AI-first application.

### Impact

All future AI integrations must consume PhoenixContext.

### Status

✅ Accepted

---

# Decision Guidelines

A decision should be added only if it:

- Changes architecture
- Changes product philosophy
- Introduces a new platform capability
- Alters long-term direction
- Affects multiple modules

Minor implementation details should not be added.

---

# Ownership

Maintained by:

Phoenix Core Team

Last Updated:

2026-07-12