# Open Points — Frozen Defaults

Ez a fájl azokat a technikai részleteket fagyasztja be, amelyekről még nem született külön alapítói döntés, de az autonóm kivitelezéshez most kell egy default.

## 1. Auth mode
Frozen default:
- email + password only

## 2. Avatar
Frozen default:
- optional avatar_url field exists
- no upload flow in MVP
- placeholder avatar in UI

## 3. Scenario fields
Frozen default:
- title + brief only
- no categories in UI
- no difficulty in UI

## 4. Submission editing
Frozen default:
- disabled in MVP

## 5. Delete semantics
Frozen default:
- hide preferred over delete for moderation
- delete only as admin maintenance fallback

## 6. Report reason
Frozen default:
- optional free-text reason
- no complex reason taxonomy in MVP

## 7. Submission ordering
Frozen default:
- order by like_count desc, then created_at asc

## 8. Profile scope
Frozen default:
- minimal profile only
- no stats page requirements

## 9. Notification logic
Frozen default:
- no full notification center in MVP
- only leave technical space for later expansion

## 10. State management / routing
Frozen defaults:
- Riverpod
- go_router

## 11. UI language
Frozen default:
- Hungarian product copy for MVP unless repo rules later specify otherwise

## 12. Admin tooling
Frozen default:
- admin UI lives inside the same Android app
- no separate admin web app in MVP
