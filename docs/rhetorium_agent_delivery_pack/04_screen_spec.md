# Screen Spec

## 1. Splash
Purpose:
- bootstrap session
- redirect to login or scenario list

States:
- loading
- auth present
- no auth

## 2. Login
Fields:
- email
- password

Actions:
- login
- navigate to signup

Errors:
- invalid credentials
- network error
- generic auth failure

## 3. Signup
Fields:
- email
- password
- confirm password
- display name

Actions:
- create account
- navigate to login

Validation:
- email format
- password minimum length
- match confirm password
- non-empty display name

## 4. Scenario list
Contents:
- page title
- list of active scenarios
- item shows title + short brief
- optional create button only for admins

States:
- loading
- empty: no scenarios yet
- error

Interaction:
- tap item -> detail screen

## 5. Scenario detail
Contents:
- title
- brief/body
- reaction composer if user has not submitted
- “already submitted” state if submission exists
- reactions list
- like counts
- report action on reactions

Reaction list item:
- display name
- reaction text
- created time
- like count
- like/unlike CTA
- report CTA
- own reaction cannot be liked

States:
- loading
- no reactions yet
- no own submission yet / already submitted

## 6. Admin create scenario
Visible only to admin.

Fields:
- title
- brief/body
- active toggle default true

Validation:
- title required
- brief required
- trimmed text only

Actions:
- save
- cancel

## 7. Admin moderation
Visible only to admin.

Sections:
- reported submissions
- reported scenarios (optional if exists)
- quick actions

Per report row:
- target info
- reason
- reporter count or reporter identity
- hide target
- unhide target
- delete target if needed
- mark resolved

## 8. Profile
Minimal MVP profile:
- display name
- email (if shown, only own account)
- optional avatar placeholder
- maybe “admin” badge only if useful for testing

Do not build stats-heavy gamification here in MVP.
