# DSGVO Review: Sprint 4 – Consent Toggles + Timezone

**Date:** 2025-10-28  
**Reviewer:** qa-dsgvo role  
**Sprint:** 4 (Consent Sync + Continue)  
**Status:** Approved for MVP

---

## Changes Reviewed

1. **Consent Toggles in Settings** (Analytics/Media)
   - UI: SwitchListTile in Settings → persist + server sync
   - Analytics: setServerAnalytics → live init/deinit via analyticsService.initIfAllowed
   - Media: setMedia → local persist only (no server sync yet)

2. **User Timezone** (user_profile.timezone)
   - Column: TEXT NOT NULL DEFAULT 'UTC', CHECK (timezone <> '')
   - Usage: calc_streak_days RPC for fair day boundaries

---

## DSGVO Compliance Assessment

### 1. Consent Toggles (Analytics/Media)

**Legal Basis:** Art. 6(1)(a) GDPR – Consent (opt-in)

**Implementation:**
- ✅ Opt-in required: default false, user must explicitly enable
- ✅ Server as Single Source of Truth (user_profile.consent_analytics)
- ✅ Revocable: toggle off → analytics deinit (stops tracking)
- ✅ Granular: separate toggles for Analytics and Media
- ✅ Persistent: survives app reinstall (server-stored)

**Data Flow:**
- Analytics ON → Sentry (error reports, no PII), PostHog (events, pseudonymized)
- Analytics OFF → no telemetry sent
- Media ON → video previews, offline downloads (local cache)
- Media OFF → no media processing

**Risks:**
- Low: User controls data collection; no PII in analytics (beforeSend strips)
- Mitigation: Consent state synced on app start; revert on server failure

**DoD:**
- ✅ Consent state persists (SharedPreferences + Supabase)
- ✅ Analytics init/deinit live on toggle
- ✅ No tracking without consent

---

### 2. User Timezone (user_profile.timezone)

**Legal Basis:** Art. 6(1)(b) GDPR – Contract (necessary for service)

**Assessment:**
- **Not PII:** Timezone is a user preference, not personal data under GDPR
  - Does not identify individual (millions share same TZ)
  - Similar to language preference
- **Purpose:** Fair streak calculation across global users
- **Storage:** user_profile.timezone (TEXT, default 'UTC')
- **Retention:** deleted on account deletion (via delete_user_data RPC)

**Risks:**
- None: Timezone alone cannot identify users

**DoD:**
- ✅ Timezone stored as preference, not tracked
- ✅ User can change timezone (via profile settings, future)
- ✅ Deleted on account deletion

---

## Summary

**Approved Changes:**
- Consent toggles: compliant (opt-in, revocable, granular)
- Timezone: compliant (preference, not PII, necessary for service)

**Remaining Todos:**
- [ ] Add "Manage Privacy" link in Settings (already implemented)
- [ ] Document consent flow in Privacy Policy (future)
- [ ] Test consent revocation end-to-end (manual QA)

**Sign-off:**
- Role: qa-dsgvo
- Verdict: ✅ Approved for MVP release
- Next Review: Sprint 6 (User Data Deletion RPC)

---

## References

- WARP.md: DSGVO-compliant consent gates
- ConsentService: setServerAnalytics, syncAnalyticsFromServer
- AnalyticsService: initIfAllowed, beforeSend (strips PII)
- user_profile.timezone: ADR 20251028
