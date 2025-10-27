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
-- Create index for fast sorting (idempotent)
CREATE INDEX IF NOT EXISTS idx_technique_display_order
  ON public.technique(display_order);
-- Document the column
COMMENT ON COLUMN public.technique.display_order IS
  'Sort order for Learn catalog (1..N); lower values appear first.';
