# Migration + Seed Pack

## 1. Migration scope
The MVP requires these primary tables:

### profiles
Core fields:
- id uuid pk references auth.users(id)
- display_name text not null
- avatar_url text null
- is_admin boolean not null default false
- is_suspended boolean not null default false
- created_at timestamptz not null default now()
- updated_at timestamptz not null default now()

### scenarios
- id uuid pk
- title text not null
- brief text not null
- created_by uuid not null references profiles(id)
- is_active boolean not null default true
- is_hidden boolean not null default false
- created_at timestamptz not null default now()
- updated_at timestamptz not null default now()

### submissions
- id uuid pk
- scenario_id uuid not null references scenarios(id)
- author_id uuid not null references profiles(id)
- body text not null
- is_hidden boolean not null default false
- created_at timestamptz not null default now()
- unique(scenario_id, author_id)

### submission_likes
- submission_id uuid not null references submissions(id)
- user_id uuid not null references profiles(id)
- created_at timestamptz not null default now()
- primary key(submission_id, user_id)

### submission_reports
- id uuid pk
- submission_id uuid not null references submissions(id)
- reporter_id uuid not null references profiles(id)
- reason text null
- status text not null default 'open'
- created_at timestamptz not null default now()

## 2. Derived views / queries
Recommended read view:
### scenario_submissions_public
Includes:
- submission id
- scenario_id
- author display_name
- body
- created_at
- like_count

Purpose:
- normal user list rendering without complex client joins

## 3. Frozen defaults
- hard delete: not used for normal moderation flow
- moderation default: hide, not destroy
- `is_hidden=true` means invisible to non-admin readers
- edit history: none in MVP
- dislike table: none

## 4. Suggested RLS intent
### profiles
- user can read own profile
- user can update own non-admin fields
- admin fields cannot be self-promoted by normal user

### scenarios
- signed-in users can read active + non-hidden scenarios
- admin can create
- admin can update/hide

### submissions
- signed-in users can insert their own submission
- signed-in users can read non-hidden submissions attached to visible scenarios
- author cannot update body in MVP
- admin can hide

### submission_likes
- signed-in user can insert/delete own like row
- self-like must be blocked by constraint/check or RPC logic

### submission_reports
- signed-in user can insert report
- admin can read and resolve

## 5. Seed pack
Minimum seed set for local/dev:
- one admin auth user + profile (`is_admin=true`)
- one normal auth user + profile
- 2 active scenarios
- 2-3 sample submissions on first scenario
- 1 sample report for moderation view

## 6. Seed behavior
Seeds must be:
- idempotent where practical
- safe in local/dev only
- not auto-run in production

## 7. Migration strategy
Recommended order:
1. profiles
2. scenarios
3. submissions
4. likes
5. reports
6. views
7. policies
8. seed scripts
