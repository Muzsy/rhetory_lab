# Technikai architektúra és repo spec

## 1. Fő elv
Flutter monorepo + Supabase backend + moduláris monolit szemlélet.

## 2. Javasolt gyökérstruktúra
```text
rhetorium/
├─ apps/
│  ├─ mobile_app/
│  └─ admin_app/        # lehet kezdetben közös appon belüli admin felület is
├─ packages/
│  ├─ core/
│  ├─ ui_kit/
│  ├─ auth/
│  ├─ user_profile/
│  ├─ scenario/
│  ├─ submission/
│  ├─ evaluation/
│  ├─ moderation/
│  ├─ api_client/
│  └─ shared_types/
├─ services/
│  └─ supabase/
├─ docs/
└─ infra/
```

## 3. Mobile app oldali feature szerkezet
```text
apps/mobile_app/lib/
├─ app/
├─ features/
│  ├─ auth/
│  ├─ profile/
│  ├─ scenarios/
│  ├─ submissions/
│  ├─ evaluation/
│  ├─ admin/
│  └─ moderation/
├─ composition/
├─ shared/
└─ main.dart
```

## 4. Modulhatár elv
- domain logika package-ekben éljen
- UI-kötés a mobile_app feature szinten történjen
- ranking logika ne a widgetekben legyen
- admin jogosultság ne csak UI-ban dőljön el

## 5. Supabase oldal
- auth
- postgres
- storage opcionálisan avatarhoz
- RLS minden táblán

## 6. Naming szabályok
- domain-first elnevezés
- nincs `misc`, `helpers2`, `common_stuff`
- minden modul egyértelmű felelősséggel él

## 7. MVP egyszerűsítés
Lehet kezdetben külön admin_app helyett ugyanabban a mobile appban role-alapú admin képernyő.
