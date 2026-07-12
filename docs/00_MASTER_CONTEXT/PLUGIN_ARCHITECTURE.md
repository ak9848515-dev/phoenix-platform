# Phoenix Plugin Architecture

Version: 1.0

Status: Draft

---

# Purpose

Phoenix is designed as a Personal Growth Operating System.

The Core provides the intelligence.

Plugins provide the domain knowledge.

This separation allows Phoenix to support unlimited careers, businesses, and life journeys while keeping the Core stable.

---

# Philosophy

Phoenix Core never knows:

- Flutter
- SAP
- YouTube
- Business
- Medicine
- UPSC

Phoenix Core only knows:

- Identity
- Journey
- Mission
- Knowledge
- Progress
- Memory
- Decision
- Context
- AI

Everything career-specific belongs inside a Plugin.

---

# Architecture

```
                Phoenix Core

Repository

Storage

Decision Engine

Phoenix Context

OmniRoute

Authentication

Plugin Manager

        ▲

        │

        ▼

Career Plugin
```

---

# Plugin Responsibilities

A Plugin defines:

- Identity
- Journey
- Missions
- Knowledge DNA
- Academy
- Career Metrics
- AI Prompt Templates

A Plugin never modifies Phoenix Core.

---

# Plugin Structure

```
plugins/

flutter_developer/

├── plugin_manifest.json

├── identity.json

├── journey.json

├── missions.json

├── knowledge_dna.json

├── academy.json

├── career.json

└── ai_prompts.json
```

---

# Plugin Manifest

Example

```json
{
  "id": "flutter_developer",
  "name": "Flutter Developer",
  "version": "1.0.0",
  "author": "Phoenix",
  "category": "Technology",
  "description": "Complete Flutter developer roadmap."
}
```

---

# Identity

Defines:

- Name
- Description
- Category
- Target Level
- Estimated Duration

---

# Journey

Defines:

- Stages
- Milestones
- Completion Rules
- Estimated Timeline

---

# Missions

Defines:

Daily Missions

Weekly Missions

Projects

Assessments

Challenges

---

# Knowledge DNA

Defines:

Skills

Topics

Difficulty

Dependencies

Knowledge Graph

---

# Academy

Defines:

Books

Videos

Courses

Articles

Practice

References

---

# Career

Defines:

Career Score

Portfolio Requirements

Interview Requirements

Job Readiness

Salary Information

Career Paths

---

# AI Prompts

Defines prompts for:

Teaching

Coaching

Code Review

Interview

Career Advice

Reflection

Project Review

---

# Plugin Lifecycle

Install

↓

Validate

↓

Register

↓

Load

↓

Activate

↓

Provide Data

↓

Deactivate

↓

Update

↓

Remove

---

# Plugin Manager

Future responsibility:

Discover plugins

Install plugins

Validate plugin versions

Resolve dependencies

Activate plugins

Update plugins

Remove plugins

---

# Multiple Plugins

Users may install multiple plugins.

Example

Flutter Developer

+

Content Creator

+

Business Owner

Phoenix Core merges all contexts.

Decision Engine determines priorities.

---

# Marketplace (Future)

Phoenix Marketplace will distribute plugins.

Examples:

Flutter Developer

SAP Consultant

ABAP Consultant

Content Creator

Video Editor

Business Owner

Doctor

Lawyer

UPSC

NEET

Finance

Health

Language Learning

---

# Design Rules

Plugins must never:

Modify Core

Access Storage directly

Call AI providers directly

Modify Repository

Own Authentication

Own OmniRoute

---

# Plugins may:

Define journeys

Define missions

Provide learning resources

Provide prompt templates

Provide career metrics

Provide assessments

---

# AI Integration

Plugins do not call AI.

Plugins provide prompt templates.

Phoenix Context +

Prompt Template +

OmniRoute

↓

AI Provider

↓

Response

---

# Versioning

Every plugin follows semantic versioning.

Major

Minor

Patch

Example:

1.2.0

---

# Compatibility

Each plugin specifies:

Minimum Phoenix Version

Maximum Phoenix Version

Supported Plugin API Version

---

# Long-Term Vision

Eventually Phoenix should support thousands of plugins.

The Core should remain unchanged.

Only plugins evolve.

This ensures long-term scalability and maintainability.

---

# Golden Rule

If a feature is specific to one career or one life path,

it belongs in a Plugin.

If a feature benefits every user,

it belongs in Phoenix Core.