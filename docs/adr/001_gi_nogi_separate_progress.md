# ADR-001: Gi/No-Gi Separate Progress Tracking

**Status:** Accepted  
**Datum:** 2025-10-23  
**Autoren:** Product/Engineering  
**Kontext:** Sprint 4 (DB-Schema)

---

## Kontext

OSS soll sowohl Gi- als auch No-Gi-BJJ unterstützen. Viele Techniken unterscheiden sich erheblich zwischen den Varianten (z.B. Griffe: Kragen/Ärmel vs. Wrist-Control/2-on-1).

**Fragestellung:**
- Sollen Gi/No-Gi als separate Techniken oder als Varianten einer Technik modelliert werden?
- Wie tracken wir User-Progress?

**Constraints:**
- User wollen klar sehen, wo sie in Gi vs. No-Gi stehen
- Gemeinsame Basics (z.B. Hüftwinkel) sollen nicht dupliziert werden
- DB-Schema muss einfach bleiben (keine Over-Engineering)

---

## Entscheidung

**Wir tracken Gi/No-Gi-Progress separat auf Step-Ebene:**

1. **Datenmodell:**
   ```sql
   technique (id, title, category)
   technique_step (id, technique_id, variant: gi|nogi|both, idx, title)
   user_step_progress (user_id, technique_step_id, completed_at)
   ```

2. **Logik:**
   - Steps mit `variant = 'both'` (z.B. Hüftwinkel) zählen für beide Varianten
   - Steps mit `variant = 'gi'` oder `variant = 'nogi'` zählen nur für ihre Variante
   - User sieht pro Technik zwei Chips: `[Gi] [No-Gi]` → wählt Variante, sieht passende Steps

3. **UI:**
   - Technique-Screen: Chips `Gi | No-Gi` (aktiv = farbig)
   - Progress wird pro Variante separat angezeigt (z.B. "Armbar Gi: 4/6, No-Gi: 2/6")

---

## Konsequenzen

### Positiv
- **Klare Trennung:** User sieht sofort, wo er in welcher Variante steht
- **Deduplizierung:** Basics (z.B. Hüftwinkel) werden nicht doppelt gespeichert
- **Flexibilität:** Neue Techniken können 100% Gi, 100% No-Gi oder hybrid sein

### Negativ
- **Komplexität im Seed:** `technique_step` braucht `variant`-Field + sorgfältiges Labeling
- **Abfrage-Komplexität:** Progress-Berechnung muss `variant` berücksichtigen

### Neutral
- DB-Schema wächst minimal (1 Field `variant` + Index)

---

## Alternativen

### Option A: Gi/No-Gi als separate Techniken
- **Pro:** Einfaches Schema, keine Varianten-Logik
- **Contra:** Doppelte Techniken (z.B. "Armbar Gi", "Armbar No-Gi"), Basics dupliziert, UI-Chaos
- **Warum abgelehnt:** Schlechte UX, Datenredund

anz

### Option B: Nur Gi ODER No-Gi (nicht beide)
- **Pro:** Maximal einfach, kein `variant`-Field
- **Contra:** Schließt 50% der Zielgruppe aus (No-Gi-Only-Gyms)
- **Warum abgelehnt:** Produkt-Vision umfasst beide Stile

---

## Verweise

- Sprint: [OSS_ROADMAP_S0-S4.md](../roadmap/OSS_ROADMAP_S0-S4.md#sprint-4)
- Product Context: [OSS_PRODUCT_CONTEXT.md](../OSS_PRODUCT_CONTEXT.md#giNo-gi-auswahl)
- DB Schema: [DB_SCHEMA_MIN.sql](../DB_SCHEMA_MIN.sql)
- Code: `seeds/techniques.json`, `seeds/steps.json`
