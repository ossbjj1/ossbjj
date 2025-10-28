# Developer Handover

Role: db-admin, api-backend, ui-frontend  
Keywords: seeds, importer, RPC, RLS, search_path, timeouts, Riverpod, consent, onboarding, timezone, streak

BMAD
- Business: Stabilität, Sicherheit, Inhalt vollständig; Seeds/Importer robust; UI blockiert nicht; Server entscheidet Zugang.
- Modellierung: auth.uid()-RPC, service-role-only grants, user_profile.timezone (offen), 30‑min grace (offen).
- Architektur: Timeouts, Logger, typed parsing; Riverpod ref.read; composite Index; CHECK constraint; absolute seed paths; konfigurierbare Zählvalidierung.
- DoD: Commits grün, Seeds ergänzt (keine Orphans), Importer robust; offene Punkte klar spezifiziert.

Prove
- Lint/format Hooks liefen; Commits erstellt.
- RLS/SECURITY gehärtet (get_next_step, achievements).
- Noch offen: Deno nicht installiert; Streak+TZ, Onboarding‑Timer, Settings‑Toggles, Docs.

---

## Ziele
Projekt nach PR-Review sofort weiterführen: Seeds vollständig, Importer robust, Backend sicher, UI entkoppelt; verbleibende Arbeiten deterministisch umsetzen.

## Was bereits umgesetzt (mit Warum, Wo)

### 1) Seeds vervollständigt
- Warum: 5 Techniken ohne Steps → Learn‑Flows brechen.
- Was: 50 neue Steps (5 Techniken × 2 Varianten × 5 Steps) hinzugefügt. Entfernte Techniken wiederhergestellt.
- Wo:
  - seeds/techniques.json: re‑added
    - toreando-pass, over-under-pass, back-take-from-turtle, straight-armbar-mount, guillotine-choke
  - seeds/steps.json: 50 neue Objekte je Technik/Variante/idx 1..5 mit title_en/de, cues_en/de
- Commit: feat(seeds): restore 5 techniques + add 50 steps

### 2) Importer robust + konfigurierbar
- Warum: Relative Pfade brechen bei anderem CWD; starre Zählprüfungen blockieren künftige Importe.
- Was:
  - Pfad‑Auflösung via import.meta.url; optional SEEDS_DIR Override.
  - Zählvalidierung per Env: EXPECT_TECHNIQUES, MIN_STEPS, MAX_STEPS, ENFORCE_COUNTS (Warnungen standard).
  - Bessere Fehlermeldungen bei Dateizugriff.
- Wo: server/supabase/scripts/seed_import.ts
- Commit: fix(seeds): make seed_import.ts robust + configurable

### 3) get_next_step RPC gehärtet
- Warum: Trust boundary Client→DB schließen; search_path‑Injection vermeiden.
- Was: p_user_id entfernt; user via auth.uid(); SECURITY DEFINER + SET search_path = pg_catalog, public.
- Wo: supabase/migrations/20251027_get_next_step.sql

### 4) Technique‑Darstellung + Performance
- Warum: Sortierung/Abfrage stabil und performant.
- Was: CHECK constraint (display_order 0..32767), Composite Index (category, display_order), Kommentar präzisiert (Default 999 = unten, bis kuratiert).
- Wo: supabase/migrations/20251027003100_technique_display_order.sql

### 5) Achievements – RLS fix
- Warum: Users konnten sich selbst Achievements geben.
- Was: ua_insert_own entfernt; neue Policy ua_insert_service (nur service_role).
- Wo: supabase/migrations/20251023_roadmap_achievements.sql

### 6) App‑Stabilität (Netzwerk/Timeout/Typing)
- Warum: UI darf nicht hängen; Observability; sichere Typen.
- Wo/Was:
  - app/lib/core/services/progress_service.dart: RPC/Query Timeouts (8s), Logger injection, type‑safe parsing, p_user_id entfernt (Server nutzt auth.uid()).
  - app/lib/features/home/continue_card.dart: Client‑Gating entfernt; immer serverseitige Prüfung via gatingService.
  - app/lib/features/learn/data/technique_repository.dart: Timeouts (10s), strukturierte Fehler (TechniqueLoadFailure), typed mapping.
  - app/lib/features/learn/providers/technique_providers.dart: ref.watch → ref.read in FutureProvider.
  - app/lib/features/learn/data/models.dart: Safe casts, Validation, num→int Coercion.
  - app/lib/main.dart: ProgressService erhält shared Logger.

### 7) Dead code entfernt
- Warum: Single Source of Truth.
- Was entfernt: app/lib/features/learn/repositories/technique_repository.dart, app/lib/features/learn/models/technique_dto.dart

---

## Offene Punkte (aus ursprünglichem Plan)
A) DB: user_profile.timezone + calc_streak_days (User‑TZ, ±30min)
B) App: Onboarding ≤60s (Timer + Autosave, Telemetrie)
C) App: Settings – echte Consent‑Toggles (Analytics/Media) statt nur Navigation
D) Docs: Roadmap DoD präzisieren (60s Soft‑Ziel, Consent in Settings live)
E) Seeds Deploy: seed_import —dry-run/—apply (Deno installieren)
F) CI/Checks: flutter format/analyze/test (lokal und CI), Supabase lint optional

---

## Exakte Umsetzungsschritte (Do it like this)

### A) DB – user_profile.timezone + calc_streak_days
1. Migration anlegen: supabase/migrations/20251028_user_profile_timezone.sql
```sql path=null start=null
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='user_profile' AND column_name='timezone'
  ) THEN
    ALTER TABLE public.user_profile
      ADD COLUMN timezone TEXT NOT NULL DEFAULT 'UTC'
      CHECK (timezone <> '');
  END IF;
END$$;
```

2. RPC ersetzen: supabase/migrations/20251028_calc_streak_days_tz.sql
```sql path=null start=null
CREATE OR REPLACE FUNCTION public.calc_streak_days()
RETURNS int
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_uid uuid;
  v_tz  text;
  v_today date;
  v_streak int;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;

  SELECT COALESCE(up.timezone, 'UTC') INTO v_tz
  FROM public.user_profile up WHERE up.user_id = v_uid;

  v_today := (now() AT TIME ZONE v_tz - interval '30 minutes')::date;

  WITH step_days AS (
    SELECT DISTINCT (usp.completed_at AT TIME ZONE v_tz - interval '30 minutes')::date AS d
    FROM public.user_step_progress usp
    WHERE usp.user_id = v_uid AND (usp.completed_at AT TIME ZONE v_tz) <= now() AT TIME ZONE v_tz
  ),
  numbered AS (
    SELECT d, ROW_NUMBER() OVER (ORDER BY d DESC) AS rn
    FROM step_days WHERE d <= v_today
  )
  SELECT COUNT(*) INTO v_streak
  FROM numbered
  WHERE d = v_today - (rn - 1);

  RETURN COALESCE(v_streak, 0);
END;
$$;
```

3. Tests (SQL)
- Tage rund um Mitternacht (23:50, 00:20) prüfen → ±30m greift.
- Anonymer Nutzer → Exception.

### B) App – Onboarding ≤60s (Timer + Autosave)
1. Dateien: app/lib/features/onboarding/onboarding_screen.dart, app/lib/core/services/profile_service.dart
2. Umsetzung
- Timer startet beim ersten User‑Input.
- Countdown‑Badge (sichtbar ab 45s).
- Bei 60s: einmaliger Autosave (profileService.upsert(draft=true)), Snackbar „Gespeichert…“.
- Telemetrie (bei consent_analytics): onboarding_duration_sec, onboarding_autosave.
- Fehlerfall: Revert/Retry via Snackbar.
3. Tests
- Widget‑Test: Zeit simulieren, Autosave‑Call assert, Countdown sichtbar.

### C) App – Settings: Consent‑Toggles
1. Datei: app/lib/features/settings/settings_screen.dart
2. UI
- Section „Datenschutz & Einwilligung“
- Switch „Analytics“ (consentService.analytics)
- Switch „Media“ (falls genutzt)
- „Details ansehen“ → ConsentModal
3. Logik
- onChanged: persist + consentService.syncToServer(); onFail revert + Snackbar.
- Analytics live init/deinit (analyticsService.initIfAllowed/teardown).
4. Tests
- Widget‑Test: Toggle → consentService state, Analytics init/deinit aufgerufen.

### D) Docs – Roadmap
- Datei: docs/roadmap/OSS_ROADMAP_S0-S4.md
- Update: „≤60s“ als Soft‑Ziel mit Timer+Autosave; Consent‑Toggles in Settings als live, sobald implementiert.

### E) Seeds Deploy
1. Deno installieren (macOS):
```bash path=null start=null
brew install deno
```
2. Env setzen (Service Role sicher):
```bash path=null start=null
export SUPABASE_URL=https://xqgqentkowzxckwlmyqc.supabase.co
export SUPABASE_SERVICE_ROLE=$(security find-generic-password -a oss -s oss_supa_service_role -w)
```
3. Dry‑Run / Apply:
```bash path=null start=null
deno run -A server/supabase/scripts/seed_import.ts --dry-run
EXPECT_TECHNIQUES=20 MIN_STEPS=80 MAX_STEPS=240 ENFORCE_COUNTS=false \
  deno run -A server/supabase/scripts/seed_import.ts --apply
```

### F) CI/Checks
```bash path=null start=null
flutter format .
flutter analyze
flutter test
```
(Optional) Supabase Lint, falls vorhanden.

---

## Akzeptanzkriterien (DoD)
- Seeds: keine Orphans, keine Duplicates; Importer findet Seeds unabhängig vom CWD; Counts per Env; Dry‑Run/Apply grün.
- RPC/DB: get_next_step via auth.uid(); achievements Insert nur service_role; calc_streak_days korrekt (User‑TZ, ±30m).
- App: Onboarding‑Timer+Autosave; Settings‑Toggles live; Continue‑Card nutzt serverseitiges Gating für alle Steps.
- Docs: Roadmap beschreibt den realen Stand.

## Risiken/Rollback
- Migrations idempotent (IF NOT EXISTS/CREATE OR REPLACE).
- Seeds via Upsert idempotent.
- UI‑Änderungen feature‑scoped; revertbar per Git.

## Nächste Session – Startcheckliste
- Deno installieren
- seed_import —dry-run → prüfen
- seed_import —apply → deploy
- Migrationen: timezone + calc_streak_days
- Onboarding‑Timer implementieren
- Settings‑Toggles implementieren
- Roadmap updaten, dann format/analyze/test
