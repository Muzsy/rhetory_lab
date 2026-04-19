-- Rhetorium MVP Schema Migration
-- Based on: docs/04_data_backend/strict_data_model_spec.md

-- Enable UUID extension
create extension if not exists pgcrypto;

-- profiles table
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  avatar_url text,
  is_admin boolean not null default false,
  is_banned boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- scenarios table
create table if not exists public.scenarios (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  brief text not null,
  status text not null default 'draft' check (status in ('draft', 'published', 'hidden', 'archived')),
  created_by uuid not null references public.profiles(id),
  published_at timestamptz,
  hidden_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- submissions table
create table if not exists public.submissions (
  id uuid primary key default gen_random_uuid(),
  scenario_id uuid not null references public.scenarios(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (char_length(trim(body)) > 0),
  status text not null default 'active' check (status in ('active', 'hidden', 'removed')),
  hidden_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (scenario_id, author_id)
);

-- submission_likes table
create table if not exists public.submission_likes (
  submission_id uuid not null references public.submissions(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (submission_id, user_id)
);

-- reports table
create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  target_type text not null check (target_type in ('scenario', 'submission')),
  target_id uuid not null,
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  reason_code text not null check (reason_code in ('spam', 'abuse', 'hate', 'harassment', 'offtopic', 'other')),
  details text,
  status text not null default 'open' check (status in ('open', 'reviewed', 'resolved', 'dismissed')),
  handled_by uuid references public.profiles(id),
  handled_at timestamptz,
  admin_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- moderation_events table
create table if not exists public.moderation_events (
  id uuid primary key default gen_random_uuid(),
  target_type text not null check (target_type in ('scenario', 'submission', 'user', 'report')),
  target_id uuid not null,
  action_type text not null check (action_type in ('hide', 'remove', 'archive', 'ban_user', 'unban_user', 'resolve_report', 'dismiss_report')),
  actor_id uuid not null references public.profiles(id),
  note text,
  created_at timestamptz not null default now()
);

-- Indexes
create index if not exists idx_profiles_display_name_lower on public.profiles ((lower(display_name)));
create index if not exists idx_scenarios_status_created_at on public.scenarios (status, created_at desc);
create index if not exists idx_scenarios_created_by on public.scenarios (created_by);
create index if not exists idx_submissions_scenario_created_at on public.submissions (scenario_id, created_at desc);
create index if not exists idx_submissions_author_created_at on public.submissions (author_id, created_at desc);
create index if not exists idx_submissions_status on public.submissions (status);
create index if not exists idx_submission_likes_user_created_at on public.submission_likes (user_id, created_at desc);
create index if not exists idx_reports_status_created_at on public.reports (status, created_at);
create index if not exists idx_reports_target on public.reports (target_type, target_id);
create index if not exists idx_reports_reporter on public.reports (reporter_id);

-- Auto-update timestamps
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists trg_scenarios_updated_at on public.scenarios;
create trigger trg_scenarios_updated_at
before update on public.scenarios
for each row execute function public.set_updated_at();

drop trigger if exists trg_submissions_updated_at on public.submissions;
create trigger trg_submissions_updated_at
before update on public.submissions
for each row execute function public.set_updated_at();

drop trigger if exists trg_reports_updated_at on public.reports;
create trigger trg_reports_updated_at
before update on public.reports
for each row execute function public.set_updated_at();

-- RLS Policies
alter table public.profiles enable row level security;
alter table public.scenarios enable row level security;
alter table public.submissions enable row level security;
alter table public.submission_likes enable row level security;
alter table public.reports enable row level security;
alter table public.moderation_events enable row level security;

-- profiles policies
create policy "Users can view their own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- scenarios policies
create policy "Anyone can view published scenarios"
  on public.scenarios for select
  using (status = 'published' or exists (
    select 1 from public.profiles where id = auth.uid() and is_admin = true
  ));

create policy "Only admins can insert scenarios"
  on public.scenarios for insert
  with check (exists (
    select 1 from public.profiles where id = auth.uid() and is_admin = true
  ));

create policy "Only admins can update scenarios"
  on public.scenarios for update
  using (exists (
    select 1 from public.profiles where id = auth.uid() and is_admin = true
  ));

-- submissions policies
create policy "Anyone can view active submissions for published scenarios"
  on public.submissions for select
  using (
    status = 'active' and
    exists (select 1 from public.scenarios where id = scenario_id and status = 'published')
  );

create policy "Authenticated users can create submissions"
  on public.submissions for insert
  with check (
    auth.uid() = author_id and
    not exists (select 1 from public.profiles where id = auth.uid() and is_banned = true) and
    exists (select 1 from public.scenarios where id = scenario_id and status = 'published')
  );

create policy "Only admins can update submissions"
  on public.submissions for update
  using (exists (
    select 1 from public.profiles where id = auth.uid() and is_admin = true
  ));

-- submission_likes policies
create policy "Anyone can view likes"
  on public.submission_likes for select
  using (true);

create policy "Authenticated users can like"
  on public.submission_likes for insert
  with check (
    auth.uid() = user_id and
    not exists (select 1 from public.profiles where id = auth.uid() and is_banned = true) and
    not exists (select 1 from public.submissions where id = submission_id and author_id = auth.uid())
  );

create policy "Users can unlike their own likes"
  on public.submission_likes for delete
  using (auth.uid() = user_id);

-- reports policies
create policy "Users can create reports"
  on public.reports for insert
  with check (
    auth.uid() = reporter_id and
    not exists (select 1 from public.profiles where id = auth.uid() and is_banned = true)
  );

create policy "Admins can view all reports"
  on public.reports for select
  using (exists (
    select 1 from public.profiles where id = auth.uid() and is_admin = true
  ));

create policy "Admins can update reports"
  on public.reports for update
  using (exists (
    select 1 from public.profiles where id = auth.uid() and is_admin = true
  ));

-- moderation_events policies
create policy "Only admins can view moderation events"
  on public.moderation_events for select
  using (exists (
    select 1 from public.profiles where id = auth.uid() and is_admin = true
  ));

create policy "Only admins can insert moderation events"
  on public.moderation_events for insert
  with check (exists (
    select 1 from public.profiles where id = auth.uid() and is_admin = true
  ));
