# ADR-003: Achievement System mit JSON Conditions

**Status:** Accepted  
**Datum:** 2025-10-23  
**Autoren:** Product/Engineering  
**Kontext:** Sprint 7 (Achievements)

---

## Kontext

Achievements (Badges) sind zentral für User-Retention. User sollen für Meilensteine belohnt werden (z.B. "Erster Step", "7 Tage Streak", "25 Steps erledigt").

**Fragestellung:**
- Wie definieren wir Achievement-Unlock-Bedingungen flexibel?
- Soll die Logik hardcoded oder data-driven sein?

**Constraints:**
- Neue Achievements sollen ohne Code-Deploy hinzufügbar sein (via Seeds)
- Bedingungen können komplex sein (z.B. "5 Techniken 100% UND Streak ≥ 7")
- Performance: Achievement-Check läuft nach jedem Step-Complete

---

## Entscheidung

**Achievement-Bedingungen werden als JSON in der DB gespeichert:**

1. **Datenmodell:**
   ```sql
   achievement (
     id int PRIMARY KEY,
     key text UNIQUE,
     title_en text,
     title_de text,
     icon text,
     type text, -- 'milestone', 'streak', 'progress'
     unlock_condition jsonb
   );
   ```

2. **Beispiel-Condition:**
   ```json
   {
     "steps_completed": 25
   }
   ```
   oder komplex:
   ```json
   {
     "AND": [
       {"techniques_completed": 5},
       {"streak_days": 7}
     ]
   }
   ```

3. **Check-Logik (Edge-Function nach Step-Complete):**
   ```typescript
   // Hole alle Achievements
   const achievements = await supabase.from('achievement').select('*');
   
   // Für jedes Achievement: Parse Condition, prüfe
   for (const ach of achievements) {
     const condition = ach.unlock_condition;
     let shouldUnlock = false;
     
     if (condition.steps_completed) {
       const count = await getUserStepCount(userId);
       shouldUnlock = count >= condition.steps_completed;
     } else if (condition.streak_days) {
       const streak = await calcStreak(userId);
       shouldUnlock = streak >= condition.streak_days;
     }
     // ... weitere Conditions
     
     if (shouldUnlock) {
       await supabase.from('user_achievement').upsert({user_id, achievement_id});
     }
   }
   ```

4. **Neue Achievements hinzufügen:**
   - Kein Code-Deploy nötig, nur Seed-Update:
     ```json
     {"id": 7, "key": "blue_belt_ready", "unlock_condition": {"steps_completed": 50}}
     ```

---

## Konsequenzen

### Positiv
- **Flexibel:** Neue Achievements ohne Code-Deploy (nur DB-Insert/Seed)
- **Daten-Driven:** Product kann Conditions anpassen (z.B. "25 → 30 Steps")
- **Testbar:** Conditions sind JSON → einfach zu mocken/testen

### Negativ
- **Performance:** JSON-Parsing pro Achievement-Check (~10ms bei 10 Achievements)
- **Komplexität:** Verschachtelte Conditions (AND/OR) brauchen Recursive Parser
- **Typsicherheit:** JSON = keine Compile-Time-Checks (Fehler erst zur Laufzeit)

### Neutral
- Bei >100 Achievements: Caching oder Index auf `type` nötig

---

## Alternativen

### Option A: Hardcoded Conditions (Switch-Case im Code)
- **Pro:** Schnell, typsicher, kein JSON-Parsing
- **Contra:** Jedes neue Achievement = Code-Deploy; nicht skalierbar
- **Warum abgelehnt:** Nicht flexibel, Product-Team kann nicht iterieren

### Option B: Lua/JavaScript-Scripts in DB
- **Pro:** Maximale Flexibilität (beliebige Logik)
- **Contra:** Sicherheitsrisiko (Code-Injection), schwer zu testen
- **Warum abgelehnt:** Over-Engineering, Sicherheitsrisiko

### Option C: Dedicated Achievement-Service
- **Pro:** Entkopplung, eigene Skalierung
- **Contra:** Overhead (neuer Service, Deployment, Monitoring)
- **Warum abgelehnt:** MVP braucht kein Microservice

---

## Verweise

- Sprint: [OSS_ROADMAP_S5-S8.md](../roadmap/OSS_ROADMAP_S5-S8.md#sprint-7)
- DB Schema: [DB_SCHEMA_MIN.sql](../DB_SCHEMA_MIN.sql)
- Seeds: `seeds/achievements.json`
- Code: `server/supabase/functions/gating_step_complete/index.ts` (Achievement-Check)
