# OSS Roadmap Index

**Zentrale Übersicht aller Sprints für MVP (iOS first)**

---

## 📍 Roadmap-Struktur

Die Roadmap ist in 2 Phasen aufgeteilt:

### Phase 1: Foundation (Sprint 0–4)
→ **[OSS_ROADMAP_S0-S4.md](./OSS_ROADMAP_S0-S4.md)**

- **Sprint 0:** Projekt-Fundament (CI, Health, CodeRabbit)
- **Sprint 1:** Navigation-Shell + Bottom-Nav
- **Sprint 2:** Consent (DSGVO) + Legal + Auth
- **Sprint 3:** Onboarding + Settings (Basis)
- **Sprint 4:** DB-Schema & Seeds & Lernen-Katalog

### Phase 2: Feature Completion & Launch (Sprint 5–8)
→ **[OSS_ROADMAP_S5-S8.md](./OSS_ROADMAP_S5-S8.md)**

- **Sprint 5:** Technique + Step-Player (UI-Zustände)
- **Sprint 6:** Serverseitiges Gating + RLS + Account-Deletion
- **Sprint 7:** Statistik + Content-Roadmap + Achievements + Testimonials
- **Sprint 8:** Paywall + RevenueCat + iOS-Store-Paket

---

## 🎯 Aktueller Status

**Sprint:** Pre-0 (nur Docs/Governance vorhanden)
**Nächster Schritt:** Sprint 0 starten (Flutter-App aufsetzen, CI, Health-Endpoint)

---

## 📊 Sprint-Übersicht (kompakt)

| Sprint | Phase | Thema | DoD Highlight |
|--------|-------|-------|---------------|
| S0 | Foundation | Projekt-Fundament | iOS Dev-Build startet; CI grün |
| S1 | Foundation | Navigation + Bottom-Nav | 4 Tabs wechselbar |
| S2 | Foundation | Consent + Auth | Signup/Login stabil |
| S3 | Foundation | Onboarding + Settings | Onboarding ≤60 s |
| S4 | Foundation | DB + Seeds + Katalog | 20 Techniken sichtbar |
| S5 | Features | Step-Player | Step 1–2 bedienbar |
| S6 | Features | Server-Gating + RLS | Free-User: Step 3 → 403 |
| S7 | Features | Stats + Retention | Achievements unlock |
| S8 | Launch | Paywall + Store | App-Store Submit |

---

## 📖 Weitere Dokumentation

- **Product Context:** [../OSS_PRODUCT_CONTEXT.md](../OSS_PRODUCT_CONTEXT.md)
- **Tone & i18n:** [../OSS_TONE_EAGLE_FANG.md](../OSS_TONE_EAGLE_FANG.md) + [../i18n_keys.json](../i18n_keys.json)
- **API Contracts:** [../API_CONTRACTS.md](../API_CONTRACTS.md)
- **DB Schema:** [../DB_SCHEMA_MIN.sql](../DB_SCHEMA_MIN.sql)
- **ADRs:** [../adr/](../adr/)

---

## 🔄 Roadmap-Pflicht (für Warp)

Vor jeder Aufgabe:
1. Diesen Index lesen → relevanten Sprint-File öffnen
2. OSS_PRODUCT_CONTEXT.md für Use-Cases/Flows
3. i18n_keys.json für Microcopy
4. ADRs für architektonische Entscheidungen
