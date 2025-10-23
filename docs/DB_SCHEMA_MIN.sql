create table technique(
  id int primary key,
  category text not null,
  title_en text not null,
  title_de text not null,
  video_url text,
  thumb_url text,
  content_version int default 1
);

create table technique_step(
  id int primary key,
  technique_id int references technique(id) on delete cascade,
  variant text check (variant in ('gi','nogi')) not null,
  idx int not null,
  title_en text not null,
  title_de text not null,
  duration_s int default 10,
  unique(technique_id, variant, idx)
);

create table user_profile(
  user_id uuid primary key references auth.users on delete cascade,
  belt text, exp_range text, weekly_goal int, goal_type text, age_group text,
  consent_analytics boolean default false,
  entitlement text default 'free',
  trial_end_at timestamptz
);

create table user_step_progress(
  user_id uuid references user_profile(user_id) on delete cascade,
  technique_step_id int references technique_step(id) on delete cascade,
  completed_at timestamptz default now(),
  primary key(user_id, technique_step_id)
);

-- RLS
alter table user_step_progress enable row level security;
create policy usp_sel on user_step_progress for select using (auth.uid()=user_id);
create policy usp_ins on user_step_progress for insert with check (auth.uid()=user_id);

-- Performance indexes
create index idx_usp_user_date on user_step_progress(user_id, completed_at);

