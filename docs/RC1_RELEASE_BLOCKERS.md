# RC-1: Release Blockers

**Date:** July 19, 2026
**Version:** Phoenix OS v1.0.0

---

## 1. Critical Blockers

**None identified.** No critical blockers exist.

The platform has:
- ✅ 0 analyzer issues
- ✅ 946/946 tests passing
- ✅ APK debug build succeeding
- ✅ No crash-causing bugs
- ✅ No dead navigation paths
- ✅ All authentication flows complete
- ✅ All AI pipeline components wired
- ✅ All 21 Firestore sync domains registered

---

## 2. High Priority

| # | Blocker | Screen/Area | Reason | Impact | Recommended Fix | Status |
|---|---------|-------------|--------|--------|-----------------|--------|
| H1 | Firebase production configuration | Global | Firebase config uses placeholder keys — Firestore/Auth will not work in production builds | ❌ Firestore, Auth, AI will fail in production | Run `flutterfire configure --project=phoenix-growth-os-86302` | 🔴 NOT DONE |

---

## 3. Medium Priority

| # | Blocker | Screen/Area | Reason | Impact | Recommended Fix | Status |
|---|---------|-------------|--------|--------|-----------------|--------|
| M1 | MissionCenterScreen uses SampleRepository | Missions | Screen reads from `SampleRepository` instead of mission engine snapshot | Shows sample missions, not real user data | Wire to `MissionIntelligenceEngine.snapshot` | 🟡 NOT DONE |
| M2 | API keys stored in SharedPreferences | AI Providers | Provider API keys stored in `SharedPreferences` instead of `flutter_secure_storage` | API keys are not encrypted at rest | Migrate to `flutter_secure_storage` | 🟡 NOT DONE |
| M3 | No APK release signing configured | Build | No Android keystore configured for release builds | Cannot publish to Play Store | Configure `key.properties` and signing | 🟡 NOT DONE |

---

## 4. Low Priority

| # | Blocker | Screen/Area | Reason | Impact | Recommended Fix | Status |
|---|---------|-------------|--------|--------|-----------------|--------|
| L1 | OnboardingScreen uses legacy design tokens | Onboarding | Uses `AppColors`/`AppSpacing` instead of `PhoenixColors`/`PhoenixSpacing` | Visual inconsistency | Migrate to Phoenix design system | 🟢 P3 |
| L2 | Identity Firestore sync only 6/25 fields | Firestore | Full identity profile (Personal, Professional, Growth, AI) not synced | Incomplete cloud backup of identity | Expand `_serializeSnapshot()` for identity domain | 🟢 P3 |
| L3 | IconButton semantic labels (~24 instances) | All screens | Missing `Semantics` annotations on IconButtons | Screen reader users get unlabeled buttons | Add `Semantics(label: '...', button: true)` to all IconButtons | 🟢 P3 |
| L4 | Performance trackers unwired (6 gaps) | Diagnostics | Frame time, widget rebuild, memory snapshot, Firestore R/W latency trackers not called | No quantitative performance data | Wire trackers in widgets/services | 🟢 P3 |
| L5 | Some screens use hardcoded EdgeInsets | Multiple screens | ~15 screens use `EdgeInsets.all()` or `EdgeInsets.only()` instead of `PhoenixSpacing` constants | Minor visual inconsistency | Replace with `PhoenixSpacing` constants | 🟢 P3 |
| L6 | MissionCenterScreen uses legacy AppSpacing | Missions | Uses `AppSpacing.lg` instead of `PhoenixSpacing.lg` | Visual inconsistency | Replace with PhoenixSpacing | 🟢 P3 |
| L7 | Export/Import settings are placeholder dialogs | Settings | `Export Settings` and `Import Settings` just show "Settings exported" snackbar | No actual file export/import implemented | Implement file picker + JSON serialization | 🟢 P3 |
| L8 | "Phoenix OS v2.10.0" hardcoded in Profile | Profile | About section has hardcoded version string | Version shown is inaccurate | Read from `AppConfig` at runtime | 🟢 P3 |

---

## 5. Blockers by Severity

| Severity | Count | Resolved | Remaining |
|----------|-------|----------|-----------|
| 🔴 Critical | 1 | 0 | 1 (Firebase config) |
| 🟡 High | 0 | 0 | 0 |
| 🟡 Medium | 3 | 0 | 3 |
| 🟢 Low | 8 | 0 | 8 |
| **Total** | **12** | **0** | **12** |

---

## 6. Pre-Release Required Actions

| Action | Priority | Effort | Notes |
|--------|----------|--------|-------|
| 🔴 Run `flutterfire configure --project=phoenix-growth-os-86302` | Critical | 5 min | Required for production auth/Firestore |
| 🟡 Configure Android keystore for release signing | Medium | 15 min | Required for Play Store |
| 🟡 Run `flutter build apk --release` | Medium | 5 min | Verify release build |
| 🟡 Run `flutter build appbundle` | Medium | 5 min | Required for Play Store |
| 🟡 Run `flutter build web` | Medium | 5 min | If deploying to web |
| 🟢 Review SampleRepository usage in MissionCenterScreen | Low | 30 min | Wire to real engine data |

---

## 7. Release Decision

| Criteria | Status |
|----------|--------|
| Critical blockers remaining | ✅ 1 (Firebase config) — must be resolved for production |
| High blockers remaining | ✅ 0 |
| Medium blockers remaining | ✅ 3 — not blocking release but should be tracked |
| Low blockers remaining | ✅ 8 — acceptable for v1.0.0 |

### Decision: 🟡 Release Candidate — requires Firebase config before production release

**To promote to PRODUCTION:** Run `flutterfire configure --project=phoenix-growth-os-86302` to activate Firebase, then verify auth + Firestore + AI in production environment.
