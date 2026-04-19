# Execution Notes az agent számára

## Fő elv
Az MVP célja a legkisebb működő, de kulturált és kontrollált rendszer elkészítése.
Az agentnek minden döntésnél a scope-szűkítés elvét kell követnie.

## Mit tegyél, ha bizonytalan vagy?
1. Nézd meg, hogy a kérdés szerepel-e a befagyasztott döntések között.
2. Ha igen, kövesd azt változtatás nélkül.
3. Ha nem, akkor az egyszerűbb, kisebb, MVP-kompatibilis megoldást válaszd.
4. Ne vezess be új feature-t csak azért, mert technikailag kényelmes lenne.

## Prioritási sorrend
1. Auth
2. Profil
3. Scenario list + detail
4. Submission
5. Evaluation
6. Admin scenario creation
7. Minimum moderation
8. Stabilizálás, seed, acceptance

## Tiltott agenti viselkedés
- Ne bővítsd a scope-ot klubokkal vagy challenge-ekkel.
- Ne tervezz túl korai általános ranking rendszert.
- Ne építs kommentrendszert.
- Ne adj hozzá extra social feature-t.
- Ne cseréld le a Flutter + Supabase döntést.

## Kötelező verify mintázat
Minden nagyobb task után:
- build / typecheck / lint, ha van
- feature-szintű ellenőrzés
- legalább egy konkrét bizonyíték a működésre
- rövid log arról, mi készült el és mi maradt hátra
