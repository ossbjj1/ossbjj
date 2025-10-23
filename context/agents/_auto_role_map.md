# Auto‑Role Map (SSOT – OSS)

## Rollen & Keywords
- ui-frontend: Flutter, Widget, Screen, GoRouter, Theme, A11y, Tokens, Lottie, Confetti
- api-backend: Edge Function, Gating, /gating/step-complete, Webhook, RevenueCat, Health, Rate‑Limit, Idempotenz
- db-admin: RLS, Supabase, Migration, Policy, Trigger, SQL, Schema, delete_user_data
- dataviz: Stats, Streak, Analytics, PostHog, Chart, Metric, Backfill
- qa-dsgvo: Privacy, DSGVO, Consent, PII, Opt‑in, Data‑Deletion, Retention

## Priorität
- P1: db-admin, qa-dsgvo
- P2: api-backend
- P3: ui-frontend, dataviz

## Anwendung
- Match Keywords → Rolle wählen
- Multi‑Match → höchste Priorität gewinnt
- Erste Zeile der Antwort:
  `🔵 Role: <rolle> | Keywords: [k1, k2, …]`
