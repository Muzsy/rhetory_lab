# Repo Bootstrap Spec

## 1. Root structure
```text
rhetorium/
├─ apps/
│  └─ mobile_app/
├─ packages/
│  ├─ core/
│  ├─ design_system/
│  ├─ auth/
│  ├─ profile/
│  ├─ scenario/
│  ├─ submission/
│  ├─ evaluation/
│  ├─ moderation/
│  └─ api_client/
├─ supabase/
│  ├─ migrations/
│  ├─ seed/
│  └─ config/
├─ docs/
└─ scripts/
```

## 2. Flutter baseline
- Flutter stable
- one app only in MVP: `apps/mobile_app`
- package imports follow domain names
- no feature code in `shared_misc` buckets
- no giant `helpers.dart`

## 3. State management
Frozen default:
- Riverpod

## 4. Routing
Frozen default:
- go_router

## 5. Form handling
Frozen default:
- simple `Form` + validators
- no heavy form abstraction unless repeated pain appears

## 6. Foldering inside mobile_app
```text
apps/mobile_app/lib/
├─ app/
│  ├─ router/
│  ├─ theme/
│  ├─ bootstrap/
│  └─ guards/
├─ features/
│  ├─ auth/
│  ├─ scenario/
│  ├─ submission/
│  ├─ evaluation/
│  ├─ admin/
│  └─ moderation/
├─ composition/
├─ shared/
└─ main.dart
```

## 7. Package responsibility
- `auth`: sign up / sign in / session / role lookup
- `profile`: profile model, minimal read/update
- `scenario`: scenario queries and create
- `submission`: create and list
- `evaluation`: like/unlike
- `moderation`: report + hide/delete logic
- `api_client`: Supabase wrappers
- `design_system`: spacing, type, components
- `core`: error/result/shared abstractions

## 8. Naming rules
- singular domain names
- snake_case files
- no “new”, “temp”, “final2”
- no screen-first domain leakage into packages

## 9. Secrets/env
Minimum env:
- SUPABASE_URL
- SUPABASE_ANON_KEY

Admin seeding secrets or temporary passwords must not be committed in plaintext.
