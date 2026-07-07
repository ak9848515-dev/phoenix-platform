# Phoenix Platform

## Project Vision

Phoenix Platform is a next-generation learning and growth operating system designed to help individuals and teams build capability, maintain momentum, and turn ambition into measurable progress. The platform combines structured academies, mission-driven learning, adaptive knowledge tracking, and an extensible plugin architecture into a unified experience.

The system is built to be more than a course app. It is designed as a personal intelligence layer for learning, execution, and continuous professional development.

## Mission

To help people learn with purpose, act with clarity, and grow with measurable momentum through a structured, intelligent, and beautifully designed platform.

## Long-term Goal

To become a scalable digital operating system for growth, where users can navigate learning, missions, knowledge development, and product execution from a single intelligent environment.

## Product Philosophy

Phoenix Platform is guided by the belief that growth should feel intentional, visible, and motivating. The product should reduce friction in learning, make progress legible, and provide a clear path from curiosity to mastery.

## Core Principles

- Clarity over complexity
- Progress over perfection
- Modular design over monolithic implementation
- Human-centered experience over feature bloat
- Reusable architecture over one-off solutions
- Trustworthy systems over clever shortcuts
- Scalable foundations over short-term prototypes

## Target Users

- Professionals seeking structured growth and skill development
- Teams wanting aligned learning pathways and execution systems
- Builders and operators who need a mission-driven productivity layer
- Organizations looking to create learning ecosystems around capability development

## Problem Statement

Modern learning and growth are fragmented. Users often juggle disconnected resources, vague progress tracking, and unclear next steps. Phoenix Platform exists to unify these experiences into one coherent environment that supports both learning and action.

## Why Phoenix Exists

Phoenix exists to create momentum where there is often uncertainty. It provides a foundation for users to understand where they are, what matters next, and how to move forward in a meaningful way.

## Product Roadmap

### Phase 1: Foundation
- Establish architecture and design system
- Create core theme, models, and folder structure
- Build initial presentation screens for mission and knowledge DNA experiences

### Phase 2: Core Experience
- Expand academy, mission, and progress experiences
- Introduce richer content structure and state handling
- Refine navigation and information hierarchy

### Phase 3: Intelligence Layer
- Add adaptive insight and personalization capabilities
- Introduce knowledge graph and recommendation patterns
- Create richer learning feedback mechanisms

### Phase 4: Platform Expansion
- Support teams, workspaces, and multi-user collaboration
- Integrate plugins and external services
- Expand analytics and growth intelligence

## Architecture Overview

Phoenix Platform is being built as a modular Flutter application with a layered architecture that separates presentation, domain models, infrastructure concerns, and feature-specific modules. The design favors readability, scalability, and maintainability over premature optimization.

The architecture is intentionally structured so that future logic, services, and integrations can be added without restructuring the application foundation.

## Folder Structure

```text
lib/
  core/
  config/
  shared/
  features/
  services/
  models/
  routes/
  theme/
```

Each top-level folder has a defined purpose and should remain focused on its responsibility.

## Theme System

The visual system is based on a reusable design token foundation. Theme values are centralized in the theme layer and should be consumed by all UI components.

The design system includes:
- Color tokens
- Spacing tokens
- Radius tokens
- Typography tokens
- Duration tokens
- Light and dark ThemeData definitions

The application uses Material 3 conventions and should remain visually consistent across all features.

## Navigation Strategy

Navigation should remain explicit, predictable, and easy to evolve. The app should organize routes around feature domains and keep navigation logic decoupled from UI composition.

The route layer is intended to support future deep linking, modular entry points, and expansion into additional experiences over time.

## Mission Engine

The mission engine represents the product's execution layer. It is the organizing mechanism that turns goals into short-term, actionable, motivating tasks.

Mission flows should support:
- Daily and weekly objectives
- Priority-based learning tasks
- Completion tracking
- Visible momentum and progress feedback

## Knowledge DNA

Knowledge DNA is the platform's adaptive profile layer. It captures the user's learning posture, strengths, weaknesses, and growth pattern. It is not a static score; it is a living summary of capability growth.

It should reflect:
- Confidence
- Retention
- Consistency
- Velocity of learning
- Missions and projects completed
- Strong and weak areas
- Long-term career direction

## Academy Engine

The academy engine is the structured learning framework for the platform. It organizes content into academies, levels, stages, missions, and lessons.

This supports progressive learning paths where users can move from foundational concepts to advanced capability over time.

## Plugin System

The plugin system is an extensibility layer intended to support modular capabilities that can be added without redesigning the core experience. Plugins may provide specialized functionality or external integrations while remaining composable within the broader product.

## AI Router

The AI Router is a future orchestration layer designed to direct requests and tasks to the appropriate AI backend depending on the user need. It may route between internal logic, external provider services, and local inference models.

## Business Module

The business module is intended to host the commercial and operational logic of the platform, including plans, incentives, team alignment, and product enablement structures. This module should remain separate from the learning experience itself.

## Memory Module

The memory module is designed to store and retrieve contextual information about the user and their interaction history. It will support continuity, personalization, and future adaptive capabilities.

## Developer Mode

Developer Mode is a future environment for internal workflows, diagnostics, local experimentation, and content authoring. It should empower contributors to prototype safely and validate product behavior without affecting the end-user experience.

## Coding Standards

- Write clear, maintainable Dart code
- Prefer small, focused components and classes
- Keep UI presentation separate from domain concerns
- Favor immutable models and explicit data flows
- Avoid unnecessary abstraction
- Keep the codebase consistent and easy to read

## Git Workflow

All work should be tracked through Git using short-lived, purpose-driven branches. Changes should be atomic and easy to review.

## Branch Strategy

- main for stable production-ready code
- feature/* for new functionality
- fix/* for bug fixes
- chore/* for maintenance and structure updates
- docs/* for documentation work

## Commit Strategy

Commits should be small, descriptive, and focused on one change at a time. Commit messages should clearly communicate intent and scope.

## Sprint Workflow

Each sprint should begin with clear goals, a scoped set of deliverables, and explicit acceptance criteria. Work should be broken into manageable tasks and reviewed continuously.

## Definition of Done

A task is considered done when:
- The requirement is implemented
- The change is reviewed for quality and clarity
- The relevant analysis checks pass
- The code remains aligned with project structure and standards
- The feature or change is documented where appropriate

## Flutter Standards

- Use Material 3 by default
- Reuse centralized theme tokens
- Keep screens presentation-focused unless explicitly implementing logic
- Follow a clean and modular folder structure
- Preserve separation between UI, models, and services
- Prefer readable widget composition over deeply nested logic

## Folder Responsibilities

- core: shared foundational abstractions and app-wide utilities
- config: app configuration and environment-level concerns
- shared: reusable UI and logic that is not feature-specific
- features: feature-based presentations and experience modules
- services: service-layer integrations and external access points
- models: immutable domain models and data structures
- routes: navigation structure and route definitions
- theme: design tokens and theme configuration

## Naming Conventions

- Files use snake_case
- Classes use PascalCase
- Methods and variables use camelCase
- Feature folders use lowercase snake_case
- Constants use descriptive uppercase names where appropriate

## UI Guidelines

The user interface should feel calm, contemporary, and professional. It should prioritize clarity, accessibility, and momentum. Interface elements should be consistent and intentionally spaced.

## Design Language

Phoenix Platform adopts a premium, modern, growth-oriented design language characterized by clarity, structure, and confidence. The experience should feel inspiring without becoming noisy or overly decorative.

## Material 3 Guidelines

- Use Material 3 components and color roles by default
- Apply theme tokens consistently
- Favor surfaces, containers, and elevation with purpose
- Keep touch targets accessible and clear
- Support both light and dark experience modes

## Future Integrations

### Supabase
Supabase is intended to support authentication, persistence, storage, and backend services when the platform moves beyond static presentation layers.

### n8n
n8n is a candidate automation layer for workflows, triggers, and operational processes that can connect the platform with external tools and systems.

### OmniRoute
OmniRoute is envisioned as a routing and orchestration layer to connect experiences, flows, and execution paths across the platform ecosystem.

### OpenAI
OpenAI may be used for intelligent content generation, adaptive assistance, and knowledge-based experiences once the product foundation is mature.

### Claude
Claude may be used for sophisticated reasoning, content synthesis, and internal product assistance where appropriate.

### Gemini
Gemini may support multimodal and intelligent content experiences as the product expands.

### Local LLM
A local LLM strategy may be adopted for private, low-latency, or offline-friendly experiences where data control is critical.

## Current Progress

### Completed
- Project structure established
- Theme system foundation created
- Mission Center presentation screen created
- Knowledge DNA presentation foundation created
- Domain model layer created
- Documentation structure initialized

### Pending
- Route definitions
- Feature integration
- State management foundation
- Service abstractions
- Real content model and seed data
- Persistence and backend planning

## Next Sprint

- Formalize navigation structure
- Expand feature screens into reusable presentation modules
- Introduce sample state and content flows
- Prepare integration boundaries for future services
- Start formalizing the persistence strategy

## Future Milestones

- Launch a polished MVP experience
- Introduce adaptive insights and personalization
- Support team and workspace experiences
- Integrate external services and automation
- Build a durable platform foundation for long-term growth

## Important Decisions

The following decisions are now part of the permanent direction of Phoenix Platform:

1. The project will use Flutter as the primary application framework.
2. The application will follow a modular feature-based architecture.
3. The project will use Material 3 as the default design system foundation.
4. The theme layer will be centralized through reusable design tokens.
5. The codebase will keep UI presentation separate from business logic and services.
6. The domain model layer will remain immutable and serialization-friendly.
7. The application will begin with presentation-oriented scaffolding before introducing stateful logic.
8. The product will be designed around learning, mission execution, and knowledge growth rather than simple content delivery.
9. The project will evolve in phases, with the foundation built first and intelligence layers introduced later.
10. The architecture will remain extensible to support future integrations such as Supabase, n8n, OmniRoute, OpenAI, Claude, Gemini, and local LLMs.
