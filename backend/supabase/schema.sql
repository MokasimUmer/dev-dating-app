-- ============================================================
-- DevDate: Full Database Schema (Phases 1–5)
-- Run in Supabase SQL Editor (Dashboard > SQL > New Query)
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 1. PROFILES
-- ────────────────────────────────────────────────────────────
create table if not exists public.profiles (
  id              uuid references auth.users on delete cascade primary key,
  github_username text unique not null,
  display_name    text,
  bio             text,
  avatar_url      text,
  tech_stack      text[] default '{}',
  github_repos    jsonb default '[]',
  location_lat    float8,
  location_lng    float8,
  xp              integer default 0,
  rank            text default 'Intern',
  created_at      timestamptz default now(),
  updated_at      timestamptz default now()
);

alter table public.profiles enable row level security;

create policy "profiles_select_public"
  on public.profiles for select using (true);

create policy "profiles_insert_own"
  on public.profiles for insert with check (auth.uid() = id);

create policy "profiles_update_own"
  on public.profiles for update using (auth.uid() = id);


-- ────────────────────────────────────────────────────────────
-- 2. CONNECTIONS
-- ────────────────────────────────────────────────────────────
create table if not exists public.connections (
  id            uuid default gen_random_uuid() primary key,
  requester_id  uuid references public.profiles(id) on delete cascade not null,
  target_id     uuid references public.profiles(id) on delete cascade not null,
  status        text default 'pending' check (status in ('pending', 'accepted', 'rejected')),
  project_id    uuid,  -- FK added after projects table is created
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);

create index if not exists idx_connections_requester on public.connections(requester_id);
create index if not exists idx_connections_target on public.connections(target_id);

alter table public.connections enable row level security;

-- Users can see connections they are involved in
create policy "connections_select_own"
  on public.connections for select
  using (auth.uid() = requester_id or auth.uid() = target_id);

-- Only the requester can create a connection
create policy "connections_insert_requester"
  on public.connections for insert
  with check (auth.uid() = requester_id);

-- Only the target can update status (accept/reject)
create policy "connections_update_target"
  on public.connections for update
  using (auth.uid() = target_id);


-- ────────────────────────────────────────────────────────────
-- 3. PROJECTS
-- ────────────────────────────────────────────────────────────
create table if not exists public.projects (
  id            uuid default gen_random_uuid() primary key,
  name          text not null,
  description   text,
  creator_id    uuid references public.profiles(id) on delete cascade not null,
  partner_id    uuid references public.profiles(id) on delete set null,
  status        text default 'active' check (status in ('active', 'completed', 'archived')),
  container_id  text,       -- Docker container reference (Phase 2)
  preview_url   text,       -- Temporary deploy URL (Phase 2)
  stars_count   integer default 0,
  published     boolean default false,
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);

create index if not exists idx_projects_creator on public.projects(creator_id);
create index if not exists idx_projects_partner on public.projects(partner_id);

-- Now add the FK from connections -> projects
alter table public.connections
  add constraint fk_connections_project
  foreign key (project_id) references public.projects(id) on delete set null;

alter table public.projects enable row level security;

-- Members (creator or partner) can see/update their project
create policy "projects_select_member"
  on public.projects for select
  using (
    auth.uid() = creator_id
    or auth.uid() = partner_id
    or published = true
  );

create policy "projects_insert_creator"
  on public.projects for insert
  with check (auth.uid() = creator_id);

create policy "projects_update_member"
  on public.projects for update
  using (auth.uid() = creator_id or auth.uid() = partner_id);


-- ────────────────────────────────────────────────────────────
-- 4. PROJECT INTERACTIONS (append-only activity log)
-- ────────────────────────────────────────────────────────────
create table if not exists public.project_interactions (
  id                uuid default gen_random_uuid() primary key,
  project_id        uuid references public.projects(id) on delete cascade not null,
  user_id           uuid references public.profiles(id) on delete cascade not null,
  interaction_type  text not null check (interaction_type in ('commit', 'build', 'deploy', 'terminal')),
  xp_earned         integer default 0,
  metadata          jsonb default '{}',
  created_at        timestamptz default now()
);

create index if not exists idx_interactions_project on public.project_interactions(project_id);
create index if not exists idx_interactions_user on public.project_interactions(user_id);

alter table public.project_interactions enable row level security;

-- Project members can read interactions
create policy "interactions_select_member"
  on public.project_interactions for select
  using (
    exists (
      select 1 from public.projects p
      where p.id = project_id
        and (p.creator_id = auth.uid() or p.partner_id = auth.uid())
    )
  );

-- Insert is done via service role (backend), but allow project members too
create policy "interactions_insert_member"
  on public.project_interactions for insert
  with check (
    exists (
      select 1 from public.projects p
      where p.id = project_id
        and (p.creator_id = auth.uid() or p.partner_id = auth.uid())
    )
  );


-- ────────────────────────────────────────────────────────────
-- 5. AI CHAT HISTORY (project-scoped, shared between both devs)
-- ────────────────────────────────────────────────────────────
create table if not exists public.ai_chat_history (
  id            uuid default gen_random_uuid() primary key,
  project_id    uuid references public.projects(id) on delete cascade not null,
  user_id       uuid references public.profiles(id) on delete cascade not null,
  role          text not null check (role in ('user', 'assistant', 'system')),
  content       text not null,
  context_files text[] default '{}',
  created_at    timestamptz default now()
);

create index if not exists idx_ai_chat_project on public.ai_chat_history(project_id);

alter table public.ai_chat_history enable row level security;

-- Project members can read and insert
create policy "ai_chat_select_member"
  on public.ai_chat_history for select
  using (
    exists (
      select 1 from public.projects p
      where p.id = project_id
        and (p.creator_id = auth.uid() or p.partner_id = auth.uid())
    )
  );

create policy "ai_chat_insert_member"
  on public.ai_chat_history for insert
  with check (
    exists (
      select 1 from public.projects p
      where p.id = project_id
        and (p.creator_id = auth.uid() or p.partner_id = auth.uid())
    )
  );


-- ────────────────────────────────────────────────────────────
-- 6. PROJECT STARS (community upvotes)
-- ────────────────────────────────────────────────────────────
create table if not exists public.project_stars (
  id          uuid default gen_random_uuid() primary key,
  project_id  uuid references public.projects(id) on delete cascade not null,
  user_id     uuid references public.profiles(id) on delete cascade not null,
  created_at  timestamptz default now(),
  unique(project_id, user_id)  -- one star per user per project
);

create index if not exists idx_stars_project on public.project_stars(project_id);

alter table public.project_stars enable row level security;

-- Anyone can view stars
create policy "stars_select_public"
  on public.project_stars for select using (true);

-- Authenticated users can star (one per project enforced by unique constraint)
create policy "stars_insert_auth"
  on public.project_stars for insert
  with check (auth.uid() = user_id);

-- Users can remove their own star
create policy "stars_delete_own"
  on public.project_stars for delete
  using (auth.uid() = user_id);


-- ════════════════════════════════════════════════════════════
-- FUNCTIONS & TRIGGERS
-- ════════════════════════════════════════════════════════════

-- ── calculate_rank(xp) ─────────────────────────────────────
create or replace function public.calculate_rank(p_xp integer)
returns text as $$
begin
  return case
    when p_xp >= 5000 then 'Principal'
    when p_xp >= 2000 then 'Staff'
    when p_xp >= 500  then 'Senior'
    when p_xp >= 100  then 'Junior'
    else 'Intern'
  end;
end;
$$ language plpgsql immutable;


-- ── set_updated_at() ────────────────────────────────────────
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Apply updated_at triggers to all tables with that column
drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

drop trigger if exists connections_set_updated_at on public.connections;
create trigger connections_set_updated_at
  before update on public.connections
  for each row execute function public.set_updated_at();

drop trigger if exists projects_set_updated_at on public.projects;
create trigger projects_set_updated_at
  before update on public.projects
  for each row execute function public.set_updated_at();


-- ── handle_new_user() — auto-create profile on signup ───────
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, github_username, display_name, avatar_url, bio)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'user_name', 'unknown'),
    coalesce(
      new.raw_user_meta_data ->> 'full_name',
      new.raw_user_meta_data ->> 'user_name'
    ),
    new.raw_user_meta_data ->> 'avatar_url',
    new.raw_user_meta_data ->> 'bio'
  );
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();


-- ── update_xp_on_interaction() ──────────────────────────────
-- When a project_interaction is inserted, add XP to the user
-- and recalculate their rank.
create or replace function public.update_xp_on_interaction()
returns trigger as $$
begin
  update public.profiles
  set
    xp   = xp + new.xp_earned,
    rank = public.calculate_rank(xp + new.xp_earned)
  where id = new.user_id;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_interaction_created on public.project_interactions;
create trigger on_interaction_created
  after insert on public.project_interactions
  for each row execute function public.update_xp_on_interaction();


-- ── update_stars_count() ────────────────────────────────────
-- Keep projects.stars_count in sync and award/remove XP
-- +50 XP to the project creator when starred.
create or replace function public.update_stars_count()
returns trigger as $$
declare
  v_creator_id uuid;
begin
  if TG_OP = 'INSERT' then
    -- Increment star count
    update public.projects
    set stars_count = stars_count + 1
    where id = new.project_id
    returning creator_id into v_creator_id;

    -- Award XP to creator
    if v_creator_id is not null then
      update public.profiles
      set
        xp   = xp + 50,
        rank = public.calculate_rank(xp + 50)
      where id = v_creator_id;
    end if;

    return new;

  elsif TG_OP = 'DELETE' then
    -- Decrement star count
    update public.projects
    set stars_count = greatest(stars_count - 1, 0)
    where id = old.project_id
    returning creator_id into v_creator_id;

    -- Remove XP from creator
    if v_creator_id is not null then
      update public.profiles
      set
        xp   = greatest(xp - 50, 0),
        rank = public.calculate_rank(greatest(xp - 50, 0))
      where id = v_creator_id;
    end if;

    return old;
  end if;

  return null;
end;
$$ language plpgsql security definer;

drop trigger if exists on_star_changed on public.project_stars;
create trigger on_star_changed
  after insert or delete on public.project_stars
  for each row execute function public.update_stars_count();
