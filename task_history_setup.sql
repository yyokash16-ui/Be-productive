-- Be Productive task history schema and audit log.
-- Idempotent backup/setup script. Running it preserves existing study_tasks.
create extension if not exists pgcrypto;

create table if not exists public.study_task_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  task_id uuid not null,
  task_title text not null,
  task_subject text not null default 'Other',
  due_date date not null,
  priority text not null default 'normal' check (priority in ('low','normal','high')),
  estimated_minutes integer not null default 0 check (estimated_minutes between 0 and 1440),
  event_type text not null check (event_type in ('created','completed','reopened','deleted','edited')),
  event_at timestamptz not null default now(),
  task_created_at timestamptz not null,
  is_completed boolean not null default false
);
alter table public.study_task_history add column if not exists is_completed boolean not null default false;

create index if not exists study_task_history_user_event_idx
  on public.study_task_history (user_id, event_at desc);
create index if not exists study_task_history_user_task_idx
  on public.study_task_history (user_id, task_id, event_at desc);

alter table public.study_task_history enable row level security;
drop policy if exists "Users can read own task history" on public.study_task_history;
create policy "Users can read own task history"
  on public.study_task_history for select to authenticated using (auth.uid() = user_id);
revoke all on public.study_task_history from anon;
revoke all on public.study_task_history from authenticated;
grant select on public.study_task_history to authenticated;

create or replace function public.log_study_task_history()
returns trigger language plpgsql security definer set search_path = public, pg_temp
as $$
declare v_event text; v_when timestamptz;
begin
  if TG_OP = 'INSERT' then
    insert into public.study_task_history(user_id,task_id,task_title,task_subject,due_date,priority,estimated_minutes,event_type,event_at,task_created_at,is_completed)
    values(NEW.user_id,NEW.id,NEW.title,NEW.subject,NEW.due_date,NEW.priority,NEW.estimated_minutes,'created',coalesce(NEW.created_at,now()),coalesce(NEW.created_at,now()),NEW.completed);
    if NEW.completed then
      insert into public.study_task_history(user_id,task_id,task_title,task_subject,due_date,priority,estimated_minutes,event_type,event_at,task_created_at,is_completed)
      values(NEW.user_id,NEW.id,NEW.title,NEW.subject,NEW.due_date,NEW.priority,NEW.estimated_minutes,'completed',coalesce(NEW.completed_at,now()),coalesce(NEW.created_at,now()),true);
    end if;
    return NEW;
  elsif TG_OP = 'UPDATE' then
    if OLD.completed is distinct from NEW.completed then
      v_event := case when NEW.completed then 'completed' else 'reopened' end;
      v_when := case when NEW.completed then coalesce(NEW.completed_at,now()) else now() end;
    elsif OLD.title is distinct from NEW.title or OLD.subject is distinct from NEW.subject
       or OLD.due_date is distinct from NEW.due_date or OLD.priority is distinct from NEW.priority
       or OLD.estimated_minutes is distinct from NEW.estimated_minutes then
      v_event := 'edited'; v_when := now();
    else return NEW;
    end if;
    insert into public.study_task_history(user_id,task_id,task_title,task_subject,due_date,priority,estimated_minutes,event_type,event_at,task_created_at,is_completed)
    values(NEW.user_id,NEW.id,NEW.title,NEW.subject,NEW.due_date,NEW.priority,NEW.estimated_minutes,v_event,v_when,coalesce(NEW.created_at,now()),NEW.completed);
    return NEW;
  elsif TG_OP = 'DELETE' then
    insert into public.study_task_history(user_id,task_id,task_title,task_subject,due_date,priority,estimated_minutes,event_type,event_at,task_created_at,is_completed)
    values(OLD.user_id,OLD.id,OLD.title,OLD.subject,OLD.due_date,OLD.priority,OLD.estimated_minutes,'deleted',now(),coalesce(OLD.created_at,now()),OLD.completed);
    return OLD;
  end if;
  return null;
end;
$$;

drop trigger if exists study_tasks_history_trigger on public.study_tasks;
create trigger study_tasks_history_trigger after insert or update or delete on public.study_tasks
for each row execute function public.log_study_task_history();

insert into public.study_task_history(user_id,task_id,task_title,task_subject,due_date,priority,estimated_minutes,event_type,event_at,task_created_at,is_completed)
select t.user_id,t.id,t.title,t.subject,t.due_date,t.priority,t.estimated_minutes,'created',coalesce(t.created_at,now()),coalesce(t.created_at,now()),false
from public.study_tasks t
where not exists (select 1 from public.study_task_history h where h.user_id=t.user_id and h.task_id=t.id and h.event_type='created');

insert into public.study_task_history(user_id,task_id,task_title,task_subject,due_date,priority,estimated_minutes,event_type,event_at,task_created_at,is_completed)
select t.user_id,t.id,t.title,t.subject,t.due_date,t.priority,t.estimated_minutes,'completed',coalesce(t.completed_at,t.created_at,now()),coalesce(t.created_at,now()),true
from public.study_tasks t
where t.completed=true
and not exists (select 1 from public.study_task_history h where h.user_id=t.user_id and h.task_id=t.id and h.event_type='completed');

do $$ begin
  alter publication supabase_realtime add table public.study_task_history;
exception when duplicate_object then null; when undefined_object then null;
end $$;
