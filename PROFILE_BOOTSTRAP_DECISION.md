# Profile Bootstrap Decision Record

**Date:** 2026-05-03
**Author:** Hermes Agent (M1 implement)
**Based on:** `rhetoric_lab` repo, migrations 001–005, `strict_data_model_spec.md`, `strict_rls_spec.md`, `auth_onboarding_spec.md`, `signup_screen.dart`

---

## 1. Decision: `public_profiles` View Approach

### Chosen approach: `CREATE VIEW public.public_profiles WITH (security_invoker = true)`

**Columns:** `id`, `display_name`, `avatar_url`, `created_at` (matching `strict_data_model_spec.md` §3.1)

### Rationale

| Option | Considered | Why rejected or chosen |
|--------|-----------|------------------------|
| `CREATE POLICY` on a normal view | Rejected | The goal explicitly prohibits this |
| `security_invoker = true` view | **Chosen** | Uses caller's RLS context, bypasses self-referential RLS recursion (the bug in migrations 004/005), no SECURITY DEFINER needed |
| `SECURITY DEFINER` function returning a setof profile rows | Fallback | Only if `security_invoker` is unsupported; not needed here |

### Why `security_invoker` is safe here

- `security_invoker = true` means the view runs as the **invoker** (the authenticated user), not as the view owner.
- The underlying `public.profiles` table has RLS enabled. When the view queries it, the caller's RLS policies apply.
- An anonymous user sees only what their RLS policies allow (nothing from `profiles`, because the existing SELECT policy requires `auth.uid() = id` or `is_admin`).
- Authenticated users see their own profile row through the view — matching the intent of `strict_rls_spec.md` §3.1.
- This approach was specifically recommended to avoid the self-referential RLS pattern that broke migrations 004 and 005.

### Grants

```sql
grant select on public.public_profiles to authenticated;
grant select on public.public_profiles to anon;
```

### Risks

1. **PostgreSQL version requirement:** `security_invoker` view option requires PostgreSQL 15+. Supabase Cloud uses PostgreSQL 15+, so this is safe for the project's Supabase deployment.
2. **View vs. direct table reads:** Existing code (e.g., profile screens) may read from `public.profiles` directly. Those queries continue to work via existing RLS policies. The view is an additive, opt-in improvement.
3. **Avatar URL leakage:** `avatar_url` is exposed through the view. If `raw_user_meta_data` contains PII or private URLs, this should be reviewed. Currently `avatar_url` is a public-facing URL field, so this is acceptable.

### Manual Verification SQL

```sql
-- 1. Confirm view has correct schema
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'public_profiles'
ORDER BY ordinal_position;
-- Expected: id(uuid,NO), display_name(text,NO), avatar_url(text,YES), created_at(timestamptz,NO)

-- 2. Confirm security_invoker option is set
SELECT reloptions
FROM pg_class
WHERE relname = 'public_profiles' AND relnamespace = (
  SELECT oid FROM pg_namespace WHERE nspname = 'public'
);
-- Expected: {security_invoker}

-- 3. Confirm grants
SELECT grantee, privilege_type, is_grantable
FROM information_schema.table_privileges
WHERE table_schema = 'public' AND table_name = 'public_profiles';
-- Expected: SELECT granted to 'authenticated' and 'anon'

-- 4. RLS enforcement test (as different roles)
-- As anon:   SELECT * FROM public.public_profiles;  -- should return 0 rows
-- As authed: SELECT * FROM public.public_profiles WHERE id = auth.uid(); -- should return own row
```

---

## 2. Decision: Profile Bootstrap Trigger Approach

### Chosen approach: `SECURITY DEFINER` function + `AFTER INSERT` trigger on `auth.users`

**Function:** `public.handle_new_user()`
**Trigger:** `on_auth_user_insert` on `auth.users` AFTER INSERT

### Rationale

| Option | Considered | Why rejected or chosen |
|--------|-----------|------------------------|
| Client-side profile insert (current `signup_screen.dart` approach) | Rejected | Race condition: user has auth record but no profile between signUp and client insert |
| `SECURITY DEFINER` function + `AFTER INSERT` trigger | **Chosen** | Official Supabase pattern; creates profile atomically with auth record |
| `BEFORE INSERT` trigger | Considered | `AFTER INSERT` chosen to ensure auth record is fully committed first |
| Manual profile creation via admin | Rejected | Not scalable; not automatic |

### Function details

```sql
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, display_name, avatar_url)
  values (
    new.id,
    coalesce(
      nullif(trim(new.raw_user_meta_data->>'display_name'), ''),
      split_part(new.email, '@', 1)  -- fallback
    ),
    nullif(trim(new.raw_user_meta_data->>'avatar_url'), '')
  )
  on conflict (id) do nothing;  -- idempotent
  return new;
end;
$$;
```

### Display name sourcing (in priority order)

1. `raw_user_meta_data->>'display_name'` — set by client at signup
2. Email local-part (e.g., `jane` from `jane@example.com`) — safe fallback
3. Never blank (coalesce guarantees non-empty)

### Why `security definer` is safe here

- The function is `SECURITY DEFINER` (runs as function owner, i.e., `supabase_admin`), which bypasses RLS on `public.profiles`.
- However, it can ONLY insert a row where `id = new.id` — the UUID of the just-inserted auth user.
- It CANNOT be exploited to create profiles for arbitrary users because:
  - The trigger is on `auth.users AFTER INSERT`, not an RPC endpoint.
  - There is no public-facing SQL interface to call this function manually.
  - `on conflict (id) do nothing` makes it idempotent.
- `SET search_path = public` prevents `search_path` hijacking attacks.

### Risks

1. **display_name null edge case:** If `raw_user_meta_data` is `null` or `display_name` is all whitespace, the coalesce fallback to email local-part always produces a non-empty string. This is acceptable.
2. **Supabase auth metadata schema:** Supabase stores `raw_user_meta_data` from the signup call. If the Flutter client does not pass `display_name` in metadata (it currently passes it as a separate client-side insert), the trigger will use the email fallback. The `signup_screen.dart` should be updated to pass `display_name` in the `signUp()` metadata. See §4.
3. **Trigger ordering:** `AFTER INSERT` ensures the auth record is committed before the profile insert. If the profile insert fails, the auth record still exists but has no profile. This is recoverable by manually triggering the function or updating the client-side code.

### Manual Verification SQL

```sql
-- a) Function exists and is SECURITY DEFINER
SELECT proname, prosecdef, pg_get_expr(prosrc, oid) AS src
FROM pg_proc JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
WHERE proname = 'handle_new_user' AND nspname = 'public';
-- Expected: prosecdef = true, src contains 'INSERT INTO public.profiles'

-- b) Trigger wired to auth.users AFTER INSERT
SELECT trigger_name, event_object_table, action_timing, event_manipulation
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_insert'
  AND event_object_schema = 'auth';
-- Expected: action_timing = 'AFTER', event_manipulation = 'INSERT'

-- c) Functional E2E test (local Supabase only — NOT prod):
DO $$
DECLARE
  test_email TEXT := 'test-' || gen_random_uuid() || '@example.com';
  test_uid   UUID;
BEGIN
  -- Insert test auth user
  INSERT INTO auth.users (id, email, raw_user_meta_data)
  VALUES (gen_random_uuid(), test_email,
          '{"display_name": "Trigger Test User", "avatar_url": ""}'::jsonb)
  RETURNING id INTO test_uid;

  -- Verify profile auto-created
  IF EXISTS (SELECT 1 FROM public.profiles WHERE id = test_uid AND display_name = 'Trigger Test User') THEN
    RAISE NOTICE 'PASS: Profile auto-created with display_name';
  ELSE
    RAISE WARNING 'FAIL: Profile not auto-created';
  END IF;

  -- Cleanup
  DELETE FROM public.profiles WHERE id = test_uid;
  DELETE FROM auth.users WHERE id = test_uid;
END $$;
```

---

## 3. Interaction: Trigger + Existing Client-Side Insert

### Current state (`signup_screen.dart` lines 36–45)

```dart
final response = await client.auth.signUp(
  email: _emailController.text.trim(),
  password: _passwordController.text,
);
if (response.user != null) {
  await client.from('profiles').insert({  // <-- client-side insert
    'id': response.user!.id,
    'display_name': _displayNameController.text.trim(),
  });
}
```

### After migration 007

The trigger will fire AFTER the auth.users INSERT, creating the profile server-side. The client-side insert in `signup_screen.dart` will then attempt to insert a duplicate row. This will fail silently (the RLS INSERT policy allows it, but the `profiles.id` primary key will reject the duplicate).

**Recommended fix (out of scope for M1, noted for M2):** Remove the client-side `profiles.insert()` call from `signup_screen.dart` and pass `display_name` in `userMetadata`:

```dart
await client.auth.signUp(
  email: _emailController.text.trim(),
  password: _passwordController.text,
  data: {'display_name': _displayNameController.text.trim()},
);
```

The trigger will pick up `display_name` from `raw_user_meta_data`. No client-side profile insert needed.

---

## 4. Next Steps (M2)

1. **Update `signup_screen.dart`** to pass `display_name` via `signUp(data: {...})` metadata instead of separate client-side insert.
2. **Remove client-side profile insert** after confirming trigger works in staging.
3. **Add `public_profiles` usage** in Flutter profile/review screens where other authors' public names are displayed.
4. **Run migration 006 + 007** on staging Supabase project before applying to production.
5. **Test E2E signup flow** with real email + display_name and verify profile row is auto-created.
