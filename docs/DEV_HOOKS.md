# Developer Hooks (Lefthook)

Goal: Zero-friction commits. Your code is auto-formatted before commit and basic checks run before push so CI stays green.

Setup (once):
1) Install Lefthook
   - macOS (Homebrew):
     ```bash
     brew install lefthook
     ```
   - Or see: https://github.com/evilmartians/lefthook
2) Install Git hooks in this repo:
   ```bash
   lefthook install
   ```

What happens:
- pre-commit:
  - Formats Dart code in `app/lib` and `app/test` (dart format)
  - Formats Deno functions in `supabase/functions` (deno fmt; skipped if Deno not installed)

Notes:
- Hooks change files (format). If that happens during commit, just add and commit again.
- No secrets are touched. No external network calls.
- If you don’t have Deno locally, hooks will skip Deno steps; CI will still check them.
- Full checks (analyze/tests) bleiben in CI, damit dein Push nicht blockiert.
