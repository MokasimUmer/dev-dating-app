-- ============================================================
-- DevDate: Phase 1 Schema — Profiles
-- Run this in Supabase SQL Editor (Dashboard → SQL → New Query)
-- ============================================================

-- Enable PostGIS for geospatial discovery (find --near)
create extension if not exists postgis;

-- ── Profiles table ──────────────────────────────────────────
create table if not exists public.profiles (
  id            uuid references auth.users on delete cascade primary key,
  github_username text unique not null,
  display_name  text,
  avatar_url    text,
  bio           text,
  tech_stack    text[] default '{}',
  location      geography(Point, 4326),
  github_repos  jsonb default '[]',
  xp            integer default 0,
  rank          text default 'Intern',
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);

-- ── Row Level Security ──────────────────────────────────────
alter table public.profiles enable row level security;

-- Anyone can read profiles (public discovery feed)
create policy "Public profiles are viewable by everyone"
  on public.profiles for select
  using (true);

-- Users can only insert their own profile
create policy "Users can insert own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

-- Users can only update their own profile
create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- ── Auto-create profile on signup ───────────────────────────
-- This trigger creates a profile row when a new user signs up
-- via GitHub OAuth, pulling metadata from the auth response.
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, github_username, display_name, avatar_url, bio)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'user_name', 'unknown'),
    coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'user_name'),
    new.raw_user_meta_data ->> 'avatar_url',
    new.raw_user_meta_data ->> 'bio'
  );
  return new;
end;
$$ language plpgsql security definer;

-- Drop the trigger first if it exists (safe re-run)
drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ── Nearby profiles RPC (PostGIS) ───────────────────────────
-- Call via: supabase.rpc('nearby_profiles', { lat, lng, radius_km, filter_tech })
create or replace function public.nearby_profiles(
  lat double precision,
  lng double precision,
  radius_km double precision default 50,
  filter_tech text default null
)
returns setof public.profiles as $$
begin
  return query
    select *
    from public.profiles p
    where
      p.location is not null
      and ST_DWithin(
        p.location,
        ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography,
        radius_km * 1000  -- convert km to meters
      )
      and (filter_tech is null or filter_tech = any(p.tech_stack))
    order by p.location <-> ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography
    limit 50;
end;
$$ language plpgsql security definer;

-- ── Updated_at auto-timestamp ───────────────────────────────
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists profiles_updated_at on public.profiles;

create trigger profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();
