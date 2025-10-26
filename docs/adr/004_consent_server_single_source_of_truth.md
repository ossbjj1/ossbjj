# ADR-004: Consent Analytics — Server als Single Source of Truth

**Status:** Accepted  
**Datum:** 2025-10-26  
**Autoren:** Sprint 4 Team  
**Kontext:** Sprint 4 (Consent-Sync + Continue-Flow)

---

## Kontext

**Problem:**  
Sprint 2 speicherte Analytics-Consent nur lokal (SharedPreferences). Bei Multi-Device-Nutzung oder App-Reinstall entstand Inkonsistenz: User gibt auf Gerät A Consent, auf Gerät B fehlt er → Analytics werden nicht korrekt initialisiert.

**DSGVO-Anforderung:**  
Consent muss geräteübergreifend einheitlich sein, widerrufen bleiben auch nach Logout/Reinstall wirksam.

**Constraints:**
- Bestehender Sprint-2-Code (lokale Consent-Verwaltung) darf nicht brechen
- Minimaler Client-Overhead (kein dauerhaftes Polling)
- RLS-gesichert (User kann nur eigene Consent-Daten ändern)

**Stakeholder:**
- User (Datenschutz, Konsistenz)
- Entwickler (einfache Migration)
- Compliance (DSGVO-Auditierbarkeit)

---

## Entscheidung

**Analytics-Consent wird serverseitig als SoT (`user_profile.consent_analytics`) gespeichert; lokale Werte sind Mirror für Performance.**

### Implementierung:
1. **Server:** Spalte `user_profile.consent_analytics` (boolean NOT NULL default false, RLS own-only)
2. **Client:** 
   - `ConsentService.syncAnalyticsFromServer()` beim Login (nach Auth)
   - `fetchServerAnalytics()` → Server-Wert holen
   - `setServerAnalytics(value)` → Server UPDATE, dann lokal spiegeln
3. **RPC:** `ensure_user_profile()` (idempotent INSERT, falls Zeile fehlt)
4. **Fallback:** Bei Server-Fehler bleibt lokaler Wert; Retry beim nächsten App-Start

### Warum diese Option?
- **DSGVO-Konform:** Server ist Audit-Log (Consent-Änderungen nachverfolgbar via DB-Timestamps)
- **Multi-Device:** Consent auf Gerät A → sofort auf B nach Login
- **Backward-Compatible:** Sprint-2-Code (lokale Methoden) bleibt funktional
- **Minimale Latenz:** Sync nur beim Login, nicht bei jedem Analytics-Call

---

## Konsequenzen

### Positiv ✅
- **Geräteübergreifende Konsistenz:** User-Consent einheitlich
- **DSGVO-Sicherheit:** Widerruf persistent, auch nach Reinstall
- **Auditierbar:** Server-Logs zeigen Consent-Historie
- **Performance:** Lokaler Cache → kein Netzwerk-Call bei jedem Analytics-Event

### Negativ ⚠️
- **Netzwerk-Abhängigkeit:** Sync schlägt fehl bei Offline-Login (Fallback: lokaler Wert)
- **Migration-Aufwand:** Bestehende User müssen Consent initial auf Server schreiben (Onboarding/Settings)
- **Datenbank-Last:** Ein zusätzlicher SELECT beim Login (minimal, via Index)

### Neutral 🔄
- **Lokale Werte bleiben:** Sprint-2-API unverändert, Server-Sync additiv
- **RPC statt Client-Logic:** `ensure_user_profile()` reduziert Client-Komplexität

---

## Alternativen

### Option A: Nur lokale Speicherung (Status Quo Sprint 2)
- **Pro:** Kein Server-Aufwand, sofortige Verfügbarkeit
- **Contra:** Keine Multi-Device-Konsistenz, DSGVO-Widerruf nicht dauerhaft
- **Warum abgelehnt:** DSGVO-Risiko (Consent-Verlust bei Reinstall), User-Verwirrung bei Gerätewechsel

### Option B: Server als SoT + Echtzeit-Sync (Firebase Realtime DB)
- **Pro:** Instant-Sync über Geräte
- **Contra:** Zusätzliche Abhängigkeit (Firebase), höhere Kosten, Overkill für einmaligen Login-Sync
- **Warum abgelehnt:** MVP braucht keine Echtzeit; Login-Sync ausreichend

### Option C: Consent nur Server, kein lokaler Cache
- **Pro:** Einfachste Architektur (eine Quelle)
- **Contra:** Netzwerk-Call bei jedem Analytics-Init (Startup-Latenz)
- **Warum abgelehnt:** Performance-Degradation, Offline-Probleme

---

## Verweise

- **Sprint:** [OSS_ROADMAP_INDEX.md](../roadmap/OSS_ROADMAP_INDEX.md) — Sprint 4
- **Verwandte ADRs:** ADR-002 (Server-Side Gating) — gleiche "Server-autoritativ"-Philosophie
- **Code:**
  - `app/lib/core/services/consent_service.dart` (Client-Sync)
  - `server/supabase/rpc/ensure_user_profile.sql` (RPC)
  - `app/lib/main.dart` (Login-Hook)
- **Migration:** `server/supabase/migrations/20251026_user_profile.sql` (Spalte bereits vorhanden aus Sprint 3)
- **Tests:** `app/test/services/consent_service_test.dart` (TODO: Mock-Tests für Sync)

---

## Offene Fragen / Tech Debt

- **Migration bestehender User:** Einmalig lokalen Consent → Server schreiben (via Settings-Screen "Consent bearbeiten")
- **Offline-Edge-Case:** Wenn User offline ist UND nie Consent gegeben hat → Analytics bleiben disabled (acceptable)
- **Consent-History:** Optional: Audit-Tabelle `consent_log` mit Timestamps für Compliance (Sprint 6+)
