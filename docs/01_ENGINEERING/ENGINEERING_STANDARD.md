# Phoenix Engineering Standard

**Document ID:** PES-001

**Version:** 1.0.0

**Status:** Approved

**Owner:** Chief Software Architect

**Applies To:** Entire Phoenix Platform Repository

---

# 1. Purpose

This document defines the engineering standards used to design, implement, review, test, and maintain the Phoenix Platform.

Its purpose is to ensure that every contributor—human or AI—follows the same engineering process and architectural principles.

This document governs **how** Phoenix is built.

It complements `MASTER_CONTEXT.md`, which governs **what** Phoenix is and **why** it exists.

---

# 2. Scope

These standards apply to:

* Flutter application development
* UI implementation
* Architecture implementation
* Documentation
* Refactoring
* Bug fixing
* Code reviews
* AI-assisted development
* Git workflow
* Release preparation

---

# 3. Engineering Principles

Phoenix follows these engineering principles:

1. Protect the architecture.
2. Clarity over complexity.
3. Small, reviewable changes.
4. Preserve working code.
5. Prefer composition over inheritance.
6. Reuse before duplication.
7. Keep presentation separate from business logic.
8. Prefer explicit behavior over hidden magic.
9. Optimize readability before optimization.
10. Every commit should improve the project.

---

# 4. Governance

## Product Owner

Responsible for:

* Product vision
* Roadmap
* Priorities
* Feature acceptance

---

## Chief Software Architect

Responsible for:

* Architecture
* Engineering standards
* Technical decisions
* Reviews
* Quality approval
* Long-term scalability

---

## Implementation Engineer

Responsible for:

* Implementing approved tasks
* Refactoring within task scope
* Fixing analyzer and test failures
* Maintaining code quality

Implementation Engineers never redesign architecture.

---

## Validation

Validation is performed through:

* dart format
* flutter analyze
* flutter test
* Architecture review

---

# 5. Decision Hierarchy

Product Owner

↓

Chief Software Architect

↓

Engineering Standards

↓

Implementation

↓

Validation

↓

Merge

Architecture decisions always override implementation preferences.

---

# 6. AI Collaboration Rules

Every AI assistant must:

* Read the required project documents.
* Follow approved architecture.
* Implement only the assigned task.
* Preserve existing behavior unless instructed otherwise.
* Ask for clarification instead of making assumptions.
* Never redesign architecture.
* Never certify its own implementation.
* Never introduce new frameworks without approval.

---

# 7. Mandatory Reading Order

Before any implementation begins, the following documents must be read in order:

1. MASTER_CONTEXT.md
2. ENGINEERING_STANDARD.md
3. CURRENT_TASK.md
4. PROJECT_STATUS.md

No implementation should begin before these documents are understood.

---

# 8. Development Workflow

Task Definition

↓

Architecture Specification

↓

Implementation

↓

Formatting

↓

Analyzer

↓

Tests

↓

Architecture Review

↓

Git Commit

↓

Merge

---

# 9. Implementation Rules

Implementation must:

* Modify only the required files.
* Preserve working functionality.
* Avoid unrelated refactoring.
* Reuse existing widgets.
* Follow existing folder structure.
* Keep changes focused.
* Keep widgets small.
* Keep files readable.
* Use Material 3.
* Reuse theme tokens.

Implementation must not:

* Change architecture.
* Introduce new frameworks.
* Introduce new state management.
* Modify persistence unless instructed.
* Modify services unless instructed.
* Modify repositories unless instructed.

---

# 10. Quality Gates

Every task must satisfy all of the following:

* Project builds successfully.
* Code formatted.
* Analyzer passes.
* Tests pass.
* Documentation updated if necessary.
* Architecture review approved.

A task is not complete until every quality gate passes.

---

# 11. Definition of Ready

A task is ready when:

* Requirements are clear.
* Scope is defined.
* Acceptance criteria exist.
* Dependencies are identified.
* Architecture impact is understood.

---

# 12. Definition of Done

A task is complete only when:

* Implementation completed.
* Code reviewed.
* Analyzer passes.
* Tests pass.
* Documentation updated.
* Git commit completed.
* Ready for merge.

---

# 13. Change Control

| Document                | Change Frequency |
| ----------------------- | ---------------- |
| MASTER_CONTEXT.md       | Rare             |
| ENGINEERING_STANDARD.md | Rare             |
| PROJECT_STATUS.md       | Every Sprint     |
| CURRENT_TASK.md         | Every Task       |

Architecture documents should change only through architectural review.

---

# 14. Documentation Rules

Documentation must:

* Be accurate.
* Reflect implementation.
* Avoid duplication.
* Use Markdown.
* Reference the authoritative document instead of repeating content.

---

# 15. Code Review Rules

Every review checks:

* Architecture
* Folder structure
* SOLID principles
* Readability
* Maintainability
* Performance
* Scalability
* Material 3 compliance
* Theme usage
* Technical debt

Reviews should produce actionable feedback.

---

# 16. Git Workflow

Development should follow this sequence:

Feature Branch

↓

Implementation

↓

Review

↓

Commit

↓

Push

↓

Pull Request

↓

Merge

Commits should be small, descriptive, and atomic.

---

# 17. Release Process

Every release requires:

* Passing quality gates
* Updated documentation
* Updated release notes
* Approved architecture review
* Git tag
* Merge into the appropriate branch

---

# 18. AI Operating Principles

AI assistants exist to accelerate engineering—not replace engineering judgment.

AI may:

* Generate code
* Refactor code
* Suggest improvements
* Create documentation
* Fix bugs

AI may not:

* Approve architecture
* Invent requirements
* Introduce frameworks
* Redesign modules
* Ignore engineering standards

---

# 19. Escalation Rules

Implementation must stop immediately when:

* Architecture conflicts are found.
* Requirements are ambiguous.
* Existing standards are insufficient.
* A requested change violates MASTER_CONTEXT.md.

Escalations are resolved by the Chief Software Architect.

---

# 20. Engineering Philosophy

Phoenix is engineered for long-term maintainability.

Every decision should improve one or more of:

* Readability
* Consistency
* Simplicity
* Maintainability
* Scalability
* Reliability

Short-term convenience must never compromise long-term architecture.

---

# Revision History

| Version | Date            | Description                                 |
| ------- | --------------- | ------------------------------------------- |
| 1.0.0   | Initial Release | First official Phoenix Engineering Standard |

---

# References

This document must be used together with:

* MASTER_CONTEXT.md
* PROJECT_STATUS.md
* CURRENT_TASK.md
* ARCHITECTURE_STANDARD.md
* FLUTTER_STANDARD.md
* ROUTING_STANDARD.md
* UI_STANDARD.md
* CODING_STANDARD.md
* REVIEW_STANDARD.md
* GIT_STANDARD.md
* AI_COLLABORATION_STANDARD.md
