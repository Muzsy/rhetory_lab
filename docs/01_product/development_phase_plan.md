# Fejlesztési fázisterv

## 1. Cél
A fejlesztés ne horizontális szétaprózásból, hanem vertikális szeletekből álljon.

## 2. Javasolt sorrend

### Fázis 1 — projektalap
- repo létrehozás
- Flutter monorepo setup
- Supabase projekt setup
- auth kapcsolat
- alap routing
- design system minimum

### Fázis 2 — auth + profile slice
- regisztráció
- belépés
- profil létrehozás
- kijelentkezés

### Fázis 3 — scenario slice
- scenario adatmodell
- scenario lista
- scenario részletes oldal
- admin scenario create

### Fázis 4 — submission slice
- submission adatmodell
- reakcióbeküldés
- saját reaction szabály
- reaction lista

### Fázis 5 — evaluation slice
- like / unlike
- own reaction tiltás
- like count megjelenítés

### Fázis 6 — moderation minimum
- report
- admin review
- hide/remove action

### Fázis 7 — zárt béta stabilizálás
- hibajavítás
- acceptance check
- zárt béta build

## 3. Első működő vertical slice
A legelső valódi végigfutó szelet:
1. admin létrehoz egy scenario-t
2. user belép
3. user megnyitja a scenario-t
4. user beküldi a reactiont
5. másik user like-olja

## 4. Mi nem kerülhet az MVP elé
- klubrendszer
- challenge
- comment
- reputációs rendszer
- témák
- payment
