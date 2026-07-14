# Technical Debt Register

## Active Debt Items

### P1 — Critical
*None currently identified.*

### P2 — High
| ID | Item | Location | Notes |
|----|------|----------|-------|
| TD-001 | Old `core/design/widgets/phoenix_card.dart` still referenced | 11 files import from deprecated path | Requires migrating to `shared/widgets/phoenix_card.dart` and deleting duplicate |
| TD-002 | Old `core/design/widgets/phoenix_badge.dart` still referenced | 8 files (profile, ai, dashboard) | No canonical version in `shared/widgets/` yet |
| TD-003 | Old `core/design/widgets/phoenix_stat_tile.dart` still referenced | 6 files (dashboard, profile, ai) | No canonical version in `shared/widgets/` yet |

### P3 — Medium
| ID | Item | Location | Notes |
|----|------|----------|-------|
| TD-004 | `phoenix_context_builder.dart` standalone | `lib/core/context/builders/` | Single-file builder, only 1 consumer |
| TD-005 | `learning_path_registry.dart` standalone | `lib/features/academy/engine/` | Single-file registry, only 1 consumer |
| TD-006 | Accessibility audit not performed | Across all widgets | Semantics, focus traversal, screen reader labels |
| TD-007 | Error handling review not performed | Across all features | Empty states, loading states, offline behaviour |

### P4 — Low
| ID | Item | Location | Notes |
|----|------|----------|-------|
| TD-008 | `lib/theme/` wrapper files duplicate `core/design/theme/` | `lib/theme/colors.dart`, `spacing.dart`, `radius.dart`, `theme.dart` | Thin wrappers delegating to Phoenix* tokens — 2 already deleted |
| TD-009 | `CurriculumMission` naming | `lib/models/mission.dart` | Renamed from `Mission` for clarity but still a legacy DTO |

## Resolved Debt
| ID | Item | Resolved In |
|----|------|-------------|
| TD-R01 | `Mission` name collision with mission engine | PR-002 — Renamed to `CurriculumMission` |
| TD-R02 | Duplicate `KnowledgeDNA` model | PR-002 — Deleted `lib/models/knowledge_dna.dart` |
| TD-R03 | Duplicate `PhoenixPrimaryButton` | PR-001 — Consolidated to `shared/widgets/` |
| TD-R04 | Duplicate `PhoenixProgressBar` | PR-001 — Moved to `shared/widgets/` |
| TD-R05 | Duplicate `PhoenixEmptyState` | PR-001 — Deleted duplicate |
| TD-R06 | Dead `page_transition` animation | PR-003 — Deleted |
| TD-R07 | Dead placeholder files (4) | PR-003 — Deleted |
| TD-R08 | Dead `plugin.dart` model | PR-003 — Deleted |
| TD-R09 | Dead `knowledge_dna_metrics/recommendation` | PR-003 — Deleted |
| TD-R10 | Dead `AppTypography`/`AppDurations` wrappers | PR-003 — Deleted |
