-- T2.1 Fix: Admin visibility, report-state consistency, moderation_events consistency
-- Problem 1: Admin can't see all profiles - missing admin SELECT policy
-- Problem 2: Admin can't see all submissions with different statuses
-- Problem 3: 'unhide' action_type not in check constraint
-- Problem 4: Report state not updated after moderation from dialog

-- ============================================================================
-- 1. ADMIN SELECT POLICY FOR PROFILES
-- ============================================================================

create policy "Admins can view all profiles"
  on public.profiles for select
  using (exists (
    select 1 from public.profiles where id = auth.uid() and is_admin = true
  ));

-- ============================================================================
-- 2. ADMIN SELECT POLICY FOR SUBMISSIONS (ALL STATUSES)
-- ============================================================================

-- Drop the restrictive policy
drop policy "Anyone can view active submissions for published scenarios" on public.submissions;

-- Create new policy: admin sees all, normal user sees only active for published scenarios
create policy "View submissions based on role"
  on public.submissions for select
  using (
    -- Admin can see all submissions
    exists (select 1 from public.profiles where id = auth.uid() and is_admin = true)
    or
    -- Normal user can see only active submissions for published scenarios
    (
      status = 'active'
      and exists (select 1 from public.scenarios where id = scenario_id and status = 'published')
    )
  );

-- ============================================================================
-- 3. FIX MODERATION_EVENTS ACTION_TYPE CHECK CONSTRAINT
-- Need to alter the check constraint to include 'unhide'
-- Since we can't directly alter check constraints, we recreate the table

-- Drop the constraint
alter table public.moderation_events drop constraint if exists moderation_events_action_type_check;

-- Add new constraint with 'unhide'
alter table public.moderation_events
add constraint moderation_events_action_type_check
check (action_type in ('hide', 'remove', 'unhide', 'archive', 'ban_user', 'unban_user', 'resolve_report', 'dismiss_report'));

-- ============================================================================
-- 4. VERIFY: List of valid action_types after fix
-- hide, remove, unhide, archive, ban_user, unban_user, resolve_report, dismiss_report
-- ============================================================================
