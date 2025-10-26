# Privacy Review – Sprint 3 (Onboarding + Settings)

Date: 2025-10-26
Author: Warp Agent
Scope: New Supabase migration and client-side features that touch user data.

## Changes in this Sprint

- DB: Added table `public.user_profile` via migration `20251026_user_profile.sql`
  - Columns: user_id (PK, uuid, FK auth.users, CASCADE), belt (text), exp_range (text), weekly_goal (int), goal_type (text), age_group (text, optional), consent_analytics (bool, default false), entitlement (text, default 'free'), trial_end_at (timestamptz, optional), created_at (timestamptz), updated_at (timestamptz)
  - RLS: ENABLED
    - up_select_own: SELECT using (auth.uid() = user_id)
    - up_insert_own: INSERT with check (auth.uid() = user_id)
    - up_update_own: UPDATE using (auth.uid() = user_id)
  - Trigger: `trg_up_updated_at` updates `updated_at` on UPDATE
  - Index: `idx_up_user(user_id)`

## Data Categories and PII

- Stored fields are preference/meta-data for personalization (belt, experience, goals) – no directly identifying PII like name/email/phone.
- `user_id` links to `auth.users` (identifier under Supabase Auth). Email remains in auth schema; app never stores emails in public schema.
- `consent_analytics` controls analytics initialization; defaults to false.

## Lawful Basis & Consent

- Analytics only after explicit opt-in (consent modal); without consent, `AnalyticsService.initIfAllowed` is a no-op.
- Sentry configured without PII (beforeSend strips id/email/username/name/ip).
- No PostHog initialization in MVP; placeholder only.

## Data Minimization

- Only coaching-relevant fields are stored. Age group is bucketed and optional.
- No free-text PII fields introduced.

## Access Control (RLS)

- Users can only read/insert/update their own `user_profile` row (auth.uid() == user_id).
- No DELETE exposed client-side; server-side deletion will be implemented via RPC in Sprint 6 (see roadmap).

## Retention & Deletion

- Profile data retained while account exists.
- Planned: RPC `delete_user_data()` removes profile and progress (Sprint 6) – UI button present but disabled.

## Security

- No service_role keys in client.
- No secrets committed. Env via `--dart-define`.
- Rate limiting and idempotency for progress writes are server-side (future sprints).

## User Rights

- Consent can be withdrawn from Settings → Consent; local consent flags are reset; analytics remains disabled until new opt-in.
- Delete Account UI visible but disabled until server RPC lands.

## Risk Assessment

- Low risk: non-sensitive profile fields, strict RLS, consent default-off.
- Monitoring: Sentry without PII; analytics gated.

## Testing Notes

- Verified RLS policies compile and restrict access by `auth.uid()`.
- Widget tests updated; manual checks for consent gating and language toggle.

## Changeset Reference

- Migration file: `server/supabase/migrations/20251026_user_profile.sql`
- App changes: Onboarding form writes to `user_profile`; Settings adds language/audio and consent access; Router enforces onboarding when profile incomplete.
