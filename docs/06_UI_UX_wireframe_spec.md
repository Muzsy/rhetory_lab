# UI/UX wireframe spec

## 1. Fő képernyők

### 1.1. Auth képernyő
Elemei:
- email input
- jelszó input
- regisztráció / belépés váltás
- primary CTA
- hibaüzenet blokk

### 1.2. Első profil setup
Elemei:
- display name input
- opcionális avatar
- folytatás gomb

### 1.3. Szituációlista
Elemei:
- top app bar
- lista aktív szituációkkal
- scenario card:
  - cím
  - rövid brief-részlet
  - létrehozás ideje vagy státusz
- empty state
- loading state
- pull to refresh opcionálisan

### 1.4. Szituáció részletes oldal
Blokkok:
- scenario header
  - cím
  - teljes brief
- saját reakció szekció
  - ha nincs még beküldés: editor + beküldés gomb
  - ha van: saját reakció blokk
- reakciólista
  - szerző display name
  - reakció szöveg
  - like szám
  - like gomb
- report action

### 1.5. Profil oldal
Elemei:
- avatar
- display name
- egyszerű profil adatok
- kijelentkezés
- később bővíthető helyek, de MVP-ben egyszerű

### 1.6. Admin oldal
Elemei:
- új scenario létrehozó űrlap
- meglévő scenario-k listája
- alap moderációs belépési pont
- hidden / active állapot kezelés

### 1.7. Moderációs lista (admin)
Elemei:
- report lista
- target preview
- hide / remove action
- note mező

## 2. Navigáció
MVP-ben egyszerű bottom nav vagy minimal tab struktúra:

Javaslat:
- Szituációk
- Profil
- Admin (csak adminnak látható)

## 3. Állapotok
Minden fő képernyőn kell:
- loading
- empty
- error
- success feedback

## 4. UX alapelvek
- kevés vizuális zaj
- a szöveg jól olvasható legyen
- a primary action egyértelmű legyen
- a like interakció gyors legyen
- a reaction beküldés ne legyen túl sok lépés

## 5. Reakcióírás UX
- egyértelmű editor
- karakterszámláló opcionális
- beküldés előtt alap validáció
- sikeres beküldés után azonnali visszajelzés

## 6. Wireframe szintű komponensek
- AppBar
- ScenarioCard
- ScenarioHeader
- SubmissionEditor
- SubmissionCard
- LikeButton
- EmptyState
- ErrorState
- ReportActionSheet
- AdminScenarioForm
