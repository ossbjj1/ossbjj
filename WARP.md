# WARP.md

Zweck
- Diese Datei steuert, wie Warp in diesem Repo arbeitet. Vor jeder Aufgabe lesen und befolgen.

Roadmap-Pflicht
- Vor jeder Aufgabe: `docs/roadmap/OSS_ROADMAP_INDEX.md` lesen → relevanten Sprint-File öffnen
- `docs/OSS_PRODUCT_CONTEXT.md` für Use-Cases/Flows
- `docs/i18n_keys.json` für Microcopy (maschinenlesbar)
- `docs/adr/` für architektonische Entscheidungen
- Dateipfade aus Roadmap übernehmen (kein Raten)

Repo-Struktur (SSOT)
```
/app/
  lib/
    app.dart
    router.dart
    theme/
    l10n/
    core/{design_tokens,services}/
    features/
      home/
      learn/
      technique/
      step_player/
      paywall/
      stats/
      settings/
      onboarding/
      auth/
      consent/
  pubspec.yaml

/server/supabase/
  migrations/
  policies/
  functions/
    gating_step_complete/
    rc_webhook/
    health/
  rpc/delete_user_data.sql

/seeds/ {techniques.json, steps.json, content_roadmap.json, achievements.json, testimonials.json}
/design/ {tokens/, assets/}
/infra/ci/github-actions.yml
/docs/ {OSS_ROADMAP_v1.md, OSS_PRODUCT_CONTEXT.md, OSS_TONE_EAGLE_FANG.md, API_CONTRACTS.md, DB_SCHEMA_MIN.sql, PR_TEMPLATE.md}
/context/agents/ {_acceptance_v1.1.md, _auto_role_map.md, reqing-ball.md, ui-polisher.md}
.coderabbit.yaml
WARP.md
README.md
```
- **Features:** 1 Ordner pro Screen/Flow (z.B. `features/home/`, `features/stats/`)
- **Core:** Shared Code (services, design_tokens, utils)
- **Migrations:** SQL-Dateien chronologisch (`001_initial.sql`, `002_achievements.sql`)
- **Functions:** 1 Ordner pro Edge Fn (z.B. `gating_step_complete/index.ts`)
- **Seeds:** JSON-Dateien für Testdaten (techniques, steps, roadmap, achievements, testimonials)

Operating Rules
- Pflicht-Checkpoints in jeder Antwort:
  1) 🔵 Role: <rolle> | Keywords: [k1,…]
  2) 🟢 BMAD fertig (Business/Modellierung/Architektur/DoD)
  3) ✅ Prove abgeschlossen (analyze/test/RLS/DSGVO)
- Kein UI-only Gating. Fortschritt nur serverseitig. Keine Secrets im Code.

Auto‑Role (SSOT, inkl. OSS-Domain)
- Priorität: P1 db-admin, qa-dsgvo > P2 api-backend > P3 ui-frontend, dataviz
- ui-frontend: Flutter, Widget, Screen, GoRouter, Theme, A11y, Tokens, Lottie
- api-backend: Edge Fn, Gating, /gating/step-complete, Webhook, RevenueCat, Health, Rate‑Limit, Idempotenz
- db-admin: RLS, Supabase, Migration, Policy, Trigger, SQL, Schema, delete_user_data
- dataviz: Stats, Streak, Analytics, PostHog, Chart, Backfill
- qa-dsgvo: Privacy, DSGVO, Consent, PII, Opt‑in, Deletion, Retention
- Erste Zeile jeder Antwort: `🔵 Role: <rolle> | Keywords: [k1,…]`

Governance (BMAD → PRP)
- BMAD: Business (1 Satz + DSGVO‑Impact), Modellierung (Flows/ERD/Typen), Architektur (Interfaces/Upserts/Policies), DoD (Tests/Gates)
- PRP: Plan (mini) → Run (kleinste Schritte) → Prove (flutter format/analyze/test, RLS‑Check, DSGVO‑Note)

Acceptance (SSOT v1.1)
- Required Checks: format/analyze/test ✅ · CodeRabbit ✅ · Health /health (EU) 200 ✅
- DoD: Tests grün, ADRs gepflegt, DSGVO‑Review aktualisiert
- Role‑Extensions:
  - UI/DataViz: ≥1 Widget‑Test
  - Backend: Contract-/Edge‑Fn‑Tests
  - DB: RLS‑Policies & Migrations
  - QA/DSGVO: Review unter docs/privacy/reviews/{id}.md

Soft‑Gates (Self‑Review, kurz)
- reqing-ball: ≤5 Gaps (Was/Warum/Wie, File:Line, Severity)
- ui-polisher: 5–10 UI‑Fixes (Kontrast/Spacing/Typo/Tokens/States)

Security/Privacy
- MIWF: Engine darf nackt laufen — Daten nie (Consent/RLS/Secrets Pflicht)
- Fortschritt ausschließlich server‑autoritativ via Edge Fn; Idempotenz + Rate‑Limit

Ton & Microcopy (Eagle‑Fang, PG‑13 Default, RAW opt‑in)
- Imperative, 3–6 Wörter, Respekt, keine Slurs.
- Beispiel‑Keys:
  - learn.variant.title, learn.variant.gi, learn.variant.nogi
  - step.title, step.complete
  - sensei.grip, sensei.angle, sensei.legover
  - streak.alive
  - gate.locked, paywall.title
- RAW nur per Opt‑in; ggf. zensiert (Schei**).

Gi/No‑Gi Semantik
- Pro Technik zwei Varianten (Gi | No‑Gi) mit getrenntem Progress; gemeinsame Basics dedupliziert.
- UI: Chips Gi/No‑Gi auf Technique‑Screen; Fortschrittssync pro Variante.
- Datenmodell (konzeptuell): technique, technique_step (variant: gi|nogi|both), user_step_progress (user_id, technique_step_id, done_at)

Step‑Gating, Reset & Anti‑Cheat
- N+1: Step 1–2 free; ab 3 Pro (entitlement==premium).
- Edge Fn POST /gating/step-complete: Auth, Prereq (idx‑1), Freemium ≤2, Idempotenz (PK (user_id, technique_step_id)), 429 Rate‑Limit.
- Client: Nach „Fertig“ zurück in die Ausgangsposition; Offline‑Queue mit Retry; UI spiegelt Serverstatus.

Streak Regeln
- ≥1 serverbestätigter Step pro Kalendertag (User‑TZ).
- Kulanz ±30 Min an Tagesgrenzen; max 24h Backfill.

Assets & Tokens
- Videos 8–12 s, HLS/MP4 mit Postern.
- Ordnerkonventionen: design/assets/{icons,images,animations,videos}; design/tokens/{colors.json, typography.json}.
- Dark‑Only, Tatami‑Textur, dezente Rot/Blau‑Akzente.

Paywall & RevenueCat
- Produkte: monthly, annual (−25%), optional 7‑Tage‑Trial.
- Entitlement „premium“; Restore → sofortiger Server‑Check; Webhook /rc/webhook (Signatur, idempotent) setzt entitlement/trial_end_at.

Offline „letzter Clip“
- Zuletzt gespielten Clip lokal puffern; Flugmodus: abspielbar; Fortschritt queued und serverseitig idempotent.

A11y
- Touch‑Targets ≥44×44 pt; Kontrast AA; Dynamic Type; Fokusmodus blendet Tab‑Bar aus.

Telemetry (Consent‑first)
- PostHog Events (nur mit consent_analytics): technique_started, step_completed, paywall_shown; Sentry ohne PII.

Troubleshooting (Kurz)
- flutter doctor/analyze/test; iOS Signing; Supabase functions logs; /health (EU) 200.

Ignore Patterns
- .DS_Store, supabase/.temp/, .dart_tool/, build/, ios/Pods/, android/.gradle/, .env