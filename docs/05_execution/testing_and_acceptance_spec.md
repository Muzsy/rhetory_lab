# Tesztelési és acceptance spec

## 1. Acceptance cél
Az MVP akkor kész, ha a fő user flow-k stabilan működnek Androidon zárt béta szinten.

## 2. Kötelező acceptance flow-k

### 2.1. Regisztráció
- user tud regisztrálni
- profile létrejön
- display name mentődik

### 2.2. Belépés
- user újra be tud lépni
- session fennmarad megfelelően

### 2.3. Scenario lista
- aktív scenario-k látszanak
- hidden / archived scenario nem látszik sima usernek

### 2.4. Scenario detail
- brief betölt
- reaction lista betölt
- saját reaction állapot helyesen jelenik meg

### 2.5. Submission
- user tud reactiont beküldeni
- ugyanarra a scenario-ra nem tud kétszer beküldeni
- tiltott user nem tud beküldeni

### 2.6. Evaluation
- idegen reaction like-olható
- unlike működik
- saját reaction nem like-olható
- duplikált like nem jön létre

### 2.7. Moderation
- user tud reportot küldeni
- admin látja a reportot
- admin el tud rejteni reactiont

### 2.8. Admin
- admin tud scenario-t létrehozni
- nem admin nem tud admin műveletet végrehajtani

## 3. Nem funkcionális minimumok
- alap hibakezelés
- nincs blokkoló crash a fő flow-kban
- lassú hálózatra elfogadható loading állapotok
- üres állapotok értelmesen jelennek meg

## 4. Zárt béta checklista
- signed Android build
- működő auth
- működő Supabase környezet
- minimális seed tartalom
- hibajelentés módja a béta tesztelőknek
