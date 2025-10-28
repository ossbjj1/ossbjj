# Server-Authoritative Gating Deployment

## Overview
This document describes the deployment order for migrating step completion from direct client RPC to server-authoritative Edge Function gating.

## Components
1. **Edge Function** (`supabase/functions/gating_step_complete/index.ts`)
   - Authenticates user via JWT
   - Enforces prerequisite checks (previous step completed)
   - Enforces freemium gating (idx >= 2 requires premium/trial)
   - Calls `mark_step_complete()` RPC with service_role
   - Returns structured errors (401/402/409/429/500)

2. **Migration** (`supabase/migrations/20251026_mark_step_complete_rpc.sql`)
   - Locks RPC `mark_step_complete()` to service_role only
   - Prevents direct client calls

3. **Client** (`app/lib/core/services/gating_service.dart`)
   - Calls Edge Function instead of direct RPC
   - Maps error codes to domain exceptions
   - Handles paywall/prereq UI flows

## Deployment Order (Zero-Downtime)

### Phase 1: Deploy Edge Function (No Breaking Changes)
```bash
# Deploy Edge Function
cd /Volumes/Project_SSD/OSS/oss
supabase functions deploy gating_step_complete --project-ref xqgqentkowzxckwlmyqc

# Verify health (manual test)
curl -X POST https://xqgqentkowzxckwlmyqc.supabase.co/functions/v1/gating_step_complete \
  -H "Authorization: Bearer <user-jwt>" \
  -H "Content-Type: application/json" \
  -d '{"technique_step_id": "<test-uuid>"}'
# Expected: 200 {success: true, ...} or 402 {error: "payment_required"}
```

### Phase 2: Deploy Client Update (Backward Compatible)
```bash
# Build and release Flutter app with Edge Function calls
cd app
flutter build apk --release  # Android
flutter build ios --release  # iOS

# Deploy to stores / TestFlight
# Old RPC still accessible, so rollback safe
```

### Phase 3: Apply Migration (Lock RPC)
⚠️ **CRITICAL**: Only after Edge Function + Client are live and verified.

```bash
# Apply migration to lock RPC to service_role only
cd /Volumes/Project_SSD/OSS/oss
supabase db push --project-ref xqgqentkowzxckwlmyqc

# Verify privileges
supabase db execute --project-ref xqgqentkowzxckwlmyqc <<SQL
SELECT
  proname,
  array_agg(DISTINCT rolname) AS granted_roles
FROM pg_proc
JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
LEFT JOIN pg_proc_acl ON pg_proc.oid = pg_proc_acl.prooid
LEFT JOIN pg_roles ON pg_proc_acl.grantee = pg_roles.oid
WHERE proname = 'mark_step_complete'
  AND nspname = 'public'
GROUP BY proname;
SQL
# Expected: granted_roles = {service_role}
```

## Rollback Plan

### If Edge Function Issues (Phase 1)
- Delete/redeploy Edge Function
- No impact on existing clients (RPC still open)

### If Client Issues (Phase 2)
- Revert client to previous RPC-based version
- Redeploy from previous commit

### If Migration Applied Too Early (Phase 3)
⚠️ Emergency rollback if clients still using direct RPC:
```sql
-- Temporarily re-enable RPC for authenticated users
GRANT EXECUTE ON FUNCTION public.mark_step_complete(uuid) TO authenticated;
```
Then fix Edge Function + redeploy clients → re-apply migration.

## Monitoring

### Edge Function Logs
```bash
supabase functions logs gating_step_complete --project-ref xqgqentkowzxckwlmyqc
```
Watch for:
- `payment_required` events (expected for free users on idx >= 2)
- `prerequisite_missing` events (expected when skipping steps)
- `unauthorized` / `rate_limited` spikes (investigate)
- `server_error` / `rpc_error` (critical)

### Client Error Tracking
- Monitor Sentry/Crashlytics for `GatingException` frequency
- Track `paymentRequired` → paywall shown conversion
- Track `prerequisiteMissing` → UI hint shown

### Database Monitoring
```sql
-- Check mark_step_complete call frequency (should be service_role only after Phase 3)
SELECT
  usename,
  COUNT(*)
FROM pg_stat_statements
JOIN pg_user ON pg_stat_statements.userid = pg_user.usesysid
WHERE query LIKE '%mark_step_complete%'
GROUP BY usename;
```

## Testing Checklist

### Pre-Deployment (Local)
- [ ] Edge Function smoke test (curl with valid/invalid JWT)
- [ ] Client unit tests pass (error mapping)
- [ ] Flutter analyze + format clean

### Phase 1 (Edge Function Deployed)
- [ ] Health check: `curl /functions/v1/gating_step_complete` returns 401 (no auth)
- [ ] Authenticated call succeeds for free user (idx 0-1)
- [ ] Authenticated call returns 402 for free user (idx >= 2)
- [ ] Prerequisite check works (409 when skipping steps)
- [ ] Idempotency works (duplicate calls return already_completed)

### Phase 2 (Client Deployed)
- [ ] New clients use Edge Function successfully
- [ ] Paywall shown on 402 response
- [ ] "Complete previous step" hint on 409
- [ ] Retry/backoff on 429
- [ ] Offline queue still works

### Phase 3 (Migration Applied)
- [ ] RPC no longer callable by authenticated role
- [ ] Edge Function still works (service_role client)
- [ ] No client errors (all on new version)

## Security Notes
- Service role key stored in Supabase Edge Function secrets (never in client)
- User ID derived from JWT (`auth.uid()`) server-side, never client-supplied
- Rate limiting (2s per user) prevents abuse
- All errors logged with hashed user ID (no PII)

## DSGVO Compliance
- Logs contain hashed user IDs only (SHA-256)
- No entitlement values stored in logs (only "allowed" boolean)
- Retention follows Supabase edge function default (7 days)
- User can request deletion via `delete_user_data` RPC (existing flow)
