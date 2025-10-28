-- Migration: Add timezone column to user_profile
-- Purpose: Support user-specific timezone for streak calculation with ±30min grace
-- WARP.md: DB-Admin role, DSGVO-compliant (timezone is user preference, not PII)

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='user_profile' AND column_name='timezone'
  ) THEN
    ALTER TABLE public.user_profile
      ADD COLUMN timezone TEXT NOT NULL DEFAULT 'UTC'
      CHECK (timezone <> '');
    
    COMMENT ON COLUMN public.user_profile.timezone IS 
      'IANA timezone (e.g. "Europe/Berlin"). Used for streak calc with ±30min grace. Default: UTC.';
  END IF;
END$$;
