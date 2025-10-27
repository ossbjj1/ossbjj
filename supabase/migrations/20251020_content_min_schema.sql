-- 20251020_content_min_schema.sql
-- Provide minimal content tables to satisfy downstream functions/migrations.
-- MVP-safe: creates if not exists, no destructive ops.

-- technique (minimal)
create table if not exists public.technique (
  id uuid primary key,
  category text,
  title_en text,
  title_de text,
  created_at timestamptz default now()
);
-- technique_step (minimal)
create table if not exists public.technique_step (
  id uuid primary key,
  technique_id uuid,
  variant text not null check (variant in ('gi','nogi')),
  idx int not null,
  title_en text,
  title_de text,
  duration_s int default 10,
  unique(technique_id, variant, idx)
);
-- user_step_progress (minimal)
create table if not exists public.user_step_progress (
  user_id uuid not null,
  technique_step_id uuid not null,
  completed_at timestamptz default now(),
  primary key (user_id, technique_step_id)
);
-- RLS for user_step_progress (idempotent)
alter table public.user_step_progress enable row level security;
do $$
begin
  if not exists (
    select 1 from pg_policies where tablename='user_step_progress' and policyname='usp_select_own'
  ) then
    create policy usp_select_own on public.user_step_progress
      for select using (auth.uid() = user_id);
  end if;

  if not exists (
    select 1 from pg_policies where tablename='user_step_progress' and policyname='usp_insert_own'
  ) then
    create policy usp_insert_own on public.user_step_progress
      for insert with check (auth.uid() = user_id);
  end if;
end$$;
-- Optional: add FK to user_profile if exists
do $$
begin
  if exists (
    select 1 from information_schema.tables
    where table_schema='public' and table_name='user_profile'
  ) then
    -- add constraint only if not exists (check pg_constraint, not constraint_column_usage)
    if not exists (
      select 1 from pg_constraint
      where conname = 'usp_user_fk'
        and conrelid = 'public.user_step_progress'::regclass
    ) then
      alter table public.user_step_progress
        add constraint usp_user_fk
        foreign key (user_id) references public.user_profile(user_id) on delete cascade;
    end if;
  end if;
end$$;
