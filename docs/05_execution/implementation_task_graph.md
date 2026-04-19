# Implementation Task Graph

## Legend
- [B] blocker
- [D] depends on
- [P] parallelizálható

## T1 Repo bootstrap [B]
- create monorepo root
- create mobile app shell
- create shared packages skeleton
- wire env loading
- wire Supabase client
- DONE feltétel: app buildel és elindul placeholder state-ben

## T2 Theming + navigation shell [D:T1]
- app shell
- route map
- auth gate
- standard page scaffold
- error/loading/empty primitives

## T3 Auth backend + profile provisioning [D:T1]
- email/password auth
- profile table
- signup flow
- login flow
- profile fetch/update minimal

## T4 Auth screens [D:T2,T3]
- splash
- login
- signup
- signed-in redirect

## T5 Scenario schema + read API layer [D:T1]
- scenarios table
- scenario read queries
- active visibility logic

## T6 Scenario list/detail UI [D:T2,T5,T4]
- list screen
- detail screen
- loading/empty/error states

## T7 Submission schema + create flow [D:T5,T4]
- submissions table
- unique constraint user+scenario
- create action
- edit disabled

## T8 Submission UI [D:T6,T7]
- input box
- submit CTA
- validation
- success/error states

## T9 Likes schema + logic [D:T7,T4]
- likes table
- one like per user per submission
- self-like block
- unlike = remove row

## T10 Reactions list + like UI [D:T8,T9]
- submissions list on detail screen
- counts
- like button state
- refresh/update behavior

## T11 Admin role enforcement [D:T3]
- is_admin logic
- shared authz helper

## T12 Admin create scenario backend/UI [D:T11,T5,T2]
- create scenario action
- create screen
- form validation
- admin route guard

## T13 Reports schema + moderation backend [D:T7,T11]
- reports table
- report create action
- hide/unhide submission
- hide/unhide scenario

## T14 Moderation UI [D:T13,T12]
- admin moderation list
- action buttons
- status feedback

## T15 Seeds + smoke routes [D:T12,T14]
- seeded admin
- seeded user
- seeded scenarios
- seeded example submissions

## T16 Acceptance + hardening [D:All core tasks]
- run checklist
- fix blockers
- verify Android manual flow

## Recommended execution bundles
- Bundle A: T1,T2,T3
- Bundle B: T4,T5,T6
- Bundle C: T7,T8,T9,T10
- Bundle D: T11,T12,T13,T14
- Bundle E: T15,T16
