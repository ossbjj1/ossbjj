# Roadmap (8 Sprints · iOS zuerst · MVP)

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

**Tasks:**
1. Onboarding-Form: Belt, Erfahrung, Wochenziel, Zieltyp, optional Altersgruppe
2. Speichern in `user_profile` (Supabase)
3. Settings erweitert: Sprache (DE/EN), Consent-Toggle, Audio-Feedback, Logout, "Konto löschen" (UI)
4. Home: Hero-Karte "Weiter machen"

**DoD:**
- Onboarding ≤60 s; Antworten werden gespeichert
- Settings ändert Sprache/Consent live

---

## Sprint 4 – DB-Schema & Seeds & Lernen-Katalog

**Ziel:** Strukturierter Inhalt, sichtbares Lernen.

**Tasks:**
1. Supabase Migrations: `user_profile`, `technique`, `technique_step`, `user_step_progress`
2. `seeds/techniques.json` (20 Techniken) + `seeds/steps.json` (100 Steps) – DE/EN Titel
3. Learn-Screen (`/learn`): Kategorien-Grid → Technikliste je Kategorie
4. Home-"Weiter machen": Client-Heuristik (erster nicht erledigter Step)

**DoD:**
- Kategorien und Techniklisten laden schnell
- "Weiter machen" zeigt plausiblen nächsten Step

---

## Sprint 5 – Technique + Step-Player (UI-Zustände)

**Ziel:** Lernkern bedienbar; Paywall-Teaser für Step >2.

**Tasks:**
1. Technique-Screen: Video-Header, Step-Liste mit current/completed/locked
2. Step-Player: Video 8–12 s, Checkliste, CTA "Fertig" (lokaler State)
3. Locked-Step → `/paywall` (Modal-Teaser, kein Kauf)
4. Atmosphäre: Tatami-Texture, Confetti (Lottie) bei lokalem Abschluss

**DoD:**
- Step 1–2 vollständig bedienbar (UI-seitig)
- Step 3 zeigt Paywall-Modal-Teaser

---

## Sprint 6 – Serverseitiges Gating + RLS + Account-Deletion

**Ziel:** Fortschritt nur via Server, sicher; Löschung funktionsfähig.

**Tasks:**
1. RLS: `user_step_progress` SELECT/INSERT nur `auth.uid()`
2. Edge-Fn `POST /gating/step-complete`:
   - Input: `{ technique_step_id }`
   - Checks: Auth, Step existiert, Prereq (idx-1), Freemium (idx ≤ 2) oder entitlement == 'premium'
   - UPSERT (PK user_id, technique_step_id), Idempotenz → 409 already_done
   - Rate-Limit: 10/Minute/Benutzer → 429
3. Client: "Fertig" immer → Server; UI spiegelt Antwort; Offline-Puffer
4. RPC `delete_user_data()` + Settings-Button verbindet RPC

**DoD:**
- Doppel-Tap erzeugt 1 Eintrag
- Free-User: Step 3 → 403 + Paywall-Modal
- Konto löschen entfernt Profil+Progress, loggt aus

---

## Sprint 7 – Statistik + Content-Roadmap + Achievements + Testimonials

**Ziel:** Retention-Features aktiv, User sieht kommenden Content + Erfolge.

**Tasks:**

### DB-Setup (3 neue Tabellen):
1. `content_roadmap` (id, release_date, title_en/de, description_en/de, technique_count, status)
2. `achievement` (id, key, title_en/de, description_en/de, icon, type, unlock_condition JSON)
3. `user_achievement` (user_id, achievement_id, unlocked_at, PK)
4. `testimonial` (id, user_name, user_belt, user_location, user_role, quote_en/de, rating, featured)

### Backend (Achievement-Granting):
5. `supabase/functions/gating_step_complete/` erweitern:
   - Nach erfolgreichem Step-Write: Achievement-Check (via service role)
   - Bedingungen: `steps_completed ≥ 1` → 'first_grip', `calc_streak_days(user_id) ≥ 7` → 'streak_7', `steps_completed ≥ 25` → 'steps_25', `count_completed_techniques ≥ 5` → 'tech_5'
   - UPSERT `user_achievement` (idempotent)
6. Optional: PostHog Event `achievement_unlocked` (nur mit Consent)

### Frontend (3 neue Widgets):
7. `features/home/widgets/content_roadmap_card.dart`:
   - Zeigt nächste 3–4 Releases (release_date, title, technique_count)
   - Status: ✅ released / 🔒 locked
   - Riverpod: `contentRoadmapProvider`
8. `features/stats/widgets/achievements_section.dart`:
   - Unlocked Achievements (Grid mit Icons)
   - Upcoming Achievements (Top 3, Fortschrittsbalken)
   - Riverpod: `userAchievementsProvider`, `allAchievementsProvider`
9. `features/home/widgets/testimonial_carousel.dart`:
   - Rotierendes Card mit Zitat, Name, Belt, Rating
   - Navigation: [← Zurück] [Weiter →]
   - Riverpod: `testimonialProvider`

### Seeds:
10. `seeds/content_roadmap.json` (4 Releases: Guard Passes, Leg Locks, Advanced Escapes, Takedowns)
11. `seeds/achievements.json` (6 Badges: first_grip, streak_7, steps_25, tech_5, purple_belt_ready, all_positions)
12. `seeds/testimonials.json` (3 Zitate: White Belt User, Blue Belt User, Coach)

### i18n:
13. Keys: `roadmap.*`, `achievements.*`, `testimonials.*`

### Stats-Screen (erweitert):
14. `/stats`: Streak (User-TZ, Kulanz ±30 Min), erledigte Steps/Techniken, "Wiederholen" (zuletzt gelernt)

**DoD:**
- Home-Screen zeigt Content-Roadmap (nächste 3 Releases sichtbar)
- Stats-Screen zeigt unlocked Achievements + Progress zu nächsten 3
- Home-Screen rotiert Testimonials (3 Zitate, Navigation funktioniert)
- Achievement "first_grip" wird nach Step 1 freigeschaltet (Server-Check funktioniert)
- Widget-Tests: `ContentRoadmapCard`, `AchievementsSection`, `TestimonialCarousel`
- Consent → Events (PostHog), CI grün

---

## Sprint 8 – Paywall + RevenueCat + iOS-Store-Paket

**Ziel:** Kauf/Restore/Entitlement-Sync; Apple-konform; Einreichung.

**Tasks:**
1. RevenueCat: Produkte (monthly, annual −25 %), Entitlement `premium`, optional 7-Tage-Trial
2. Paywall (endgültig): Preise/Zeiträume, "Käufe wiederherstellen", ethische Copy
3. Webhook `/rc/webhook`: Signaturprüfung, idempotentes Update `user_profile.entitlement`/`trial_end_at`
4. Client-Guard: `entitlement == 'premium'` → Steps >2 startbar; Restore triggert Server-Check
5. iOS Store Paket: Privacy Label, AGB/Datenschutz, Altersfreigabe 12+, Safety-Hinweis; TestFlight Käufe/Restore
6. A11y AA, Copy (Eagle-Fang), iOS-Assets/Privacy, In-App Deletion funktioniert

**DoD:**
- Free-User ab Step 3 blockiert; Pro-User frei
- Restore funktioniert; Entitlement spiegelt in Supabase
- App-Store Submit vollständig hochgeladen

---

## DoD Global (MVP-Ready)

- CI grün (format/analyze/test)
- CodeRabbit ✅
- Health `/health` (EU) 200 ✅
- Gating greift (Step 3 → 403 für Free)
- Paywall sichtbar + Restore ok
- Deletion path getestet
- Achievements unlock korrekt
- Content-Roadmap + Testimonials sichtbar

