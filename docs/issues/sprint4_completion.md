# Sprint 4 – DB-Schema, Seeds, Learn-Katalog (Abschlussbericht)

Status: ✅ Abgeschlossen
Branch: `sprint-4/consent-sync-and-continue`
Commit: 1dbe71b

Ziel
- Strukturierter Inhalt und sichtbares Lernen: DB-Schema, Seeds (→ 120 Steps), Learn-Katalog performant, Continue-Heuristik.

Was wurde umgesetzt (kombiniert: vorheriger Chat + aktuelle Arbeit)
- Datenbank & Migrations
  - content baseline Tabellen: `technique`, `technique_step`, `user_step_progress` (RLS) – 20251020_content_min_schema.sql
  - RPCs: `mark_step_complete` (idempotent) – 20251026_mark_step_complete_rpc.sql; `get_next_step` (variant-aware) – 20251027_get_next_step.sql
  - Katalog-Sortierung: `technique.display_order` + Index – 20251027003100_technique_display_order.sql
  - Performance-Indizes – 20251027003200_performance_indexes.sql
  - Seed-Erweiterung +26 Steps (→ 120 total): 20251027_seed_steps_26.sql (idempotent, titelbasiert)
- Seeds
  - `seeds/techniques.json` (20 Techniken)
  - `seeds/steps.json` erweitert: Gi/No‑Gi, idx fortlaufend, neue Paare für Triangle, Kimura, RNC, sowie idx:5 für Kerntechniken
- Edge Function / Serverlogik
  - `supabase/functions/gating_check_step_access/` (CORS, Rate-Limit, RLS-konform, idempotente Entscheidung)
- App (Client)
  - Learn: Kategorien‑Grid → Technikliste (sortiert)
  - Home Continue‑Card: Heuristik via `get_next_step`
  - Services: `ProgressService` (Continue), `GatingService` (server‑authoritativ), Init‑Reihenfolge fix in `app/lib/main.dart`
- Dokumentation / Compliance
  - Roadmap aktualisiert: Sprint 4 auf ✅
  - Privacy Review (Sprint 4): `docs/privacy/reviews/sprint4.md` (RLS, keine neuen PII, idempotente RPCs)

Nachweis / Verifikation
- DB: `SELECT count(*) FROM technique_step;` → 120
- DoD:
  - Learn‑Listen laden flott (Indexing + display_order)
  - Continue zeigt plausiblen nächsten Step (RPC geprüft)
- Manuelle Backfill‑Schritte dokumentiert (RNC‑Titel‑Mapping, UUID default auf technique_step)

Datei‑Referenzen
- Seeds: `seeds/steps.json`
- Migration Seeds: `supabase/migrations/20251027_seed_steps_26.sql`
- RPC: `supabase/migrations/20251027_get_next_step.sql`
- Edge Fn: `supabase/functions/gating_check_step_access/index.ts`
- Services: `app/lib/core/services/progress_service.dart`, `app/lib/core/services/gating_service.dart`
- Roadmaps: `docs/roadmap/OSS_ROADMAP_S0-S4.md`, `docs/roadmap/OSS_ROADMAP_INDEX.md`
- Privacy: `docs/privacy/reviews/sprint4.md`

Akzeptanzkriterien (erfüllt)
- 20 Techniken sichtbar, 100–120 Steps (120 erreicht)
- Continue‑Heuristik serverbestätigt
- Seeds/DB idempotent, RLS aktiv

Lessons Learned / Folgeaufgaben (für S5+)
- Cues künftig als JSONB oder Kindtabelle modellieren (ADR + Migration)
- CI‑gestützter DB‑Push (GitHub Actions) zur Vermeidung lokaler Pooler‑Hänger
- Optional: zusätzliche Seeds für Balance Guard/Pass/Submission

Bitte schließen, wenn keine weiteren Einwände bestehen.
