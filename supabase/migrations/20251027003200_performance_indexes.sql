-- Migration: 20251027003200_performance_indexes.sql
-- Add performance indexes for Continue and Learn queries (idempotent)
-- Date: 2025-10-27

-- Index for technique_step filtering by variant + idx (used in getNextStep)
CREATE INDEX IF NOT EXISTS idx_ts_variant_idx
  ON public.technique_step(variant, idx);

-- Index for user_step_progress lookups by user_id (used in progress queries)
CREATE INDEX IF NOT EXISTS idx_usp_user
  ON public.user_step_progress(user_id);

-- Document
COMMENT ON INDEX idx_ts_variant_idx IS
  'Speeds up variant-filtered step queries for Continue/Learn';
COMMENT ON INDEX idx_usp_user IS
  'Speeds up user progress lookups for stats and Continue heuristic';
