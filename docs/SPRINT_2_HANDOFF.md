# SPRINT 2 – HANDOFF (Consent, Legal, Auth)

**Status:** ✅ Complete
**Branch:** sprint-2/consent-auth
**PR:** #5 (https://github.com/ossbjj1/ossbjj/pull/5)
**Issue Summary:** #6 (https://github.com/ossbjj1/ossbjj/issues/6)

---

## Scope & Deliverables

### What was built
1. **Consent Modal (DSGVO-compliant)**
   - Fullscreen modal at first launch; legal routes whitelisted
   - Toggles: Analytics, Media (persisted via ConsentService → SharedPreferences)
   - Links to Privacy + Terms
   - Re-initializes AnalyticsService only when analytics consent granted

2. **Auth System (Supabase)**
   - Login, Signup, Reset Password screens
   - AuthService wrapper: signUp, signIn, signOut, resetPassword
   - Error mapping (invalid credentials, email validation, timeout, generic)
   - AuthResult (success/failure) with user + error fields

3. **Legal Screens**
   - Privacy Policy, Terms of Service
   - Shared LegalDocumentScreen for reusability

4. **Settings Screen (Extended)**
   - Legal links (Privacy, Terms)
   - Logout action (visible only when user logged in)
   - Layout: ListTile nav pattern
   - Placeholder for Sprint 3: Language, Audio feedback, Delete account

5. **Router Enhancements**
   - Factory pattern with DI: authService, consentService, analyticsService
   - Consent redirect on first launch (legal routes exempt)
   - Bottom nav hide-rules intact (consent, paywall, auth, legal routes → no nav)

6. **Docs Hygiene**
   - README.md: fenced code block formatting normalized
   - SPRINT_1_HANDOFF.md: blank line before ```bash fixed
   - Roadmap updated: Sprint 2 marked ✅ Done, PR #5 referenced

---

## Implementation Details

### ConsentService (core/services/consent_service.dart)
```
- Properties: analytics (bool), media (bool), shown (bool)
- Methods: load(), setAnalytics(bool), setMedia(bool), markShown()
- Persists to SharedPreferences; defaults false
```

### AnalyticsService (core/services/analytics_service.dart)
```
- initIfAllowed(analyticsAllowed: bool) — gate for Sentry/PostHog init
- No telemetry until consent granted (idempotent)
- PII stripping in Sentry beforeSend hook
```

### AuthService (core/services/auth_service.dart)
```
- Supabase integration: signUp, signIn, signOut, resetPassword
- Error mapping via regex on Supabase AuthException
- AuthResult factory (success/failure) — explicit error surfacing
- currentUser getter (null if not initialized or not logged in)
```

### Auth Screens
- **LoginScreen:** Email + Password input, login CTA, forgot password link, signup redirect
- **SignupScreen:** Email + Password input; password complexity (8+ chars, 3 of: upper/lower/digit/special); signup CTA; login redirect
- **ResetPasswordScreen:** Email input; proper validation message (AuthStrings.errEmailEmpty); send link CTA

### Auth Strings (core/strings/auth_strings.dart)
```
- Errors: errEmailEmpty, errEmailInvalid, errPasswordInvalid, errLoginUnavailable, errGeneric
- All Eagle-Fang tone (imperative, respectful, PG-13)
```

### Router Configuration (router.dart)
```
- createRouter(forceConsent, consentService, analyticsService, authService)
- Consent redirect exempts legal routes (GDPR compliance)
- Shell route: 4 tabs + hide-rules for modal/auth/legal/future routes
- Modal routes: consent, paywall (fullscreen)
- Auth/Legal: login, signup, resetPassword, privacy, terms
```

### Settings Screen
```
- List of menu items: Privacy settings, Legal links, Logout (conditional)
- Navigation to consent (/consent), privacy (/privacy), terms (/terms)
- Auth-aware: logout only shown if currentUser != null
```

---

## Acceptance Criteria Met

✅ **Consent Gating**
- Analytics (Sentry) only initialized after opt-in
- No telemetry without consent

✅ **Auth Flows**
- Signup → account created, success message, navigate home
- Login → user session, navigate home
- Logout → sign out, message, local state cleared
- Reset → email sent, message, nav back

✅ **Legal Compliance**
- Privacy + Terms screens accessible from Settings and Consent modal
- Legal routes bypass consent redirect

✅ **UI/UX**
- Signup/Login validation messages clear
- Settings integrates logout + legal links
- Consent modal prominent on first launch

✅ **Code Quality**
- flutter analyze: 0 issues
- flutter test: all green (11+ tests)
- Pre-commit formatting: pass
- No secrets in code

---

## Testing Status

### Test Files
- app/test/services/consent_service_test.dart — 5 tests (load, set, persist)
- app/test/services/auth_service_test.dart — 3 tests (error mapping, AuthResult factories)
- app/test/router_test.dart — 6+ tests (router nav, hide-rules from Sprint 1)
- app/test/widgets/bottom_nav_test.dart — 4 tests (nav rendering, active state, a11y)

### CI/CD Status
- GitHub Actions: flutter format, analyze, test ✅
- Pre-commit hooks: dart-format ✅
- Pre-push hooks: no additional checks

---

## Known Limitations & TODOs

1. **Separate Confirm Password Field**
   - Signup MVP has single password field (TODO comment in code)
   - Sprint 3+ can add separate confirm field with match validation

2. **Supabase Configuration**
   - .env file must be populated with Supabase credentials (SUPABASE_URL, SUPABASE_ANON_KEY)
   - AnalyticsService skips PostHog init (MVP: API complex)

3. **Analytics Events**
   - PostHog event tracking scaffold in place; `track()` is no-op MVP
   - Sprint 7+ will implement achievement events

4. **User Profile Persistence**
   - Auth user created; user_profile table not yet seeded/managed
   - Sprint 3 will add onboarding form → user_profile insert

5. **Delete Account**
   - Settings UI placeholder only; RPC `delete_user_data()` stub
   - Sprint 6+ will implement server-side deletion

---

## File Structure (Sprint 2 Final)

```
app/lib/
├── core/
│   ├── services/
│   │   ├── consent_service.dart (new)
│   │   ├── analytics_service.dart (new)
│   │   ├── auth_service.dart (new)
│   │   └── ...
│   ├── strings/
│   │   ├── auth_strings.dart (enhanced)
│   │   └── ...
│   ├── navigation/
│   │   ├── routes.dart (constants)
│   │   └── route_orientation_controller.dart
│   └── ...
├── features/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── reset_password_screen.dart
│   ├── consent/
│   │   └── consent_modal.dart
│   ├── legal/
│   │   ├── privacy_screen.dart
│   │   ├── terms_screen.dart
│   │   └── legal_document_screen.dart (shared)
│   ├── settings/
│   │   └── settings_screen.dart (enhanced)
│   └── ...
├── router.dart (factory + DI)
└── main.dart

app/test/
├── services/
│   ├── consent_service_test.dart
│   └── auth_service_test.dart
├── router_test.dart
├── widgets/bottom_nav_test.dart
└── widget_test.dart
```

---

## Commits in Sprint 2

| Commit | Message |
|--------|---------|
| 11df531 | fix: correct empty email validation message in reset password screen |
| 98e170e | fix(coderabbit): 14 findings - analytics PII, auth guards, validation, i18n |
| 6bab6a7 | resolve: merge conflicts with main for Sprint 2 (keep Sprint-2 features) |
| 0fa4406 | feat(sprint-2): Consent + Legal + Auth (MVP, DSGVO) |
| 24c65bf | docs(roadmap): mark Sprint 1 complete and add SPRINT_1_HANDOFF.md |

---

## Next Steps: Sprint 3

**Focus:** Onboarding + Settings (Basis)

### Sprint 3 Tasks
1. **Onboarding Flow** (~60 s):
   - Belt level (Beginner, Intermediate, Advanced)
   - Experience (Years of training)
   - Weekly goal (Sessions per week)
   - Goal type (Flexibility, Strength, Technique)
   - Optional: Age group (U18, 18-30, 30-40, 40+)
   - Save to `user_profile` (Supabase)

2. **Settings Extensions**:
   - Language toggle (DE/EN) → live app text update
   - Consent re-open
   - Audio feedback toggle (placeholder)
   - Logout action (already present)
   - "Delete account" UI (RPC stub)

3. **Home Screen Hero Card**
   - "Weiter machen" (Continue) card
   - Shows last/recommended next step (client heuristic)

### Sprint 3 DoD
- Onboarding completes in ≤60 s
- Settings: language change reflects UI immediately
- User profile persists and loads on app restart

### Dependencies
- Supabase: user_profile table with schema (belt, experience, weekly_goal, goal_type, age_group)
- i18n: onboarding copy keys in ARB (DE/EN)
- Riverpod: userProfileProvider for async state management

---

## Environment Setup (for next chat)

### .env File (app/.env)
```
SUPABASE_URL=<your-supabase-url>
SUPABASE_ANON_KEY=<your-anon-key>
SENTRY_DSN=<optional>
POSTHOG_API_KEY=<optional>
```

### Supabase Schema (ready for Sprint 3)
- user_profile table (id, user_id, belt, experience, weekly_goal, goal_type, age_group, created_at, updated_at)
- RLS: SELECT/INSERT/UPDATE own rows only (auth.uid())

### Flutter & CI
- Flutter 3.35.5 stable
- Dart 3.9.2
- CI: github-actions.yml runs format/analyze/test on PR
- Lefthook: pre-commit (dart-format), pre-push (no-op)

---

## How to Resume in Sprint 3

1. **Checkout branch:**
   ```bash
   git fetch origin sprint-2/consent-auth
   git checkout sprint-2/consent-auth
   ```

2. **Create Sprint 3 branch:**
   ```bash
   git checkout -b sprint-3/onboarding-settings
   ```

3. **Run baseline:**
   ```bash
   cd app && flutter pub get && flutter analyze && flutter test
   ```

4. **Read roadmap:**
   - docs/roadmap/OSS_ROADMAP_S0-S4.md (Sprint 3 section)
   - docs/OSS_PRODUCT_CONTEXT.md (onboarding flows)
   - docs/i18n_keys.json (microcopy patterns)

5. **Start Warp chat with this handoff as context** → builds Sprint 3 screens + logic

---

## Critical Files for Reference

- **Roadmap:** docs/roadmap/OSS_ROADMAP_INDEX.md, OSS_ROADMAP_S0-S4.md
- **Architecture Decisions:** docs/adr/{001_gi_nogi_separate_progress, 002_server_side_only_gating, 003_achievement_json_conditions}
- **Product Context:** docs/OSS_PRODUCT_CONTEXT.md
- **Tone Guide:** docs/OSS_TONE_EAGLE_FANG.md
- **i18n Keys:** docs/i18n_keys.json
- **DB Schema:** docs/DB_SCHEMA_MIN.sql
- **WARP Rules:** WARP.md (project-specific directives)

---

## Quick Health Check (next chat kickoff)

Run these to confirm everything is ready:

```bash
cd /Volumes/Project_SSD/OSS!/oss/app
flutter pub get
flutter analyze                    # Should be 0 issues
flutter test -r expanded          # Should be all green
flutter format --set-exit-if-changed lib/ test/  # Should be 0 changes needed
```

If all pass → **ready for Sprint 3**.

---

**Prepared by:** Warp Agent (Sprint 2 completion)
**Date:** 2025-10-26 16:44 UTC
**Status:** Ready for handoff
