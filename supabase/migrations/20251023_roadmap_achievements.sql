-- 20251023_roadmap_achievements.sql
-- Content-Roadmap + Achievements (MVP light) + RLS + Helper RPCs

-- 1) CONTENT ROADMAP (planned/released content)
create table if not exists public.content_roadmap (
  id serial primary key,
  release_date date not null,
  title_de text not null,
  title_en text not null,
  description_de text,
  description_en text,
  technique_count int,
  status text default 'planned' check (status in ('planned','released','archived')),
  created_at timestamptz default now()
);
-- 2) ACHIEVEMENTS (definition)
create table if not exists public.achievement (
  id serial primary key,
  key text unique not null,
  title_de text not null,
  title_en text not null,
  description_de text,
  description_en text,
  icon text,
  unlock_condition jsonb not null,
  created_at timestamptz default now()
);
-- 3) USER-ACHIEVEMENTS (grants)
create table if not exists public.user_achievement (
  user_id uuid references public.user_profile(user_id) on delete cascade,
  achievement_id int references public.achievement(id) on delete cascade,
  unlocked_at timestamptz default now(),
  primary key (user_id, achievement_id)
);
-- 4) RLS for user_achievement
alter table public.user_achievement enable row level security;
do $$
begin
  if not exists (
    select 1 from pg_policies where tablename='user_achievement' and policyname='ua_select_own'
  ) then
    create policy ua_select_own on public.user_achievement
      for select using (auth.uid() = user_id);
  end if;

  -- ua_insert_own removed: achievements must be granted server-side
  -- Drop existing policy if present (safe idempotent migration)
  drop policy if exists ua_insert_own on public.user_achievement;

  -- Service-role policy for server-side achievement grants
  if not exists (
    select 1 from pg_policies where tablename='user_achievement' and policyname='ua_insert_service'
  ) then
    create policy ua_insert_service on public.user_achievement
      for insert to service_role
      with check (true);
  end if;
end$$;
-- 5) Helper: calc_streak_days (counts consecutive days with ≥1 completed step)
create or replace function public.calc_streak_days(p_user_id uuid)
returns int language plpgsql stable as $$
declare
  d date := current_date;
  streak int := 0;
  has_prog int := 0;
begin
  loop
    select count(*) into has_prog
    from public.user_step_progress
    where user_id = p_user_id
      and completed_at::date = d;

    exit when has_prog = 0;

    streak := streak + 1;
    d := d - interval '1 day';
  end loop;
  return streak;
end$$;
-- 6) Helper: count_completed_techniques (techniques with all steps done per variant)
create or replace function public.count_completed_techniques(p_user_id uuid)
returns int language sql stable as $$
with per_tech as (
  select ts.technique_id, ts.variant,
         count(*) as total_steps,
         sum(case when usp.user_id is not null then 1 else 0 end) as completed_steps
  from public.technique_step ts
  left join public.user_step_progress usp
    on usp.technique_step_id = ts.id
   and usp.user_id = p_user_id
  group by ts.technique_id, ts.variant
)
select count(*)::int from per_tech where completed_steps = total_steps;
$$;
-- 7) Performance indexes
create index if not exists idx_ua_user on public.user_achievement(user_id);
create index if not exists idx_cr_status_date on public.content_roadmap(status, release_date);
