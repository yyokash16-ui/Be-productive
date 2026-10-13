-- Be Productive: wake-up target tracking migration
-- Run this ONCE in Supabase SQL Editor. It does not delete or alter your existing study records.
create extension if not exists pgcrypto;

create table if not exists public.wake_up_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  plan_date date not null,
  target_time time not null,
  actual_wake_time time,
  completed boolean not null default false,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint wake_up_plan_unique_user_day unique (user_id, plan_date),
  constraint wake_up_completed_on_time check (
    not completed or (
      actual_wake_time is not null
      and actual_wake_time <= target_time
    )
  )
);

alter table public.wake_up_plans enable row level security;

drop policy if exists "wake up plans own account only" on public.wake_up_plans;
create policy "wake up plans own account only"
  on public.wake_up_plans
  for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

grant select, insert, update, delete on public.wake_up_plans to authenticated;

do $$
begin
  alter publication supabase_realtime add table public.wake_up_plans;
exception
  when duplicate_object then null;
  when undefined_object then null;
end $$;
