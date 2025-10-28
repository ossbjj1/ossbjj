-- Migration: 20251027_technique_display_order.sql
-- Sprint 4: Add display_order column for catalog sorting
-- Date: 2025-10-27

-- Add display_order column (idempotent; default high value for existing rows)
do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'technique'
      and column_name = 'display_order'
  ) then
    alter table public.technique
      add column display_order smallint not null default 999;
  end if;
end$$;

-- Create index for fast sorting (idempotent)
create index if not exists idx_technique_display_order
  on public.technique(display_order);

-- Optional: add comment for documentation
comment on column public.technique.display_order is
  'Sort order for Learn catalog (1..N); lower values appear first.';
