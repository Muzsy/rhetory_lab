# Szigorú adatmodell-specifikáció — MVP

## 1. Általános döntések

- Adatbázis: Supabase Postgres
- Elsődleges kulcsok: `uuid`
- Időbélyegek: `timestamptz`
- Soft delete szemlélet: igen, ahol moderációs vagy audit értéke van
- Az auth az `auth.users` táblában él, az app-specifikus profil a `public.profiles` táblában

## 2. Táblák

### 2.1 `public.profiles`

Cél: felhasználói profil és alap jogosultsági információ.

Mezők:
- `id uuid primary key references auth.users(id) on delete cascade`
- `display_name text not null`
- `avatar_url text null`
- `is_admin boolean not null default false`
- `is_banned boolean not null default false`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Megjegyzések:
- Az `is_admin` autorizációs jelentésű mező.
- Az `is_banned` MVP-ben egyszerű globális korlátozásra szolgál.
- Későbbi fázisban külön szerepkörmodellre bontható.

Indexek:
- opcionális index `lower(display_name)` kereséshez

---

### 2.2 `public.scenarios`

Cél: admin által létrehozott retorikai szituációk.

Mezők:
- `id uuid primary key default gen_random_uuid()`
- `title text not null`
- `brief text not null`
- `status text not null default 'draft'`
- `created_by uuid not null references public.profiles(id)`
- `published_at timestamptz null`
- `hidden_at timestamptz null`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Megengedett `status` értékek MVP-ben:
- `draft`
- `published`
- `hidden`
- `archived`

Értelmezés:
- `draft`: még nem látható a normál usernek
- `published`: látható és használható
- `hidden`: moderációs vagy admin döntés miatt rejtett
- `archived`: lezárt, nem aktív, de megőrzött

Későbbre előkészíthető, de most nem szükséges mezők:
- `category`
- `difficulty`
- `scenario_type`

Indexek:
- index `status, created_at desc`
- index `created_by`

---

### 2.3 `public.submissions`

Cél: felhasználói reakciók tárolása.

Mezők:
- `id uuid primary key default gen_random_uuid()`
- `scenario_id uuid not null references public.scenarios(id) on delete cascade`
- `author_id uuid not null references public.profiles(id) on delete cascade`
- `body text not null`
- `status text not null default 'active'`
- `hidden_at timestamptz null`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Megengedett `status` értékek MVP-ben:
- `active`
- `hidden`
- `removed`

Szabályok:
- egy user egy szituációhoz legfeljebb egy reakciót küldhet be
- szerkesztés MVP-ben nincs
- csak published szituációhoz lehet aktív reakciót beküldeni

Kényszerek:
- unique: `(scenario_id, author_id)`
- check: `char_length(trim(body)) > 0`

Indexek:
- index `scenario_id, created_at desc`
- index `author_id, created_at desc`
- index `status`

---

### 2.4 `public.submission_likes`

Cél: like események tárolása.

Mezők:
- `submission_id uuid not null references public.submissions(id) on delete cascade`
- `user_id uuid not null references public.profiles(id) on delete cascade`
- `created_at timestamptz not null default now()`

Kulcs:
- primary key `(submission_id, user_id)`

Szabályok:
- dislike nincs
- unlike = rekord törlése
- saját reakció nem like-olható
- hidden / removed submission nem like-olható
- banned user nem like-olhat

Indexek:
- index `user_id, created_at desc`

---

### 2.5 `public.reports`

Cél: minimális user report rendszer.

Mezők:
- `id uuid primary key default gen_random_uuid()`
- `target_type text not null`
- `target_id uuid not null`
- `reporter_id uuid not null references public.profiles(id) on delete cascade`
- `reason_code text not null`
- `details text null`
- `status text not null default 'open'`
- `handled_by uuid null references public.profiles(id)`
- `handled_at timestamptz null`
- `admin_note text null`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Megengedett `target_type` értékek:
- `scenario`
- `submission`

Megengedett `reason_code` értékek MVP-ben:
- `spam`
- `abuse`
- `hate`
- `harassment`
- `offtopic`
- `other`

Megengedett `status` értékek MVP-ben:
- `open`
- `reviewed`
- `resolved`
- `dismissed`

Indexek:
- index `status, created_at`
- index `target_type, target_id`
- index `reporter_id`

---

### 2.6 `public.moderation_events`

Cél: admin műveletek auditálása.

Mezők:
- `id uuid primary key default gen_random_uuid()`
- `target_type text not null`
- `target_id uuid not null`
- `action_type text not null`
- `actor_id uuid not null references public.profiles(id)`
- `note text null`
- `created_at timestamptz not null default now()`

Megengedett `target_type` értékek:
- `scenario`
- `submission`
- `user`
- `report`

Megengedett `action_type` értékek MVP-ben:
- `hide`
- `remove`
- `archive`
- `ban_user`
- `unban_user`
- `resolve_report`
- `dismiss_report`

---

## 3. Ajánlott view-k

### 3.1 `public.public_profiles`
Csak nyilvános mezők olvasására:
- `id`
- `display_name`
- `avatar_url`
- `created_at`

### 3.2 `public.scenario_submission_feed`
A scenario részletnézethez egy aggregált view:
- submission alapmezők
- author public profil mezői
- `like_count`
- `liked_by_me` kliensoldalon vagy külön queryből

## 4. Tudatos MVP-egyszerűsítések

- nincs külön notification tábla
- nincs külön ranking tábla
- nincs külön category/tags rendszer
- nincs edit history
- nincs soft delete minden táblán, csak ahol moderációs értéke van

## 5. Nyitott, de már eldöntött technikai alapfeltevések

- a like darabszám nem denormalizált mező az MVP-ben
- a profil minimális marad
- az admin flag egyelőre a profile táblában él
