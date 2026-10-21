-- Hallenplaner: zuerst in Supabase SQL Editor ausführen
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 display_name text,
 role text not null default 'pending' check(role in ('pending','trainer','admin')),
 team text check(team in ('G','F','E','D')),
 constraint trainer_team check(role <> 'trainer' or team is not null)
);
create or replace function public.make_profile() returns trigger language plpgsql security definer set search_path = '' as $$
begin insert into public.profiles(id,display_name) values(new.id,coalesce(new.email,'Benutzer')) on conflict do nothing; return new; end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.make_profile();
insert into public.profiles(id,display_name) select id,email from auth.users on conflict do nothing;
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path = '' as $$
select exists(select 1 from public.profiles where id=(select auth.uid()) and role='admin') $$;
create or replace function public.my_team() returns text language sql stable security definer set search_path = '' as $$
select team from public.profiles where id=(select auth.uid()) and role='trainer' $$;
create or replace function public.is_active() returns boolean language sql stable security definer set search_path = '' as $$
select exists(select 1 from public.profiles where id=(select auth.uid()) and role in ('admin','trainer')) $$;
create table if not exists public.slots (
 id bigint generated always as identity primary key,
 day date not null check(day between '2026-10-19' and '2027-03-31'),
 hall text not null check(hall in ('gross','klein','willi')),
 start_time time not null check(start_time >= '14:00' and start_time < '22:00' and extract(minute from start_time) in (0,30)),
 assigned_team text check(assigned_team in ('G','F','E','D')),
 unique(day,hall,start_time)
);
create table if not exists public.applications (
 slot_id bigint not null references public.slots(id) on delete cascade,
 team text not null check(team in ('G','F','E','D')),
 created_at timestamptz not null default now(),
 primary key(slot_id,team)
);
create index if not exists slots_day_idx on public.slots(day);
alter table public.profiles enable row level security;
alter table public.slots enable row level security;
alter table public.applications enable row level security;
drop policy if exists profiles_read on public.profiles;
create policy profiles_read on public.profiles for select to authenticated using(id=(select auth.uid()) or (select public.is_admin()));
drop policy if exists slots_read on public.slots;
create policy slots_read on public.slots for select to authenticated using((select public.is_active()));
drop policy if exists slots_insert on public.slots;
create policy slots_insert on public.slots for insert to authenticated with check((select public.is_admin()));
drop policy if exists slots_update on public.slots;
create policy slots_update on public.slots for update to authenticated using((select public.is_admin())) with check((select public.is_admin()));
drop policy if exists slots_delete on public.slots;
create policy slots_delete on public.slots for delete to authenticated using((select public.is_admin()));
drop policy if exists apps_read on public.applications;
create policy apps_read on public.applications for select to authenticated using((select public.is_active()));
drop policy if exists apps_insert on public.applications;
create policy apps_insert on public.applications for insert to authenticated with check(team=(select public.my_team()) and exists(select 1 from public.slots where id=slot_id and (assigned_team is null or assigned_team=team)));
drop policy if exists apps_delete on public.applications;
create policy apps_delete on public.applications for delete to authenticated using((select public.is_admin()) or (team=(select public.my_team()) and exists(select 1 from public.slots where id=slot_id and assigned_team is null)));
-- Rollen nur durch den Supabase SQL Editor vergeben, nie über öffentliche Client-Rechte.
