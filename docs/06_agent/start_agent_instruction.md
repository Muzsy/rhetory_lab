Feladat: készíts működő MVP állapotot a jelenlegi repo alapján. Ne tágítsd a scope-ot, ne találj ki új feature-öket, és ne módosítsd a befagyasztott termékdöntéseket.

Kötelező source of truth dokumentumok, ebben a sorrendben:
1. docs/00_overview/frozen_product_decisions.md
2. docs/01_product/mvp_product_spec.md
3. docs/03_architecture/technical_architecture_repo_spec.md
4. docs/04_data_backend/strict_data_model_spec.md
5. docs/04_data_backend/strict_rls_spec.md
6. docs/04_data_backend/api_contracts_backend_actions.md
7. docs/04_data_backend/validation_state_transitions.md
8. docs/05_execution/mvp_execution_plan.md
9. docs/05_execution/feature_acceptance_checklist.md
10. docs/05_execution/definition_of_done.md
11. docs/06_agent/agent_master_prompt.md
12. docs/06_agent/runner_prompt.md
13. docs/06_agent/goal.yaml

Munkaszabályok:
- Csak az MVP-t építsd meg.
- Android + Flutter + Supabase stackkel dolgozz.
- Ne nyúlj a docs/09_archive tartalmához.
- Ne hozz be klubokat, challenge-eket, reputációs rendszert, kategóriákat, prémium funkciókat vagy más nem-MVP elemet.
- A .env.local létezik a repo gyökerében. Használd a benne lévő környezeti változókat, de ne írd ki a titkokat, ne másold őket dokumentumba, és ne commitold őket.
- Az admin auth user manuálisan létrejöttnek tekintendő; a kódban és adatmodellben a profiles.is_admin mező alapján kezeld az admin jogosultságot.
- Backendben kizárólag a strict data backend dokumentumok szerint dolgozz. Ha bármely más dokumentum eltér, a strict backend dokumentumok az elsődlegesek.
- Haladj vertikális szeletekben: bootstrap → auth/profile → scenario read flow → submission → like/unlike → admin scenario create → minimum moderation.
- Minden szelet után futtass verify lépést, javítsd a hibákat, és csak utána menj tovább.
- Ne állj meg tervezési kérdésekkel, ha a source of truth alapján eldönthető valami.
- Ha ellentmondást találsz, a munkát ne terjeszd ki; a strict backend + frozen product decisions szerint dönts, és ezt röviden dokumentáld.
- Minden módosítást a meglévő repo struktúrájába illesztve készíts el.
- A végén adj rövid összefoglalót: mi készült el, mi fut, mi nem kész, milyen parancsokkal ellenőrizhető.

Elvárt MVP funkciók:
- regisztráció / bejelentkezés
- alap profil
- szituációlista
- szituáció részletes oldal
- reakció beküldése
- reakciók olvasása
- like visszavonható like/unlike logikával
- saját reakció nem like-olható
- admin szituáció létrehozás
- minimum report/moderation alap

Most kezdd el a munkát a repo felmérésével, majd készítsd el az MVP-t a fenti szabályok szerint.