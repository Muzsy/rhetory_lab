# Rhetorium MVP — implementációközeli technikai csomag

Ez a csomag az MVP-hez tartozó három legtechnikaibb területet konkretizálja:

- adatmodell
- Supabase RLS és jogosultságok
- API / backend műveletek és állapotátmenetek

A csomag célja, hogy a korábban lezárt MVP-döntéseket közvetlenül implementálható formába fordítsa.

## Tartalom
- `01_Strict_data_model_spec.md`
- `02_Strict_RLS_spec.md`
- `03_API_contracts_and_backend_actions.md`
- `04_Validation_and_state_transitions.md`
- `05_schema_draft.sql`
- `06_rls_policies_draft.sql`
- `07_queries_and_views_draft.sql`
- `08_Implementation_assumptions.md`

## Fő alapelvek
- Flutter monorepo + Supabase
- Android-only zárt béta MVP
- admin hoz létre szituációt
- egy user egy szituációhoz egy reakciót küldhet be
- értékelés: like / like visszavonása
- dislike nincs
- saját reakciót nem lehet like-olni
- minimális moderáció van már MVP-ben

## Szándékosan egyszerűsített pontok
- témák / kategóriák nem részei az MVP-nek
- fejlett reputáció és rangsor nincs
- klubok, challenge-ek, reward rendszer nincs
- fizetési logika nincs
