# Branch Protection Setup (GitHub)

## 🎯 Ziel
PRs auf `main` können nur gemerged werden, wenn:
- ✅ GitHub Actions CI grün ist (`build` + `privacy-gate`)
- ✅ CodeRabbit Review abgeschlossen ist

---

## 📋 Schritt-für-Schritt Anleitung

### 1. **Gehe zu GitHub Repo Settings**
```
https://github.com/ossbjj1/ossbjj/settings/branches
```

### 2. **Bearbeite die `main` Branch Protection Rule**
- Klicke auf **"Edit"** neben der `main` Regel
- Falls keine Regel existiert: **"Add branch protection rule"**
  - Branch name pattern: `main`

### 3. **Aktiviere diese Optionen:**

#### ✅ **Require a pull request before merging**
```
☑️ Require a pull request before merging
   ☐ Require approvals: 0 (falls solo)
       ODER 1+ (falls Team)
```

#### ✅ **Require status checks to pass before merging**
```
☑️ Require status checks to pass before merging
   ☑️ Require branches to be up to date before merging
   
   🔍 Search for status checks:
       Type "build" → ☑️ build (GitHub Actions)
       Type "privacy-gate" → ☑️ privacy-gate (DSGVO-Gate)
       Type "CodeRabbit" → ☑️ coderabbit (nach erstem PR-Review)
```

**⚠️ Wichtig:**
- Status Checks erscheinen erst NACH dem ersten PR-Run
- Erstelle zuerst einen PR → Warte auf CI → Dann erscheinen sie in der Suche

#### ✅ **Require conversation resolution before merging**
```
☑️ Require conversation resolution before merging
```
→ Alle CodeRabbit-Kommentare müssen "Resolved" sein

#### ✅ **Require linear history**
```
☑️ Require linear history
```
→ Keine Merge-Commits, nur Rebase/Squash

#### ✅ **Do not allow bypassing the above settings**
```
☑️ Do not allow bypassing the above settings
```
→ Auch du als Admin musst die Regeln befolgen

### 4. **Optional (empfohlen):**
```
☑️ Require deployments to succeed before merging
☑️ Lock branch (nur für Production-Branches)
```

### 5. **Save changes**

---

## 🧪 Testen

### **Nach Aktivierung:**
1. Erstelle einen Test-Branch:
   ```bash
   git checkout -b test/branch-protection
   echo "test" >> README.md
   git add README.md
   git commit -m "test: verify branch protection"
   git push -u origin test/branch-protection
   ```

2. Erstelle PR auf GitHub

3. **Erwartetes Verhalten:**
   - ⏳ GitHub Actions läuft automatisch
   - ⏳ CodeRabbit reviewt Code
   - ❌ **"Merge" Button ist disabled** bis Checks grün sind
   - ✅ Nach grünen Checks: "Merge" Button wird aktiv

---

## 🚨 Troubleshooting

### **Problem: Status Checks tauchen nicht in Suche auf**
**Lösung:**
1. Erstelle zuerst einen PR (dieser Sprint-0 PR)
2. Warte bis CI gelaufen ist (~2-3 min)
3. Gehe zurück zu Branch Protection Settings
4. Suche erneut nach "build" / "privacy-gate" / "CodeRabbit"
5. Jetzt sollten sie erscheinen

### **Problem: CodeRabbit erscheint nicht**
**Lösung:**
1. Prüfe ob CodeRabbit App installiert ist: https://github.com/apps/coderabbit-ai
2. Autorisiere für `ossbjj1/ossbjj` Repo
3. `.coderabbit.yaml` muss im Repo Root liegen (✅ bereits vorhanden)
4. Nach erstem PR-Comment erscheint "coderabbit" als Status Check

---

## 📊 Finale Konfiguration

**Branch:** `main`

**Required Checks:**
- ✅ `build` (GitHub Actions: format/analyze/test)
- ✅ `privacy-gate` (DSGVO-Review-Enforcement)
- ✅ `coderabbit` (Code-Review AI)

**Rules:**
- ✅ Require PR
- ✅ Require status checks
- ✅ Require conversation resolution
- ✅ Require linear history
- ✅ No bypass

---

## 🎯 Ergebnis

**Ab jetzt:**
- ❌ Direct Push auf `main` → **blocked**
- ❌ PR mit failing CI → **blocked**
- ❌ PR mit unresolved CodeRabbit comments → **blocked**
- ✅ PR mit grünen Checks → **merge erlaubt**

**WARP.md Compliance:** ✅ Achieved
