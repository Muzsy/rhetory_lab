# Validációs szabályok és állapotátmenetek — MVP

## 1. Profile

### Validáció
- `display_name`: kötelező, trim után nem üres
- `avatar_url`: opcionális, URL vagy storage path

## 2. Scenario

### Validáció
- `title`: kötelező, nem üres
- `brief`: kötelező, nem üres
- admin only művelet

### Állapotátmenetek
- `draft -> published`
- `published -> hidden`
- `published -> archived`
- `hidden -> published`
- `archived -> published` admin döntés alapján

### Nem engedett
- normál user scenario insert/update

## 3. Submission

### Validáció
- `body`: kötelező, trim után nem üres
- egy user / egy scenario = egy submission
- csak published scenariohoz
- banned user nem küldhet be

### Állapotátmenetek
- létrehozáskor: `active`
- admin moderációval: `active -> hidden`
- admin moderációval: `active -> removed`

### Nem engedett
- user edit MVP-ben
- user delete MVP-ben

## 4. Like

### Validáció
- nem lehet self-like
- csak active submission like-olható
- csak published scenario submissionje like-olható
- egy user ugyanazt a submissiont egyszer like-olhatja

### Állapotlogika
- like = rekord létrehozása
- unlike = rekord törlése

## 5. Report

### Validáció
- `target_type` csak `scenario` vagy `submission`
- `reason_code` az előre rögzített listából
- reporter az auth user
- banned user nem küld reportot

### Állapotátmenetek
- `open -> reviewed`
- `open -> resolved`
- `open -> dismissed`
- `reviewed -> resolved`
- `reviewed -> dismissed`

## 6. Ban logika

Ha `profiles.is_banned = true`, akkor:
- sign in technikailag történhet, de app oldali használat korlátozott
- submission insert tiltott
- like insert tiltott
- report insert tiltott
- admin kézzel feloldhatja

## 7. UI oldali állapotlogika minimum

### Scenario detail
- ha nincs saját submission: editor látszik
- ha már van saját submission: editor helyett saját reakció nézet látszik
- hidden/archived scenario esetén normál usernek ne jelenjen meg aktív részvételi felület

### Submission feed
- csak active submissionök látszanak normál usernek
- admin külön nézetben láthat hidden/removed elemeket is
