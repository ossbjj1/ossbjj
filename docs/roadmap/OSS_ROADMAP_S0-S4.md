# Roadmap Sprint 0–4 (Foundation Phase)

## Sprint 0 – Projekt-Fundament

**Ziel:** Buildbar, UI-Kit angeschlossen, CI+Gates aktiv.

**Tasks:**
1. Monorepo anlegen: `/app/lib/{features,core,theme}`, `/server/supabase/{migrations,functions}`
2. UI-Tokens: `design/tokens/{colors.json, typography.json}` → `lib/theme/`
3. `app/lib/theme/` – ColorScheme.dark aus Tokens; Button/Card Styles
4. `infra/ci/github-actions.yml`: flutter format, flutter analyze, flutter test minimal
5. `/server/supabase/functions/health/` – GET /health 200 (Deno/TS)
6. `.coderabbit.yaml` mit Must-Fix Regeln
7. `docs/PR_TEMPLATE.md`: BMAD/PRP-Checkliste + Health-Link Platzhalter
8. PostHog/Sentry registrieren (nicht initialisieren)

**DoD:**
- iOS Dev-Build startet; CI grün
- Health-Endpoint deployed und im PR verlinkbar
- CodeRabbit auf PRs aktiv

---

## Sprint 1 – Navigation-Shell + Bottom-Nav

**Ziel:** Tab-Navigation steht; alle Top-Screens als Stubs.

**Status:** ✅ Done (CI grün; Analyze/Test/Format bestanden)

**Tasks:**
1. `lib/router.dart`: Shell-Route mit 4 Tabs → `/home`, `/learn`, `/stats`, `/settings`
2. Bottom-Nav-Widget: Icons/Labels (DE/EN) + Active-State (AA)
3. Stubs: `features/{home,learn,stats,settings}` Screens (Figma Layout übertragen)
4. Modale Stubs: `features/{consent, paywall}` (Vollbild-Modal mit "X")
5. Hide-Rule: Bottom-Nav verstecken auf `/technique`, `/step`, Modalrouten
6. i18n-Keys: `tab.*`, `nav.title.*`, `cta.continue`, `cta.save`

**DoD:**
- Per Tabs wechselbar; korrekte Sichtbarkeit/Hide-Regeln
- Figma-Layouts visuell erkennbar (Stub-Inhalte ok)

---

## Sprint 2 – Consent (DSGVO) + Legal + Auth

**Ziel:** Nutzereinwilligung + Konto.

**Status:** ✅ Done (Consent opt-in gates analytics; Auth + Legal + Settings implemented)

**Tasks:**
1. Consent-Modal: Toggles Analytics, Media; Links zu Privacy/AGB
2. Runtime-Gate: PostHog/Sentry nur bei `consent_analytics == true`
3. Auth-Screens: Login/Signup/Reset mit Supabase E-Mail/Passwort
4. Settings: Legal-Links sichtbar

**DoD:**
- Ohne Consent: keine Telemetrie
- Signup/Login/Logout stabil

---

## Sprint 3 – Onboarding + Settings (Basis)

**Ziel:** Personalisierung; Basis-Einstellungen vollständig.

**Status:** ✅ Done (PR #7, Issue #8)
- Onboarding Screen mit Belt/Exp/Goal/Type + Validierung + Upsert
- Settings: Live-i18n (DE/EN), Audio‑Feedback, Privacy/Legal/Logout
- Home ContinueCard mit Hint oder Onboarding‑CTA
- Router Redirects (Consent → Onboarding)
- DB: user_profile + RLS + Constraints
- i18n: Runtime Strings mit Safe Accessors
- Services: DI, Persist‑First, Notifiers (Audio/Locale)
- Tests: Router Redirects, Profile Validation
- Lint: 0 Issues, Tests Green

**Tasks:**
1. Onboarding-Form: Belt, Erfahrung, Wochenziel, Zieltyp, optional Altersgruppe ✅
2. Speichern in `user_profile` (Supabase) ✅
3. Settings erweitert: Sprache (DE/EN), Consent-Toggle, Audio-Feedback, Logout, "Konto löschen" (UI) ✅
4. Home: Hero-Karte "Weiter machen" ✅

**DoD:**
- Onboarding ≤60 s; Antworten werden gespeichert ✅
- Settings ändert Sprache/Consent live ✅

---

## Sprint 4 – DB-Schema & Seeds & Lernen-Katalog

**Ziel:** Strukturierter Inhalt, sichtbares Lernen.

**Tasks:**
1. Supabase Migrations: `user_profile`, `technique`, `technique_step`, `user_step_progress` — ✅ Done
2. `seeds/techniques.json` (20 Techniken) + `seeds/steps.json` (100 Steps) – DE/EN Titel
3. Learn-Screen (`/learn`): Kategorien-Grid → Technikliste je Kategorie
4. Home-"Weiter machen": Client-Heuristik (erster nicht erledigter Step)

**DoD (aktueller Status):**
- Kategorien und Techniklisten laden schnell — ⏳ Open (Seeds/Screen fehlen)
- "Weiter machen" zeigt plausiblen nächsten Step — ⏳ Open (Heuristik fehlt)

**Carryover / TODO:**
- Seeds Step-Count Angleichen: aktuell 94 Steps; DoD fordert 100–120. Option A) +6–26 Steps ergänzen (gi/nogi duplizieren falls sinnvoll). Option B) DoD/Docs auf 80–120 anpassen (Validator bereits 80–120). Owner: Content/DB. Sprint: 4→5.
