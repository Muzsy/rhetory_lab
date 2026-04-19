# Befagyasztott MVP-döntések

## Termék
- A termék fókusza: **retorikai szituációkezelés**.
- Az MVP hangulata: **intelligens, letisztult, enyhén kompetitív**.
- A rendszer nem általános fórum, nem kommentcentrikus közösségi app.

## Technológia
- Mobilstack: **Flutter monorepo**.
- Backend: **Supabase**.
- Induló platform: **Android**.
- Indulási forma: **zárt béta**.

## MVP scope
Az MVP-ben kötelezően benne van:
- regisztráció és profil
- szituációlista
- szituáció részletes oldal
- reakció beküldése
- reakciók olvasása
- egyszerű szavazás
- admin oldal szituációk létrehozására
- minimum moderáció

## Nem MVP
Az agent nem építheti be saját döntésből:
- klubok
- csapatcsaták
- challenge-ek
- szezonok
- badge-ek
- reward rendszer
- fejlett ranking / reputáció
- többszempontú evaluation
- témák / kategóriák UI-s kezelése
- comment rendszer
- fizetős account logika

## Scenario létrehozás
- MVP-ben csak admin hozhat létre szituációt.
- Az admin státusz autorizációs adat.
- Technikai induló forma: `profiles.is_admin = true/false`.

## Értékelés
- MVP-ben az evaluation: **like / unlike**.
- Az unlike a like visszavonása, nem negatív szavazat.
- Egy user egy reakciót legfeljebb egyszer like-olhat.
- Saját reakciót nem lehet like-olni.

## Submission szabályok
- Egy user egy szituációhoz egy reakciót küldhet be.
- Beküldés után a reakció az MVP-ben nem szerkeszthető.

## Tartalom
- Induláskor csak admin által létrehozott szituációk.
- Nincs kötelező minimális induló darabszám.
- Témák / kategóriák nem MVP-funkciók.

## Moderáció minimum
- report reakcióra
- admin elrejtés / törlés reakcióra
- admin elrejtés / törlés szituációra
- user korlátozható extrém esetben

## Monetizáció
- MVP-ben nincs előfizetés, paywall vagy premium account logika.
- Később legfeljebb önkéntes támogatásos irány képzelhető el.
