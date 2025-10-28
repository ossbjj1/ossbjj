-- Migration: mark_step_complete RPC
-- Sprint 4.1: Idempotent step completion
-- Date: 2025-10-26

-- RPC: mark_step_complete
-- Idempotent insert for user_step_progress.
-- Prevents duplicate completions via PK conflict.
-- Returns {success, idempotent, message} for client feedback.
-- SECURITY DEFINER with explicit search_path hardening.

CREATE OR REPLACE FUNCTION public.mark_step_complete(
  p_technique_step_id uuid
)
RETURNS TABLE(success boolean, idempotent boolean, message text)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_user_id uuid;
  v_inserted integer;
BEGIN
  -- Get authenticated user ID
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RETURN QUERY SELECT false, false, 'unauthorized'::text;
    RETURN;
  END IF;

  -- Idempotent insert: ON CONFLICT DO NOTHING
  INSERT INTO public.user_step_progress (user_id, technique_step_id, completed_at)
  VALUES (v_user_id, p_technique_step_id, now())
  ON CONFLICT (user_id, technique_step_id) DO NOTHING;

  -- Check if row was inserted (1) or already existed (0)
  GET DIAGNOSTICS v_inserted = ROW_COUNT;

  IF v_inserted = 1 THEN
    -- New completion
    RETURN QUERY SELECT true, false, 'completed'::text;
  ELSE
    -- Already completed (idempotent)
    RETURN QUERY SELECT true, true, 'already_completed'::text;
  END IF;
END;
$$;
-- Restrict EXECUTE to service_role only (called via Edge Function)
-- ⚠️ IMPORTANT: Deploy Edge Function gating_step_complete BEFORE applying this migration
REVOKE EXECUTE ON FUNCTION public.mark_step_complete(uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.mark_step_complete(uuid) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.mark_step_complete(uuid) TO service_role;
