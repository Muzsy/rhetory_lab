# Feature Acceptance Checklist

## Auth
- [ ] user can sign up with email + password
- [ ] profile row is created automatically or transactionally
- [ ] user can log in after signup
- [ ] invalid credentials show controlled error
- [ ] signed-in user is routed past auth screens
- [ ] signed-out user cannot access protected flows

## Profile
- [ ] profile has display_name
- [ ] profile fetch works after login
- [ ] admin flag is readable for authz checks
- [ ] non-admin user is not treated as admin

## Scenario list/detail
- [ ] active scenarios load for signed-in user
- [ ] empty state renders with no crash
- [ ] detail screen opens from list
- [ ] hidden scenario is not shown to normal user
- [ ] admin can still moderate hidden scenario if intended

## Submission
- [ ] user can submit one reaction to one scenario
- [ ] second submission to same scenario is blocked
- [ ] empty submission is blocked
- [ ] successful submission becomes visible in list
- [ ] user cannot edit submission in MVP

## Evaluation
- [ ] user can like someone else’s submission
- [ ] same user cannot duplicate-like same submission
- [ ] user can unlike by removing their like
- [ ] user cannot like own submission
- [ ] like count updates correctly

## Admin scenario create
- [ ] admin-only route is protected
- [ ] admin can create scenario
- [ ] non-admin create attempt fails server-side
- [ ] newly created scenario appears in list if active

## Moderation
- [ ] user can report a submission
- [ ] report stores target and reason
- [ ] admin can view reports
- [ ] admin can hide submission
- [ ] hidden submission disappears from normal user view
- [ ] admin can mark report resolved
- [ ] admin can hide scenario

## UX baseline
- [ ] loading states exist
- [ ] empty states exist
- [ ] error messages are controlled
- [ ] Android back navigation is sane
- [ ] no major dead ends in auth/list/detail flows

## Release-readiness for closed beta
- [ ] seeded admin exists
- [ ] at least one active scenario exists
- [ ] installable Android build is produced
- [ ] smoke-tested on a real device or emulator
