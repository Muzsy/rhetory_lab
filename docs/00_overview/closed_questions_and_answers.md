# Rhetorium / retorikai szituációkezelő alkalmazás — lezárt kérdések és kiegészített MVP-válaszok

Ez a dokumentum az eddig nyitott kérdésekre adott válaszokat rögzíti, és az MVP-hez szükséges minimum pontosításokkal egészíti ki őket.

A cél nem végleges, teljes termékspecifikáció, hanem egy olyan stabil alap, amire a tervezés, az architektúra és később a fejlesztés már félreértés nélkül ráépíthető.

---

## 1. Technológiai alapok

### Döntés
- Mobilstack: **Flutter monorepo**
- Backend: **Supabase**
- Induló kliensplatform: **Android**

### Értelmezés
A projekt induló technikai iránya egy Flutter-alapú, monorepo szemléletű alkalmazás, Supabase háttérrendszerrel.

### MVP-szintű következmény
- Egyetlen mobilalkalmazás készül Androidra.
- A backend oldalon nincs szükség külön túlkomplikált szolgáltatáshalmazra.
- A rendszer induló formája maradjon **moduláris monolit szemléletű**, ne legyen túl korán szétbontva.

### Kiegészítés
Az admin jogosultságot nem pusztán UI-szintű jelzésként kell kezelni, hanem **jogosultsági szerepkörként**. Technikai szinten ezt lehet a user profilhoz kapcsolt mezőként tárolni, de logikailag ez **autorizációs adat**, nem csak profiladat.

Javasolt induló megoldás:
- `profiles.is_admin: boolean`
- a backend oldali ellenőrzés minden admin műveletnél kötelező
- kliensoldali elrejtés önmagában nem elég

---

## 2. MVP scope

### Döntés
Az MVP csak a következő funkciókat tartalmazza:
- regisztráció és profil
- szituációlista
- egy szituáció részletes oldala
- reakció beküldése
- reakciók olvasása
- egyszerű szavazás
- admin oldal szituációk létrehozására

### Értelmezés
Az MVP célja nem a teljes közösségi ökoszisztéma felépítése, hanem a **magmechanika validálása**.

### Mit jelent ez a gyakorlatban?
Az MVP-ben még nincs:
- klubrendszer
- csapatverseny
- szezonok
- badge-ek és reward rendszer
- bonyolult pontozás
- reputációs súlyozás
- témák / kategóriák UI-s kezelése
- kommentrendszer
- fejlett discovery rendszer
- felhasználói szituációbeküldés
- fizetős funkciók

### MVP fókusz
Az MVP-ben egyetlen kérdést validálunk:

**Akarják-e a felhasználók retorikai szituációkra írt reakciókkal játszani ezt a rendszert?**

---

## 3. Ki gyártja a szituációkat induláskor?

### Döntés
Az MVP-ben **csak admin** hozhat létre szituációt.

### Értelmezés
Induláskor a rendszer nem támaszkodik user-generated scenario modellre. A tartalommag szerkesztett, kontrollált és kézi létrehozású.

### Későbbi bővítési irány
A jövőben más felhasználók is beküldhetnek vagy létrehozhatnak szituációt, de ez feltételekhez köthető, például:
- bizonyos regisztrációs idő
- minimum aktivitás
- minimum reputáció
- moderációs előszűrés
- jóváhagyási folyamat

### MVP-szintű szabály
- csak admin hozhat létre szituációt
- nem admin user ilyen műveletet nem láthat és nem hajthat végre
- a szituációk létrehozása backend oldalon védett művelet

---

## 4. Mennyi induló tartalom kell?

### Döntés
Nincs rögzített minimum darabszám.

### Értelmezés
Az induláshoz technikailag elég akár egyetlen tesztszituáció is.

### Kiegészítés
Két külön szintet kell szétválasztani:

#### A. Technikai validációhoz
- 1 darab szituáció is elég lehet

#### B. Használható zárt bétához
- érdemes több szituációval számolni, hogy ne legyen túl üres az élmény
- ez nem formális MVP-feltétel, hanem gyakorlati minőségi szempont

### MVP-szintű következtetés
A rendszer nem tartalomdarabszámhoz, hanem működő magfolyamathoz kötődik. Az első működő verzió létrejöhet minimális kezdőtartalommal.

---

## 5. Milyen témák domináljanak induláskor?

### Döntés
A témák / kategóriák külön kezelése **nem MVP-funkció**.

### Értelmezés
Az MVP-ben nem építünk külön tematikai rendszert, kategóriaoldalakat vagy szűrőalapú témakezelést.

### Kiegészítés
A második fázisban bevezethető:
- téma
- kategória
- nehézségi szint
- szituációtípus
- editorial címkék

### Technikai javaslat
Az adatmodell előkészítheti a későbbi bővítést, de az MVP-ben ezek:
- vagy egyáltalán nincsenek használva,
- vagy vannak háttérmezőként, de a UI és logika nem épít rájuk.

Javasolt MVP-hozzáállás:
- ha kell, legyen opcionális háttérmező
- de a felhasználói élményben ne jelenjen meg még tematikus rendszer

---

## 6. Az értékelés végső formája

### Döntés
Az MVP-ben az értékelés formája: **like / unlike**

### Pontosított MVP-szabály
Az MVP-ben az `unlike` jelentése:
- **nem negatív szavazat**
- hanem a korábban adott like visszavonása

### Kötelező működési szabályok
- egy felhasználó egy reakciót legfeljebb egyszer like-olhat
- a like visszavonható
- dislike nincs az MVP-ben
- saját reakciót nem lehet like-olni
- a reakciók rangsorolása történhet like-szám alapján

### Mi nincs még az MVP-ben?
- vak értékelés
- többdimenziós pontozás
- reputációs súlyozás
- párbajalapú szavazás
- fejlett ranking-képlet

### Kiegészítés
Az MVP célja itt is a magvalidáció: elég-e egy nagyon egyszerű, könnyen érthető visszajelzési rendszer az alapélményhez?

---

## 7. A termék hangulata és identitása

### Döntés
Az MVP hangulata:
- **intelligens**
- **letisztult**
- **enyhén kompetitív**

### Értelmezés
A termék ne legyen:
- mémes káosz
- cinikus propaganda-játék
- harsány közösségi trollfelület

### MVP identitás
Az alkalmazás induló benyomása inkább legyen:
- stratégiai
- kulturált
- szövegközpontú
- fókuszált
- elegáns, de nem steril

### UX-irány
- kevés zaj
- tiszta vizuális hierarchia
- a szituáció és a reakció legyen a középpontban
- ne fórumérzet domináljon, hanem strukturált játékszituáció

---

## 8. Mi legyen a fő fókusz?

### Döntés
A termék fókusza:

**retorikai szituációkezelés**

### Értelmezés
Csak olyan szituációk kerülnek be, amelyek megoldásához valóban retorikai, kommunikációs vagy meggyőző szövegalkotási készség kell.

### Ez mit zár ki?
A rendszer nem általános fórum és nem bármilyen szabad szöveges játék. Nem cél, hogy bármiről lehessen beszélgetni vagy vitázni.

### MVP-ben előnyben részesített logika
A szituáció:
- röviden érthető legyen
- tényleg szöveges reakciót igényeljen
- ne pusztán véleménykérés legyen
- legyen benne valódi megoldási tér

---

## 9. Jogi-etikai határvonalak

### Döntés
A részletes, teljes moderációs és jogi policy **nem MVP-feladat**.

### De az MVP-ben is kell minimumszint
Az MVP-ben legalább általános szinten rögzíteni kell:
- alap viselkedési elvek
- tiltott tartalom általános körei
- admin moderáció lehetősége

### Minimum moderációs szabályok az MVP-ben
Az MVP-ben legyen lehetőség:
- reakció jelentésére
- admin általi reakcióelrejtésre vagy törlésre
- admin általi szituációelrejtésre vagy törlésre
- felhasználó korlátozására extrém esetben

### Általános tiltott tartalmi körök
Részletes jogi szabálykönyv nélkül is ki lehet mondani, hogy nem megengedett:
- gyűlöletkeltő tartalom
- nyílt zaklatás
- személyeskedő vagy súlyosan sértő tartalom
- nyilvánvalóan káros, fenyegető vagy erőszakos szöveg
- spam vagy teljesen rendszeridegen tartalom

### Kiegészítés
A részletes policy később külön dokumentumban készülhet el, de az MVP nem maradhat teljesen moderációs minimum nélkül.

---

## 10. Indulási stratégia

### Döntés
- Platform: **Android**
- Indulási forma: **zárt béta**
- Monetizáció: **ingyenes**, később is inkább önkéntes támogatásos logika

### Értelmezés
A cél az indulásnál nem a bevételoptimalizálás, hanem a magélmény és a használhatóság validálása.

### Kiegészítés
A zárt béta technikai formáját később még külön rögzíteni kell, de az induló stratégia egyértelmű:
- nem publikus nyitott rajt
- korlátozott tesztelői kör
- korai visszajelzésgyűjtés

### Mi nincs az MVP-ben?
- előfizetés
- prémium fiók
- paywall
- funkciókorlátozás fizetés alapján

---

## 11. Auth minimum pontosítás

Ez nem szerepelt az eredeti válaszok között külön, de az MVP tisztázásához szükséges.

### Javasolt MVP-döntés
Az induló belépési mód legyen egyszerű:
- email + jelszó

### Miért?
Mert ez a legkönnyebben kontrollálható, legegyszerűbben megvalósítható alap.

### Később bővíthető
- Google login
- magic link
- egyéb social auth

### MVP-ben nem szükséges
- anonymous auth
- vendégmód
- túl sok auth-provider

---

## 12. Profil minimum pontosítás

### MVP profil minimális tartalma
- felhasználónév / display name
- opcionális avatar
- alap regisztrációs adatok
- admin státusz háttérmezőként, ha releváns

### Mi nincs még benne?
- fejlett stílusprofil
- badge-ek
- reputációs bontás
- bonyolult statisztika

A profil az MVP-ben azonosítási és alap közösségi jelenlét funkciót ad, nem teljes gamification központ.

---

## 13. Reakció életciklus minimum pontosítás

Ez is szükséges az MVP tiszta értelmezéséhez.

### Javasolt MVP-szabály
- egy felhasználó egy szituációhoz egy reakciót küldhet be
- beküldés után a reakció olvasható a listában
- szerkesztés az MVP-ben **ne legyen**, hogy egyszerű maradjon a működés

### Miért?
A szerkesztés később plusz bonyolultságot hoz:
- verziózás
- like-logika torzulása
- moderációs nehézség

Ezért az MVP-ben jobb a végleges, egyszerű beküldés.

---

## 14. Szituáció minimum szerkezete az MVP-ben

Az MVP-s scenario entitás legalább a következőket tartalmazza:
- cím
- rövid leírás vagy brief
- létrehozó admin azonosítója
- létrehozás ideje
- láthatósági / aktív státusz

Opcionálisan előkészíthető, de még nem használt mezők:
- kategória
- nehézség
- típus

Az MVP-ben a szituáció fő szerepe az, hogy világos, röviden érthető és reakcióra alkalmas legyen.

---

## 15. MVP-ben ténylegesen meglévő modulok

Az eddigi döntések alapján az MVP-ben ezek a modulok szükségesek:

### Kötelező modulok
- Auth
- User Profile
- Scenario
- Submission
- Evaluation
- Admin / Editorial
- Minimum Moderation

### Opcionális, de kis mértékben megjelenő háttérlogika
- Notification minimum
- alap lista- és rendezési logika

### Kifejezetten nem MVP modulok
- Club
- Challenge / Battle
- Reward
- fejlett Ranking / Reputation
- Analytics / Anti-abuse mélyebb verzió
- Comment / Discussion
- Discovery fejlett formája

---

## 16. MVP végső célmondata

Az MVP célja egy olyan zárt bétás, Androidos, Flutter + Supabase alapú alkalmazás elkészítése, amelyben a felhasználók admin által létrehozott retorikai szituációkra rövid reakciókat küldenek be, ezeket elolvashatják, egyszerű like-rendszerrel értékelhetik, és a rendszer már kulturált, letisztult, minimálisan moderált formában működőképes.

---

## 17. Mi marad későbbre?

A következő fázisokban kerülhetnek be:
- témák / kategóriák
- részletesebb pontozás
- vak értékelés
- rangsor és reputáció bővítése
- klubok és csapatok
- challenge-ek és szezonok
- felhasználói szituációbeküldés
- fejlettebb moderációs policy
- támogatási / önkéntes finanszírozási lehetőségek

---

## 18. Rövid összegzés

Az MVP mostani, tisztázott formája tudatosan szűk.

Ez jó döntés.

Nem egy teljes közösségi univerzumot építünk első körben, hanem a legfontosabb magmechanikát:
- érthető szituáció
- reakcióírás
- reakcióolvasás
- egyszerű értékelés
- kontrollált tartalomgyártás
- alapmoderáció

Ha ez működik és van rá valós felhasználói érdeklődés, akkor lehet továbbépíteni a rendszert a mélyebb közösségi és versenyfunkciók felé.

