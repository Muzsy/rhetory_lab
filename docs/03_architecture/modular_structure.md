# Retorikai versenyalkalmazás – moduláris felépítés és megvalósítás

Ez a dokumentum azt írja le, hogyan érdemes ezt az alkalmazást **modulszerűen felépíteni**, hogy:
- ne egy összefolyó, nehezen karbantartható app legyen,
- a funkciók egymástól jól elválasztott egységek legyenek,
- a fejlesztés fokozatosan, bővíthetően haladhasson,
- az egyes funkciók külön-külön tervezhetők, tesztelhetők és beköthetők legyenek,
- és később új játékmódok, klubrendszer, szezonok vagy extra értékelési logikák úgy kerülhessenek be, hogy ne kelljen újraépíteni az egész rendszert.

A cél nem az, hogy mindenből külön mikroszerviz legyen, hanem az, hogy **a termék logikája modulok mentén legyen szétválasztva**. Induláskor ez leginkább egy **moduláris monolit** legyen, nem túlkorai szétbontással.

---

# 1. Alapelv: moduláris monolitból indulni

## Miért nem kell rögtön szétszedni sok külön backend szolgáltatásra?
Mert az ötlet első verziójánál a legnagyobb kihívás nem az infrastruktúra, hanem:
- a játékszabály,
- a pontozási logika,
- a moderáció,
- az élmény,
- és a közösségi dinamika.

Ha túl korán szétszeded sok apró technikai egységre, abból hamar túltervezett rendszer lesz.

## Ezért az ajánlott indulás:
- **egy közös alkalmazás**, amelyen belül
- **szigorúan elkülönített feature modulok** vannak,
- saját adatmodellel,
- saját üzleti logikával,
- saját UI-résszel,
- és tiszta kapcsolatokkal a többi modul felé.

Tehát:
- kívülről egy app,
- belülről jól szétválasztott funkcionális egységek.

---

# 2. A legfontosabb architektúra-elv

A rendszer felépítését én három nagy rétegre bontanám:

## A. Platform / alapréteg
Ez adja a közös működési alapot.

Ide tartozik:
- autentikáció,
- jogosultságkezelés,
- felhasználói session,
- adatbázis-hozzáférés alaplogika,
- értesítések,
- riportálás,
- audit log,
- közös UI-komponensek,
- keresés,
- admin hozzáférések,
- alap analitika.

## B. Domain / feature modulok
Ez maga a termék lényege.

Ide tartozik:
- szituációk,
- válaszbeküldés,
- szavazás,
- rangsor,
- klubok,
- challenge-ek,
- szezonok,
- moderáció,
- kommentelés, ha lesz,
- jutalmak.

## C. Presentation / felületi bekötés
Ez nem csak képernyőket jelent, hanem azt is, hogyan jelenik meg a modul a teljes appban:
- menüpont,
- feed-kártya,
- részletes oldal,
- profilhoz tartozó blokk,
- kluboldal widget,
- értesítésből nyíló nézet,
- adminpanel nézet.

---

# 3. Fejlesztési alapelv: minden funkció legyen modul

Egy funkció akkor számít valódi modulnak, ha van neki:
- **egyértelmű célja**,
- **saját adatmodellje**,
- **saját üzleti logikája**,
- **saját API-ja vagy szolgáltatásrétege**,
- **saját UI-egységei**,
- **saját állapotkezelése**,
- és **világos kapcsolata a többi modulhoz**.

Nem jó megoldás, ha mindenhol minden mindennel közvetlenül beszél.

---

# 4. A javasolt fő modulok

Az alkalmazást én a következő fő modulokra bontanám.

---

## 4.1. Auth & Identity modul

### Feladata
- regisztráció,
- belépés,
- kijelentkezés,
- session-kezelés,
- email / social login,
- alap felhasználói jogosultságok.

### Miért külön modul?
Mert minden más erre épül, de maga nem tartozik a játéklogikához.

### Adatkörei
- user id,
- auth provider,
- státusz,
- verifikációs állapot,
- tiltás/korlátozás státusza.

### UI részek
- login,
- signup,
- jelszókezelés,
- onboarding első lépések.

### Megvalósítási elv
Ezt nem érdemes egyedi logikával túlbonyolítani. Stabil, egyszerű auth-megoldást kell használni, és erre építeni a belső profilt.

---

## 4.2. User Profile modul

### Feladata
- nyilvános profil,
- avatar,
- bio,
- statisztikák,
- rang,
- badge-ek,
- aktivitási előzmények,
- saját beküldések,
- saját győzelmi mutatók.

### Miért külön modul?
Mert az auth csak az azonosításról szól, a profil pedig már a közösségi és játékbeli identitás.

### Adatkörei
- display name,
- avatar,
- profilleírás,
- reputáció,
- összpont,
- szezonális pont,
- stílusprofil,
- aktivitási mutatók.

### UI részek
- profiloldal,
- mini profilkártya,
- statisztikai blokkok,
- badge lista,
- felhasználói előzményoldal.

### Fontos megjegyzés
A profil modul ne birtokolja a teljes játéklogikát, csak összegyűjtse és megjelenítse a többi modulból érkező eredményeket.

---

## 4.3. Scenario modul

### Feladata
Ez az egyik legfontosabb modul. Itt jönnek létre és itt élnek a szituációk.

### Mit kezel?
- szituáció létrehozása,
- szituáció típusa,
- leírás,
- nehézségi szint,
- kategória,
- nyitási és zárási idő,
- résztvevési szabályok,
- egyéni vagy klubos mód,
- fiktív / anonimizált / valós lezárt eset jelölése,
- kiemelt vagy napi challenge státusz.

### Miért különösen kritikus modul?
Mert ez adja a teljes játék pályáját. Ha ez rosszul van megépítve, az egész app szétesik.

### Adatkörei
- scenario id,
- cím,
- rövid leírás,
- teljes brief,
- típus,
- kategória,
- szabályok,
- pontozási mód,
- státusz,
- visibility,
- creator,
- moderation status.

### UI részek
- szituáció lista,
- szituáció kártya,
- szituáció részletes oldal,
- napi challenge felület,
- admin / szerkesztő létrehozó nézet.

### Megvalósítási elv
A scenario modul legyen teljesen külön kezelve a válaszoktól. A szituáció és a beküldött reakció két külön domain.

---

## 4.4. Submission / Response modul

### Feladata
A felhasználói válaszok, reakciószövegek kezelése.

### Mit kezel?
- válasz beküldése,
- módosítási szabály,
- határidőkezelés,
- verziózás, ha kell,
- státuszok,
- rejtett vagy nyilvános megjelenítés,
- formai limitek,
- esetleges sablonok.

### Adatkörei
- submission id,
- scenario id,
- author id,
- text,
- created at,
- edited at,
- visibility,
- moderation status,
- anonymized flag,
- club association, ha klubos a mód.

### UI részek
- válaszíró editor,
- válaszlista,
- saját válasz megtekintése,
- edit nézet,
- vak párbajnál megjelenő response card.

### Miért kell külön kezelni?
Mert a szituáció és a rá adott reakciók életciklusa eltérő.

---

## 4.5. Evaluation / Voting modul

### Feladata
A beküldött válaszok értékelése.

### Ez a modul kulcsfontosságú
Itt dől el, hogy a termék fair lesz-e vagy sem.

### Mit kezelhet?
- egyszerű upvote / like,
- párbaj alapú összehasonlítás,
- többdimenziós értékelés,
- anonim értékelés,
- értékelői jogosultság,
- saját beküldés kizárása,
- brigádolás elleni korlátok,
- értékelési limit,
- súlyozott pontozás.

### Adatkörei
- vote id,
- evaluator id,
- target submission id,
- scenario id,
- vote type,
- score,
- timestamp,
- weight,
- source context.

### UI részek
- szavazó komponens,
- vak párbaj képernyő,
- összehasonlító nézet,
- pontozási panel,
- szavazás utáni eredményvisszajelzés.

### Nagyon fontos
A pontszámképzés ne közvetlenül a UI-ban történjen. Az értékelés logikája szerveroldali vagy központi domain-szabály legyen.

---

## 4.6. Ranking & Reputation modul

### Feladata
- rangsorok,
- reputáció,
- felhasználói pontszámok,
- szezonális és összesített statisztikák,
- klubpontok,
- toplisták.

### Miért külön modul?
Mert ez nem azonos a szavazással. A voting esemény, a ranking pedig annak feldolgozott, aggregált eredménye.

### Mit kezel?
- összpontszám,
- heti pont,
- havi pont,
- szezon pont,
- megbízhatósági mutató,
- győzelmi arány,
- játékmód-specifikus rangok,
- klubranking.

### UI részek
- leaderboard,
- ranglista-szűrők,
- szezonális toplista,
- profilon belüli helyezés blokk,
- klubranglista.

### Megvalósítási elv
A ranking modul aggregátumokra épüljön, ne mindig élőben számolja újra az egészet.

---

## 4.7. Club / Team modul

### Feladata
- klub létrehozás,
- klubprofil,
- tagkezelés,
- klubszerepkörök,
- klubpontok,
- klubstatisztika,
- klubhoz kötött aktivitások.

### Szerepkörök például
- alap tag,
- klubkapitány,
- klub admin,
- meghívott,
- moderátor.

### Adatkörei
- club id,
- név,
- leírás,
- embléma,
- létrehozó,
- taglista,
- tag státusz,
- klubszint,
- klubpont,
- szezoneredmény.

### UI részek
- klublista,
- kluboldal,
- csatlakozás / meghívás,
- tagnézet,
- belső rangsor,
- klubstatisztika blokkok.

### Fontos határ
A Club modul ne kezelje önmagában a meccslogikát. Az már külön battle/challenge modul feladata.

---

## 4.8. Battle / Challenge modul

### Feladata
Ez kezeli a versenyformákat.

### Mit kezelhet?
- napi challenge,
- heti challenge,
- kieséses forduló,
- klub vs klub csata,
- tematikus event,
- privát meghívásos párbaj,
- szezonhoz kötött események.

### Adatkörei
- challenge id,
- kapcsolódó scenario,
- játékmód,
- résztvevési szabály,
- időkeret,
- állapot,
- eredménystruktúra,
- reward config.

### UI részek
- challenge lista,
- aktív challenge képernyő,
- event detail nézet,
- eredményoldal,
- klubcsata dashboard.

### Miért külön modul?
Mert a szituáció maga még nem versenyformátum. A challenge modul mondja meg, hogy abból milyen játék lesz.

---

## 4.9. Reward / Progression modul

### Feladata
- badge-ek,
- achievementek,
- szintek,
- napi streak,
- jutalmak,
- unlock rendszerek,
- szezonjutalmak.

### Miért kell külön modul?
Mert a jutalomrendszer a retention egyik fő eszköze, és nem jó, ha beleolvad a pontozásba vagy profilba.

### Adatkörei
- achievement id,
- feltétel,
- megszerzés ideje,
- user reward state,
- klubreward state,
- streak counter.

### UI részek
- badge fal,
- értesítő popup,
- haladási csík,
- szezonjutalom nézet,
- profilon belüli eredmények.

---

## 4.10. Moderation modul

### Feladata
Ez az app egyik túlélési modulja.

### Mit kezel?
- jelentések,
- tiltott tartalom,
- review queue,
- automatikus előszűrés,
- szituációk moderálása,
- válaszok moderálása,
- felhasználók korlátozása,
- klubok szankcionálása,
- audit napló.

### Adatkörei
- report id,
- target type,
- target id,
- reporter,
- reason,
- evidence,
- review status,
- moderator action,
- action history.

### UI részek
- jelentés gomb,
- moderation review panel,
- admin queue,
- felhasználói státusz figyelmeztetés,
- döntési előzmény nézet.

### Megvalósítási elv
A moderáció ne utólagos kiegészítő legyen, hanem eleve önálló modul.

---

## 4.11. Notification modul

### Feladata
- push értesítések,
- in-app értesítések,
- challenge emlékeztetők,
- eredményértesítések,
- klubmeghívások,
- moderációs üzenetek,
- reward értesítések.

### Miért külön modul?
Mert majdnem minden feature használni fogja, de egyikhez sem tartozik közvetlenül.

### UI részek
- notification center,
- push preference beállítás,
- értesítésből nyíló deep linkek.

---

## 4.12. Feed / Discovery modul

### Feladata
- mit lásson a felhasználó a kezdőlapon,
- kiemelt szituációk,
- trendelő challenge-ek,
- ajánlott klubok,
- új és népszerű beküldések,
- személyre szabott vagy alap discovery logika.

### Miért külön modul?
Mert a tartalomfelfedezés külön terméklogika. Nem ugyanaz, mint maga a scenario modul.

### UI részek
- home feed,
- discover fül,
- ajánlott kártyák,
- kategória böngészés,
- szűrők.

---

## 4.13. Search & Filter modul

### Feladata
- szituáció keresés,
- felhasználó keresés,
- klub keresés,
- challenge szűrés,
- kategóriák böngészése.

### UI részek
- keresősáv,
- szűrőpanel,
- kategória oldalak,
- gyorskereső.

---

## 4.14. Comment / Discussion modul (opcionális, nem induló kötelező)

### Feladata
- válaszokhoz kapcsolódó beszélgetés,
- szituáció körüli eszmecsere,
- klubon belüli megbeszélés.

### Miért opcionális?
Mert kommentek nélkül is működhet az app, és a kommentrendszer önmagában toxikus terület lehet.

### Javaslat
Induláskor vagy egyáltalán ne legyen, vagy nagyon korlátozott módon legyen.

---

## 4.15. Admin / Editorial modul

### Feladata
- hivatalos szituációk létrehozása,
- kategóriák kezelése,
- kiemelés,
- napi challenge kijelölés,
- szabályrendszer karbantartása,
- szezonkezelés,
- editorial kontroll.

### Miért fontos?
Mert az app induláskor nem támaszkodhat csak user-generated szituációkra. Kell szerkesztett tartalommag.

---

## 4.16. Analytics / Anti-abuse modul

### Feladata
- aktivitásmérés,
- funnel elemzés,
- retention mérés,
- csalásgyanús minták,
- brigádolási minták,
- multiaccount jelzések,
- szokatlan szavazási minták.

### Miért külön modul?
Mert ez nem csak üzleti analitika, hanem a rendszer hitelességének védelme is.

---

# 5. A modulok közötti kapcsolat

A moduláris rendszernél a legfontosabb kérdés nem csak az, hogy mik a modulok, hanem az is, hogy **hogyan beszélnek egymással**.

## Rossz megoldás
Minden modul közvetlenül beleír minden másik adatbázistáblájába és belső logikájába.

## Jó megoldás
Minden modulnak van:
- saját felelősségi köre,
- saját szolgáltatásrétege,
- és világos interfésze.

### Példa kapcsolat
- a Scenario modul létrehoz egy szituációt,
- a Submission modul csak hivatkozik rá,
- az Evaluation modul a submissionöket pontozza,
- a Ranking modul a pontozásból aggregál,
- a Profile modul ezeket csak megjeleníti,
- a Notification modul eseményekből küld üzenetet,
- a Moderation modul bármelyikre rá tud ülni review szinten.

Ez nagyon fontos különbség.

---

# 6. Adatmodell szintű bontás

Minden modulnak legyen saját fő entitása.

## Példa fő entitások
- users
- user_profiles
- scenarios
- submissions
- votes
- rankings
- clubs
- club_members
- challenges
- rewards
- reports
- notifications
- search_index / discovery projections

## Fontos elv
A táblák vagy kollekciók ne csak technikai okból legyenek külön, hanem domain-határok alapján.

---

# 7. UI-szinten hogyan kell bekötni a modulokat?

Itt sok app hibázik. Nem elég hátul modulokra bontani, a felületen is modulárisan kell gondolkodni.

## 7.1. A felület ne képernyő-lista szerint, hanem feature szerint épüljön

Tehát ne így gondolkodj:
- home screen,
- detail screen,
- profile screen,
- club screen.

Hanem így:
- scenario feature,
- submission feature,
- voting feature,
- profile feature,
- club feature.

Ezekből aztán képernyők épülnek.

## 7.2. Egy képernyő több modulból állhat

### Példa: szituáció részletes oldal
Ez valójában több modulból épül össze:
- Scenario header,
- Submission editor,
- Submission list,
- Voting CTA,
- Challenge state,
- Moderation actions,
- Share / report panel.

Tehát a képernyő nem önálló funkció, hanem modulok összeállítása.

## 7.3. A home feed is modul-kompozíció legyen

Például:
- napi challenge kártya,
- trendelő szituáció blokk,
- saját klub aktivitás blokk,
- ajánlott párbaj blokk,
- új badge blokk.

Ez különösen fontos, mert később könnyen cserélhetők vagy sorrendezhetők ezek az egységek.

---

# 8. Állapotkezelés és frontend szerkezet

A frontend oldalon minden nagyobb modulnak legyen:
- saját view modelje vagy state store-ja,
- saját service rétege,
- saját komponenskészlete,
- saját route vagy route-részlete,
- saját tesztjei.

## Példa felosztás frontend oldalon
- feature/scenario/
- feature/submission/
- feature/voting/
- feature/profile/
- feature/club/
- feature/challenge/
- feature/moderation/
- shared/ui/
- shared/domain/
- shared/services/
- core/auth/
- core/navigation/
- core/analytics/

## Miért jó ez?
Mert a fejlesztő pontosan tudja, hova kell nyúlni, és nem lesz minden egyetlen hatalmas képernyőfájlban összekeverve.

---

# 9. Backend oldali szerkezet

Backend oldalon is ugyanez az elv kell.

## Javasolt logikai bontás
- auth service layer
- profile service
- scenario service
- submission service
- voting service
- ranking service
- club service
- challenge service
- reward service
- moderation service
- notification service
- discovery service
- analytics / anti-abuse service

## Fontos
Nem kell ebből rögtön 12 külön deployolt szolgáltatás. Elég, ha kód szinten szét van választva.

---

# 10. Modulok bevezetési sorrendje

Nem szabad mindent egyszerre megépíteni.

## 1. hullám – működő alapjáték
Ezek kellenek legelőször:
- Auth
- User Profile alapverzió
- Scenario
- Submission
- Evaluation alapverzió
- Ranking alapverzió
- Admin / Editorial alapverzió
- Moderation minimum
- Notification minimum

Ez már kiad egy működő első terméket.

## 2. hullám – retention és tisztább élmény
- Feed / Discovery
- Reward / Progression
- vak párbaj mód az Evaluation részen belül
- Search & Filter
- Analytics alapok

## 3. hullám – közösségi mélyítés
- Club modul
- Challenge / Battle modul
- klubhoz kötött ranking
- klubértesítések

## 4. hullám – haladó versenyrendszer
- szezonok
- klubligák
- meghívásos versenyek
- fejlett anti-abuse
- részletesebb reputációs súlyozás

## 5. hullám – opcionális mélyítés
- kommentrendszer
- részletes elemző mód
- tanulási / coaching mód
- extra editorial és curated módok

---

# 11. Mit nem szabad túl korán megépíteni?

A jó moduláris fejlesztés nem azt jelenti, hogy mindent előre lemodellezel.

## Nem szabad túl korán túlkomplikálni:
- túl sok szerepkör,
- túl bonyolult klubhierarchia,
- túl részletes reputációs képlet,
- túl sok játékmód,
- AI-alapú extrák,
- nagyon kifinomult discovery algoritmus,
- teljes komment- és fórumrendszer,
- túl korai mikroszerviz-esítés.

Először a magot kell bizonyítani.

---

# 12. Modulonkénti megvalósítási szabályok

Minden modulra érvényes szabály legyen:

## 12.1. Egy modulnak legyen saját felelőssége
Ne akarjon mindent csinálni.

## 12.2. A modul publikus interfészen keresztül adjon adatot
Ne belső részletekből éljen a többi modul.

## 12.3. A domain-szabályok ne a UI-ban legyenek
Pl. pontszámítás, szavazási korlát, határidőkezelés ne csak kliensoldali szabály legyen.

## 12.4. Legyen modulonként tesztelhető üzleti logika
Ez különösen fontos a voting, ranking, club battle, moderation területen.

## 12.5. Modulonként lehessen feature flaggel be- vagy kikapcsolni funkciókat
Így könnyebb fokozatosan nyitni dolgokat.

---

# 13. A legfontosabb kulcsmodulok, amiket különösen jól kell megcsinálni

Ha ebből az appból komoly termék lesz, akkor három modul minősége döntő lesz:

## 13.1. Scenario modul
Mert ez adja a tartalom minőségét.

## 13.2. Evaluation modul
Mert ez dönti el a fair versenyt.

## 13.3. Moderation modul
Mert ez védi meg a terméket a széteséstől.

Utánuk a negyedik legfontosabb:

## 13.4. Ranking modul
Mert ez adja a státuszérzetet és a hosszabb távú motivációt.

---

# 14. Én hogyan építeném fel a terméket modulárisan, a gyakorlatban?

## Fázis 1 – magtermék
Először csak ezt építeném meg:
- bejelentkezés,
- profil,
- admin által létrehozott szituációk,
- válasz beküldése,
- anonim vagy félig anonim értékelés,
- eredmény és toplista,
- alapmoderáció.

## Fázis 2 – játékosabb rendszer
Utána:
- napi challenge,
- jutalmak,
- jobb feed,
- részletesebb profilstatisztika,
- jobb discovery.

## Fázis 3 – közösségi verseny
Utána:
- klubok,
- klubpontok,
- klubcsaták,
- heti klubesemények,
- szezonkezdés.

## Fázis 4 – finomhangolás és védelem
Végül:
- anti-abuse,
- reputációs súlyozás,
- fejlett moderáció,
- szezonlogika,
- meta és balansz finomítás.

---

# 15. Végkövetkeztetés

Ezt az alkalmazást **nem képernyők alapján**, és nem is „egy nagy közösségi appként” kell megépíteni, hanem **jól szétválasztott domain modulokból**.

A helyes gondolkodásmód szerintem ez:

- **van egy platformréteg**,
- **vannak játékspecifikus feature modulok**,
- **ezekből épülnek össze a képernyők**,
- **minden modulnak saját adatköre és felelőssége van**,
- **és a fejlesztés hullámokban történik, nem mindent egyszerre**.

Ha ezt így építed fel, akkor:
- könnyebb lesz fejleszteni,
- könnyebb lesz bővíteni,
- kisebb eséllyel csúszik szét az app,
- és sokkal kontrolláltabban lehet majd új funkciókat bevezetni.

Az alkalmazás valódi ereje nem az lesz, hogy sok funkció van benne, hanem az, hogy **a funkciók tiszta modulokként, jól összeillesztve működnek**.

