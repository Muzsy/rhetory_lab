# Modul-spec

## 1. Alapelv
A rendszer moduláris monolit szemléletben épül. Minden fő funkció külön modul, világos felelősséggel.

## 2. MVP-ben kötelező modulok

### 2.1. Auth modul
Felelősség:
- regisztráció
- belépés
- session kezelés
- kijelentkezés
- auth állapot

Kimenet más modulok felé:
- bejelentkezett user azonosító
- session információ

### 2.2. User Profile modul
Felelősség:
- display name
- avatar
- alap profiladatok
- admin státusz technikai tárolása

Nem felelőssége:
- gamification
- reputációs rendszer
- haladó statisztikák

### 2.3. Scenario modul
Felelősség:
- szituáció entitás
- szituációlista lekérdezés
- szituáció részletes nézet adatforrása
- aktív / rejtett állapot kezelése
- admin oldali létrehozás

### 2.4. Submission modul
Felelősség:
- reakció beküldése
- egy user egy szituációhoz egy reakció szabály
- reakciólista kiszolgálása
- szerkesztés nélküli végleges beküldés

### 2.5. Evaluation modul
Felelősség:
- like
- unlike
- egyediség biztosítása
- saját reakció like tiltása

### 2.6. Admin / Editorial modul
Felelősség:
- szituációk létrehozása
- rejtés / törlés adminoldalon
- alap tartalomkezelés

### 2.7. Moderation minimum modul
Felelősség:
- reakció jelentése
- report adatok tárolása
- admin review
- tartalom elrejtése / törlése
- user korlátozás extrém esetben

## 3. Határmodulok, amik később jönnek
- Club
- Challenge / Battle
- Reward
- Reputation / Ranking advanced
- Comment / Discussion
- Discovery advanced
- Analytics / Anti-abuse advanced

## 4. Modulkapcsolatok
- Auth -> minden belépett useres funkció alapja
- Profile -> Auth után jön
- Scenario -> tartalmi gerinc
- Submission -> Scenario-ra hivatkozik
- Evaluation -> Submission-re hivatkozik
- Moderation -> Scenario és Submission fölé ül review szinten
- Admin -> Scenario és Moderation fölött dolgozik

## 5. UI oldali illesztés
A képernyők modulkompozíciók:
- scenario list screen = Scenario modul
- scenario detail screen = Scenario + Submission + Evaluation + Moderation trigger
- profile screen = Profile
- admin screen = Admin + Moderation
