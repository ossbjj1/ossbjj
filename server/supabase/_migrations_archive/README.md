# Archived Migrations (Do not use)

This folder contains the old copy of SQL migrations that used to live under `server/supabase/migrations/`.

Single Source of Truth (SSOT) for migrations is now:

- `supabase/migrations/` (used by `supabase db push` and CI)

Do not add or edit SQL here. CI will fail if new `.sql` files are committed under `server/supabase/`.
