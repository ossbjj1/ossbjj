# Ton (PG-13 default, RAW opt-in)

## Säulen

1. **Befehl statt Bitte:** "Hol den Griff." / "Dreh die Hüfte."
2. **Zwei-Takt-Sätze:** Befehl + Grund ("Hol den Griff. Kein Griff = kein Armbar.")
3. **Spott nur gegen Ausreden, nie gegen Menschen:** "Ausreden raus."
4. **Respekt/Safety bleiben drin:** "Tap heißt stoppen." – Eagle-Fang ≠ "No Mercy"
5. **Roh-Humor sparsam (RAW-Modus):** bleep/censor bei Bedarf (App-Store-sicher)

---

## Profanity-Regler (Settings)

- **Tonintensität:** `dojo` (PG-13, Standard) / `raw` (opt-in)
- **PG-13:** "Verdammt", "zur Hölle mit …" / z. T. zensiert ("Schei**")
- **RAW:** klare Kraftausdrücke in kurzen Stößen, nie gegen Personen, nie diskriminierend

---

## Sprachmuster

- **Imperativ-Verben:** hol, klemm, stell, heb, leg drüber, zieh, winkel, finish
- **Rhythmus:** 3–6 Wörter / Satz
- **Rhetorik:** kurze Fragen zum Aktivieren („Bereit? Dann hol den Griff.“)
- **Verboten:** Herabwürdigung, Slurs, Gewaltverherrlichung; markenrechtliche Originalslogans (wir paraphrasieren)

---

## i18n-Keys (vollständiger Katalog)

### Onboarding / Motivation
- `onb.headline`: "Zeit auf der Matte. Los."
- `onb.variant.prompt`: "Gi oder No-Gi?"
- `onb.belt`: "Dein Gürtel?"
- `onb.goal`: "Wochenziel?"

### Tabs / Navigation
- `tab.home`: "Home"
- `tab.learn`: "Lernen"
- `tab.stats`: "Statistik"
- `tab.settings`: "Einstellungen"

### Gi/No-Gi
- `learn.variant.title`: "Gi oder No-Gi?"
- `learn.variant.gi`: "Gi"
- `learn.variant.nogi`: "No-Gi"

### Step-Player / Sensei-Hinweise
- `sensei.grip`: "Hol den Griff. Punkt." (RAW: "Hol den verdammten Griff.")
- `sensei.angle`: "Winkel schlägt Kraft." (RAW: "Hör auf zu drücken. Winkel, nicht Ego.")
- `sensei.legover`: "Leg drüber. Schließ." (RAW: "Leg drüber. Kopf runter – jetzt.")
- `sensei.finish`: "Hip extend. Tap = sofort lösen."
- `step.title`: "Step {n} – {label}"
- `step.complete`: "Fertig"
- `step.locked`: "Gesperrt. Erst {prev}."

### Toasts / Bestätigungen
- `toast.step_done`: "Sitzt. Weiter." (RAW: "Sitzt. Weiter, keine Ausreden.")
- `toast.streak`: "{n} Tage Streak. Respekt."
- `toast.achievement`: "🏆 {title} freigeschaltet!"

### Fehler / Gates
- `gate.prereq_missing`: "Vorherigen Step erledigen."
- `gate.paywall`: "Free endet hier. Pro schaltet frei."
- `gate.locked`: "Gesperrt. Erst Step {prev}."
- `err.network`: "Kein Netz. Wiederholen."
- `err.generic`: "Fehler. Nochmal probieren."

### Paywall (ehrlich, Johnny-direkt)
- `paywall.title`: "Willst du finishen oder scrollen?" (RAW: "Trainieren oder rumscrollen?")
- `paywall.subtitle`: "Alle Steps freischalten."
- `paywall.cta_primary`: "Pro holen und rollen"
- `paywall.cta_secondary`: "Später"
- `paywall.restore`: "Käufe wiederherstellen"
- `paywall.benefit_1`: "Alle 100+ Steps"
- `paywall.benefit_2`: "Gi + No-Gi"
- `paywall.benefit_3`: "Kein Limit"

### Streak / Stats
- `streak.alive`: "{n} Tage Streak. Respekt."
- `streak.lost`: "Streak gerissen. Neu starten."
- `stats.completed`: "{n} Steps erledigt"
- `stats.techniques`: "{n} Techniken gemeistert"
- `stats.repeat`: "Wiederholen"

### Content-Roadmap
- `roadmap.title`: "📅 Nächste Inhalte"
- `roadmap.status.released`: "Jetzt freigeschaltet"
- `roadmap.status.locked`: "Kommt bald"
- `roadmap.guard_passes`: "Abwehr-Techniken"
- `roadmap.leg_locks`: "Beintechnik-System"
- `roadmap.advanced_escapes`: "Fortgeschrittene Fluchtbewegungen"

### Achievements
- `achievements.title`: "🏆 Deine Erfolge"
- `achievements.unlocked`: "✅ Erreichte Abzeichen"
- `achievements.upcoming`: "🔒 Nächste Abzeichen"
- `achievement.first_grip`: "Erstes Greifen"
- `achievement.streak_7days`: "Streak-Krieger"
- `achievement.tech_master`: "Technik-Meister"
- `achievement.purple_belt`: "Purple Belt Ready"
- `achievement.all_positions`: "Alle Positionen"
- `achievement.steps_25`: "25 Steps gemeistert"

### Testimonials
- `testimonials.title`: "💬 Was andere sagen"
- `testimonials.prev`: "← Zurück"
- `testimonials.next`: "Weiter →"

### Settings
- `settings.language`: "Sprache"
- `settings.consent`: "Datenschutz & Consent"
- `settings.tone`: "Tonintensität"
- `settings.tone.dojo`: "Dojo (Standard)"
- `settings.tone.raw`: "RAW (opt-in)"
- `settings.audio`: "Audio-Feedback"
- `settings.delete_account`: "Konto & Daten löschen"
- `settings.logout`: "Abmelden"

### Consent
- `consent.title`: "Deine Zustimmung"
- `consent.analytics`: "Analytics (PostHog)"
- `consent.media`: "Medien-Download"
- `consent.save`: "Speichern"

### Legal
- `legal.privacy`: "Datenschutz"
- `legal.terms`: "AGB"

---

## UI-Punkte, an denen der Ton wirkt (ohne zu nerven)

- **Home-Hero „Weiter machen“:** kurze, fordernde Unterzeile (Sensei-Hinweis)
- **Technique-Header:** 1-Zeiler tough-love (kein Roman)
- **Step-Player:** Stichpunkt-Checkliste + 1 Sensei-Hinweis
- **Statistik:** knappe Anerkennung („Streak lebt. Weiter.“)
- **Fehler:** kurz & kalt („Gesperrt. Erst {prev}.“)
- **Keine Schimpfwort-Dauerbeschallung** – Spitzen nur an Wendepunkten

---

## App-Store-Sicherheit (ohne Zahmwerden)

- **Default = PG-13**; RAW nur per opt-in in Einstellungen (mit Hinweis „kräftige Sprache“)
- Keine Ziel-Beleidigungen, kein Hass/Herabsetzung; bleep/censor bei Bedarf
- Paraphrasen statt markenrechtlicher Original-Slogans

---

## TL;DR für Entwicklung

- **Johnny-Ton** = kurz, aggressiv, frech – aber fair
- **PG-13/RAW-Schalter** macht’s App-Store-sicher und markenkonform
- **Tough-Love** richtet sich gegen Ausreden, nicht gegen Menschen
- EN-Spiegeln in `intl_en.arb` (gleiche Keys, übersetzt)

