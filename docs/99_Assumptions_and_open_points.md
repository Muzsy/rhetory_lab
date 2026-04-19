# Feltételezések és még később finomítható pontok

Ez a dokumentum azokat az alapfeltevéseket rögzíti, amelyeket a dokumentációs csomag azért vezet be, hogy az MVP-spec teljesen használható legyen.

## 1. Auth induló mód
- MVP-ben email + jelszó alapú auth
- később bővíthető Google / magic link irányba

## 2. Avatar
- MVP-ben opcionális
- ha nincs feltöltött avatar, generált vagy default avatar jelenik meg

## 3. Szerepkörkezelés
- `profiles.is_admin` mező technikai tárolásra elfogadható
- de ezt logikailag autorizációs adatként kell kezelni
- minden admin műveletnél backend oldali ellenőrzés kell

## 4. Reakciók láthatósága
- MVP-ben a szituáció reakciói minden belépett felhasználó számára olvashatók
- nincs privát reakció, nincs klub-only láthatóság

## 5. Like logika
- egy user egy reakciót egyszer like-olhat
- unlike = korábbi like visszavonása
- dislike nincs
- saját reakció nem like-olható

## 6. Reakció szerkesztése
- MVP-ben nincs edit
- a beküldött reakció végleges
- később lehet külön edit policy és verziózás

## 7. Delete stratégia
- ahol indokolt, adminnál soft-delete / hidden logika javasolt
- user-oldali destruktív törlési workflow MVP-ben nem elsődleges

## 8. Zárt béta forma
- a dokumentáció Play Store closed testing logikával számol
- ettől később el lehet térni

## 9. Téma / kategória mezők
- MVP UI-ban nincsenek használva
- opcionálisan előkészíthetők a sémában jövőbeli bővítéshez

## 10. Ranking
- MVP-ben nincs teljes külön reputációs rendszer
- az egyszerű lista like-szám / idő szerinti rendezésre épül
- komolyabb leaderboard későbbi fázis
