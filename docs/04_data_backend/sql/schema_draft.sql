create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  avatar_url text,
  is_admin boolean not null default false,
  is_banned boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

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

create table if not exists public.submission_likes (
  submission_id uuid not null references public.submissions(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (submission_id, user_id)
);

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

create table if not exists public.moderation_events (
  id uuid primary key default gen_random_uuid(),
  target_type text not null check (target_type in ('scenario', 'submission', 'user', 'report')),
  target_id uuid not null,
  action_type text not null check (action_type in ('hide', 'remove', 'archive', 'ban_user', 'unban_user', 'resolve_report', 'dismiss_report')),
  actor_id uuid not null references public.profiles(id),
  note text,
  created_at timestamptz not null default now()
);

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
