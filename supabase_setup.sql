-- Run this complete script once in Supabase SQL Editor.
-- The app uses the same account on both devices for simplest cross-device syncing.
create extension if not exists pgcrypto;

create table if not exists public.study_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  subject text not null,
  study_date date not null default current_date,
  duration_minutes integer not null check (duration_minutes between 1 and 1440),
  study_type text not null default 'Concept learning',
  topic text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.study_tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 140),
  subject text not null default 'Other',
  due_date date not null default current_date,
  priority text not null default 'normal' check (priority in ('low','normal','high')),
  estimated_minutes integer not null default 0 check (estimated_minutes between 0 and 1440),
  completed boolean not null default false,
  completed_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.study_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  daily_target integer not null default 6 check (daily_target between 1 and 14),
  updated_at timestamptz not null default now()
);

alter table public.study_sessions enable row level security;
alter table public.study_tasks enable row level security;
alter table public.study_settings enable row level security;

drop policy if exists "sessions own account only" on public.study_sessions;
create policy "sessions own account only" on public.study_sessions for all to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "tasks own account only" on public.study_tasks;
create policy "tasks own account only" on public.study_tasks for all to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "settings own account only" on public.study_settings;
create policy "settings own account only" on public.study_settings for all to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

grant select, insert, update, delete on public.study_sessions to authenticated;
grant select, insert, update, delete on public.study_tasks to authenticated;
grant select, insert, update, delete on public.study_settings to authenticated;

do $$ begin
  alter publication supabase_realtime add table public.study_sessions;
exception when duplicate_object then null; when undefined_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.study_tasks;
exception when duplicate_object then null; when undefined_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.study_settings;
exception when duplicate_object then null; when undefined_object then null; end $$;
