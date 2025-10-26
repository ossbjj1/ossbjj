# OSS – BJJ Lernapp (iOS first)

## Sprint 2: Consent + Legal + Auth

**Status:** ✅ Complete (Analyze/Test grün, DSGVO-konform)

### Features
- ✅ Consent Modal: Analytics/Media Toggles mit Opt-in-Gate
- ✅ Legal Screens: Privacy Policy + Terms of Service (Placeholder)
- ✅ Auth: Email/Password Login/Signup/Reset (Supabase)
- ✅ Settings: Privacy Settings, Legal Links, Logout
- ✅ Router: Consent-Redirect beim Erststart

### Setup (Entwicklung)
```bash
cd app
flutter pub get

# Env-Variablen setzen (NIE committen!)
flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=eyJhb... \
            --dart-define=SENTRY_DSN=https://...
```

### Tests
```bash
flutter analyze  # 0 issues
flutter test     # 16 tests (11 router + 5 consent service)
```

### Wichtig vor Launch
- [ ] Legal-Texte in `features/legal/*_screen.dart` durch echte Policies ersetzen
- [ ] Supabase-Keys via CI/CD Secrets setzen (nicht lokal)
- [ ] PostHog optional nachaktivieren (aktuell disabled wegen API-Change)

### Test Coverage (MVP)
- ✅ ConsentService: Persistenz + Getters
- ✅ AuthService: Error-String-Mapping
- ✅ Router: Navigation + Hide-Rules
- ⚠️ Integration-Tests für Auth-Flows fehlen (Sprint 3)

---

## Governance

- WARP.md: Regeln für Warp (Auto‑Role, Checkpoints, Gates)
- context/agents: SSOT-Dateien (Auto‑Role Map, Acceptance, Soft‑Gates)

Entwickler-Hooks: Siehe `docs/DEV_HOOKS.md` (auto-format on commit, quick checks on push).
