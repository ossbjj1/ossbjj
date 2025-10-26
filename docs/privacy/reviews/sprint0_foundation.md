# DSGVO-Review: Sprint 0 – Foundation

**Reviewer:** Warp Agent  
**Datum:** 2025-10-23  
**Sprint:** S0 – Projekt-Fundament  
**Status:** ✅ Bestanden

---

## Scope
Sprint 0 legt die technische Grundlage ohne User-Daten:
- Flutter-App mit Dark-Theme (UI-Tokens)
- GoRouter mit Navigation-Stubs
- Health-Endpoint (`/health`) ohne Auth
- CI/CD (GitHub Actions: format/analyze/test)
- `.coderabbit.yaml` mit DSGVO-Warnungen

---

## PII-Check

### ❌ Keine PII in diesem Sprint
- Keine User-Registrierung
- Keine Telemetrie (PostHog/Sentry registriert aber nicht initialisiert)
- Keine Persistierung von Nutzerdaten
- Health-Endpoint gibt nur `status: ok, region: eu, time: <iso>` zurück

---

## Consent-Gate

### Status: ⚠️ Vorbereitet (Sprint 2)
- PostHog/Sentry im `pubspec.yaml` vorhanden
- Initialisierung erfolgt erst in Sprint 2 mit Consent-Modal
- Runtime-Gate via `consent_analytics` Flag (siehe S2 Task 2)

**Code-Vorbereitung:**

```dart
// Beispiel für Sprint 2:
if (userConsent.analytics) {
  PostHog.init(...);
  Sentry.init(...);
}
```

---

## Server-Side Security

### ✅ Health-Endpoint
- **URL:** `https://<ref>.supabase.co/functions/v1/health`
- **Method:** GET (OPTIONS für CORS)
- **Response:** `{ "status": "ok", "region": "eu", "time": "..." }`
- **PII:** Keine
- **Auth:** Nicht erforderlich (öffentlicher Health-Check)

### ⚠️ Zukünftige Edge Functions (Sprint 6+)
- Gating (`/gating/step-complete`) benötigt Auth + RLS
- RevenueCat Webhook (`/rc/webhook`) benötigt Signaturprüfung

---

## RLS (Row Level Security)

### Status: 🔜 Sprint 4
- Migrations noch nicht erstellt
- Policies werden mit Sprint 4 (DB-Schema) + Sprint 6 (Gating) implementiert
- **Regel:** Alle Tabellen mit User-Daten MÜSSEN RLS-Policies haben

---

## Secrets Management

### ✅ Korrekt
- `.env` in `.gitignore`
- `.env.sample` als Template ohne Secrets
- Supabase-Keys werden via Environment Variables injiziert (nicht im Code)

---

## Retention & Deletion

### Status: 🔜 Sprint 6
- `delete_user_data` RPC (siehe `/server/supabase/rpc/delete_user_data.sql`)
- Implementierung folgt mit Account-Deletion UI (Sprint 3 Settings + Sprint 6 Backend)

---

## Compliance-Status

| Kriterium | Status | Sprint |
|-----------|--------|--------|
| Consent-Gate | ⏳ Vorbereitet | S2 |
| PII-Minimierung | ✅ | S0 |
| RLS-Policies | ⏳ | S4, S6 |
| User-Deletion | ⏳ | S6 |
| Secrets-Management | ✅ | S0 |
| Telemetrie-Opt-in | ⏳ | S2 |

---

## Nächste Schritte (Sprint 2)
1. Consent-Modal implementieren (Analytics/Media Toggles)
2. PostHog/Sentry nur bei `consent_analytics == true` initialisieren
3. Runtime-Gate in `main.dart` vor Telemetrie-Init
4. Privacy Policy + AGB verlinken

---

## Approval
✅ **Sprint 0 ist DSGVO-konform** – keine PII, keine Telemetrie, Secrets geschützt.
