-- 20251027_get_next_step.sql
-- Deploy get_next_step RPC (variant-aware, incomplete-only)

CREATE OR REPLACE FUNCTION get_next_step(
  p_user_id UUID,
  p_variant TEXT DEFAULT 'gi'
)
RETURNS TABLE (
  step_id UUID,
  title_en TEXT,
  title_de TEXT,
  idx INT,
  variant TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    ts.id AS step_id,
    ts.title_en,
    ts.title_de,
    ts.idx,
    ts.variant
  FROM technique_step ts
  INNER JOIN technique t ON ts.technique_id = t.id
  LEFT JOIN user_step_progress usp ON usp.technique_step_id = ts.id AND usp.user_id = p_user_id
  WHERE usp.technique_step_id IS NULL
    AND ts.variant = p_variant
  ORDER BY t.display_order ASC, ts.idx ASC
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
