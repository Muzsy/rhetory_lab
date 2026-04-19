# Local Runbook

## 1. Prerequisites
- Flutter SDK installed
- Dart bundled with Flutter
- Android toolchain or emulator
- Supabase CLI
- local or remote Supabase project credentials

## 2. Environment
Create app env values for:
- SUPABASE_URL
- SUPABASE_ANON_KEY

Optional for local tooling:
- project ref if Supabase CLI uses linked project

## 3. First-time setup
1. install Flutter dependencies
2. install package dependencies in monorepo
3. configure Supabase env
4. run migrations
5. run seeds
6. start app on Android emulator/device

## 4. Recommended command groups
Because exact package manager is not frozen here, the repo must expose stable wrapper commands, for example:
- bootstrap
- test
- lint
- run:android
- supabase:reset
- seed:dev

## 5. Smoke test sequence
1. launch app
2. sign up normal user
3. verify scenario list visible
4. open scenario detail
5. submit reaction
6. like another reaction
7. sign in as admin
8. create scenario
9. report a submission
10. resolve report / hide submission

## 6. Failure triage order
1. auth/session
2. profile provisioning
3. scenario reads
4. submission writes
5. like mutations
6. admin authz
7. moderation authz

## 7. Closed beta prep
Before a beta build:
- clean seeded junk if needed
- ensure at least one active scenario exists
- verify admin account access
- verify no debug-only UI leaks into release
