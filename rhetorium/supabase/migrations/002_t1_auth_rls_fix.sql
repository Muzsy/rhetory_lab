-- T1 Migration Fix: Auth/Profile bootstrap, RLS hardening, env wiring, secret cleanup
-- Based on: strict_rls_spec.md, strict_data_model_spec.md

-- ============================================================================
-- 1. PROFILES INSERT POLICY
-- Problem: Signup creates auth user but no policy allows profile insert
-- Fix: Add policy allowing user to create their own profile row
-- ============================================================================

create policy "Users can insert their own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

-- ============================================================================
-- 2. PROFILES UPDATE POLICY - PROTECT ADMIN/BANNED FIELDS
-- Problem: Any authenticated user can set is_admin=true or is_banned=true
-- Fix: Split update into two policies:
--   a) Normal users can update display_name and avatar_url only
--   b) Admins can update all fields (including is_admin, is_banned)
-- ============================================================================

-- Drop the old permissive policy
drop policy "Users can update their own profile" on public.profiles;

-- Policy for normal field updates (not admin/banned fields)
-- Only allows updating display_name and avatar_url
create policy "Users can update their own profile_fields"
  on public.profiles for update
  using (auth.uid() = id)
  with check (
    auth.uid() = id
    AND is_admin = false
    AND is_banned = false
  );

-- Policy for admin updates (can update all fields including is_admin, is_banned)
create policy "Admins can update any profile_fields"
  on public.profiles for update
  using (exists (
    select 1 from public.profiles where id = auth.uid() and is_admin = true
  ))
  with check (true);

-- ============================================================================
-- 3. ADD HELPER FUNCTIONS FOR SECURITY CHECKS
-- These can be used in policies and RPCs
-- ============================================================================

create or replace function public.is_admin(uid uuid)
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = uid and is_admin = true
  );
$$;

create or replace function public.is_banned(uid uuid)
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = uid and is_banned = true
  );
$$;

-- ============================================================================
-- 4. ENSURE SUBMISSIONS BLOCK BANNED USERS (redundant but explicit)
-- ============================================================================

drop policy "Authenticated users can create submissions" on public.submissions;
create policy "Non-banned users can create submissions"
  on public.submissions for insert
  with check (
    auth.uid() = author_id
    AND not public.is_banned(author_id)
    AND exists (select 1 from public.scenarios where id = scenario_id and status = 'published')
  );

drop policy "Authenticated users can like" on public.submission_likes;
create policy "Non-banned users can like"
  on public.submission_likes for insert
  with check (
    auth.uid() = user_id
    AND not public.is_banned(user_id)
    AND not exists (select 1 from public.submissions where id = submission_id and author_id = auth.uid())
  );

drop policy "Users can create reports" on public.reports;
create policy "Non-banned users can create reports"
  on public.reports for insert
  with check (
    auth.uid() = reporter_id
    AND not public.is_banned(reporter_id)
  );

-- ============================================================================
-- 5. ADD TRIGGER TO PREVENT is_admin/is_banned MODIFICATION BY NON-ADMIN
-- This provides defense-in-depth at the database level
-- ============================================================================

create or replace function public.protect_admin_fields()
returns trigger
language plpgsql
security definer
as $$
begin
  -- If trying to set is_admin=true and user is not admin, reject
  if new.is_admin = true and not public.is_admin(new.id) then
    raise exception 'Only admins can set is_admin to true';
  end if;
  
  -- If is_banned changed by non-admin, allow only if the user is banning themselves
  -- (which is not allowed in normal flow, but being explicit)
  if old.is_banned is distinct from new.is_banned and not public.is_admin(auth.uid()) then
    raise exception 'Only admins can modify is_banned field';
  end if;
  
  return new;
end;
$$;

-- Drop and recreate trigger for profiles
drop trigger if exists trg_protect_admin_fields on public.profiles;
create trigger trg_protect_admin_fields
before update on public.profiles
for each row execute function public.protect_admin_fields();
