# Migration + Seed Pack

## 1. Migration scope
The MVP requires these primary tables:

### profiles
Core fields:
- id uuid pk references auth.users(id)
- display_name text not null
- avatar_url text null
- is_admin boolean not null default false
- is_banned boolean not null default false
- created_at timestamptz not null default now()
- updated_at timestamptz not null default now()

### scenarios
- id uuid pk
- title text not null
- brief text not null
- created_by uuid not null references profiles(id)
- status text not null default 'draft' check (status in ('draft', 'published', 'hidden', 'archived'))
- created_at timestamptz not null default now()
- updated_at timestamptz not null default now()

### submissions
- id uuid pk
- scenario_id uuid not null references scenarios(id)
- author_id uuid not null references profiles(id)
- body text not null
- status text not null default 'active' check (status in ('active', 'hidden', 'removed'))
- created_at timestamptz not null default now()
- unique(scenario_id, author_id)

### submission_likes
- submission_id uuid not null references submissions(id)
- user_id uuid not null references profiles(id)
- created_at timestamptz not null default now()
- primary key(submission_id, user_id)

### reports
- id uuid pk
- target_type text not null check (target_type in ('scenario', 'submission'))
- target_id uuid not null
- reporter_id uuid not null references profiles(id)
- reason_code text not null check (reason_code in ('spam', 'abuse', 'hate', 'harassment', 'offtopic', 'other'))
- status text not null default 'open' check (status in ('open', 'reviewed', 'resolved', 'dismissed'))
- created_at timestamptz not null default now()
- updated_at timestamptz not null default now()

### moderation_events
- id uuid pk
- target_type text not null
- target_id uuid not null
- action_type text not null
- actor_id uuid not null references profiles(id)
- note text null
- created_at timestamptz not null default now()

## 2. Frozen defaults

### Status értékek

**scenarios.status:**
- `draft` – még nem látható
- `published` – aktív, user által látható
- `hidden` – moderációs elrejtés
- `archived` – lezárt

**submissions.status:**
- `active` – látható
- `hidden` – moderációs elrejtés
- `removed` – törölt/stornózott

**reports.status:**
- `open` – függőben
- `reviewed` – átnézve
- `resolved` – kezelve
- `dismissed` – elutasítva

### Moderációs elvek
- hard delete: nem használt normál moderációs folyamatban
- moderációs default: status váltás, nem destroy
- admin műveletek server-side ellenőrzöttek
- edit history: nincs MVP-ben
- dislike: nincs

## 3. Seed pack

### Admin bootstrap (MANUÁLIS – nem seed-ből)
MVP-ben az admin felhasználó **manuálisan** jön létre Supabase dashboardon keresztül:
1. Auth users → Create user
2. profiles tábla → profiles.is_admin = true

### Demo seed adatok (local/dev only)
- 2 normál user + profiles (display_name: "Teszt User 1", "Teszt User 2")
- 2 published scenario
- 3-4 sample submission az első scenario-ra
- 1 sample report a moderation nézet teszteléséhez

### Seed behavior
- idempotent where practical
- local/dev only
- not auto-run in production

## 4. Migration strategy
Recommended order:
1. profiles
2. scenarios
3. submissions
4. submission_likes
5. reports
6. moderation_events
7. views
8. RLS policies
9. seed scripts

## 5. Séma referencia
A pontos SQL schema: [../04_data_backend/sql/schema_draft.sql](../04_data_backend/sql/schema_draft.sql)
RLS policy-k: [../04_data_backend/sql/rls_policies_draft.sql](../04_data_backend/sql/rls_policies_draft.sql)
