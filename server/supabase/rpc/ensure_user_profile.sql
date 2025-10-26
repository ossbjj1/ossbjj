-- RPC: ensure_user_profile
-- Sprint 4: Idempotent insert for user_profile row.
-- Creates profile row if missing; no-op if exists.
-- Used by ConsentService.syncAnalyticsFromServer().
-- SECURITY DEFINER with explicit search_path hardening.

CREATE OR REPLACE FUNCTION public.ensure_user_profile()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
BEGIN
  INSERT INTO public.user_profile (user_id)
  VALUES (auth.uid())
  ON CONFLICT (user_id) DO NOTHING;
  
  RETURN true;
END;
$$;

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION public.ensure_user_profile() TO authenticated;
