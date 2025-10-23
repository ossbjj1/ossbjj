# ADR-002: Server-Side-Only Step Gating

**Status:** Accepted  
**Datum:** 2025-10-23  
**Autoren:** Engineering/Security  
**Kontext:** Sprint 6 (Gating + RLS)

---

## Kontext

User-Progress (erledigte Steps) muss gespeichert werden. Freemium-Logik erfordert Gating (Step 1–2 free, ab 3 Paywall).

**Fragestellung:**
- Soll der Client Step-Progress direkt in Supabase schreiben (via RLS)?
- Oder muss Progress über eine Edge-Function laufen?

**Constraints:**
- **Anti-Cheat:** Freemium-User dürfen Step 3+ nicht manipulieren
- **Store-Konformität:** Apple/Google verlangen, dass In-App-Purchases nicht umgehbar sind
- **Idempotenz:** Doppel-Taps dürfen nicht zu doppelten Einträgen führen

---

## Entscheidung

**Alle Step-Completions laufen ausschließlich über Edge-Function `POST /gating/step-complete`:**

1. **Client-Logik:**
   - User tippt "Fertig" → Client sendet `{ technique_step_id }`
   - Client schreibt **NICHTS** direkt in `user_step_progress`
   - UI spiegelt Server-Response (success → grün, 403 → Paywall)

2. **Server-Logik (Edge-Function):**
   ```typescript
   POST /gating/step-complete
   - Auth-Check (Supabase JWT)
   - Step existiert?
   - Prereq (idx-1 erledigt)?
   - Freemium-Check: idx ≤ 2 ODER entitlement == 'premium'
   - UPSERT (idempotent via PK)
   - Rate-Limit: 10 req/min/User
   - Achievement-Granting (inline)
   ```

3. **RLS:**
   - `user_step_progress` SELECT nur `auth.uid() = user_id`
   - `user_step_progress` INSERT **disabled** (nur via Edge-Fn mit service role)

---

## Konsequenzen

### Positiv
- **Anti-Cheat:** Client kann Freemium-Gate nicht umgehen
- **Store-Konform:** Fortschritt ist serverseitig autoritativ
- **Idempotent:** Doppel-Tap → 409 `already_done` (keine Duplikate)
- **Audit-Trail:** Alle Completions logbar (via Edge-Fn-Logs)

### Negativ
- **Offline-Limitation:** User kann Steps nicht offline "erledigen" (nur Queue)
- **Latenz:** User wartet auf Server-Response (~200ms)
- **Edge-Fn-Kosten:** Jede Completion = 1 Edge-Fn-Invocation (~0.000002€)

### Neutral
- Offline-Queue möglich: Client speichert pending Completions lokal → synct später

---

## Alternativen

### Option A: Client schreibt direkt via RLS
- **Pro:** Einfach, schnell, offline-fähig
- **Contra:** Freemium-Gate umgehbar (User manipuliert lokale DB/HTTP-Requests)
- **Warum abgelehnt:** Store-Rejection-Risiko, kein Anti-Cheat

### Option B: Hybrid (Free via RLS, Pro via Edge-Fn)
- **Pro:** Free-User haben weniger Latenz
- **Contra:** Zwei Code-Pfade, komplexer, Freemium-Gate trotzdem umgehbar
- **Warum abgelehnt:** Komplexität, kein Sicherheitsgewinn

---

## Verweise

- Sprint: [OSS_ROADMAP_S5-S8.md](../roadmap/OSS_ROADMAP_S5-S8.md#sprint-6)
- API Contract: [API_CONTRACTS.md](../API_CONTRACTS.md)
- Code: `server/supabase/functions/gating_step_complete/index.ts`
- WARP.md: [Security/Privacy](../../WARP.md#securityprivacy)
