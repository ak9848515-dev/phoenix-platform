# Release Notes — Phoenix OS v2.0

## Overview
Phoenix OS v2.0 marks the completion of platform foundation and architecture stabilization. This release delivers a clean, maintainable codebase with 0 analyzer issues and 595 passing tests.

## Key Changes

### PHX-060 — Platform Foundation
- Global search service aggregating from 11 engines
- Unified home experience (PhoenixHomeScreen with 9+ sections)
- Cross-engine synchronization (mission/habit → timeline sync)
- Navigation audit (all 30+ routes verified)
- 595 tests, 0 analyzer issues

### PHX-061 PR-001 — Widget Consolidation
- Consolidated `PhoenixPrimaryButton`, `PhoenixEmptyState`, `PhoenixProgressBar` from `core/design/widgets` to canonical `shared/widgets/`
- Enhanced `PhoenixPrimaryButton` with loading/disabled state support

### PHX-061 PR-002 — Model Cleanup
- Removed dead duplicate `KnowledgeDNA` model
- Removed dead legacy `User` model
- Renamed `Mission` → `CurriculumMission` to resolve name collision with mission engine

### PHX-061 PR-003 — Dead Code Cleanup
- Audited 377 files across entire codebase
- Removed 12 dead files (unused widgets, placeholders, models, theme wrappers)

## Architecture
- Clean repository/service/engine pattern
- `UserState` as single source of truth
- 2 repository implementations (SampleRepository, LocalRepository)
- Named routes with deep-link readiness

## Known Issues
See `docs/04_REVIEWS/TECHNICAL_DEBT.md` for full debt register.

## Build
- Branch: `feature/phase-3-platform-foundation`
- Release branch: `release/phoenix-v2`
