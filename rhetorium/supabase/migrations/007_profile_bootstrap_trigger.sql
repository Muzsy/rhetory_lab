-- 007: Profile bootstrap trigger
-- Based on: official Supabase pattern (handle_new_user + AFTER INSERT trigger on auth.users)
-- Idempotent: DROP TRIGGER IF EXISTS / CREATE OR REPLACE FUNCTION
--
-- Problem solved: signup_screen.dart inserts profile client-side after signUp returns,
-- creating a race condition window where the user has an auth record but no profile.
-- This server-side trigger ensures the public.profiles row is created atomically
-- with the auth.users record.
--
-- Security: function is SECURITY DEFINER (runs as definer, not invoker) so it can
-- bypass RLS to insert into public.profiles. It is restricted to inserting only
-- one row for the just-created user, with safe fallback for missing display_name.
--
-- The trigger fires ONLY on auth.users AFTER INSERT, so it cannot be exploited
-- to create profiles for arbitrary users.

-- ===========================================================================
-- 1. SECURITY DEFINER bootstrap function
-- ===========================================================================
-- Runs as the schema owner (supabase_admin), bypassing RLS.
-- Inserts exactly one row into public.profiles for the new auth user.
-- display_name sourced from raw_user_meta_data, with safe fallback.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name, avatar_url)
  values (
    new.id,
    coalesce(
      nullif(trim(new.raw_user_meta_data->>'display_name'), ''),
      split_part(new.email, '@', 1)  -- fallback: email local-part
    ),
    nullif(trim(new.raw_user_meta_data->>'avatar_url'), '')
  )
  on conflict (id) do nothing;  -- idempotent: safe if called twice
  return new;
end;
$$;

-- ===========================================================================
-- 2. AFTER INSERT trigger on auth.users
-- ===========================================================================
-- Fires immediately after a new row is inserted into auth.users.
-- Uses OR REPLACE so migration can be re-run safely.

drop trigger if exists on_auth_user_insert on auth.users;

create trigger on_auth_user_insert
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ===========================================================================
-- 3. Verification SQL (run locally or via Supabase SQL editor)
-- ===========================================================================
--
-- a) Function exists:
--    SELECT routine_name, data_type
--    FROM information_schema.routines
--    WHERE routine_schema = 'public' AND routine_name = 'handle_new_user';
--
-- b) Function is SECURITY DEFINER:
--    SELECT proname, prosecdef
--    FROM pg_proc
--    WHERE proname = 'handle_new_user';
--    -- Expected: prosecdef = true
--
-- c) Trigger exists and is wired to auth.users AFTER INSERT:
--    SELECT trigger_name, event_manipulation, action_statement
--    FROM information_schema.triggers
--    WHERE trigger_name = 'on_auth_user_insert'
--      AND event_object_schema = 'auth';
--    -- Expected: event_manipulation = 'INSERT', action_timing = 'AFTER'
--
-- d) Functional test (requires remote Supabase — do NOT run against prod):
--    -- 1. Create a test auth user manually:
--    INSERT INTO auth.users (id, email, raw_user_meta_data)
--    VALUES (
--      gen_random_uuid(),
--      'test-bootstrap-' || now()::text || '@example.com',
--      '{"display_name": "Bootstrap Test User"}'::jsonb
--    );
--    -- 2. Verify profile was auto-created:
--    SELECT id, display_name, avatar_url, is_admin, is_banned
--    FROM public.profiles
--    WHERE display_name = 'Bootstrap Test User';
--    -- Expected: one row with correct display_name
--    -- 3. Cleanup:
--    DELETE FROM public.profiles WHERE display_name = 'Bootstrap Test User';
--    DELETE FROM auth.users WHERE email LIKE 'test-bootstrap-%@example.com';
