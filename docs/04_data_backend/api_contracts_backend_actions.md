# API / backend műveletek — MVP

Ez a dokumentum Supabase-alapú MVP-hez írja le a fő műveleteket. Nem klasszikus külön REST szerverre optimalizált terv, hanem Supabase Auth + PostgREST + opcionális RPC szemlélet.

## 1. Auth

### 1.1 Regisztráció
Művelet:
- Supabase Auth `signUp(email, password)`

Utólagos lépés:
- `profiles` rekord létrehozása

Sikeres eredmény:
- auth user létrejön
- profile létrejön

Hibák:
- email foglalt
- gyenge jelszó
- profil insert sikertelen

---

### 1.2 Bejelentkezés
Művelet:
- Supabase Auth `signInWithPassword`

Eredmény:
- session
- hozzáférés saját profilhoz

---

### 1.3 Kijelentkezés
Művelet:
- Supabase Auth `signOut`

## 2. Profile

### 2.1 Saját profil lekérdezése
Forrás:
- `profiles`

### 2.2 Saját profil frissítése
Engedett mezők MVP-ben:
- `display_name`
- `avatar_url`

Nem engedett mezők:
- `is_admin`
- `is_banned`

## 3. Scenario műveletek

### 3.1 Published scenario lista
Forrás:
- `scenarios`

Szűrés:
- `status = 'published'`

Rendezés:
- `published_at desc nulls last`
- másodlagosan `created_at desc`

Visszaadott mezők:
- `id`
- `title`
- `brief`
- `published_at`
- `created_at`

---

### 3.2 Scenario részletoldal
Forrás:
- `scenarios`
- kapcsolt submission feed

Visszaadott minimum:
- scenario alapmezők
- submission lista
- submission author public profil
- like count submissionönként
- current user already submitted flag

---

### 3.3 Scenario létrehozása admin által
Művelet:
- insert `scenarios`

Input:
- `title`
- `brief`
- kezdeti `status` (`draft` vagy `published`)

Backend ellenőrzés:
- user admin
- title és brief valid

---

### 3.4 Scenario státuszváltás admin által
Engedett átmenetek MVP-ben:
- `draft -> published`
- `published -> hidden`
- `published -> archived`
- `hidden -> published`
- `archived -> published` csak admin döntéssel, ha kell

## 4. Submission műveletek

### 4.1 Submission létrehozása
Művelet:
- insert `submissions`

Input:
- `scenario_id`
- `body`

Backend ellenőrzés:
- user authenticated
- user nem banned
- scenario published
- user még nem adott be submissiont ugyanahhoz a scenariohoz
- body nem üres

Sikeres eredmény:
- submission rekord létrejön

Hibák:
- duplicate submission
- scenario not published
- banned user
- invalid body

---

### 4.2 Submission lista scenario alatt
Forrás:
- `submissions`
- `public_profiles`
- `submission_likes` aggregáció

Csak látható rekordok:
- `status = 'active'`

Rendezés MVP-javaslat:
- `like_count desc`
- majd `created_at asc`

---

### 4.3 Saját submission ellenőrzése
Cél:
- eldönteni, hogy az editor jelenjen meg vagy a saját korábbi beküldés

Lekérdezés:
- `submissions where scenario_id = :scenarioId and author_id = auth.uid()`

## 5. Like műveletek

### 5.1 Like létrehozása
Művelet:
- insert `submission_likes`

Input:
- `submission_id`

Backend ellenőrzés:
- a target nem saját submission
- a target active
- a scenario published
- user nem banned
- még nincs meglévő like rekord

Sikeres eredmény:
- új like rekord

---

### 5.2 Like visszavonása
Művelet:
- delete `submission_likes`

Szűrés:
- `submission_id = :submissionId and user_id = auth.uid()`

Megjegyzés:
- ez az MVP-ben az "unlike"
- negatív szavazat nincs

---

### 5.3 Liked by me állapot
Művelet:
- a kliens lekérdezi, van-e rekord `(submission_id, auth.uid())`
- vagy view/rpc számolja

## 6. Report műveletek

### 6.1 Report létrehozása
Művelet:
- insert `reports`

Input:
- `target_type`
- `target_id`
- `reason_code`
- `details` opcionális

Backend ellenőrzés:
- user authenticated
- user nem banned
- target létezik

---

### 6.2 Saját reportok listázása
Művelet:
- select `reports` by `reporter_id = auth.uid()`

## 7. Admin moderációs műveletek

### 7.1 Submission elrejtése
Javasolt megoldás:
- RPC vagy admin update
- `status = 'hidden'`, `hidden_at = now()`
- moderation event log írása

### 7.2 Scenario elrejtése
- `status = 'hidden'`
- moderation event log írása

### 7.3 User tiltása
- `profiles.is_banned = true`
- moderation event log írása

### 7.4 Report kezelése
- `status = 'resolved'` vagy `dismissed`
- `handled_by`, `handled_at`, `admin_note` kitöltése
- moderation event log írása

## 8. Opcionális RPC-k az MVP kényelméért

Javasolt, de nem kötelező:
- `get_scenario_detail_with_feed(p_scenario_id uuid)`
- `admin_hide_submission(p_submission_id uuid, p_note text)`
- `admin_hide_scenario(p_scenario_id uuid, p_note text)`
- `admin_ban_user(p_user_id uuid, p_note text)`
- `admin_resolve_report(p_report_id uuid, p_resolution text, p_note text)`

## 9. Válaszformátumok általános elvárása

MVP-ben is fontos:
- egyértelmű hibaüzenet-kódok
- validációs hibák és jogosultsági hibák külön kezelése
- soft delete / hidden állapotok miatt a kliens ne feltételezze, hogy minden korábban látott rekord később is látható
