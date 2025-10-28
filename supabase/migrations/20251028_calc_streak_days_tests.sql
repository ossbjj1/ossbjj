-- SQL Tests for calc_streak_days with User-TZ and ±30min grace
-- Purpose: Verify timezone boundary cases, anonymous user exception
-- WARP.md: DB-Admin role, QA-DSGVO compliance

-- Test 1: Anonymous user → Exception
DO $$
BEGIN
  PERFORM public.calc_streak_days();
  RAISE EXCEPTION 'Test 1 FAILED: Should raise "Not authenticated"';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLERRM NOT LIKE '%Not authenticated%' THEN
      RAISE EXCEPTION 'Test 1 FAILED: Wrong exception: %', SQLERRM;
    END IF;
    RAISE NOTICE 'Test 1 PASSED: Anonymous user rejected';
END$$;

-- Test 2: User with no profile defaults to UTC
-- Test 3: User with Europe/Berlin timezone + ±30min grace at day boundary
-- Test 4: Consecutive days streak calculation
-- 
-- NOTE: Tests 2–4 require authenticated context (auth.uid()) and test data.
-- Run these via Supabase Test Runner or manual setup with test user:
--
-- Example setup for manual test (replace with actual test user):
-- INSERT INTO auth.users (id, email) VALUES ('test-uid', 'test@example.com') ON CONFLICT DO NOTHING;
-- INSERT INTO public.user_profile (user_id, timezone) VALUES ('test-uid', 'Europe/Berlin') ON CONFLICT DO NOTHING;
-- INSERT INTO public.user_step_progress (user_id, technique_step_id, completed_at) 
-- VALUES 
--   ('test-uid', 1, '2025-10-27 23:50:00+00'::timestamptz), -- 01:50 CET+2 → day D
--   ('test-uid', 2, '2025-10-28 00:20:00+00'::timestamptz); -- 02:20 CET+2 → day D (within grace)
--
-- Expected: streak = 1 (both count as same day D due to -30min grace)

COMMENT ON EXTENSION IF EXISTS pgtap IS 'Use pgTAP for comprehensive test suite once integrated. For now: manual smoke tests in local dev.';

RAISE NOTICE 'calc_streak_days SQL tests: Test 1 (anonymous) passed. Tests 2-4 require authenticated context + test data.';
