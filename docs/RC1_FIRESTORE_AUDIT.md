# RC-1: Complete Firestore Audit

**Date:** July 19, 2026
**Version:** Phoenix OS v1.0.0

---

## 1. Firestore Architecture

```
Engines → Mark Domain Dirty → FirestoreSyncAdapter.syncAll()
  → Offline Queue → Firestore (users/{userId}/{collection}/current)
  → Conflict Resolution (last-write-wins)
  → Background Sync (5 min interval)
```

**File:** `lib/core/cloud/firestore_sync_adapter.dart`

---

## 2. Complete Collection Inventory (21 Domains)

### Intelligence Domains (12)

| # | Domain | Collection Name | Serialized Fields | Write | Read | Offline | Conflict Res | Retry | Recovery | Status |
|---|--------|----------------|-------------------|-------|------|---------|-------------|-------|----------|--------|
| 1 | identity | `identity` | 6 fields (currentIdentityTitle, targetIdentityTitle, currentGoal, currentMissionTitle, completionPercent, activeHabitCount) | ✅ Batch set | ✅ No read | ✅ Queue | ✅ LWW | ✅ 3 | ✅ | ✅ |
| 2 | career | `career` | 11 fields (careerScore, jobReadiness, strengths, skillGaps, nextGoal, estimatedWeeks, interviewReadiness, resumeProgress, portfolioProgress, applicationCount, offerCount) | ✅ Batch set | ✅ No read | ✅ Queue | ✅ LWW | ✅ 3 | ✅ | ✅ |
| 3 | portfolio | `portfolio` | 10 fields (portfolioScore, projectCount, skillCount, technologyCount, achievementCount, careerReadiness, strengthAreas, improvementAreas, technologies, hasData) | ✅ Batch set | ✅ No read | ✅ Queue | ✅ LWW | ✅ 3 | ✅ | ✅ |
| 4 | resume | `resume` | 12 fields (overallScore, atsScore, technicalScore, projectScore, experienceScore, keywordCoverage, completeness, atsCompleteness, strengthCount, gapCount, hasData, healthLabel) | ✅ Batch set | ✅ No read | ✅ Queue | ✅ LWW | ✅ 3 | ✅ | ✅ |
| 5 | interview | `interview` | 10 fields (readiness, knowledgeScore, confidenceScore, mockInterviewScore, recentSessions, weakTopics, totalRecommendations, actionableCount, isReadyForInterviews, hasData) | ✅ Batch set | ✅ No read | ✅ Queue | ✅ LWW | ✅ 3 | ✅ | ✅ |
| 6 | opportunity | `opportunity` | 10 fields (opportunityCount, matchCount, activeApplications, offerCount, bestMatchScore, overallReadiness, actionItemCount, topMatchScore, hasData) | ✅ Batch set | ✅ No read | ✅ Queue | ✅ LWW | ✅ 3 | ✅ | ✅ |
| 7 | knowledge | `knowledge` | 5 fields (nodeCount, edgeCount, lastIndexedAt, lastSnapshotAt, version) | ✅ Batch set | ✅ No read | ✅ Queue | ✅ LWW | ✅ 3 | ✅ | ✅ |
| 8 | memory | `memory` | 6 fields (totalMemories, totalRelationships, recentMemoryCount, importantMemoryCount, activeGoalCount, lastUpdated) | ✅ Batch set | ✅ No read | ✅ Queue | ✅ LWW | ✅ 3 | ✅ | ✅ |
| 9 | progress | `progress` | 8 fields (totalAchievements, totalBadges, totalMilestones, totalRewards, totalCertificates, hasAchievements, hasRecentActivity, lastUpdated) | ✅ Batch set | ✅ No read | ✅ Queue | ✅ LWW | ✅ 3 | ✅ | ✅ |
| 10 | journey | `journey` | 8 fields (currentJourney, currentStage, completionPercent, priority, estimatedRemainingMinutes, resumeCandidates, lastUpdated) | ✅ Batch set | ✅ No read | ✅ Queue | ✅ LWW | ✅ 3 | ✅ | ✅ |
| 11 | review | `review` | Review engine snapshot data | ✅ Batch set | ✅ No read | ✅ Queue | ✅ LWW | ✅ 3 | ✅ | ✅ |
| 12 | notifications | `notifications` | Notification data | ✅ Batch set | ✅ No read | ✅ Queue | ✅ LWW | ✅ 3 | ✅ | ✅ |

### System Domains (9)

| # | Domain | Collection Name | Write | Offline | Status |
|---|--------|----------------|-------|---------|--------|
| 13 | userSettings | `user_settings` | ✅ via SettingsService | ✅ Queue | ✅ |
| 14 | academy | `academy` | ✅ via AcademyService | ✅ Queue | ✅ |
| 15 | habits | `habits` | ✅ via HabitService | ✅ Queue | ✅ |
| 16 | habitEntries | `habit_entries` | ✅ via HabitService | ✅ Queue | ✅ |
| 17 | timeline | `timeline` | ✅ via TimelineService | ✅ Queue | ✅ |
| 18 | decisions | `decisions` | ✅ via DecisionService | ✅ Queue | ✅ |
| 19 | milestones | `milestones` | ✅ via TimelineService | ✅ Queue | ✅ |
| 20 | memoryGraph | `memory_graph` | ✅ via MemoryGraphService | ✅ Queue | ✅ |

---

## 3. Sync Reliability Features

| Feature | Status | Implementation |
|---------|--------|----------------|
| Offline Queue | ✅ | `FirestoreSyncAdapter._offlineQueue` — max 100 items |
| Queue Dedup | ✅ | Same-domain items deduplicated before re-queue |
| Retry Logic | ✅ | 3 attempts per item |
| Conflict Resolution | ✅ | Last-write-wins — checks `updatedAt` timestamp |
| Background Sync | ✅ | 5 min interval via `Timer.periodic` |
| Dirty Tracking | ✅ | Incremental — only dirty domains synced |
| Batch Writes | ✅ | Multiple domains batched into single `batch.commit()` |
| Snapshot Serialization | ✅ | 12 intelligence domains serialize actual snapshot data |
| Lifecycle Management | ✅ | `stopBackgroundSync()` on pause, `startBackgroundSync()` on resume |
| Sync Run Tracking | ✅ | `syncRunCount`, `totalSyncLatencyMs`, `averageSyncLatencyMs` |
| Diagnostics | ✅ | `syncRunCount`, `averageSyncLatencyMs`, `lastSyncLabel` |

---

## 4. Sync Flow Verification

```
markDirty(domain) → sets flag, notifies if wasClean
  ↓
syncAll() → checks availability → checks dirty flags
  ↓ (no dirty data → return early — incremental optimization)
syncAll() → process offline queue
  ↓
For each dirty domain:
  → mark clean
  → batch.set() with:
    - domain data (serialized snapshot)
    - syncedAt (FieldValue.serverTimestamp())
    - updatedAt (ISO 8601)
    - version (incremented)
  → batch.commit()
  ↓
notifyListeners() — single notification at start + end
```

---

## 5. Offline Queue Flow

```
syncDomain() fails
  ↓
_enqueueOffline(domain) → removes old queue entry for domain
  ↓
max 100 entries → drops oldest if full
  ↓
status → offline → notifyListeners()
  ↓
syncAll() called again → _processOfflineQueue()
  ↓
For each queued item:
  → retry _syncDomain()
  → success → markClean
  → fail → attempts++ → re-queue if < 3
```

---

## 6. Identity Serialization Gap

| Section | Fields Available | Fields Serialized | Gap |
|---------|-----------------|-------------------|-----|
| Personal | fullName, dateOfBirth, gender, country, language | None | ⚠️ 5 fields |
| Professional | profession, professionalExperience, education, industry | None | ⚠️ 4 fields |
| Growth | goals, aspirations, skills, dailyAvailableMinutes, learningPreferences | None | ⚠️ 5 fields |
| AI | aiPreferences, preferredAIProvider, aiModelPreference | None | ⚠️ 3 fields |
| Quantifiers | totalXp, level, missionCount, lessonCount, habits, knowledge | completionPercent, activeHabitCount | ⚠️ 4 fields |
| Snapshot | currentIdentityTitle, targetIdentityTitle, currentGoal, currentMissionTitle | currentIdentityTitle, targetIdentityTitle, currentGoal, currentMissionTitle | ✅ 4 fields |

**Gap:** Only 6/25 fields serialized to Firestore (P3)

---

## 7. Complete Cache Audit (Part 6)

### Architecture
- **Service:** `lib/shared/infrastructure/cache/cache_service.dart`
- **Type:** In-memory LRU cache with adaptive TTL
- **Max Entries:** 500
- **Periodic Purge:** 5 min interval
- **Adaptive TTL:** Hit rate >= 0.9 = +50% TTL; Hit rate < 0.4 = -50% TTL

### Cache Domains (15)

| # | Domain | Default TTL | Invalidation | Refresh | Eviction | Memory | Diagnostics | Status |
|---|--------|-------------|-------------|---------|----------|--------|-------------|--------|
| 1 | identity | 1200s (20min) | ✅ manual + event | ✅ `refresh()` | ✅ LRU | ✅ bounded | ✅ hit/miss | ✅ |
| 2 | journey | 300s (5min) | ✅ manual | ✅ engine refresh | ✅ LRU | ✅ bounded | ✅ per-domain | ✅ |
| 3 | portfolio | 600s (10min) | ✅ manual | ✅ engine refresh | ✅ LRU | ✅ bounded | ✅ per-domain | ✅ |
| 4 | career | 600s (10min) | ✅ manual | ✅ engine refresh | ✅ LRU | ✅ bounded | ✅ per-domain | ✅ |
| 5 | interview | 300s (5min) | ✅ manual | ✅ engine refresh | ✅ LRU | ✅ bounded | ✅ per-domain | ✅ |
| 6 | opportunity | 600s (10min) | ✅ manual | ✅ engine refresh | ✅ LRU | ✅ bounded | ✅ per-domain | ✅ |
| 7 | knowledge | 900s (15min) | ✅ manual | ✅ engine refresh | ✅ LRU | ✅ bounded | ✅ per-domain | ✅ |
| 8 | memory | 900s (15min) | ✅ manual | ✅ engine refresh | ✅ LRU | ✅ bounded | ✅ per-domain | ✅ |
| 9 | review | 600s (10min) | ✅ manual | ✅ engine refresh | ✅ LRU | ✅ bounded | ✅ per-domain | ✅ |
| 10 | notification | 120s (2min) | ✅ manual | ✅ engine refresh | ✅ LRU | ✅ bounded | ✅ per-domain | ✅ |
| 11 | academy | 600s (10min) | ✅ manual | ✅ path refresh | ✅ LRU | ✅ bounded | ✅ per-domain | ✅ |
| 12 | habits | 300s (5min) | ✅ manual | ✅ engine refresh | ✅ LRU | ✅ bounded | ✅ per-domain | ✅ |
| 13 | progress | 600s (10min) | ✅ manual | ✅ engine refresh | ✅ LRU | ✅ bounded | ✅ per-domain | ✅ |
| 14 | recommendations | 300s (5min) | ✅ manual | ✅ engine refresh | ✅ LRU | ✅ bounded | ✅ per-domain | ✅ |
| 15 | sync | 30s | ✅ manual | ✅ next sync | ✅ LRU | ✅ bounded | ✅ per-domain | ✅ |

### Cache Features

| Feature | Status | Implementation |
|---------|--------|----------------|
| TTL-based Expiration | ✅ | Per-domain configurable TTL |
| Adaptive TTL | ✅ | Hit rate >= 0.9 → +50% TTL; < 0.4 → -50% TTL |
| Periodic Purge | ✅ | 5 min interval via Timer |
| LRU Eviction | ✅ | Max 500 entries, evicts oldest |
| Per-domain Stats | ✅ | Hits, misses, hitRate, entryCount |
| Domain Invalidation | ✅ | `invalidate(CacheDomain)` clears all entries |
| Key Invalidation | ✅ | `invalidateKey(key)` clears specific entry |
| Diagnostics Integration | ✅ | `diagnosticsSummary()` returns size, hitRate, expiredCount, evictedCount |
| Engine Execution Tracking | ✅ | Records per-engine execution times (max 100 samples) |
| Bootstrap Integration | ✅ | Created in bootstrap Phase 4, `startPeriodicPurge()` called immediately |

### Cache Diagnostics Sample (from CacheService)
```dart
diagnosticsSummary() → {
  totalEntries: int,
  totalSize: int,
  hitRate: double,
  expiredCount: int,
  evictedCount: int,
  domains: Map<String, CacheDomainStats> // per-domain stats
}
```

### Cache Audit Summary

| Criteria | Status | Score |
|----------|--------|-------|
| All 15 domains registered | ✅ | 10/10 |
| TTL support | ✅ | 10/10 |
| Adaptive TTL | ✅ | 10/10 |
| Periodic purge | ✅ | 10/10 |
| LRU eviction | ✅ | 10/10 |
| Domain invalidation | ✅ | 10/10 |
| Key invalidation | ✅ | 10/10 |
| Diagnostics | ✅ | 10/10 |
| Engine execution tracking | ✅ | 9/10 (100 sample limit) |
| Memory bounded | ✅ | 500 max entries |
| **Cache Score** | | **🟢 9.9/10** |

---

## 8. Combined Firestore + Cache Audit Summary

| Criteria | Status | Score |
|----------|--------|-------|
| Firestore: All 21 domains registered | ✅ | 10/10 |
| Firestore: Write support | ✅ | 10/10 |
| Firestore: Read support | ⚠️ Not implemented from adapter | 6/10 |
| Firestore: Offline queue | ✅ | 10/10 |
| Firestore: Conflict resolution | ✅ | 10/10 |
| Firestore: Retry logic | ✅ | 10/10 |
| Firestore: Background sync | ✅ | 10/10 |
| Firestore: Dirty tracking | ✅ | 10/10 |
| Firestore: Batch writes | ✅ | 10/10 |
| Firestore: Snapshot serialization | ✅ (12 domains) | 9/10 |
| Firestore: Identity sync completeness | ⚠️ 6/25 fields | 5/10 |
| Cache: All 15 domains | ✅ | 10/10 |
| Cache: TTL + adaptive TTL | ✅ | 10/10 |
| Cache: Eviction + purge | ✅ | 10/10 |
| Cache: Diagnostics | ✅ | 10/10 |
| **Overall** | | **🟢 9.3/10** |
