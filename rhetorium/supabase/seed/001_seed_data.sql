-- Rhetorium MVP Seed Data
-- This file contains demo seed data for local development and testing
-- Run this AFTER 001_initial_schema.sql

-- Note: Admin user is created MANUALLY via Supabase Dashboard
-- Admin auth user: Supabase → Authentication → Create user → set is_admin = true in profiles

-- Demo users (these are regular users, not admin)
-- These will be created when users sign up through the app
-- For testing, you can manually insert test profiles if needed

-- Demo scenarios (for testing purposes)
-- Run this to have initial content to test with
DO $$
DECLARE
  admin_id uuid;
  demo_user_id uuid;
BEGIN
  -- Find or create admin profile (manually created in Supabase Dashboard)
  -- Skip if no admin exists yet

  -- Insert demo scenarios only if none exist
  IF NOT EXISTS (SELECT 1 FROM public.scenarios) THEN
    INSERT INTO public.scenarios (title, brief, status, created_by)
    SELECT 
      'Sportolói botrány nyilatkozata',
      'Egy ismert sportoló ellenfelezett egy fontos verseny után nyilvánosan. A sajtó kérdése: hogyan reagálj erre a helyzetre egy hivatalos nyilatkozatban, amely menti az arcát, de elismeri a problémát?',
      'published',
      (SELECT id FROM public.profiles ORDER BY created_at LIMIT 1)
    WHERE EXISTS (SELECT 1 FROM public.profiles LIMIT 1);

    INSERT INTO public.scenarios (title, brief, status, created_by)
    SELECT 
      'Vállalati adatvédelmi incidens',
      'Egy technológiai cég bejelentette, hogy hacker támadás érte őket, és felhasználói adatok kerülhetettek veszélybe. A CEO sajtóközleményt készül kiadni. Mire kell figyelni?',
      'published',
      (SELECT id FROM public.profiles ORDER BY created_at LIMIT 1)
    WHERE EXISTS (SELECT 1 FROM public.profiles LIMIT 1);
  END IF;
END $$;

-- Insert sample submissions for first scenario (if scenarios exist)
DO $$
DECLARE
  first_scenario_id uuid;
  demo_user_id uuid;
BEGIN
  SELECT id INTO first_scenario_id FROM public.scenarios ORDER BY created_at LIMIT 1;
  
  IF first_scenario_id IS NOT NULL THEN
    -- Get a demo user ID
    SELECT id INTO demo_user_id FROM public.profiles ORDER BY created_at DESC LIMIT 1;
    
    -- Only insert if no submissions exist
    IF NOT EXISTS (SELECT 1 FROM public.submissions WHERE scenario_id = first_scenario_id) THEN
      INSERT INTO public.submissions (scenario_id, author_id, body, status)
      VALUES (
        first_scenario_id,
        demo_user_id,
        '"Tiszteljük a verseny szellemét, és elfogadjuk a döntőbírók határozatát. A továbbiakban szeretnénk konstruktív párbeszédet folytatni az érintett felekkel, és minden szükséges lépést megteszünk a sportolói közösség és a szurkolók bizalmának visszaszerzése érdekében."',
        'active'
      );
    END IF;
  END IF;
END $$;

-- Verify seed data
SELECT 
  'profiles' as table_name,
  count(*) as count
FROM public.profiles
UNION ALL
SELECT 
  'scenarios' as table_name,
  count(*) as count
FROM public.scenarios
UNION ALL
SELECT 
  'submissions' as table_name,
  count(*) as count
FROM public.submissions;
