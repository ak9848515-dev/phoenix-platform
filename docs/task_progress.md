# PHX-061 — Authentication Foundation

## Implementation Plan

### Phase 1: Auth Models & Storage
- [ ] Create `AuthUser` model (id, email, name, avatarUrl, etc.)
- [ ] Create `AuthSession` model (accessToken, refreshToken, expiresAt)
- [ ] Create `SecureStorageService` (wraps flutter_secure_storage)

### Phase 2: Auth Service
- [ ] Create `AuthService` with:
  - [ ] Persistent login (write to secure storage)
  - [ ] Secure logout (clear secure storage)
  - [ ] Session restoration (read from secure storage)
  - [ ] Token refresh support (update tokens)
  - [ ] Offline session support (check expiry, allow cached sessions)

### Phase 3: Screens & Flow
- [ ] Create `SplashScreen` — checks auth state on startup
- [ ] Create `LoginScreen` — email/password form
- [ ] Wire auth flow: Splash → Auth Check → (Login | Dashboard)
- [ ] Add `/splash`, `/login`, and `/auth-callback` routes

### Phase 4: Bootstrap Integration
- [ ] Update `AppBootstrap` to support auth initialization
- [ ] Update `main.dart` initial route to splash
- [ ] Ensure profile loads before dashboard

### Phase 5: Testing & Verification
- [ ] Auth service unit tests
- [ ] flutter analyze — 0 issues
- [ ] flutter test — all passing