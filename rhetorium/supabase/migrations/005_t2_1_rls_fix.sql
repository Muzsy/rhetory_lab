-- T2.1 RLS Fix: Admin visibility using security definer functions
-- Problem: Migration 004 uses self-referential queries in RLS policies
-- which causes RLS recursion issues. Fix by using is_admin() security definer function.

-- ============================================================================
-- 1. FIX ADMIN SELECT POLICY FOR PROFILES
-- Change from self-referential query to is_admin() security definer function
-- ============================================================================

drop policy if exists "Admins can view all profiles" on public.profiles;

create policy "Admins can view all profiles"
  on public.profiles for select
  using (public.is_admin(auth.uid()));

-- ============================================================================
-- 2. FIX ADMIN SELECT POLICY FOR SUBMISSIONS
-- Change from self-referential query to is_admin() security definer function
-- ============================================================================

drop policy if exists "View submissions based on role" on public.submissions;

create policy "View submissions based on role"
  on public.submissions for select
  using (
    -- Admin can see all submissions
    public.is_admin(auth.uid())
    or
    -- Normal user can see only active submissions for published scenarios
    (
      status = 'active'
      and exists (select 1 from public.scenarios where id = scenario_id and status = 'published')
    )
  );

-- ============================================================================
-- 3. FIX ADMIN UPDATE POLICY FOR PROFILES (ban/unban uses this)
-- Change from self-referential query to is_admin() security definer function
-- ============================================================================

drop policy if exists "Admins can update any profile_fields" on public.profiles;

create policy "Admins can update any profile_fields"
  on public.profiles for update
  using (public.is_admin(auth.uid()))
  with check (public.is_admin(auth.uid()));

-- ============================================================================
-- 4. VERIFY - List of is_admin() usages after fix
-- - profiles SELECT policy (admin sees all)
-- - profiles UPDATE policy (admin can update any)
-- - submissions SELECT policy (admin sees all)
-- - scenarios SELECT policy (admin sees all - already correct from migration 001)
-- - scenarios INSERT policy (admin only - already correct)
-- - scenarios UPDATE policy (admin only - already correct)
-- ============================================================================
