# ADR 005: Completion Idempotency via RPC mark_step_complete

**Status:** Accepted  
**Date:** 2025-10-26  
**Sprint:** 4.1  
**Context:** server-authoritative gating, DSGVO compliance, MVP  

## Problem

User step completions via direct DB upsert had two issues:
1. **Doppelzählung**: Doppel-Tap oder Retry konnte unterschiedliche `done_at` schreiben → unklar, ob idempotent.
2. **Unklare Semantik**: Client konnte nicht verlässlich unterscheiden "neu completed" vs "bereits completed".

Für MVP: Idempotent completion required; kein server-side rate-limit/audit nötig (Sprint 4 hat check_step_access bereits gesichert).

## Decision

**RPC `mark_step_complete(p_technique_step_id uuid)`**
- SECURITY DEFINER mit `auth.uid()` Check
- `INSERT ... ON CONFLICT (user_id, technique_step_id) DO NOTHING`
- `GET DIAGNOSTICS ROW_COUNT` → 1 = neu, 0 = idempotent
- Returns `{success:bool, idempotent:bool, message:text}`

**Client**
- `gating_service.dart::completeStep()` ruft `rpc('mark_step_complete')` statt direkter upsert
- Mapping auf `CompleteResult{success, idempotent, message}`

**Migration**
- `supabase/migrations/20251026_mark_step_complete_rpc.sql`
- Grant EXECUTE to authenticated only

## Consequences

✅ Pro
- **Idempotenz garantiert**: PK conflict → DO NOTHING; client erhält klares idempotent=true.
- **Keine doppelte Zählung**: ROW_COUNT=0 signalisiert "bereits completed".
- **MVP-tauglich**: Minimal-Fix ohne neue Edge Function; schnelles Deployment.
- **RLS-sicher**: SECURITY DEFINER mit auth.uid() prüft, dass user_id=auth.uid().
- **Einfach testbar**: Flutter-Tests können doppelte calls verifizieren (idempotent=true).

⚠️ Con
- **Kein Edge-Fn-Rate-Limit**: Missbrauch kann 1000 RPC calls/sec machen (Limit via Supabase Quotas, nicht custom RL).
- **Kein Audit-Log**: Success-Events sind nicht zentral strukturiert geloggt (nur DB write logs).
- **Upgrade-Pfad nötig**: Für volle Server-Autorität später Edge Function `gating_step_complete` mit CORS/RL/userIdHash-Logs ergänzen.

## Alternatives

1. **Direct DB upsert mit client-side Timestamp-Vergleich**: ❌ Unreliable; client-side Logik kann umgangen werden.
2. **Edge Function sofort**: ⏱️ Overhead für MVP; MVP braucht nur idempotent; RL/Audit optional später.

## Implementation

- ✅ RPC created: `server/supabase/rpc/mark_step_complete.sql`
- ✅ Migration: `server/supabase/migrations/20251026_mark_step_complete_rpc.sql`
- ✅ Client updated: `app/lib/core/services/gating_service.dart`
- ⏳ Tests: Flutter integration test for idempotent=true (Sprint 4.1)
- ⏳ Deployment: Manual SQL via Supabase Dashboard (pooler issue prevents CLI push)

## Future

- Sprint 5: Edge Function `gating_step_complete` für full stack (CORS, RL, userIdHash logs).
- Wrap RPC call inside Edge Function → same RPC logic, but with CORS+RL+Audit.

## References

- [ADR 002: Server-side gating](/docs/adr/002_server_side_only_gating.md)
- [OSS_ROADMAP Sprint 4](/docs/roadmap/OSS_ROADMAP_INDEX.md)
- [DB Schema PK user_step_progress(user_id, technique_step_id)](/docs/DB_SCHEMA_MIN.sql)
