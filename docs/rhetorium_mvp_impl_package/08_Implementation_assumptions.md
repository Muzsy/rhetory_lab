# Implementációs alapfeltevések

Ezek azok a pontok, amelyeket a csomag rögzített, hogy közvetlenül használható legyen.

## 1. Soft delete / státuszalapú rejtés

MVP-ben az admini "törlés" alapvetően:
- scenario esetén `hidden` vagy `archived`
- submission esetén `hidden` vagy `removed`

Nem hard delete az elsődleges minta.

## 2. Szerkesztés nincs

A submission MVP-ben végleges beküldés.

## 3. Like számlálás

A like szám külön táblából aggregálódik, nem denormalizált oszlopból.

## 4. Admin flag

A role-rendszer MVP-ben egyszerűsített:
- `profiles.is_admin`

Később kiváltható külön role modellel.

## 5. Public profile

A normál user felé ajánlott a `public_profiles` view használata, nem a teljes `profiles` tábla.

## 6. Zárt béta forma

Ez a csomag nem dönti el, hogy a zárt béta:
- Play Store closed testing
- invite-only lista
- vagy más terítés legyen

Ez operatív döntés marad.

## 7. Témák / kategóriák

Nem részei az MVP-nek, még ha az adatmodell később bővíthető is velük.
