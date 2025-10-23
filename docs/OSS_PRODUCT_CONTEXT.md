# OSS Product Context

## Was ist OSS?

OSS ist eine mobile BJJ-Lernapp (iOS first), die dich Schritt für Schritt durch die 20 wichtigsten Grundlagen-Techniken führt. Jede Technik ist in 4–7 Mini-Schritte zerlegt, mit 8–12 Sekunden-Clips und knappen Aufgaben.

**Zielgruppe:**
- Einsteiger & White Belts: zu viel Input, kein Plan → wir geben Richtung
- Frische Blue Belts: Basics schärfen → saubere Ketten statt Zufall
- Leute mit wenig Zeit: 10 Minuten reichen, wenn du gezielt übst

**Stil:** Eagle-Fang-Ton — kurze Imperative, zero Bullshit, Respekt – ohne Ausreden.

---

## Lernen: Gi / No-Gi + Step-Gating

### Gi/No-Gi-Auswahl (pro Technik)

Beim Öffnen einer Technik (z.B. Armbar – Closed Guard) erscheinen Chips: **Gi | No-Gi**.

- **Gi**: Kragen/Ärmel-Griffe, Stoff-Kontrollen
- **No-Gi**: Wrist-Control, 2-on-1, S-Grip

Progress wird **pro Variante** gezählt (Gi und No-Gi separat). Gemeinsame Basics (z.B. Hüftwinkel) werden dedupliziert.

**UI-Flow:**
```
Lernen → "Closed Guard" → Armbar → Chips [Gi] [No-Gi] → Step 1
```

**Datenmodell (konzeptuell):**
- `technique` (id, category, title_en/de)
- `technique_step` (id, technique_id, variant: gi|nogi|both, idx, title_en/de)
- `user_step_progress` (user_id, technique_step_id, completed_at)

---

### Step-Gating (N+1)

- **Step 1–2 frei**, ab **Step 3 Paywall** (entitlement == 'premium')
- Ein Step gilt erst "Erledigt", wenn du ihn im Training mehrmals erreicht hast
- Die App "setzt dich" immer wieder in die Ausgangsposition für den nächsten Fokus (z.B. Closed Guard)

**Server-Check (POST /gating/step-complete):**
1. Auth ✓
2. Step existiert ✓
3. Prereq (idx-1 erledigt) ✓
4. Freemium (idx ≤ 2) ODER entitlement == 'premium' ✓
5. UPSERT user_step_progress (idempotent)
6. Rate-Limit: 10 req/min/User → 429

---

## Beispiel: Armbar – Closed Guard (Gi/No-Gi)

### Armbar (Gi-Variante) – 6 Schritte

1. **Grip sichern.**
   - "Hol Kragen + Ärmel. Ohne Griff kein Game."
   - Aufgabe: "Hol den Griff im Sparring, egal ob's weitergeht."
   - i18n: `sensei.grip`

2. **Hüfte stellen (45°).**
   - "Winkel schlägt Kraft. Dreh die Hüfte."
   - Aufgabe: "Nutz die Hüfte. Winkel vor Kraft."
   - i18n: `sensei.angle`

3. **Bein drüber, Kopf kontrollieren.**
   - "Leg drüber. Kopf runter, Kontrolle hoch."
   - Aufgabe: "Leg drüber – Kopf kontrollieren."
   - i18n: `sensei.legover`

4. **Klemm & Winkel.**
   - "Knie zusammen. Schulter brechen (Winkel, nicht Hals)."

5. **Daumen nach oben.**
   - "Ausrichten, nicht reißen."

6. **Finish & Safety.**
   - "Hip extend. Tap = sofort lösen."

### Armbar (No-Gi-Variante) – 6 Schritte

1. **Wrist & 2-on-1** statt Kragen/Ärmel
2. **Hüftwinkel 45°** (gleich wie Gi)
3. **Over-Leg** tief anlegen, Kopf kontrollieren
4. **Knie klemmen** & Schulter isolieren
5. **Greifwechsel (S-Griff)** statt Stoffzug
6. **Finish kontrolliert.** Safety gleich.

---

## Emotionaler Realismus (Wochen-Fokus)

**Woche 1:** Du jagst nur den Grip. Vielleicht endest du danach unten – egal. Du drückst "Erledigt", weil du den Grip mehrfach im Rollen bekommen hast.

**Woche 2:** Fokus Hüftwinkel. Du merkst: Winkel gewinnt. Wieder "Erledigt".

**Woche 3:** Bein drüber. Du kommst öfter an den Armbar-Einstieg. Du spürst: "Ich entscheide den Moment."

Nach 6 Schritten sitzt die Kette – nicht perfekt, aber im System. Das ist Fortschritt.

---

## Navigation (Bottom-Bar, 4 Tabs)

### Tabs (dauerhaft sichtbar auf Top-Ebene):
1. **Home** → `/home` (Hub mit "Weiter machen")
2. **Lernen** → `/learn` (Katalog: Kategorien → Techniken)
3. **Statistik** → `/stats` (Streak, erledigte Steps, "Wiederholen")
4. **Einstellungen** → `/settings` (Sprache, Consent, Abo/Restore, Konto löschen)

### Verhalten:
- **Sichtbar auf:** `/home`, `/learn`, `/stats`, `/settings`
- **Ausgeblendet auf:** `/technique/:id`, `/step/:id`, Modals (`/paywall`, `/consent`) → Fokusmodus
- **Icons:** Home / Book / Chart / Gear (aus UI-Kit)
- **Tap-Ziele:** ≥ 44×44 pt, Label 11–12 pt, aktiver Tab kontrastreich (AA)

### i18n-Labels:
- `tab.home`: "Home"
- `tab.learn`: "Lernen"
- `tab.stats`: "Statistik"
- `tab.settings`: "Einstellungen"

---

## Use-Cases (kurz & echt)

### "Ich hab nur 10 Minuten."
```
Home → "Weiter machen" → Step 2 Hüftwinkel → 10-Sek-Clip, 4 Stichpunkte → "Fertig"
Streak +1. Feier das.
```

### "Ich will nur Armbar No-Gi üben."
```
Lernen → Closed Guard → Armbar → No-Gi → Step 1 Wrist/2-on-1 jagen → "Fertig"
```

### "Ich hab's verkackt, will neu versuchen."
```
Statistik → "Wiederholen" (zuletzt gelernt) → direkter Sprung in den Step
Kein Suchen, null Reibung
```

---

## Look & Stimmung

- **Dark-Only**, Dojo-Atmosphäre: Tatami-Textur, dezente Rot/Blau-Akzente
- **Tough-Love-Hinweise** als kleine Sensei-Karten:
  - "Zweifel raus. Griff rein."
  - "Winkel schlägt Kraft."
  - "Leg drüber. Schließ."

---

## Fortschritt & Streak

### Streak-Regeln:
- **≥1 serverbestätigter Step** pro Kalendertag (User-TZ)
- Kulanz **±30 Min** an Tagesgrenzen
- Max **24h Backfill** (z.B. Flugmodus → später syncen)

### "Weiter machen" (Home):
- Zeigt **nächsten nicht erledigten Step** (Client-Heuristik bis Gating greift)
- **1 Tap** → direkt in Step-Player

### "Wiederholen" (Stats):
- Zeigt **zuletzt erledigten Step**
- **1 Tap** → direkt zurück in Step-Player

---

## Offline "letzter Clip"

- Zuletzt gespielten Clip **lokal puffern**
- **Flugmodus:** Clip abspielbar
- Fortschritt wird **queued** und **serverseitig idempotent** nachgeholt

---

## Privacy & DSGVO

- **Analytics nur mit Opt-in** (consent_analytics)
- **PostHog Events** (nur mit Consent): `technique_started`, `step_completed`, `paywall_shown`
- **Sentry ohne PII**
- **Konto- & Datendeletion** direkt in Settings → RPC `delete_user_data()`

---

## Assets & Tokens

- **Videos:** 8–12 s, HLS/MP4 mit Postern
- **Ordnerkonventionen:**
  - `design/assets/{icons,images,animations,videos}`
  - `design/tokens/{colors.json, typography.json}`
- **Dark-Only**, Tatami-Textur, dezente Rot/Blau-Akzente

---

## Paywall & RevenueCat

- **Produkte:** monthly, annual (−25%), optional 7-Tage-Trial
- **Entitlement:** `premium`
- **Restore:** sofortiger Server-Check
- **Webhook:** `/rc/webhook` (Signatur, idempotent) setzt `entitlement`/`trial_end_at`

---

## A11y

- Touch-Targets **≥44×44 pt**
- Kontrast **AA**
- **Dynamic Type**
- Fokusmodus blendet Tab-Bar aus

---

## Warum diese Struktur funktioniert

- **Ein Schritt, ein Fokus.** Du trainierst das Gefühl – nicht nur die Theorie.
- **Klarer Pfad statt 1000 Videos.** Ketten bauen, nicht Clips sammeln.
- **Gi / No-Gi ohne Streit:** beides drin, sauber getrennt, Basics geteilt.
- **Eagle-Fang-Ton** hält dich wach: kurz, direkt, Respekt statt Bullshit.
