# Evaluation és ranking MVP spec

## 1. Értékelési modell
MVP-ben:
- like
- unlike = like visszavonása
- dislike nincs

## 2. Üzleti szabályok
- egy user egy submissiont egyszer like-olhat
- saját submission nem like-olható
- unlike csak saját korábbi like-ra értelmes
- tiltott user nem like-olhat

## 3. UI viselkedés
- like gomb látható minden idegen reaction cardon
- aktív / inaktív vizuális állapot
- like count megjelenik

## 4. Ranking MVP szint
Nincs önálló mély reputációs rendszer.

MVP-ben a ranking/logika:
- submission szinten like count alapú rendezés
- scenario-n belül a reakciók rendezhetők like szerint
- alternatív rendezés lehet created_at szerint

## 5. Mi nincs az MVP-ben
- globális leaderboard komoly pontképlettel
- súlyozott szavazat
- vak párbaj
- többdimenziós pontozás
- trust / reputation weight

## 6. Jövőbeli bővíthetőség
A sémát és kódot úgy kell írni, hogy később beilleszthető legyen:
- anonymous evaluation
- weighted evaluation
- challenge scoring
- user reputation
