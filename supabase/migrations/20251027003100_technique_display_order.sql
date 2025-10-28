-- Migration: 20251027003100_technique_display_order.sql
-- Add display_order column for catalog sorting (idempotent)
-- Date: 2025-10-27

-- Add display_order column if missing
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'technique'
      AND column_name = 'display_order'
  ) THEN
    ALTER TABLE public.technique
      ADD COLUMN display_order SMALLINT NOT NULL DEFAULT 999;
  END IF;
END$$;

-- Add CHECK constraint to prevent negative/overflow values (idempotent)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'technique_display_order_chk'
      AND conrelid = 'public.technique'::regclass
  ) THEN
    ALTER TABLE public.technique
      ADD CONSTRAINT technique_display_order_chk
      CHECK (display_order BETWEEN 0 AND 32767);
  END IF;
END$$;

-- Create composite index for category-filtered queries (idempotent)
CREATE INDEX IF NOT EXISTS idx_technique_category_display_order
  ON public.technique(category, display_order);

-- Create single-column index for fast sorting (idempotent, optional if composite covers all queries)
CREATE INDEX IF NOT EXISTS idx_technique_display_order
  ON public.technique(display_order);

-- Document the column
COMMENT ON COLUMN public.technique.display_order IS
  'Sort order for Learn catalog (0..32767); lower values appear first. Default 999 places new items at the bottom until manually curated.';
