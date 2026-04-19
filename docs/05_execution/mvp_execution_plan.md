# MVP Execution Plan

## 0. Alapelv
Az agent ne “képernyőket építsen össze”, hanem egyetlen végigfutó, működő vertical slice-ot hozzon létre, majd ezt bővítse modulonként.

## 1. Definition of done
Az MVP akkor tekinthető késznek, ha egy új felhasználó Androidon:
1. regisztrálni tud,
2. be tud jelentkezni,
3. látja a szituációlistát,
4. meg tud nyitni egy szituációt,
5. be tud küldeni egy reakciót,
6. látja mások reakcióit,
7. like-olni és unlike-olni tud más reakciókat,
8. admin felhasználóként létre tud hozni új szituációt,
9. reportolni tud reakciót,
10. az admin el tud rejteni vagy törölni problémás tartalmat.

## 2. Végrehajtási sorrend

### Phase 1 — Repo és infrastruktúra bootstrap
- Flutter monorepo alap létrehozása
- packages/apps struktúra lefektetése
- Supabase projekt és env integráció
- alap state management, routing, theming váz
- local/dev config előkészítése

### Phase 2 — Auth + Profile vertical slice
- email+jelszó auth
- profile record létrehozás regisztráció után
- minimális profil mezők
- session kezelés
- login / signup / splash / auth guard

### Phase 3 — Scenario read flow
- scenario tábla + olvasási policy
- scenario lista képernyő
- scenario detail képernyő
- üres/hiba/loading állapotok

### Phase 4 — Submission flow
- submission tábla + insert szabályok
- egy user / egy scenario / egy submission
- submission editor a detail oldalon
- beküldés után lista-frissítés

### Phase 5 — Evaluation flow
- likes tábla
- like/unlike művelet
- saját submission like tiltása
- like count megjelenítés
- rendezés like_count, majd created_at alapján

### Phase 6 — Admin scenario creation
- admin flag ellenőrzés
- admin-only create scenario screen
- create form validáció
- friss scenario visszajelenítése listában

### Phase 7 — Minimum moderation
- report gomb reakciókon
- reports tábla
- admin moderation list
- admin hide/delete submission
- admin hide/delete scenario
- szükség esetén user suspend mező előkészítés

### Phase 8 — Hardening
- acceptance checklist végigfuttatása
- seed adatok
- üres állapotok
- alap hibatűrés
- kézi smoke test Androidon

## 3. Tiltott eltérések
Az agent nem teheti meg az alábbiakat külön jóváhagyás nélkül:
- klubok, challenge-ek, badge-ek hozzáadása
- kommentrendszer bevezetése
- dislike vagy többdimenziós voting bevezetése
- témák/kategóriák UI szintű aktiválása
- fizetős logika bevezetése
- web app vagy iOS build priorizálása

## 4. Döntési sorrend bizonytalanság esetén
1. MVP simplicity
2. Security / policy correctness
3. Stable UX
4. Future extensibility
5. Developer convenience
