# ADR: User Timezone + Streak Calculation

**Date:** 2025-10-28  
**Status:** Accepted  
**Decision-Makers:** db-admin, api-backend roles  
**Tags:** #streak #timezone #rpc #dsgvo

---

## Context

Users track their training progress across days ("streak"). Without timezone awareness, UTC-based day boundaries penalize users in non-UTC zones:
- User in Europe/Berlin trains at 23:50 local → counts as "tomorrow" in UTC
- Grace period needed: ±30min around midnight to handle edge cases

Previous calc_streak_days RPC used UTC-only; no user timezone support.

---

## Decision

Add user_profile.timezone (TEXT, default 'UTC', IANA format) + refactor calc_streak_days RPC:
- Uses user timezone for day calculation
- Applies ±30min grace period at day boundaries
- SECURITY DEFINER + SET search_path = pg_catalog,public (injection-hardened)
- Fetches timezone via auth.uid() (server-authoritative)

---

## Rationale

**Why timezone matters:**
- Fairness: Users in all timezones get consistent day boundaries
- UX: Training at 23:50 local still counts as "today", not "tomorrow"

**Why ±30min grace:**
- Edge case: User completes step at 23:55, server processes at 00:02 → still same day
- Max backfill: 24h (prevents abuse)

**Why SECURITY DEFINER:**
- Allows RLS-gated user_step_progress access without exposing user_id to client
- search_path hardened to prevent schema injection

**Alternatives considered:**
1. Client-side timezone → rejected (trust boundary, clock skew)
2. No grace period → rejected (poor UX at midnight)
3. Server-wide UTC-only → rejected (unfair to non-UTC users)

---

## Consequences

**Positive:**
- Fair streak calculation globally
- DSGVO-compliant (timezone = user preference, not PII)
- Testable (SQL tests for boundary cases)

**Negative:**
- Complexity: RPC now timezone-aware (but contained)
- Migration: existing users default to UTC (acceptable)

**Risks:**
- Invalid IANA timezone → defaults to UTC (graceful degradation)
- Timezone DB outdated → affects DST transitions (acceptable for MVP)

---

## Implementation

**Files:**
- supabase/migrations/20251028_user_profile_timezone.sql (column + CHECK)
- supabase/migrations/20251028_calc_streak_days_tz.sql (RPC with ±30m)
- supabase/migrations/20251028_calc_streak_days_tests.sql (SQL tests)

**DoD:**
- Migration idempotent (IF NOT EXISTS)
- RPC: SECURITY DEFINER + search_path set
- Tests: anonymous rejection, boundary cases documented

---

## References

- WARP.md: db-admin role, SECURITY DEFINER + search_path
- HANDOVER.md: calc_streak_days ±30min grace, User-TZ
- DB_SCHEMA_MIN.sql: user_profile.timezone column
