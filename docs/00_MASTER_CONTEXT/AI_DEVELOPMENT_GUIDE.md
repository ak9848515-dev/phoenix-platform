# Phoenix AI Agent Instructions
Version: 1.0
Status: Active
Owner: Phoenix Labs

---

# Purpose

This document is the single source of truth for every AI coding agent working on Phoenix.

Examples:

- DeepSeek
- Claude
- ChatGPT
- Gemini
- Codex
- Future AI models

Every implementation must follow this document before making changes.

---

# Product Vision

Phoenix is NOT:

- a chatbot
- a course platform
- a note taking app
- a productivity app

Phoenix IS:

> A Personal Growth Operating System.

Its purpose is to help people become the person they aspire to become.

Everything must support this vision.

---

# Core Philosophy

Phoenix asks:

> "Who do you want to become?"

NOT

> "What course do you want to learn?"

Identity is the foundation of the platform.

Courses are tools.

Transformation is the goal.

---

# Core Architecture

Current architecture:

Identity
↓

Memory
↓

Knowledge DNA
↓

Progress
↓

Recommendation
↓

Decision
↓

AI Context
↓

OmniRoute
↓

AI Models

Every new feature must fit this architecture.

Do not bypass it.

---

# Engineering Principles

Always prefer:

- reusable components
- modular design
- composition
- separation of concerns
- clean architecture

Never duplicate code.

Never introduce unnecessary complexity.

---

# Folder Rules

Allowed modifications:

lib/features/**
lib/shared/**
lib/routes/**
lib/core/**
lib/config/**
docs/**

Forbidden unless explicitly requested:

lib/theme/**
pubspec.yaml
analysis_options.yaml

Never delete existing functionality.

---

# Flutter Standards

Use:

- StatelessWidget whenever possible
- const constructors
- Theme.of(context)
- AppSpacing
- PhoenixCard
- PhoenixPrimaryButton
- PhoenixProgressIndicator
- ExperienceSecondaryButton

Avoid hardcoded:

- colors
- spacing
- typography
- radius

Follow Material 3.

---

# Coding Standards

Write readable code.

Prefer composition over inheritance.

Avoid deep widget nesting.

Keep files focused.

Do not introduce dead code.

Do not leave TODOs unless requested.

---

# State Management

Current standard:

Presentation only.

No Provider.

No Riverpod.

No Bloc.

No GetX.

State management will be introduced later.

---

# Business Logic

Presentation sprints:

NO business logic.

NO AI logic.

NO persistence.

NO networking.

Only presentation and reusable models/services when requested.

---

# Quality Gates

Every sprint must complete:

dart format

flutter analyze

flutter test

The sprint is NOT complete until all quality gates pass.

---

# Commit Rules

One sprint

=

One commit

Commit format:

feat(module): PHX-XXX short description

Examples:

feat(identity): PHX-028 identity engine foundation

feat(memory): PHX-029 memory engine foundation

---

# Output Format

Every sprint must finish with:

1. Summary

2. Files Changed

3. Architecture Report

4. Quality Gates

5. Risks

6. Suggested Commit Message

7. Self Review

---

# AI Behaviour

Before changing code:

1. Understand the requested sprint.
2. Read only the documentation required for that sprint.
3. Read only the code required for that sprint.
4. Reuse existing widgets and services whenever possible.
5. Avoid unnecessary file reads.
6. Avoid modifying unrelated files.

Minimize token usage.

---

# Design Principles

Every feature must answer:

Does this help the user become who they want to become?

If the answer is "No"

do not build it.

---

# User Experience Principles

Phoenix should:

Reduce decision fatigue.

Explain recommendations.

Remember user progress.

Build long-term continuity.

Never overwhelm the user.

---

# AI Integration Principles

AI is a mentor.

AI is a collaborator.

AI is never the product.

Phoenix remains the operating system.

AI models are interchangeable tools.

Future supported models include:

- OpenAI
- Anthropic
- DeepSeek
- Gemini
- Ollama
- Local Models

All AI access will eventually be routed through OmniRoute.

No feature should directly depend on one AI provider.

---

# Definition of Done

A sprint is complete only if:

✓ Architecture followed

✓ No duplicate code

✓ Uses shared widgets

✓ Uses theme tokens

✓ No business logic (unless requested)

✓ Quality gates pass

✓ Documentation updated if required

✓ Clean commit message prepared

---

# Phoenix Principle

Do not build features.

Build systems that help people transform.

Every line of code should move the user closer to the person they want to become.