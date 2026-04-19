# Auth és onboarding spec

## 1. MVP auth modell
- email + jelszó

## 2. Regisztráció
Kötelező mezők:
- email
- password
- display_name

Opcionális:
- avatar

## 3. Belépés
- email
- password

## 4. Onboarding flow
1. regisztráció
2. session létrejön
3. profil létrejön
4. display name ellenőrzés / megadás
5. user a szituációlistára jut

## 5. Alap validációk
- email formátum
- jelszó minimum
- display_name minimum / maximum hossz
- tiltott vagy üres név tiltása

## 6. Profil minimum
- display_name
- avatar_url
- is_admin háttérmező
- is_banned háttérmező

## 7. MVP-ben nincs
- social login
- guest mód
- bonyolult onboarding tutorial
- több lépcsős profilépítés
