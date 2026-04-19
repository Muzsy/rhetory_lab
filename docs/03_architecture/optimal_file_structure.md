# Retorikai versenyalkalmazás – optimális fájlstruktúra

Ez a dokumentum egy **gyakorlatban is jól használható, moduláris, később is bővíthető fájlstruktúrát** javasol az alkalmazáshoz.

A cél az, hogy a projekt:
- ne képernyők köré, hanem **feature modulok köré** szerveződjön,
- ne folyjon össze egyetlen nagy kódkupaccá,
- később is bővíthető maradjon,
- támogassa az egyéni és klubos játékmódokat,
- és külön tudja kezelni a közös platformréteget, az üzleti logikát, a UI-t és az adminisztrációt.

Ez a javaslat abból indul ki, hogy az alkalmazás **mobil-first**, de később lehet hozzá webes adminfelület vagy akár webes kliens is.

A helyes kiindulópont szerintem egy **moduláris monolit monorepo**.

Ez azt jelenti, hogy:
- egy közös repository van,
- de azon belül különválasztott appok és csomagok vannak,
- a domain logika nem szóródik szét véletlenszerűen,
- és a projekt később is kinőhető.

---

# 1. Magas szintű ajánlás

A legjobb induló szerkezet szerintem ez:

```text
rhetorium/
├─ apps/
├─ packages/
├─ services/
├─ infra/
├─ docs/
├─ scripts/
├─ tools/
├─ .github/
├─ .editorconfig
├─ .gitignore
├─ README.md
├─ workspace.yaml / package.json / melos.yaml / turbo.json
└─ env.example
```

A lényeg:
- **apps/** = futtatható alkalmazások
- **packages/** = közös modulok és domain egységek
- **services/** = háttérfolyamatok vagy backend logika
- **infra/** = deployment, környezet, konfiguráció
- **docs/** = termék- és fejlesztési dokumentáció
- **scripts/** = fejlesztői segédszkriptek
- **tools/** = belső eszközök, generátorok, lint presetek, stb.

---

# 2. Miért monorepo?

Ennél a projektnél a monorepo azért előnyös, mert:
- sok közös domain fog kialakulni,
- ugyanazokat a szabályokat fogja használni a mobilapp, az admin, és esetleg a backend,
- a szituációk, submissionök, ranking logika és klublogika nem másolható szét felelőtlenül több helyre,
- és később is egyszerűbb lesz a közös típusok, sémák, validációk kezelése.

Ha külön repo lenne mindenre, túl hamar jönne a szétcsúszás.

---

# 3. A teljes javasolt gyökérstruktúra

```text
rhetorium/
├─ apps/
│  ├─ mobile_app/
│  ├─ admin_app/
│  └─ web_app/
│
├─ packages/
│  ├─ core/
│  ├─ ui_kit/
│  ├─ design_tokens/
│  ├─ auth/
│  ├─ user_profile/
│  ├─ scenario/
│  ├─ submission/
│  ├─ evaluation/
│  ├─ ranking/
│  ├─ club/
│  ├─ challenge/
│  ├─ reward/
│  ├─ moderation/
│  ├─ notification/
│  ├─ discovery/
│  ├─ search/
│  ├─ analytics/
│  ├─ anti_abuse/
│  ├─ shared_types/
│  ├─ shared_schemas/
│  ├─ api_client/
│  └─ test_helpers/
│
├─ services/
│  ├─ api/
│  ├─ worker/
│  ├─ scheduler/
│  ├─ moderation_worker/
│  └─ notification_worker/
│
├─ infra/
│  ├─ environments/
│  ├─ database/
│  ├─ migrations/
│  ├─ seeds/
│  ├─ deployment/
│  ├─ monitoring/
│  └─ secrets_templates/
│
├─ docs/
│  ├─ product/
│  ├─ architecture/
│  ├─ modules/
│  ├─ api/
│  ├─ moderation/
│  ├─ ranking/
│  ├─ ux/
│  └─ decisions/
│
├─ scripts/
│  ├─ bootstrap/
│  ├─ dev/
│  ├─ release/
│  ├─ data/
│  └─ quality/
│
├─ tools/
│  ├─ generators/
│  ├─ lint/
│  ├─ format/
│  └─ ci/
│
├─ .github/
│  ├─ workflows/
│  ├─ ISSUE_TEMPLATE/
│  └─ PULL_REQUEST_TEMPLATE.md
│
├─ README.md
├─ CONTRIBUTING.md
├─ ARCHITECTURE.md
├─ env.example
└─ workspace config fájlok
```

---

# 4. Az apps/ könyvtár részletes szerepe

Ide kerülnek a **futtatható alkalmazások**.

## 4.1. apps/mobile_app/
Ez a fő fogyasztói alkalmazás.

Ez tartalmazza:
- mobil UI,
- route-ok,
- navigáció,
- platform-specifikus bootstrap,
- képernyő-kompozíciók,
- feature modulok felületbe kötése.

### Példastruktúra
```text
apps/mobile_app/
├─ lib/
│  ├─ app/
│  │  ├─ app.dart
│  │  ├─ bootstrap.dart
│  │  ├─ router/
│  │  ├─ theme/
│  │  ├─ config/
│  │  └─ guards/
│  │
│  ├─ features/
│  │  ├─ auth/
│  │  ├─ onboarding/
│  │  ├─ home/
│  │  ├─ scenario/
│  │  ├─ submission/
│  │  ├─ evaluation/
│  │  ├─ ranking/
│  │  ├─ profile/
│  │  ├─ club/
│  │  ├─ challenge/
│  │  ├─ notifications/
│  │  ├─ search/
│  │  └─ settings/
│  │
│  ├─ composition/
│  │  ├─ home_feed/
│  │  ├─ scenario_detail/
│  │  ├─ club_dashboard/
│  │  └─ profile_summary/
│  │
│  ├─ shared/
│  │  ├─ widgets/
│  │  ├─ layout/
│  │  ├─ extensions/
│  │  ├─ utils/
│  │  └─ constants/
│  │
│  └─ main.dart
│
├─ test/
├─ integration_test/
├─ assets/
└─ pubspec / app config
```

### Nagyon fontos elv
A **features/** itt csak UI-kötés legyen, ne az összes domain logika másolata. A domain lehetőleg package-ekben éljen.

---

## 4.2. apps/admin_app/
Ez a belső vagy moderátori adminfelület.

Ez különösen fontos ennél a projektnél, mert kelleni fog:
- szituáció létrehozás,
- challenge menedzsment,
- moderációs queue,
- jelentések kezelése,
- kiemelések,
- klubfigyelés,
- szezonbeállítás,
- reward és editorial kezelés.

### Példastruktúra
```text
apps/admin_app/
├─ src/
│  ├─ app/
│  ├─ pages/
│  │  ├─ dashboard/
│  │  ├─ scenarios/
│  │  ├─ submissions/
│  │  ├─ reports/
│  │  ├─ clubs/
│  │  ├─ rankings/
│  │  ├─ challenges/
│  │  ├─ rewards/
│  │  └─ users/
│  │
│  ├─ components/
│  ├─ modules/
│  └─ main
│
├─ tests/
└─ config
```

### Miért külön app?
Mert az adminfelület logikája, jogosultsága és UX-e teljesen más, mint a játékos alkalmazásé.

---

## 4.3. apps/web_app/
Ez opcionális. Akkor kell, ha később lesz nyilvános böngészhető webfelület is.

Például:
- publikus toplisták,
- nyilvános kluboldalak,
- olvasható challenge-ek,
- webes belépés és részvétel.

Induláskor nem kötelező.

---

# 5. A packages/ könyvtár: itt van a rendszer gerince

A **packages/** alatt kell lennie a legtöbb moduláris logikának.

Ez a projekt szíve.

A legfontosabb szabály:
**egy package = egy világos felelősség**.

Ne technikai apróságok szerint legyen felvágva, hanem domain határok alapján.

---

# 6. A kötelező packages modulok

## 6.1. packages/core/

Ez a közös alaprendszer.

### Ide kerülhet
- alap error handling,
- result típusok,
- base abstractions,
- common interfaces,
- clock/time helpers,
- id generation helpers,
- environment handling,
- base logging contract.

### Nem ide való
- üzleti logika,
- scenario szabályok,
- ranking képletek.

A core legyen minimális és tiszta.

---

## 6.2. packages/ui_kit/

Közös UI-komponensek.

### Ide kerülhet
- gombok,
- inputok,
- kártyák,
- badge komponensek,
- tab bar,
- modalok,
- empty state,
- loading state,
- toast,
- avatar,
- score pill,
- challenge banner,
- error display.

### Miért külön fontos?
Mert a konzisztens vizuális nyelvet ez tartja össze.

---

## 6.3. packages/design_tokens/

### Ide kerülhet
- színek,
- spacing rendszer,
- typography,
- radius,
- elevation,
- icon mapping,
- motion / animation tokenek.

Ez külön segít abban, hogy a design ne szóródjon szét véletlen konstansokba.

---

## 6.4. packages/auth/

### Felelőssége
- auth modellek,
- auth use case-ek,
- session kezelési szerződések,
- jogosultsági helper logika.

### Tipikus tartalom
```text
packages/auth/
├─ lib/
│  ├─ domain/
│  │  ├─ models/
│  │  ├─ value_objects/
│  │  ├─ policies/
│  │  └─ use_cases/
│  │
│  ├─ data/
│  │  ├─ repositories/
│  │  ├─ datasources/
│  │  └─ mappers/
│  │
│  └─ auth.dart
└─ test/
```

---

## 6.5. packages/user_profile/

### Felelőssége
- profilmodell,
- statisztikák összeillesztése,
- badge információk összefogása,
- profiloldalhoz szükséges domain lekérdezések.

### Fontos
A profil package ne számolja újra a teljes ranking rendszert, hanem más modulokból kapja az aggregált adatot.

---

## 6.6. packages/scenario/

Ez az egyik legfontosabb package.

### Felelőssége
- scenario entitás,
- kategóriák,
- nehézségi szint,
- típusok,
- létrehozási szabályok,
- publikálási állapotok,
- időzítés,
- láthatóság,
- editorial metaadatok.

### Belső struktúra
```text
packages/scenario/
├─ lib/
│  ├─ domain/
│  │  ├─ entities/
│  │  ├─ enums/
│  │  ├─ policies/
│  │  ├─ validators/
│  │  └─ use_cases/
│  │
│  ├─ data/
│  │  ├─ repositories/
│  │  ├─ datasources/
│  │  ├─ dto/
│  │  └─ mappers/
│  │
│  ├─ application/
│  │  ├─ commands/
│  │  ├─ queries/
│  │  └─ services/
│  │
│  └─ scenario.dart
└─ test/
```

---

## 6.7. packages/submission/

### Felelőssége
- reakciók beküldése,
- beküldési szabályok,
- karakterlimit,
- szerkeszthetőség,
- státusz,
- anonimizálási állapot,
- moderációs előállapot.

### Fontos
A submission külön modul legyen, ne a scenario package egyik almappája. Ez két külön domain.

---

## 6.8. packages/evaluation/

Ez a másik kulcspackage.

### Felelőssége
- szavazás,
- összehasonlító értékelés,
- párbaj logika,
- többdimenziós pontozás,
- fairness szabályok,
- értékelési limitek,
- self-vote tiltás,
- anonim értékelési módok.

### Miért legyen különösen tiszta?
Mert ha ez összefolyik a UI-val vagy rankinggal, abból később káosz lesz.

---

## 6.9. packages/ranking/

### Felelőssége
- aggregált pontszámítás,
- user leaderboard,
- challenge leaderboard,
- szezonpontok,
- klubpontok,
- reputációs súlyok,
- helyezéslogika.

### Fontos határ
A ranking package ne fogadjon el „készen kapott UI-score”-okat. Csak hiteles értékelési eseményekből építkezzen.

---

## 6.10. packages/club/

### Felelőssége
- klub entitás,
- tagság,
- szerepkörök,
- belső státusz,
- meghívás,
- csatlakozás,
- klubmetaadatok.

### Nem ide való
- klubcsata eredményszámítás,
- challenge lifecycle,
- reward kiosztás.

Azok külön modulok.

---

## 6.11. packages/challenge/

### Felelőssége
- napi/heti challenge-ek,
- eseménylogika,
- klub vs klub szituációk,
- időkeretek,
- részvételi szabályok,
- event státuszok,
- lezárás,
- reward trigger-ek.

### Miért külön modul?
Mert a scenario egy tartalom. A challenge viszont egy versenyesemény.

---

## 6.12. packages/reward/

### Felelőssége
- badge-ek,
- achievementek,
- streak-ek,
- reward feltételek,
- szezonjutalmak,
- unlock rendszerek.

---

## 6.13. packages/moderation/

Ez a túlélés package-e.

### Felelőssége
- jelentések,
- review queue,
- moderációs döntések,
- target típusok,
- szabálysértés kategóriák,
- action log,
- szankció modellek.

### Különösen fontos
A moderation legyen külön modul, ne admin oldali random segédlogika.

---

## 6.14. packages/notification/

### Felelőssége
- in-app notification modellek,
- push eseménytípusok,
- preference-ek,
- notification routing.

---

## 6.15. packages/discovery/

### Felelőssége
- home feed logika,
- kiemelt elemek,
- ajánlási szabályok,
- trendek,
- személyre szabás későbbi helye.

---

## 6.16. packages/search/

### Felelőssége
- szűrési modellek,
- keresési query objektumok,
- scenario / klub / user keresés logika.

---

## 6.17. packages/analytics/

### Felelőssége
- üzleti események,
- feature usage,
- funnel események,
- retention mérések,
- kísérletek mérési hookjai.

---

## 6.18. packages/anti_abuse/

Ez különösen ajánlott ennél az appnál.

### Felelőssége
- brigádolás gyanú,
- self-boost minták,
- több accountos visszaélés jelei,
- szokatlan szavazási aktivitás,
- védelmi szabályok.

---

## 6.19. packages/shared_types/

### Ide kerülhet
- közös enumok,
- event id-k,
- kis közös contractok,
- publikus modellek.

### Fontos
Ne legyen szemétlerakó. Csak tényleg közös, stabil típusok legyenek itt.

---

## 6.20. packages/shared_schemas/

### Felelőssége
- validációs sémák,
- API input/output contractok,
- request/response struktúrák,
- adatkonverziós sémák.

---

## 6.21. packages/api_client/

### Felelőssége
- közös kliensoldali API hívóréteg,
- endpoint wrapper-ek,
- auth header kezelés,
- retry és error mapping.

---

## 6.22. packages/test_helpers/

### Felelőssége
- fake builder-ek,
- fixture-ek,
- common test data,
- mock factory-k,
- snapshot helper-ek.

Ez sokkal tisztább tesztelést ad.

---

# 7. A services/ könyvtár

A **services/** alatt legyen a háttérrendszer logikai szerkezete.

Nem muszáj rögtön külön deployment egység mindennek, de a szerkezetet érdemes előre tisztán tartani.

## Javaslat
```text
services/
├─ api/
├─ worker/
├─ scheduler/
├─ moderation_worker/
└─ notification_worker/
```

---

## 7.1. services/api/

Ez a fő backend API.

### Példastruktúra
```text
services/api/
├─ src/
│  ├─ app/
│  │  ├─ bootstrap/
│  │  ├─ routes/
│  │  ├─ middlewares/
│  │  ├─ auth/
│  │  └─ config/
│  │
│  ├─ modules/
│  │  ├─ auth/
│  │  ├─ users/
│  │  ├─ scenarios/
│  │  ├─ submissions/
│  │  ├─ evaluations/
│  │  ├─ rankings/
│  │  ├─ clubs/
│  │  ├─ challenges/
│  │  ├─ rewards/
│  │  ├─ moderation/
│  │  ├─ notifications/
│  │  ├─ discovery/
│  │  └─ search/
│  │
│  ├─ database/
│  ├─ events/
│  └─ main
│
├─ tests/
└─ config
```

### Fontos elv
Az API modulok legyenek vékonyak. A nehéz üzleti logika package-ekben vagy domain szinten éljen.

---

## 7.2. services/worker/

### Felelőssége
- ranking újraszámolás,
- challenge lezárás,
- aggregációk,
- feed projection,
- anti-abuse elemzés,
- badge kiosztás,
- statisztikai projection.

---

## 7.3. services/scheduler/

### Felelőssége
- napi challenge nyitás,
- heti challenge lezárás,
- szezonkezdés,
- szezonzárás,
- értesítések időzítése,
- cleanup és archíválás.

---

## 7.4. services/moderation_worker/

### Felelőssége
- automatikus előszűrés,
- queue előkészítés,
- kockázatos tartalmak megjelölése,
- review prioritás számítás.

---

## 7.5. services/notification_worker/

### Felelőssége
- push értesítések kiküldése,
- digest-ek,
- klubesemény üzenetek,
- moderation státusz értesítések.

---

# 8. Az infra/ könyvtár

Itt legyen minden, ami környezet és üzemeltetés.

## Javasolt szerkezet
```text
infra/
├─ environments/
│  ├─ dev/
│  ├─ staging/
│  └─ prod/
│
├─ database/
│  ├─ schema/
│  ├─ policies/
│  ├─ functions/
│  └─ views/
│
├─ migrations/
├─ seeds/
├─ deployment/
├─ monitoring/
└─ secrets_templates/
```

### Miért fontos?
Mert nem jó, ha a DB sémák, deploy scriptek és seedek mindenhol szétszórva vannak.

---

# 9. A docs/ könyvtár ajánlott felépítése

Ez a projekt nem lesz jól kezelhető normális dokumentáció nélkül.

## Javasolt szerkezet
```text
docs/
├─ product/
│  ├─ vision.md
│  ├─ user_flows.md
│  ├─ game_modes.md
│  └─ mvp_scope.md
│
├─ architecture/
│  ├─ system_overview.md
│  ├─ module_boundaries.md
│  ├─ data_flow.md
│  └─ file_structure.md
│
├─ modules/
│  ├─ auth.md
│  ├─ scenario.md
│  ├─ submission.md
│  ├─ evaluation.md
│  ├─ ranking.md
│  ├─ club.md
│  ├─ challenge.md
│  ├─ reward.md
│  ├─ moderation.md
│  └─ discovery.md
│
├─ api/
├─ moderation/
├─ ranking/
├─ ux/
└─ decisions/
   ├─ adr_001_modular_monolith.md
   ├─ adr_002_scenario_submission_split.md
   └─ ...
```

### Miért kell ADR?
Mert később sok döntésnél nem fogjátok tudni, miért lett valami úgy megcsinálva. Az Architecture Decision Record ezt megfogja.

---

# 10. A scripts/ könyvtár

## Javasolt szerkezet
```text
scripts/
├─ bootstrap/
├─ dev/
├─ release/
├─ data/
└─ quality/
```

### Ide kerülhet
- projektindító script,
- lokális env setup,
- seed import,
- dev reset,
- release build,
- lint/test wrapper,
- adatjavító script,
- ranglista vagy challenge maintenance script.

---

# 11. A tools/ könyvtár

Ez opcionális, de később nagyon hasznos.

## Példák
- feature scaffold generator,
- package template generator,
- lint preset,
- CI helper,
- schema diff tool,
- changelog generator.

---

# 12. Az optimális belső package-struktúra mintája

A domain package-eken belül érdemes egységes szerkezetet használni.

## Ajánlott minta
```text
packages/scenario/
├─ lib/
│  ├─ domain/
│  │  ├─ entities/
│  │  ├─ value_objects/
│  │  ├─ enums/
│  │  ├─ policies/
│  │  ├─ services/
│  │  └─ use_cases/
│  │
│  ├─ application/
│  │  ├─ commands/
│  │  ├─ queries/
│  │  ├─ dto/
│  │  └─ facades/
│  │
│  ├─ data/
│  │  ├─ repositories/
│  │  ├─ datasources/
│  │  ├─ mappers/
│  │  └─ models/
│  │
│  └─ scenario.dart
│
└─ test/
   ├─ domain/
   ├─ application/
   └─ data/
```

### Ez miért jó?
Mert:
- a domain szabályok nem folynak bele a data rétegbe,
- a use case-ek külön látszanak,
- tesztelhető a logika,
- és a package-ek szerkezete egységes marad.

---

# 13. Frontend feature-szerkezet a mobile appon belül

A mobil kliensben a feature-kötés így nézhet ki optimálisan:

```text
apps/mobile_app/lib/features/
├─ auth/
│  ├─ screens/
│  ├─ widgets/
│  ├─ controllers/
│  ├─ routes/
│  └─ bindings/
│
├─ scenario/
│  ├─ screens/
│  ├─ widgets/
│  ├─ controllers/
│  ├─ mappers/
│  └─ routes/
│
├─ submission/
├─ evaluation/
├─ ranking/
├─ profile/
├─ club/
├─ challenge/
├─ notifications/
├─ search/
└─ settings/
```

### Fontos különbség
A **mobile_app/lib/features/** nem ugyanaz, mint a **packages/**.

- **packages/** = domain és közös logika
- **mobile_app/lib/features/** = UI-kompozíció és kliensoldali feature-kapcsolás

---

# 14. Mi legyen a composition/ mappában?

Ez egy különösen hasznos ötlet ennél az appnál.

A composition/ alá kerüljenek azok az összetett képernyőszekciók, amelyek több modulból állnak.

### Példák
```text
composition/
├─ home_feed/
├─ scenario_detail/
├─ club_dashboard/
├─ challenge_result/
└─ profile_summary/
```

### Miért jó?
Mert például a scenario detail oldal valójában több modul összerakása:
- scenario header,
- submission editor,
- response list,
- voting section,
- report action,
- challenge state.

Ezt jobb külön kompozíciós rétegben tartani, mint egyetlen brutális screen fájlban.

---

# 15. Mik legyenek a legfontosabb naming szabályok?

## Ajánlott konvenciók
- feature és package nevek legyenek egyes számú domain nevek: `scenario`, `submission`, `ranking`, `club`
- ne legyen vegyes plural/singular káosz
- ugyanaz a domainnév minden rétegben ugyanaz legyen
- ne legyen olyan mappa, hogy `misc`, `helpers2`, `common_stuff`, `new_logic`
- a `shared/` és `common/` mappák legyenek minimálisak, ne szemétlerakók

---

# 16. Mit nem szabad csinálni?

## 16.1. Nem szabad képernyők köré építeni az egész projektet
Például ilyen szerkezet rossz lenne:
```text
screens/
  home_screen.dart
  detail_screen.dart
  profile_screen.dart
  club_screen.dart
```

Ez túl hamar káoszhoz vezet.

## 16.2. Nem szabad egyetlen shared mappába önteni mindent
A túl nagy `shared/` könyvtár szinte mindig kódszemétlerakó lesz.

## 16.3. Nem szabad a ranking logikát a UI-ban tartani
A pontszámképzés mindig központi domain felelősség legyen.

## 16.4. Nem szabad a moderationt utólag hozzáfoldozni
Ennél a projektnél a moderation alapmodul, nem extra.

## 16.5. Nem szabad túl korán sok deployolt mikroszervizre szedni
Kód szinten legyen moduláris, de induláskor maradjon egyszerűen üzemeltethető.

---

# 17. Az induló MVP-hez szükséges minimális fájlstruktúra

Ha nagyon szűken indulnál, ezt elég lenne felhúzni:

```text
rhetorium/
├─ apps/
│  ├─ mobile_app/
│  └─ admin_app/
│
├─ packages/
│  ├─ core/
│  ├─ ui_kit/
│  ├─ auth/
│  ├─ user_profile/
│  ├─ scenario/
│  ├─ submission/
│  ├─ evaluation/
│  ├─ ranking/
│  ├─ moderation/
│  ├─ notification/
│  ├─ shared_types/
│  ├─ shared_schemas/
│  └─ api_client/
│
├─ services/
│  ├─ api/
│  └─ worker/
│
├─ infra/
├─ docs/
├─ scripts/
└─ .github/
```

Ez már elég tiszta, és később bővíthető klubokkal, challenge-ekkel, rewarddal, discoveryvel, anti-abuse modullal.

---

# 18. Az optimális növekedési út a fájlstruktúra szempontjából

## Fázis 1
- mobile_app
- admin_app
- api
- scenario / submission / evaluation / ranking / moderation

## Fázis 2
- reward
- discovery
- search
- analytics

## Fázis 3
- club
- challenge
- anti_abuse
- scheduler

## Fázis 4
- web_app
- fejlettebb worker-ek
- recommendation finomítás
- kísérleti feature package-ek

---

# 19. Saját végkövetkeztetésem

Ennek az alkalmazásnak az optimális fájlstruktúrája szerintem:
- **monorepo alapú**,
- **moduláris monolit szemléletű**,
- **domain package-ek köré épülő**,
- **külön mobil app + külön admin app** felépítésű,
- és úgy van megszervezve, hogy a képernyők ne önmagukban legyenek a rendszer középpontjai, hanem a feature modulokból álljanak össze.

A legfontosabb szerkezeti elv ez:

**nem screen-first, hanem domain-first struktúra kell.**

Vagyis:
- nem az a kérdés, hogy „milyen képernyők vannak?”,
- hanem az, hogy „milyen modulok vannak, és ezekből milyen képernyők épülnek össze?”

Ez a szerkezet adja meg azt a stabilitást, amire ennek az appnak szüksége lesz, főleg a scenario, submission, evaluation, ranking, moderation és később a club/challenge területeken.

