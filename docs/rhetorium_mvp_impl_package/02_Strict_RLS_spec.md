# Szigorú Supabase RLS-specifikáció — MVP

## 1. Általános biztonsági elvek

- Minden publikus üzleti tábla RLS alatt fut.
- A kliensoldal soha nem lehet biztonsági határ.
- Az admin-jog mindig backend/RLS oldalon is ellenőrzött.
- A `banned` user sem írni, sem like-olni, sem jelenteni nem tud.

## 2. Szerepkörök

### Authenticated user
- regisztrált, bejelentkezett felhasználó
- saját profilt módosíthat
- published szituációkat láthat
- active reakciókat láthat
- egy reakciót küldhet be egy scenariohoz
- like-olhat mások reakciójára
- jelenthet submissiont vagy scenariot

### Admin user
- minden authenticated user képessége
- scenario létrehozás
- draft/published/hidden/archived állapot kezelés
- reportok olvasása és kezelése
- submission és scenario elrejtése / archiválása
- user tiltása / feloldása

## 3. Táblánkénti RLS

### 3.1 `profiles`

SELECT:
- a user olvashatja a saját teljes profilját
- más user teljes profilja helyett ajánlott `public_profiles` view használata

INSERT:
- csak saját azonosítóval hozhat létre profilt

UPDATE:
- saját profilját módosíthatja
- `is_admin` és `is_banned` mezőt normál user nem módosíthatja
- admin módosíthat más usert is, ha szükséges

DELETE:
- kliensoldalról tiltott

---

### 3.2 `scenarios`

SELECT:
- normál user csak `published` státuszú scenariokat láthat
- admin minden scenariot láthat

INSERT:
- csak admin

UPDATE:
- csak admin

DELETE:
- hard delete kliensoldalról tiltott
- admin esetén is inkább status-alapú kezelés (`hidden`, `archived`)

---

### 3.3 `submissions`

SELECT:
- normál user csak olyan submissiont láthat, amely:
  - `status = 'active'`
  - a kapcsolódó scenario `published`
- admin minden submissiont láthat

INSERT:
- csak authenticated, nem banned user
- csak saját `author_id`-val
- csak published scenariohoz
- csak akkor, ha még nincs submissionje ugyanahhoz a scenariohoz

UPDATE:
- MVP-ben normál user update tiltott
- admin státuszt módosíthat moderációhoz

DELETE:
- normál user számára tiltott
- adminnak sem hard delete javasolt, hanem `status` váltás

---

### 3.4 `submission_likes`

SELECT:
- authenticated user olvashatja a like rekordokat, vagy helyette aggregált view használható

INSERT:
- csak authenticated, nem banned user
- `user_id = auth.uid()`
- nem lehet a saját submissionje
- a target submission `active`
- a target scenario `published`

DELETE:
- csak a saját like rekordját törölheti

UPDATE:
- tiltott

---

### 3.5 `reports`

SELECT:
- reporter láthatja a saját reportjait
- admin láthat minden reportot

INSERT:
- csak authenticated, nem banned user
- csak saját `reporter_id`-val
- csak létező targetre

UPDATE:
- normál user nem módosíthatja
- admin kezelheti a státuszt és a jegyzeteket

DELETE:
- tiltott

---

### 3.6 `moderation_events`

SELECT:
- csak admin

INSERT:
- csak admin vagy security definer függvény

UPDATE/DELETE:
- tiltott

## 4. Ajánlott security-definer függvények

A legegyszerűbb MVP-hez nem kötelező mindenhez RPC, de ezek hasznosak:

- `is_admin(uid uuid)`
- `is_banned(uid uuid)`
- `admin_hide_submission(submission_id uuid, note text)`
- `admin_hide_scenario(scenario_id uuid, note text)`
- `admin_ban_user(user_id uuid, note text)`
- `admin_resolve_report(report_id uuid, resolution text, note text)`

## 5. Minimális audit elvárás

Admin művelet, amely tartalmat vagy user státuszt módosít, írjon `moderation_events` rekordot.

## 6. MVP-hez javasolt egyszerű biztonsági szabály

Ha egy user `is_banned = true`, akkor:
- új submission insert: tiltott
- új like insert: tiltott
- új report insert: tiltott
- profil update: opcionálisan továbbra is engedhető, de javasolt korlátozni
