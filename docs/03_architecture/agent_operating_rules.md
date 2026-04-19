# Agent Operating Rules

## 1. Source of truth order
1. Frozen MVP decisions
2. Security and authorization rules
3. This delivery pack
4. Existing repository code
5. Agent preference

## 2. Behavior under uncertainty
If multiple technically valid options exist, choose the one that:
- keeps MVP smaller,
- is easier to test,
- is easier to secure,
- and does not widen future migration pain.

## 3. Forbidden self-expansions
The agent must not autonomously add:
- clubs
- challenges
- comments
- advanced ranking
- themes/categories in UI
- iOS/web deliverables
- payment/donation flows
- AI-generated scenario creation

## 4. Required working style
- implement one vertical slice at a time
- after each slice, run smoke-level verification
- prefer clear code over abstraction-heavy code
- keep UI clean and sparse
- put domain rules outside widgets

## 5. When to stop and surface a blocker
Surface blocker instead of guessing when:
- auth security is ambiguous
- RLS could expose or corrupt data
- deletion semantics are unclear and destructive
- hidden vs deleted content behavior conflicts with moderation expectations
- repository constraints prevent safe implementation

## 6. Acceptance mindset
“Compiles” is not enough.
The agent must verify:
- route works
- mutation works
- state refresh works
- permissions actually hold
- hidden content disappears where expected
