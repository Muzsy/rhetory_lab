# Rhetorium MVP — Agent Delivery Pack

Ez a csomag a már lezárt MVP-döntésekre épülő, autonóm kivitelezésre szánt dokumentumkészlet.

## Cél
Egy autonóm agent úgy tudjon Flutter + Supabase alapon működő MVP-t elkészíteni, hogy:
- ne lépjen túl az MVP scope-on,
- ne találjon ki új funkciókat,
- tisztán értse a végrehajtási sorrendet,
- legyen migration/seed alapja,
- és egyértelmű acceptance feltételek alapján tudjon haladni.

## A csomag tartalma
- 01_mvp_execution_plan.md
- 02_implementation_task_graph.md
- 03_repo_bootstrap_spec.md
- 04_screen_spec.md
- 05_agent_operating_rules.md
- 06_feature_acceptance_checklist.md
- 07_migration_seed_pack.md
- 08_local_runbook.md
- 09_open_points_frozen_defaults.md

## Forrás-igazság
A csomag a korábban lezárt döntéseket tekinti source of truth-nak:
- Flutter monorepo + Supabase
- Android-first, zárt béta, ingyenes
- MVP: auth/profil, szituációlista, szituáció részletező, reakció beküldés/olvasás, like/unlike, admin scenario creation
- MVP-ben csak admin hozhat létre szituációt
- témák, klubok, challenge-ek, bonyolult ranking nincs az MVP-ben
