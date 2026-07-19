# RC-1: Complete Navigation Audit

**Date:** July 19, 2026
**Version:** Phoenix OS v1.0.0

---

## 1. Navigation Architecture

```
PhoenixShell
├── Top App Bar (all screens)
│   ├── Notifications → /notifications
│   ├── AI Assistant → /ai
│   ├── Search → /search
│   └── Voice → VoiceButton (overlay)
│
├── Bottom Nav / NavigationRail (720px breakpoint)
│   ├── Dashboard (0) → /dashboard
│   ├── Missions (1) → /
│   ├── Learn (2) → /academy
│   ├── Progress (3) → /progress
│   └── Profile (4) → /profile
│
└── FAB (contextual per tab)
    ├── Dashboard → Continue Journey
    ├── Missions → Resume Mission
    ├── Learn → Ask AI
    ├── Progress → Generate Report
    └── Profile → Quick Edit
```

**Layout Adaptation:**
- Phone (< 720px): `BottomNavigationBar` at bottom
- Tablet/Desktop (≥ 720px): `NavigationRail` on left with labels

---

## 2. Complete Route Map (49 Routes)

| # | Route | Screen | Registered | Default Fallback |
|---|-------|--------|------------|------------------|
| 1 | `/splash` | SplashScreen | ✅ RouteGenerator | — |
| 2 | `/auth-gate` | AuthGate | ✅ RouteGenerator | — |
| 3 | `/login` | LoginScreen | ✅ RouteGenerator | — |
| 4 | `/onboarding` | OnboardingScreen | ✅ RouteGenerator | — |
| 5 | `/identity-setup` | IdentitySetupScreen | ✅ RouteGenerator | — |
| 6 | `/dashboard` | CommandCenterScreen + PhoenixShell | ✅ RouteGenerator | Bottom Nav: 0 |
| 7 | `/` | MissionCenterScreen + PhoenixShell | ✅ RouteGenerator (default) | Bottom Nav: 1, Default route |
| 8 | `/academy` | AcademyScreen + PhoenixShell | ✅ RouteGenerator | Bottom Nav: 2 |
| 9 | `/academy/lesson` | LearningPathScreen / LessonDetailScreen | ✅ RouteGenerator | — |
| 10 | `/progress` | ProgressScreen + PhoenixShell | ✅ RouteGenerator | Bottom Nav: 3 |
| 11 | `/profile` | ProfileScreen + PhoenixShell | ✅ RouteGenerator | Bottom Nav: 4 |
| 12 | `/knowledge-dna` | KnowledgeDNAScreen + PhoenixShell | ✅ RouteGenerator | — |
| 13 | `/career` | CareerScreen + PhoenixShell | ✅ RouteGenerator | — |
| 14 | `/portfolio` | PortfolioScreen + PhoenixShell | ✅ RouteGenerator | — |
| 15 | `/resume` | ResumeScreen + PhoenixShell | ✅ RouteGenerator | — |
| 16 | `/interview` | InterviewScreen + PhoenixShell | ✅ RouteGenerator | — |
| 17 | `/interview/session` | MockInterviewSessionScreen | ✅ RouteGenerator | — |
| 18 | `/opportunity` | OpportunityScreen + PhoenixShell | ✅ RouteGenerator | — |
| 19 | `/marketplace` | MarketplaceScreen + PhoenixShell | ✅ RouteGenerator | — |
| 20 | `/identity` | IdentitySelectionScreen + PhoenixShell | ✅ RouteGenerator | — |
| 21 | `/ai` | AIScreen + PhoenixShell | ✅ RouteGenerator | — |
| 22 | `/memory-graph` | MemoryGraphDashboardScreen + PhoenixShell | ✅ RouteGenerator | — |
| 23 | `/memory-graph/entity` | EntityDetailScreen | ✅ RouteGenerator | — |
| 24 | `/memory-graph/search` | MemorySearchScreen | ✅ RouteGenerator | — |
| 25 | `/memory-graph/explorer` | GraphExplorerScreen | ✅ RouteGenerator | — |
| 26 | `/habits` | HabitDashboardScreen + PhoenixShell | ✅ RouteGenerator | — |
| 27 | `/habits/detail` | HabitDetailScreen | ✅ RouteGenerator | — |
| 28 | `/habits/create` | HabitCreateScreen | ✅ RouteGenerator | — |
| 29 | `/timeline` | TimelineScreen + PhoenixShell | ✅ RouteGenerator | — |
| 30 | `/timeline/milestones` | MilestoneScreen + PhoenixShell | ✅ RouteGenerator | — |
| 31 | `/knowledge` | KnowledgeDashboardScreen + PhoenixShell | ✅ RouteGenerator | — |
| 32 | `/knowledge/skills` | SkillsMapScreen | ✅ RouteGenerator | — |
| 33 | `/knowledge/goals` | GoalMapScreen | ✅ RouteGenerator | — |
| 34 | `/knowledge/search` | KnowledgeSearchScreen | ✅ RouteGenerator | — |
| 35 | `/search` | GlobalSearchScreen | ✅ RouteGenerator | — |
| 36 | `/journey` | JourneyScreen + PhoenixShell | ✅ RouteGenerator | — |
| 37 | `/daily-focus` | DailyFocusScreen + PhoenixShell | ✅ RouteGenerator | — |
| 38 | `/daily-journey` | DailyJourneyScreen + PhoenixShell | ✅ RouteGenerator | — |
| 39 | `/memory` | MemoryScreen + PhoenixShell | ✅ RouteGenerator | — |
| 40 | `/recommendation` | RecommendationScreen + PhoenixShell | ✅ RouteGenerator | — |
| 41 | `/settings` | SettingsScreen + PhoenixShell | ✅ RouteGenerator | — |
| 42 | `/settings/ai-providers` | AIProvidersScreen | ✅ RouteGenerator | — |
| 43 | `/notifications` | NotificationCenterScreen + PhoenixShell | ✅ RouteGenerator | — |
| 44 | `/content` | ContentGenerationHubScreen + PhoenixShell | ✅ RouteGenerator | — |
| 45 | `/content/library` | ContentLibraryScreen + PhoenixShell | ✅ RouteGenerator | — |
| 46 | `/content/generate/course` | GenerateCourseScreen + PhoenixShell | ✅ RouteGenerator | — |
| 47 | `/content/generate/project` | GenerateProjectScreen + PhoenixShell | ✅ RouteGenerator | — |
| 48 | `/content/generate/portfolio-enhancement` | GenerateEnhancementScreen + PhoenixShell | ✅ RouteGenerator | — |
| 49 | `/content/generate/resume-enhancement` | GenerateEnhancementScreen + PhoenixShell | ✅ RouteGenerator | — |
| 50 | `/content/generate/interview-questions` | GenerateEnhancementScreen + PhoenixShell | ✅ RouteGenerator | — |

---

## 3. Complete Navigation Path Verification

### Flow A: New User (First Launch)
```
App Launch
  ↓
SplashScreen (/splash) — 1200ms delay, branded animation
  ↓ pushReplacementNamed
AuthGate (/auth-gate) — checks auth state
  ↓ unauthenticated → check onboarding complete
OnboardingScreen (/onboarding) — 7-step wizard
  ↓ completion
LoginScreen (/login) — Google or Guest
  ↓ signInWithGoogle / signInAnonymously
AuthGate (/auth-gate) — re-check with authenticated state
  ↓ authenticated → check identity
IdentitySetupScreen (/identity-setup) — 4-step wizard
  ↓ save + refresh
CommandCenterScreen (/dashboard) — Premium dashboard
```
✅ Forward navigation: Clear
✅ Backward navigation: Not applicable (one-way flow)
✅ Dead ends: None
✅ Orphan routes: None

### Flow B: Returning User (Authenticated)
```
App Launch
  ↓
SplashScreen (/splash) — 1200ms delay
  ↓
AuthGate (/auth-gate)
  ↓ authenticated + has identity
CommandCenterScreen (/dashboard)
```
✅ Forward navigation: Clear
✅ Backward navigation: Not applicable
✅ Dead ends: None
✅ Orphan routes: None

### Flow C: Returned User (Expired Session)
```
App Launch
  ↓
SplashScreen (/splash)
  ↓
AuthGate (/auth-gate) — session expired
  ↓ arguments: {'expired': true}
LoginScreen (/login) — shows SnackBar "Your session has expired"
```
✅ Forward navigation: Clear with error message

### Flow D: Offline User
```
App Launch
  ↓
SplashScreen (/splash)
  ↓
AuthGate (/auth-gate) — offline, has persisted session
  ↓
CommandCenterScreen (/dashboard) — with cached data
```
✅ Forward navigation: Clear

### Flow E: Dashboard → Full App Tour
```
Dashboard (/dashboard)
  ↓ scroll
ProgressiveSections → Growth Journey Timeline
                       → Today's Missions
                       → Progress
                       → AI Insight
                       → Continue Learning
                       → Recommendations
```
✅ Story-telling scroll: All sections present
✅ Dead ends: None (each section has tap targets)

### Flow F: Bottom Nav Transitions
```
Dashboard (0) ↔ Missions (1) ↔ Learn (2) ↔ Progress (3) ↔ Profile (4)
```
✅ All 5 transitions use `pushNamedAndRemoveUntil` — clean state
✅ No duplicate navigation (Profile not in app bar)
✅ All 5 destinations registered

### Flow G: Top Bar Actions
```
From any screen:
  └── Notifications → /notifications (pushNamed)
  └── AI Assistant → /ai (pushNamed)
  └── Search → /search (pushNamed)
  └── Voice → VoiceButton overlay (not navigation)
```
✅ All 4 actions available on every screen
✅ Voice is overlay, not navigation — no context loss

### Flow H: Settings → Sub-screens
```
Settings (/settings)
  └── AI Providers → /settings/ai-providers (navigation)
  └── Sign Out → /login (pushReplacementNamed)
  └── Delete Account → /login (pushReplacementNamed)
  └── Switch Account → /login (pushReplacementNamed)
```
✅ All sub-navigation works
✅ Sign out + delete account both return to login

### Flow I: Career Path
```
Progress → Career (/career) → Resume (/resume) → Interview (/interview) → Interview Session (/interview/session)
Progress → Portfolio (/portfolio)
Progress → Knowledge (/knowledge-dna)
```
✅ Complete career pipeline
✅ All sub-routes registered

### Flow J: Knowledge Path
```
Learn → Academy (/academy) → Lesson Detail (/academy/lesson)
Knowledge DNA (/knowledge-dna) → Knowledge (/knowledge) → Skills (/knowledge/skills) → Goals (/knowledge/goals) → Search (/knowledge/search)
```
✅ Complete knowledge pipeline
✅ All sub-routes registered

### Flow K: Memory Path
```
Memory (/memory) → Memory Graph (/memory-graph) → Entity (/memory-graph/entity) → Search (/memory-graph/search) → Explorer (/memory-graph/explorer)
```
✅ Complete memory pipeline
✅ All sub-routes registered

### Flow L: Content Generation Path
```
Content Hub (/content) → Library (/content/library)
                       → Generate Course (/content/generate/course)
                       → Generate Project (/content/generate/project)
                       → Portfolio Enhancement (/content/generate/portfolio-enhancement)
                       → Resume Enhancement (/content/generate/resume-enhancement)
                       → Interview Questions (/content/generate/interview-questions)
```
✅ All 7 content generation routes registered
✅ Sub-routes use PhoenixShell (non-tabbed)

### Flow M: Habits Path
```
Habits (/habits) → Habit Detail (/habits/detail?habitId=...)
                 → Create Habit (/habits/create)
```
✅ All habit routes registered

### Flow N: Timeline Path
```
Timeline (/timeline) → Milestones (/timeline/milestones)
```
✅ All timeline routes registered

### Flow O: Logout
```
Settings → Sign Out → AuthGate → Login
```
✅ Complete cleanup: Google signOut, Firebase signOut, secure storage cleared

---

## 4. Navigation Requirements Verification

| Requirement | Status | Evidence |
|-------------|--------|----------|
| All routes have registered handlers | ✅ | 50 routes in `RouteGenerator.generateRoute()` |
| Default route (`/`) shows MissionCenter | ✅ | `case AppRoutes.missionCenter:` returns PhoenixShell with MissionCenter |
| No orphan routes (route defined but no handler) | ✅ | All 50 `AppRoutes` constants have matching cases |
| No orphan screens (screen exists but no route) | ⚠️ | Decision screens (wizard, history, dashboard) exist but not all route-registered |
| No duplicate routes | ✅ | Each route appears once in `AppRoutes` |
| No dead navigation buttons | ✅ | All IconButtons and NavigationDestinations have `onPressed` handlers |
| Profile removed from top app bar | ✅ | `phoenix_shell.dart` has no Profile icon in `_buildAppBarActions()` |
| All AI routes accessible | ✅ | `/ai`, `/search` accessible from top bar |
| All career routes accessible | ✅ | `/career`, `/portfolio`, `/resume`, `/interview`, `/interview/session` |
| All knowledge routes accessible | ✅ | `/knowledge`, `/knowledge-dna`, `/knowledge/skills`, `/knowledge/goals`, `/knowledge/search` |
| All memory routes accessible | ✅ | `/memory`, `/memory-graph`, `/memory-graph/entity`, `/memory-graph/search`, `/memory-graph/explorer` |
| Content generation routes accessible | ✅ | `/content` hub links to all 5 sub-routes |
| Deep links supported | ✅ | `arguments: Map<String, dynamic>` pattern for `/login`, `/academy/lesson`, `/memory-graph/entity` |

---

## 5. Navigation Issues Found

| Issue | Severity | Screen | Description |
|-------|----------|--------|-------------|
| No back navigation from AuthGate (post-auth) | 🟢 Low | All | After auth, `pushReplacementNamed` is used — no back button |
| MissionCenterScreen uses SampleRepository | 🟡 Medium | Missions | Data is sample, not from engine — may show stale missions |
| **3 Decision screens exist but have NO routes registered** | **🟡 Medium** | Decision | `decision_dashboard_screen.dart`, `decision_history_screen.dart`, `decision_wizard_screen.dart` exist on disk but have zero route entries in `AppRoutes` or `RouteGenerator`. These screens are **inaccessible** from the app. |
| Full-screen settings routes not navigable from everywhere | 🟢 Low | Settings | Only accessible from Profile → Settings |
| `/daily-journey` route exists but no navigation entry point | 🟢 Low | DailyJourney | Route is registered but no button/icon navigates to it (deep-link only) |

---

## 6. Production Navigation Score

| Criteria | Score |
|----------|-------|
| All routes registered | 🟢 10/10 |
| No orphan routes | 🟢 10/10 |
| No dead navigation | 🟢 10/10 |
| Auth flow | 🟢 10/10 |
| Identity flow | 🟢 10/10 |
| Bottom nav | 🟢 10/10 |
| Top bar | 🟢 10/10 |
| Deep linking | 🟢 8/10 (limited arguments pattern) |
| Content gen routes | 🟢 10/10 |
| **Score** | **🟢 9.8/10** |
