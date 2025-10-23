# Roadmap (8 Sprints · iOS zuerst · MVP)
S1 Fundament: Repo, CI, Health-Fn, Theme, Bottom-Nav (Tabs: /home /learn /stats /settings).
S2 Auth & Consent: Supabase Auth; Consent-Modal (Analytics off by default); Settings->Consent.
S3 Curriculum Seeds & UI-Stubs: Kategorien/Techniken (Gi/No-Gi Chips), Technikdetail + Step-Liste (local state).
S4 Step-Player: Video (8–12s), Checkliste, "Fertig"-Button (noch ohne Server-Write).
S5 Server-Gating & RLS: DB + RLS; EdgeFn /gating/step-complete; client nutzt Fn; Free bis Step 2.
S6 Paywall (RevenueCat): Produkte (monthly/annual), Entitlement->UI, Restore-Button, Webhook-Sync.
S7 Statistik + Roadmap + Achievements (MVP light):
- /stats: Streak (User-TZ, Kulanz ±30min), Erledigt, "Wiederholen", Erfolge (Grid)
- Home: "Weiter machen" + Roadmap-Karte (3 geplante Releases)
- Server: Achievement-Vergabe NACH Step-Complete (first_grip, streak_7, steps_25, tech_5)
- Seeds: roadmap.json, achievements.json
- DoD: Roadmap sichtbar, mind. 1 Badge unlockbar, Consent→Events, CI grün
S8 Polish & Store: A11y AA, Copy (Eagle-Fang), iOS-Assets/Privacy, In-App Deletion, TestFlight.
DoD global: CI grün; Health 200; Gating greift; Paywall sichtbar; Restore ok; Deletion path getestet.

