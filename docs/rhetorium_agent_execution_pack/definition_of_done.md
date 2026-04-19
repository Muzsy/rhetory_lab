# MVP Definition of Done

Az MVP akkor tekinthető késznek, ha az alábbi feltételek egyszerre teljesülnek.

## 1. Auth és profil
- A user képes regisztrálni.
- A user képes bejelentkezni.
- A user rendelkezik létrehozott profilbejegyzéssel.
- Az admin státusz szerveroldalon érvényesül.

## 2. Scenario flow
- Admin képes új szituációt létrehozni.
- Nem admin nem képes új szituációt létrehozni.
- A user képes szituációlistát látni.
- A user képes megnyitni egy szituáció részletes oldalát.

## 3. Submission flow
- A user képes reakciót beküldeni egy szituációhoz.
- Ugyanahhoz a szituációhoz ugyanaz a user nem tud második reakciót beküldeni.
- A beküldött reakció megjelenik az olvasható reakciólistában.
- A reakció nem szerkeszthető az MVP-ben.

## 4. Evaluation flow
- Más felhasználó képes like-olni egy reakciót.
- A like visszavonható.
- A user nem képes a saját reakcióját like-olni.
- Egy user ugyanarra a reakcióra nem tud többszörös like-ot létrehozni.

## 5. Moderation minimum
- Reakció jelenthető.
- Az admin képes reakciót elrejteni vagy törölni.
- Az admin képes szituációt elrejteni vagy törölni.
- Az admin képes felhasználót korlátozni.

## 6. Android működés
- A Flutter alkalmazás Android buildet ad.
- A fő user flow futtatható emulátoron vagy valós eszközön.

## 7. Adatbiztonság
- Az RLS policy-k megakadályozzák az illetéktelen írást.
- Az admin műveletek csak admin role mellett működnek.

## 8. Seed és lokális futás
- Létezik lokális vagy fejlesztői induló seed.
- Létrehozható legalább 1 admin user és 1 teszt scenario.
- A projekt dokumentált módon helyben indítható.
