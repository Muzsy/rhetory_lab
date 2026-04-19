# Jogosultság- és RLS-spec

## 1. Szerepkörök
### 1.1. Guest
- nem bejelentkezett felhasználó
- MVP-ben nincs értelmes funkciója, az app auth után használható

### 1.2. Authenticated user
- profilját olvashatja / módosíthatja
- aktív szituációkat olvashat
- saját reakciót beküldhet
- reakciókat olvashat
- like-olhat / unlike-olhat
- reportot küldhet

### 1.3. Admin
- minden user jog
- szituációt létrehozhat
- szituációt elrejthet / archiválhat
- reakciót elrejthet / removed állapotba tehet
- reportokat review-zhat
- usert korlátozhat (pl. is_banned)

## 2. RLS alapelvek

### 2.1. profiles
Select:
- minden bejelentkezett user olvashatja a szükséges publikus profilmezőket

Insert:
- saját profil létrehozása engedett triggerrel vagy kontrollált flow-val

Update:
- user csak saját profilját módosíthatja
- admin státuszt csak admin vagy backend service role módosíthat

### 2.2. scenarios
Select:
- csak `active` státuszú scenario-k olvashatók sima usernek
- admin láthat többet is

Insert:
- csak admin

Update:
- csak admin

Delete:
- közvetlen delete tiltott, inkább status alapú elrejtés

### 2.3. submissions
Select:
- `visible` státuszú reakciók olvashatók
- admin láthat hidden/removed elemeket is

Insert:
- csak saját userként
- csak nem tiltott user
- csak aktív scenario-hoz
- csak ha még nincs ugyanahhoz a scenario-hoz saját submission

Update:
- MVP-ben nincs user edit
- admin status módosíthat

Delete:
- user-oldali delete nem szükséges
- admin moderáció kezelhet státusszal

### 2.4. submission_likes
Select:
- aggregációs és saját állapot lekérdezéshez olvasható

Insert:
- csak saját userként
- saját submissionre tilos
- ugyanarra a submissionre egyszer

Delete:
- csak saját like törölhető unlike-ként

### 2.5. reports
Insert:
- csak bejelentkezett user
- csak saját reporter_id-vel

Select:
- sima user csak saját reportjait lássa, ha egyáltalán szükséges
- admin minden reportot láthat

Update:
- admin review státuszokat módosíthat

## 3. Backend oldali kötelező ellenőrzések
Az RLS nem váltja ki az üzleti logikát. Backend oldalon is kell:
- admin művelet ellenőrzés
- saját reaction like tiltás
- egy scenario / egy user / egy submission szabály
- tiltott user blokkolása
