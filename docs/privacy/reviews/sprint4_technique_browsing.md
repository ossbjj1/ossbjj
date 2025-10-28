# Privacy Review: Sprint 4 – Technique Browsing & Progress Heuristic

**Date:** 2025-10-27  
**Reviewer:** Warp Agent (automated)  
**Scope:** Learn Screen, Progress Service, Technique Repository

---

## Summary
Sprint 4 introduces **Technique Browsing** (categories, technique lists) and **Progress Heuristic** (`getNextStep` RPC). All features comply with **DSGVO principles**: No PII logged, Supabase RLS enforced, Consent-gated analytics.

---

## Data Flows Reviewed

### 1. **Learn Screen (Categories + Techniques)**
- **Data Accessed:** `technique` table (category, title_en, title_de, display_order)
- **User Data:** None (public catalog)
- **Storage:** Supabase (RLS: public read)
- **Retention:** N/A (static catalog)
- **DSGVO Impact:** ✅ No PII, no user tracking

### 2. **Progress Service (`getNextStep`)**
- **Data Accessed:** `technique_step`, `technique`, `user_step_progress` (LEFT JOIN)
- **User Data:** `user_id` (UUID from session)
- **Storage:** Supabase (RLS: authenticated read own progress only)
- **Retention:** Until user deletes account (`delete_user_data` RPC)
- **DSGVO Impact:** ✅ Minimal necessary data, user owns their progress

### 3. **Riverpod Providers**
- **Caching:** In-memory only (no disk persistence without consent)
- **User Data:** None (technique catalog is public)
- **DSGVO Impact:** ✅ No PII, no leakage

---

## Security & Privacy Checks

| Check | Status | Notes |
|-------|--------|-------|
| RLS Policies Enforced | ✅ | All queries use Supabase client (RLS active) |
| No PII in Logs | ✅ | No `print()` or `Logger` calls with user data |
| Consent Gating | ✅ | Analytics events NOT added (future sprint) |
| User Data Deletion | ✅ | `delete_user_data` RPC covers `user_step_progress` |
| Minimal Data Principle | ✅ | Only `user_id` + `step_id` stored |
| Offline Resilience | ✅ | `getNextStep` returns `null` on error (no crash) |

---

## Risks & Mitigations

### Risk 1: RPC Leak via Logs
**Severity:** Low  
**Mitigation:** `get_next_step` RPC returns only `step_id`, `title_en/de`, `idx` (no PII). Supabase logs are scrubbed server-side.

### Risk 2: Unauthenticated Access to Progress
**Severity:** None  
**Mitigation:** `getNextStep` returns `null` if `currentUser == null`. RLS blocks unauthorized queries.

---

## DSGVO Compliance Checklist

- [x] **Art. 5 (Data Minimization):** Only `user_id` + `step_id` stored for progress tracking.
- [x] **Art. 6 (Lawful Basis):** Legitimate interest (app functionality), explicit consent for analytics (future).
- [x] **Art. 17 (Right to Erasure):** `delete_user_data` RPC deletes all user progress.
- [x] **Art. 25 (Privacy by Design):** RLS enforced, no client-side PII exposure.
- [x] **Art. 32 (Security):** HTTPS, Supabase Auth, no plaintext secrets.

---

## Recommendations for Future Sprints

1. **Analytics Events (Sprint 5+):** Ensure PostHog events (`technique_viewed`, `category_browsed`) are consent-gated via `ConsentService`.
2. **Caching:** If introducing disk caching (e.g., `flutter_cache_manager`), ensure DSGVO-compliant retention (e.g., 7-day TTL, user-triggered clear).
3. **Variant Filtering:** When adding Gi/No-Gi preference, store in `profiles.variant_preference` (covered by existing RLS).

---

## Sign-Off

**Status:** ✅ Approved for Production  
**Next Review:** Sprint 5 (Analytics Integration)
