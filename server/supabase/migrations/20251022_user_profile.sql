-- 20251026_user_profile.sql
-- Sprint 3: User onboarding profile table with RLS

-- 1) Create user_profile table
create table if not exists public.user_profile(
  user_id uuid primary key references auth.users on delete cascade,
  belt text,
  exp_range text,
  weekly_goal int,
  goal_type text,
  age_group text,
  consent_analytics boolean not null default false,
  entitlement text default 'free',
  trial_end_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Domain constraints (enforce valid values server-side)
do $$
begin
  if not exists (
    select 1 from information_schema.constraint_column_usage
    where table_name='user_profile' and constraint_name='up_weekly_goal_range'
  ) then
    alter table public.user_profile
      add constraint up_weekly_goal_range
        check (weekly_goal is null or (weekly_goal >= 1 and weekly_goal <= 7));
  end if;
end$$;

do $$
begin
  if not exists (
    select 1 from information_schema.constraint_column_usage
    where table_name='user_profile' and constraint_name='up_belt_check'
  ) then
    alter table public.user_profile
      add constraint up_belt_check
        check (belt is null or belt in ('white','blue','purple','brown','black'));
  end if;
end$$;

do $$
begin
  if not exists (
    select 1 from information_schema.constraint_column_usage
    where table_name='user_profile' and constraint_name='up_exp_range_check'
  ) then
    alter table public.user_profile
      add constraint up_exp_range_check
        check (exp_range is null or exp_range in ('beginner','intermediate','advanced'));
  end if;
end$$;

do $$
begin
  if not exists (
    select 1 from information_schema.constraint_column_usage
    where table_name='user_profile' and constraint_name='up_goal_type_check'
  ) then
    alter table public.user_profile
      add constraint up_goal_type_check
        check (goal_type is null or goal_type in ('fundamentals','technique','strength','flexibility'));
  end if;
end$$;

do $$
begin
  if not exists (
    select 1 from information_schema.constraint_column_usage
    where table_name='user_profile' and constraint_name='up_age_group_check'
  ) then
    alter table public.user_profile
      add constraint up_age_group_check
        check (age_group is null or age_group in ('u18','18-30','30-40','40+'));
  end if;
end$$;

do $$
begin
  if not exists (
    select 1 from information_schema.constraint_column_usage
    where table_name='user_profile' and constraint_name='up_entitlement_check'
  ) then
    alter table public.user_profile
      add constraint up_entitlement_check
        check (entitlement in ('free','trial','pro'));
  end if;
end$$;

-- 2) Enable RLS
alter table public.user_profile enable row level security;

-- 3) RLS Policies (idempotent)
do $$
begin
  -- SELECT: user can read own profile
  if not exists (
    select 1 from pg_policies where tablename='user_profile' and policyname='up_select_own'
  ) then
    create policy up_select_own on public.user_profile
      for select using (auth.uid() = user_id);
  end if;

  -- INSERT: user can create own profile
  if not exists (
    select 1 from pg_policies where tablename='user_profile' and policyname='up_insert_own'
  ) then
    create policy up_insert_own on public.user_profile
      for insert with check (auth.uid() = user_id);
  end if;

  -- UPDATE: user can update own profile (with CHECK to ensure row still satisfies ownership)
  if not exists (
    select 1 from pg_policies where tablename='user_profile' and policyname='up_update_own'
  ) then
    create policy up_update_own on public.user_profile
      for update
        using (auth.uid() = user_id)
        with check (auth.uid() = user_id);
  end if;
end$$;

-- 4) Trigger for updated_at
create or replace function public.touch_user_profile_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end$$;

drop trigger if exists trg_up_updated_at on public.user_profile;
create trigger trg_up_updated_at
  before update on public.user_profile
  for each row execute function public.touch_user_profile_updated_at();

-- 5) Performance index (user_id is primary key, already indexed by default in PostgreSQL)
