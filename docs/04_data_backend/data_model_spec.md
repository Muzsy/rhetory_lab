# Adatmodell-spec

## 1. Adatbázis-technológiai irány
Supabase / PostgreSQL.

## 2. Fő táblák

### 2.1. profiles
Cél: alap felhasználói profil és szerepkörjelzés

Javasolt mezők:
- id: uuid, PK, auth.users id-hez kötve
- display_name: text, required
- avatar_url: text, nullable
- is_admin: boolean, default false
- is_banned: boolean, default false
- created_at: timestamptz
- updated_at: timestamptz

### 2.2. scenarios
Cél: admin által létrehozott szituációk

Javasolt mezők:
- id: uuid, PK
- title: text, required
- brief: text, required
- created_by: uuid, FK -> profiles.id
- status: text, enum jellegű (`active`, `hidden`, `archived`)
- created_at: timestamptz
- updated_at: timestamptz

Opcionális előkészített, de MVP-ben nem használt mezők:
- category: text, nullable
- difficulty: text, nullable
- scenario_type: text, nullable

### 2.3. submissions
Cél: user reakciók

Javasolt mezők:
- id: uuid, PK
- scenario_id: uuid, FK -> scenarios.id
- author_id: uuid, FK -> profiles.id
- body: text, required
- status: text, enum jellegű (`visible`, `hidden`, `removed`)
- created_at: timestamptz
- updated_at: timestamptz

Kötelező üzleti szabály:
- unique constraint: (scenario_id, author_id)

### 2.4. submission_likes
Cél: like kapcsolatok

Javasolt mezők:
- id: uuid, PK
- submission_id: uuid, FK -> submissions.id
- user_id: uuid, FK -> profiles.id
- created_at: timestamptz

Kötelező üzleti szabály:
- unique constraint: (submission_id, user_id)

Megjegyzés:
- unlike művelet esetén a rekord törölhető

### 2.5. reports
Cél: felhasználói jelentések

Javasolt mezők:
- id: uuid, PK
- reporter_id: uuid, FK -> profiles.id
- target_type: text (`scenario`, `submission`, `profile`)
- target_id: uuid
- reason: text
- status: text (`open`, `reviewed`, `closed`)
- moderator_id: uuid, nullable
- moderator_note: text, nullable
- created_at: timestamptz
- updated_at: timestamptz

## 3. Enum irányok
Ha nincs külön enum típus bevezetve, az MVP-ben elegendő text + app oldali validáció, de hosszabb távra érdemes DB enum.

## 4. Soft delete vs hard delete
Javaslat:
- scenario és submission admin-oldalon inkább `status` mezővel rejtve / removed logika
- likes esetén hard delete elfogadható unlike-nál
- reports maradjanak audit okból

## 5. Indexek
Javasolt indexek:
- scenarios(status, created_at desc)
- submissions(scenario_id, status, created_at desc)
- submission_likes(submission_id)
- reports(status, created_at)

## 6. MVP-hez nem szükséges táblák
- clubs
- club_members
- challenges
- rewards
- seasons
- comments
- notifications advanced
