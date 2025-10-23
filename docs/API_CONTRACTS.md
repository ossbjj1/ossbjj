# Contracts
POST /gating/step-complete
Body: { "technique_step_id": number }
Checks: Auth → Step existiert → Prereq (idx-1) → Freemium (idx≤2) ODER entitlement=='pro'
Write: UPSERT user_step_progress (PK user_id+step_id) – idempotent
Rate-Limit: 10 req/min/User
Codes: 200 {state:"completed", unlocked:<number>} | 401 | 404 | 423 | 403 | 409 | 429

### ACHIEVEMENT-GRANTING (Server-side, MVP)
After successful step write, server checks (via service role):
- steps_completed ≥ 1 → 'first_grip'
- calc_streak_days(user_id) ≥ 7 → 'streak_7'
- steps_completed ≥ 25 → 'steps_25'
- count_completed_techniques(user_id) ≥ 5 → 'tech_5'

Grant: UPSERT user_achievement (idempotent)
Telemetry: optional event achievement_unlocked (only with consent)

POST /rc/webhook
Input: RevenueCat Event
Auth: Signatur-Header prüfen
Action: Upsert user_profile.entitlement, trial_end_at
Logs: Keine PII; idempotent; 2xx only bei Erfolg

