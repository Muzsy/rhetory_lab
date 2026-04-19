# Rhetorium MVP — Agent Execution Pack

Ez a csomag egy autonóm agent számára készült, hogy a már lezárt MVP-döntések alapján önállóan, kontrolláltan és ellenőrizhetően fel tudja építeni a működő MVP-t.

## Csomag tartalma

- `agent_master_prompt.md` — a fő, hosszú futásra alkalmas végrehajtási prompt
- `goal.yaml` — strukturált cél-, scope-, task- és verify-spec
- `runner_prompt.md` — rövidebb indító prompt, ami a YAML-re és a master promptra hivatkozik
- `frozen_product_decisions.md` — a lezárt MVP-döntések befagyasztott listája
- `definition_of_done.md` — mikor tekinthető késznek az MVP
- `execution_notes.md` — futási és döntési megjegyzések az agent számára

## Használati sorrend

1. Először az agent olvassa el a `frozen_product_decisions.md` fájlt.
2. Utána olvassa el az `agent_master_prompt.md` fájlt.
3. Ezután töltse be a `goal.yaml` fájlt, és a benne lévő task-sorrend szerint haladjon.
4. A `runner_prompt.md` használható rövid indító promptként olyan környezetben, ahol egyetlen indító üzenettel kell elstartolni a munkát.

## Fontos

Ez a csomag kifejezetten MVP-re készült.
Az agent nem bővítheti ki saját döntéssel a scope-ot klubokra, challenge-ekre, bonyolult rankingra, gamificationre vagy mélyebb discovery rendszerre.
