-- ============================================================================
-- /rpc Directory Pattern: Reference & Documentation Only
-- 
-- Source of Truth: server/supabase/migrations/
-- These files are for local testing, documentation, and IDE reference.
-- Do NOT edit here; maintain all RPC definitions in migrations/ exclusively.
-- ============================================================================

-- RPC: ensure_user_profile
-- Sprint 4: Idempotent insert for user_profile row.
-- Creates profile row if missing; no-op if exists.
-- Used by ConsentService.syncAnalyticsFromServer().
-- SECURITY DEFINER with explicit search_path hardening.
-- 
-- Canonical location: server/supabase/migrations/20251022_user_profile.sql

CREATE OR REPLACE FUNCTION public.ensure_user_profile()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
BEGIN
  INSERT INTO public.user_profile (user_id)
  VALUES (auth.uid())
  ON CONFLICT (user_id) DO NOTHING;
END;
$$;

-- Restrict EXECUTE to authenticated users only
REVOKE EXECUTE ON FUNCTION public.ensure_user_profile() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.ensure_user_profile() TO authenticated;
