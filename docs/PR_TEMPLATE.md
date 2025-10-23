# Pull Request Template

## 🔵 Role & Keywords
**Role:** `<ui-frontend | api-backend | db-admin | dataviz | qa-dsgvo>`  
**Keywords:** `[keyword1, keyword2, ...]`

---

## 🟢 BMAD (Governance)

### Business
- **Ziel (1 Satz):**  
- **DSGVO-Impact:** `<ja/nein>` → falls ja, siehe Review unter `docs/privacy/reviews/<id>.md`

### Modellierung
- **Flows/ERD/Typen:**  
- **Datenmodell-Änderungen:** `<ja/nein>`

### Architektur
- **Interfaces/Contracts:**  
- **Upserts/RLS-Policies:**  
- **Edge Functions:**  

### DoD (Definition of Done)
- [ ] Tests grün (`flutter test` / Edge Fn Contract-Tests)
- [ ] ADRs gepflegt (falls architektonische Entscheidung)
- [ ] DSGVO-Review aktualisiert (falls PII betroffen)

---

## ✅ Prove (Validation)

### Code Quality
- [ ] `flutter format --set-exit-if-changed .` ✅
- [ ] `flutter analyze` → 0 issues ✅
- [ ] `flutter test` → all tests pass ✅

### Backend (falls zutreffend)
- [ ] Edge Function deployed & tested
- [ ] RLS-Policies verifiziert
- [ ] Health-Endpoint: `/health` (EU) → 200 ✅

### DSGVO (falls zutreffend)
- [ ] Consent-Gate vor Telemetrie
- [ ] Keine PII in Logs/Sentry
- [ ] User-Deletion via `delete_user_data` RPC testbar

---

## 📋 Sprint Context
**Sprint:** `<S0 | S1 | S2 | ... | S8>`  
**Roadmap-Datei:** `docs/roadmap/OSS_ROADMAP_S0-S4.md` oder `OSS_ROADMAP_S5-S8.md`

**Tasks abgeschlossen:**
- [ ] Task 1: ...
- [ ] Task 2: ...

---

## 🔗 Links
- **Health-Endpoint (deployed):** `https://<your-project-id>.supabase.co/functions/v1/health` ✅
- **Figma (falls UI):** `<link>`
- **Related Issue/ADR:** `<link>`

---

## 📸 Screenshots/Videos (optional)
_Falls UI-Änderungen: Vorher/Nachher_

---

## ⚠️ Breaking Changes
`<ja/nein>` → falls ja, Migrationsplan beschreiben

---

## 📝 Notes
_Zusätzliche Kontext-Informationen für Reviewer_
