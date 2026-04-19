create or replace view public.public_profiles as
select
  id,
  display_name,
  avatar_url,
  created_at
from public.profiles;

create or replace view public.submission_like_counts as
select
  submission_id,
  count(*)::int as like_count
from public.submission_likes
group by submission_id;

create or replace view public.scenario_submission_feed as
select
  sub.id as submission_id,
  sub.scenario_id,
  sub.author_id,
  pp.display_name,
  pp.avatar_url,
  sub.body,
  sub.created_at,
  coalesce(lc.like_count, 0) as like_count
from public.submissions sub
join public.public_profiles pp on pp.id = sub.author_id
left join public.submission_like_counts lc on lc.submission_id = sub.id
where sub.status = 'active';

-- Example: scenario list query
-- select id, title, brief, published_at, created_at
-- from public.scenarios
-- where status = 'published'
-- order by published_at desc nulls last, created_at desc;

-- Example: own submission lookup for a scenario
-- select *
-- from public.submissions
-- where scenario_id = :scenario_id
--   and author_id = auth.uid();

-- Example: scenario detail feed query
-- select *
-- from public.scenario_submission_feed
-- where scenario_id = :scenario_id
-- order by like_count desc, created_at asc;
