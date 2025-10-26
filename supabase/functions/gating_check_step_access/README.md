# gating_check_step_access

Server-authoritative step access check for premium gating (Sprint 4.1
Production).

## Purpose

Replaces client-side entitlement checks with server-side validation.
Prevents bypassing premium content via app binary manipulation.

## Configuration (ENV)

| Variable                   | Default | Description                                                                                                                          |
| -------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `CORS_ALLOWED_ORIGINS`     | `""`    | Comma-separated origins (e.g., `https://app.example.com,capacitor://localhost`). Empty = dev‑mode allow‑all (`*`) via dynamic CORS. |
| `RL_USER_RATE`             | `"30/m"` | Rate limit per user (format: `{num}/{m\|h}`).                                                                                        |
| `RL_IP_RATE`               | `"60/m"` | Rate limit per IP (fallback).                                                                                                        |
| `UPSTASH_REDIS_REST_URL`   | -       | Upstash Redis REST API URL (required for rate limiting).                                                                             |
| `UPSTASH_REDIS_REST_TOKEN` | -       | Upstash Redis token.                                                                                                                 |
| `LOG_LEVEL`                | `"info"` | Log level (`info`, `warn`, `error`).                                                                                                 |
| `SUPABASE_URL`             | -       | Supabase project URL (auto-injected).                                                                                                |
| `SUPABASE_ANON_KEY`        | -       | Supabase anon key (auto-injected).                                                                                                   |

## API Contract

### Request

```bash
POST /gating_check_step_access
Authorization: Bearer <JWT>
Origin: https://app.example.com
Content-Type: application/json

{
  "techniqueStepId": "uuid-here"
}
```

### Response (200 OK)

```json
{
  "allowed": true,
  "reason": "free" | "premium" | "premiumRequired" | "authRequired"
}
```

### Error Responses

- `400`: `{"error": "bad_request"}` - Missing `techniqueStepId`
- `401`: `{"allowed": false, "reason": "authRequired"}` - Invalid/missing JWT
- `403`: `{"error": "origin_forbidden"}` - CORS origin not whitelisted
- `404`: `{"error": "not_found"}` - Step ID doesn't exist
- `429`: `{"error": "rate_limited", "retryAfter": 60}` - Rate limit exceeded (
  `Retry-After` header)
- `500`: `{"error": "server_error"}` - Internal error

## Testing

### Local (Supabase CLI)

```bash
# Start local Supabase
supabase start

# Set ENV variables
export CORS_ALLOWED_ORIGINS="http://localhost:3000"
export RL_USER_RATE="10/m"
export UPSTASH_REDIS_REST_URL="https://your-upstash.upstash.io"
export UPSTASH_REDIS_REST_TOKEN="your-token"

# Serve function
supabase functions serve gating_check_step_access --env-file .env.local

# Test
curl -X POST http://localhost:54321/functions/v1/gating_check_step_access \
  -H "Authorization: Bearer <jwt>" \
  -H "Content-Type: application/json" \
  -H "Origin: http://localhost:3000" \
  -d '{"techniqueStepId":"step-uuid"}'
```

### Rate Limit Test

```bash
# Hit endpoint 31 times in 1 minute (RL_USER_RATE=30/m)
for i in {1..31}; do
  curl -X POST ... # (same as above)
done
# 31st request should return 429
```

### CORS Test

```bash
# Allowed origin
curl -H "Origin: http://localhost:3000" ...  # → 200 with CORS headers

# Disallowed origin
curl -H "Origin: https://evil.com" ...  # → 403
```

## Observability

> Datenschutz: Niemals rohe User‑IDs an Sentry/PostHog senden. Nur pseudonyme
> IDs (z. B. hash(userId)). Telemetrie nur mit consent_analytics und
> bestehender DPA aktivieren.

### Structured Logs (JSON)

All logs include:

```json
{
  "ts": "2025-10-26T19:45:00.123Z",
  "event": "gating_check_step_access",
  "level": "info",
  "reqId": "uuid",
  "userIdHash": "a1b2c3...",
  "techniqueStepId": "step-uuid",
  "idx": 3,
  "entitlement": "premium",
  "decision": { "allowed": true, "reason": "premium" },
  "durationMs": 45
}
```

### Monitoring Queries (Supabase Logs Dashboard)

```sql
-- Rate limit violations (last hour)
SELECT count(*) FROM logs
WHERE event = 'rate_limited'
  AND ts > now() - interval '1 hour';

-- Decision breakdown
SELECT decision->>'reason' as reason, count(*)
FROM logs
WHERE event = 'gating_check_step_access'
GROUP BY reason;

-- Slow requests (>500ms)
SELECT * FROM logs
WHERE event = 'gating_check_step_access'
  AND durationMs > 500
ORDER BY ts DESC LIMIT 100;
```

## Production Checklist

- [ ] Set `CORS_ALLOWED_ORIGINS` to production domains
- [ ] Configure Upstash Redis (free tier: 10k req/day)
- [ ] Set `RL_USER_RATE` (recommended: 30/m)
- [ ] Set `RL_IP_RATE` (recommended: 60/m)
- [ ] Set `LOG_LEVEL=warn` (reduce noise)
- [ ] Monitor 429 rate via logs dashboard
- [ ] Alert on 500 errors (Sentry/PostHog) — keine PII: nur pseudonyme IDs
  (hash(userId)); Telemetrie nur mit consent_analytics und bestehender DPA

## Deployment

```bash
# Deploy to Supabase
supabase functions deploy gating_check_step_access

# Set secrets
supabase secrets set CORS_ALLOWED_ORIGINS="https://app.ossbjj.com"
supabase secrets set UPSTASH_REDIS_REST_URL="..."
supabase secrets set UPSTASH_REDIS_REST_TOKEN="..."
supabase secrets set RL_USER_RATE="30/m"
supabase secrets set RL_IP_RATE="60/m"
```

## Troubleshooting

### Rate limiting not working

- Check Upstash credentials: `curl -H "Authorization: Bearer $TOKEN" $URL/ping`
- Verify logs: `grep "rate_limiting unavailable"` (fail-open warning)

### CORS errors in browser

- Ensure `Origin` header matches `CORS_ALLOWED_ORIGINS`
- Check logs for `origin_forbidden` events
- For mobile (Capacitor), add `capacitor://localhost` to whitelist

### 401 Unauthorized

- Verify JWT is valid: `supabase auth verify <jwt>`
- Check `Authorization: Bearer <token>` header format
