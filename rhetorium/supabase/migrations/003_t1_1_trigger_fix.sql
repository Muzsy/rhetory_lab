-- T1.1 Fix: Admin-field trigger logic correction
-- Problem: Trigger checked target user's admin status instead of executor's admin status
-- Fix: Check auth.uid() (executor) instead of new.id (target user)

-- ============================================================================
-- TRIGGER FIX
-- ============================================================================

create or replace function public.protect_admin_fields()
returns trigger
language plpgsql
security definer
as $$
begin
  -- If trying to set is_admin=true, executor must be admin
  -- auth.uid() is the executor (authenticated user doing the update)
  -- new.id is the target profile being updated
  if new.is_admin = true and not public.is_admin(auth.uid()) then
    raise exception 'Only admins can set is_admin to true';
  end if;
  
  -- If is_banned changed and executor is not admin, reject
  if old.is_banned is distinct from new.is_banned and not public.is_admin(auth.uid()) then
    raise exception 'Only admins can modify is_banned field';
  end if;
  
  return new;
end;
$$;

-- Re-create trigger (same as before, but now uses fixed function)
drop trigger if exists trg_protect_admin_fields on public.profiles;
create trigger trg_protect_admin_fields
before update on public.profiles
for each row execute function public.protect_admin_fields();

-- ============================================================================
-- LOGIC VERIFICATION:
-- Case a) Normal user updates own profile with normal fields
--   - RLS policy "Users can update their own profile_fields" allows (using: auth.uid() = id)
--   - WITH CHECK: is_admin = false AND is_banned = false → allows
--   - Trigger: new.is_admin unchanged (false), old.is_banned unchanged
--   - Result: ✅ ALLOWED
--
-- Case b) Normal user tries to set is_admin=true or is_banned=true
--   - RLS policy "Users can update their own profile_fields" WITH CHECK fails
--   - Trigger: never reached (RLS blocked)
--   - Result: ✅ BLOCKED
--
-- Case c) Admin user promotes another user to admin
--   - RLS policy "Admins can update any profile_fields" allows (using: is_admin(executor) = true)
--   - WITH CHECK: true (allows any values)
--   - Trigger: new.is_admin = true, public.is_admin(auth.uid()) = true → NOT blocked
--   - Result: ✅ ALLOWED
-- ============================================================================
