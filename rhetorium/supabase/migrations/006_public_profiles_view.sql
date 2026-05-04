-- 006: public_profiles security_invoker view
-- Based on: strict_data_model_spec.md §3.1, strict_rls_spec.md §3.1
-- Replaces client-side profile reads with a safe read-only public view.
--
-- security_invoker = true: view executes with caller's (invoker's) security context,
-- so RLS on public.profiles is respected. This avoids the self-referential RLS
-- recursion that caused issues in migrations 004/005.
--
-- Columns: id, display_name, avatar_url, created_at  (per strict_data_model_spec.md §3.1)
--
-- Access: GRANT SELECT to authenticated role so anon-key clients can read public profiles
--         without triggering RLS recursion on the profiles table.

-- Create security_invoker view (PostgreSQL 15+ feature; supported by Supabase)
create or replace view public.public_profiles as
  select
    id,
    display_name,
    avatar_url,
    created_at
  from public.profiles
  with options (security_invoker = true);

-- Allow authenticated users to read the view
-- (RLS on the underlying profiles table is still enforced per-invoker)
grant select on public.public_profiles to authenticated;

-- Optional: also grant to anon for public-facing read paths
grant select on public.public_profiles to anon;

-- Verification SQL (run locally or via Supabase SQL editor):
--
-- 1. View exists and has correct columns:
--    SELECT column_name, data_type
--    FROM information_schema.columns
--    WHERE table_schema = 'public' AND table_name = 'public_profiles'
--    ORDER BY ordinal_position;
--
-- 2. security_invoker is set:
--    SELECT reloptions
--    FROM pg_class
--    WHERE relname = 'public_profiles';
--    -- Expected: {security_invoker}
--
-- 3. Grants are correct:
--    SELECT grantee, privilege_type
--    FROM information_schema.table_privileges
--    WHERE table_schema = 'public' AND table_name = 'public_profiles';
--
-- 4. Functional test (as authenticated user with a profile):
--    SELECT id, display_name, avatar_url, created_at FROM public.public_profiles LIMIT 5;
