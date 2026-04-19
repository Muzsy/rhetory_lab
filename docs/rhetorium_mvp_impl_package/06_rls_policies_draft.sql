alter table public.profiles enable row level security;
alter table public.scenarios enable row level security;
alter table public.submissions enable row level security;
alter table public.submission_likes enable row level security;
alter table public.reports enable row level security;
alter table public.moderation_events enable row level security;

create or replace function public.is_admin(uid uuid)
returns boolean
language sql
stable
as $$
  select coalesce((select is_admin from public.profiles where id = uid), false);
$$;

create or replace function public.is_banned(uid uuid)
returns boolean
language sql
stable
as $$
  select coalesce((select is_banned from public.profiles where id = uid), false);
$$;

-- profiles
create policy "profiles_select_own"
on public.profiles
for select
using (auth.uid() = id);

create policy "profiles_insert_own"
on public.profiles
for insert
with check (auth.uid() = id);

create policy "profiles_update_own_safe"
on public.profiles
for update
using (auth.uid() = id and not public.is_banned(auth.uid()))
with check (
  auth.uid() = id
  and not public.is_banned(auth.uid())
);

create policy "profiles_admin_manage"
on public.profiles
for all
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

-- scenarios
create policy "scenarios_select_published"
on public.scenarios
for select
using (status = 'published' or public.is_admin(auth.uid()));

create policy "scenarios_admin_insert"
on public.scenarios
for insert
with check (public.is_admin(auth.uid()) and created_by = auth.uid());

create policy "scenarios_admin_update"
on public.scenarios
for update
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

-- submissions
create policy "submissions_select_visible"
on public.submissions
for select
using (
  public.is_admin(auth.uid())
  or (
    status = 'active'
    and exists (
      select 1
      from public.scenarios s
      where s.id = scenario_id
        and s.status = 'published'
    )
  )
);

create policy "submissions_insert_own_once"
on public.submissions
for insert
with check (
  auth.uid() = author_id
  and not public.is_banned(auth.uid())
  and exists (
    select 1
    from public.scenarios s
    where s.id = scenario_id
      and s.status = 'published'
  )
);

create policy "submissions_admin_update"
on public.submissions
for update
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

-- submission likes
create policy "likes_select_authenticated"
on public.submission_likes
for select
using (auth.uid() is not null);

create policy "likes_insert_own_nonself"
on public.submission_likes
for insert
with check (
  auth.uid() = user_id
  and not public.is_banned(auth.uid())
  and exists (
    select 1
    from public.submissions sub
    join public.scenarios sc on sc.id = sub.scenario_id
    where sub.id = submission_id
      and sub.status = 'active'
      and sc.status = 'published'
      and sub.author_id <> auth.uid()
  )
);

create policy "likes_delete_own"
on public.submission_likes
for delete
using (auth.uid() = user_id);

-- reports
create policy "reports_select_own_or_admin"
on public.reports
for select
using (reporter_id = auth.uid() or public.is_admin(auth.uid()));

create policy "reports_insert_own"
on public.reports
for insert
with check (
  reporter_id = auth.uid()
  and not public.is_banned(auth.uid())
);

create policy "reports_admin_update"
on public.reports
for update
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

-- moderation events
create policy "moderation_events_admin_select"
on public.moderation_events
for select
using (public.is_admin(auth.uid()));

create policy "moderation_events_admin_insert"
on public.moderation_events
for insert
with check (public.is_admin(auth.uid()) and actor_id = auth.uid());
