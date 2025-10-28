-- Migration: calc_streak_days with User-TZ and ±30min grace
-- Purpose: Streak calculation respects user timezone and 30-minute grace at day boundaries
-- WARP.md: DB-Admin role, SECURITY DEFINER + search_path hardened, auth.uid() trust boundary

CREATE OR REPLACE FUNCTION public.calc_streak_days()
RETURNS int
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_uid uuid;
  v_tz  text;
  v_today date;
  v_streak int;
BEGIN
  -- Auth: Only authenticated users
  v_uid := auth.uid();
  IF v_uid IS NULL THEN 
    RAISE EXCEPTION 'Not authenticated'; 
  END IF;

  -- Fetch user timezone (default UTC if profile missing)
  SELECT COALESCE(up.timezone, 'UTC') INTO v_tz
  FROM public.user_profile up 
  WHERE up.user_id = v_uid;

  -- If no profile exists, default to UTC
  IF v_tz IS NULL THEN
    v_tz := 'UTC';
  END IF;

  -- Calculate "today" in user TZ with -30min grace
  -- Example: 23:50 UTC in Europe/Berlin (01:50 CET+2) → still counts as previous day
  v_today := (now() AT TIME ZONE v_tz - interval '30 minutes')::date;

  -- Find consecutive days from today backwards
  WITH step_days AS (
    SELECT DISTINCT 
      (usp.completed_at AT TIME ZONE v_tz - interval '30 minutes')::date AS d
    FROM public.user_step_progress usp
    WHERE usp.user_id = v_uid 
      AND (usp.completed_at AT TIME ZONE v_tz) <= (now() AT TIME ZONE v_tz)
  ),
  numbered AS (
    SELECT d, ROW_NUMBER() OVER (ORDER BY d DESC) AS rn
    FROM step_days 
    WHERE d <= v_today
  )
  SELECT COUNT(*) INTO v_streak
  FROM numbered
  WHERE d = v_today - (rn - 1);

  RETURN COALESCE(v_streak, 0);
END;
$$;

COMMENT ON FUNCTION public.calc_streak_days() IS 
  'Returns current streak (consecutive days with ≥1 step completed). Uses user timezone from user_profile with ±30min grace at day boundaries. SECURITY DEFINER with hardened search_path.';
