# Privacy Review – Sprint 4 (DB Schema & Gating Hardening)

Date: 2025-10-26
Author: Warp Agent
Scope: Supabase migrations (content baseline + RPC) and server functions that touch user data and access control.

## Changes in this Sprint

- DB: Added minimal content baseline (migration `20251020_content_min_schema.sql`)
  - Tables: `public.technique` (uuid PK), `public.technique_step` (uuid PK, unique (technique_id, variant, idx))
  - Table: `public.user_step_progress` (PK (user_id, technique_step_id), `completed_at` timestamptz)
  - RLS: ENABLED on `user_step_progress`
    - usp_select_own: SELECT using (auth.uid() = user_id)
    - usp_insert_own: INSERT with check (auth.uid() = user_id)
  - Optional FK to `public.user_profile(user_id)` added only if profile table exists
- DB: RPC `public.mark_step_complete(p_technique_step_id uuid)` (migration `20251026_mark_step_complete_rpc.sql`)
  - SECURITY DEFINER; uses `auth.uid()`; `INSERT ... ON CONFLICT DO NOTHING` → idempotent writes
  - Returns `{success:boolean, idempotent:boolean, message:text}`
- DB: RPC `public.get_next_step(p_user_id uuid, p_variant text)` (migration `20251027_get_next_step.sql`)
  - SECURITY DEFINER; returns first incomplete step for variant-aware Continue heuristic
  - Used by ProgressService.getNextStep() in client
- DB: Migration `20251027003100_technique_display_order.sql` adds `display_order` (smallint) + index for catalog sort
- DB: Migration `20251027003200_performance_indexes.sql` adds indexes (idx_ts_variant_idx, idx_usp_user)
- Seeds: Content baseline (20 techniques, 94 steps gi/nogi) imported via `server/supabase/scripts/seed_import.ts`
  - Deterministic UUID v5 (stable IDs), idempotent upserts (ON CONFLICT DO UPDATE)
  - Content: technique titles/categories, step titles/cues (EN/DE) – NO PII, only instructional text
- Edge Function (docs only, no PII): `gating_check_step_access`
  - CORS Whitelist (ENV), Rate Limiting (Upstash), structured JSON logs with `userIdHash` (SHA‑256), env fail‑fast
- UI: Learn screen (category grid, technique list) + Continue card with getNextStep heuristic + gating (idx≥3 → paywall)

## Data Categories and PII

- No new PII fields added. `user_step_progress` stores only user_id and step reference with a timestamp.
- Logs use hashed user IDs (SHA‑256) – keine Roh-IDs.

## Lawful Basis & Consent

- Keine neuen Trackingdienste; bestehende Analytics bleiben consent‑gated (opt‑in erforderlich).
- Edge‑Logs enthalten keine PII; nur pseudonyme IDs.

## Data Minimization

- `user_step_progress` speichert nur das Minimum (user_id, technique_step_id, completed_at).
- Keine Freitext- oder Profildaten-Erweiterungen.

## Access Control (RLS)

- `user_step_progress`: RLS aktiv; SELECT/INSERT beschränkt auf `auth.uid()` – verhindert Fremdzugriffe.
- RPC `mark_step_complete` erzwingt `auth.uid()` serverseitig; vermeidet clientseitige Manipulation.

## Retention & Deletion

- Progressdaten werden bis zur Kontolöschung gehalten.
- Geplante Datenlöschung via `rpc/delete_user_data()` (Sprint 6) entfernt auch Progressdaten.

## Security

- Keine service_role im Client; keine Secrets im Repo.
- Edge Fn mit CORS‑Whitelist, Rate‑Limit (Upstash), env‑Validation (fail‑fast), JSON‑Logs ohne PII.

## User Rights

- Keine Änderung an Einwilligungs- oder Lösch-Flows in diesem Sprint; bestehende Consent‑Gates bleiben aktiv.

## Risk Assessment

- Niedriges Risiko: Nur Fortschrittsmetadaten, strikte RLS, idempotente RPC, Logs ohne PII.
- Missbrauchsschutz durch Rate‑Limit (Access‑Check) und Idempotenz (Completion).

## Testing Notes

- RLS geprüft (Policies kompiliert; Zugriff via `auth.uid()` begrenzt).
- App‑Tests grün; Completion doppelt → idempotent=true verifiziert.

## Changeset Reference

- Migrations:
  - `server/supabase/migrations/20251020_content_min_schema.sql`
  - `server/supabase/migrations/20251026_mark_step_complete_rpc.sql`
- Edge Fn source/docs: `supabase/functions/gating_check_step_access/*`
- Client mapping: `app/lib/core/services/gating_service.dart` → rpc('mark_step_complete')
