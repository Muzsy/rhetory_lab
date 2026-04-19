# API / backend flow spec

## 1. Elv
Az MVP-ben nem kell túlbonyolított API-réteg. A logika lehet Supabase kliens + edge function / RPC kombinációval megoldva, ahol szükséges.

## 2. Fő műveletek

### 2.1. Regisztráció
Input:
- email
- password
- display_name

Flow:
1. auth user létrejön
2. profiles rekord létrejön
3. user belépett állapotba kerül

### 2.2. Belépés
Input:
- email
- password

Output:
- session
- profile alapadatok

### 2.3. Profil lekérdezése / frissítése
Input:
- display_name
- avatar_url (ha támogatott)

Korlát:
- admin mezők nem írhatók userként

### 2.4. Scenario lista lekérése
Output:
- active scenario-k listája
- alap mezők: id, title, rövid brief-részlet, created_at

Rendezés:
- created_at desc vagy editorial szempont szerint

### 2.5. Scenario részlet lekérése
Output:
- scenario teljes brief
- saját submission állapot
- látható submissions
- like összeg
- user saját like állapota

### 2.6. Submission létrehozása
Input:
- scenario_id
- body

Ellenőrzések:
- auth kötelező
- scenario aktív
- user nincs tiltva
- még nincs submission ugyanarra a scenario-ra

Output:
- új submission rekord

### 2.7. Submission lista lekérése
Input:
- scenario_id

Output:
- visible submissionök
- like count
- saját like státusz

### 2.8. Like létrehozása
Input:
- submission_id

Ellenőrzések:
- auth kötelező
- saját submission nem like-olható
- csak egyszer lehet like-olni

Output:
- success + frissített like count

### 2.9. Unlike
Input:
- submission_id

Flow:
- saját like rekord törlése

### 2.10. Report létrehozása
Input:
- target_type
- target_id
- reason

Output:
- report rekord

### 2.11. Admin scenario létrehozása
Input:
- title
- brief

Ellenőrzések:
- admin jogosultság

### 2.12. Admin moderation műveletek
Input:
- target_type
- target_id
- action (`hide`, `remove`, `archive`, `ban_user`)
- optional moderator_note

## 3. Javasolt backend formák
- egyszerű olvasások: direct Supabase query
- érzékenyebb üzleti logika: edge function vagy RPC
  - submission create
  - like create
  - admin moderation action

## 4. Naplózási minimum
- admin actions logolása
- moderation state változások mentése
- sikertelen üzleti szabálysértések kliens felé érthető hibával térjenek vissza
