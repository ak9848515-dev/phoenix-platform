# Release Checklist — Phoenix OS v2.0

## Pre-Release Verification

### Code Quality
- [x] `flutter analyze` — 0 issues
- [x] `flutter test` — 595 passing
- [x] `flutter build apk --release` — build\app\outputs\flutter-apk\app-release.apk
- [x] `flutter build appbundle --release` — build\app\outputs\bundle\release\app-release.aab

### Architecture
- [x] No duplicate widgets in core/design/widgets (3 consolidated in PR-001)
- [x] No duplicate models (KnowledgeDNA deleted in PR-002)
- [x] No dead code (12 files removed in PR-003)
- [x] No `Mission` name collision (renamed to `CurriculumMission` in PR-002)
- [x] Repository pattern intact
- [x] All 30+ routes registered

### Documentation
- [x] PROJECT_STATUS.md updated
- [x] task_progress.md updated
- [x] ARCHITECTURE_CERTIFICATION.md written
- [x] TECHNICAL_DEBT.md written
- [x] RELEASE_CHECKLIST.md written
- [x] RELEASE_NOTES.md written

### Remaining Pre-Release Tasks
- [ ] Accessibility audit (Phase 6)
- [ ] Error handling review (Phase 7)
- [x] Production APK built (--no-tree-shake-icons for dynamic IconData from JSON)
- [x] Production AAB built (--no-tree-shake-icons for dynamic IconData from JSON)
- [ ] Release branch merge to `main`
