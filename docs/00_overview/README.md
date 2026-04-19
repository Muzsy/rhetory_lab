# Rhetorium MVP – Dokumentációs csomag

Ez a mappa a Rhetorium retorikai versenyalkalmazás MVP fázisának teljes dokumentációját tartalmazza.

## Mappastruktúra

```
docs/
├── 00_overview/          # Kezdőpont – áttekintés és döntések
├── 01_product/           # Termék specifikációk
├── 02_ux_ui/             # UI/UX tervek
├── 03_architecture/      # Technikai architektúra
├── 04_data_backend/      # Adatmodell és backend
├── 05_execution/         # Végrehajtási tervek
├── 06_agent/             # Agent konfigurációk
├── 07_testing/           # Tesztelési dokumentumok (DRAFT)
├── 08_source_materials/  # Eredeti forrásanyagok
└── 09_archive/           # Archivált fájlok
```

## Belépési pont – javasolt sorrend

Ha újonc vagy a projektben, ezt a sorrendet ajánljuk:

1. **[frozen_product_decisions.md](frozen_product_decisions.md)** – A befagyasztott MVP döntések összefoglalója
2. **[mvp_product_spec.md](../01_product/mvp_product_spec.md)** – Mit csinál az MVP, és mit nem
3. **[technical_architecture_repo_spec.md](../03_architecture/technical_architecture_repo_spec.md)** – Technológiai stack és repo felépítés
4. **[strict_data_model_spec.md](../04_data_backend/strict_data_model_spec.md)** – Adatmodell részletesen
5. **[mvp_execution_plan.md](../05_execution/mvp_execution_plan.md)** – Végrehajtási fázisok
6. **[agent_master_prompt.md](../06_agent/agent_master_prompt.md)** – Agent utasítások

## Legfontosabb fájlok

| Fájl | Leírás |
|------|--------|
| `frozen_product_decisions.md` | Befagyasztott döntések – ne változtasd meg könnyen |
| `mvp_product_spec.md` | Termék vízió és scope |
| `strict_data_model_spec.md` | Teljes adatmodell |
| `strict_rls_spec.md` | Supabase RLS szabályok |
| `mvp_execution_plan.md` | 8 fázisos végrehajtási terv |
| `schema_draft.sql` | PostgreSQL schema |

## MVP befejezési feltételek

Lásd: [definition_of_done.md](../05_execution/definition_of_done.md)

## Tiltott bővítések MVP-ben

- Klubok, csapatok
- Challenge-ek, szezonok
- Badge-ek, reward rendszer
- Kommentrendszer
- Dislike vagy többtényezős pontozás
- Témák/kategóriák UI kezelése
- Fizetős funkciók