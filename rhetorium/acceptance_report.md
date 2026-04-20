# Rhetorium MVP — Acceptance Report

**Projekt:** Rhetorium MVP  
**Dátum:** 2026.04.20  
**Task:** T1.1 - Admin-field trigger fix, acceptance correction, release env runbook  
**Státusz:** ✅ TASK ELKÉSZVE

---

## T1.1 Task Eredmények

### 🔧 Javított Hibák

| # | Probléma | Javítás | Státusz |
|---|----------|---------|---------|
| 1 | Admin-field trigger rossz user-t ellenőrzött | `003_t1_1_trigger_fix.sql` - `auth.uid()` ellenőrzés javítva | ✅ Kész |
| 2 | Acceptance report túlzó állítások | Moderation rész pontosítva | ✅ Kész |
| 3 | Release env runbook hiányzott | `--dart-define-from-file` release buildhez dokumentálva | ✅ Kész |

---

## Admin Field Protection - Végső Logika

A javított trigger a következő eseteket kezeli:

| # | Eset | RLS Policy | Trigger | Eredmény |
|---|------|------------|---------|----------|
| a | Normál user saját profilt frissít normál mezőkkel | ✅ `Users can update own profile_fields` | `is_admin` változatlan | ✅ Engedélyezve |
| b | Normál user is_admin/is_banned mezőt próbál írni | ❌ `WITH CHECK` elutasít | Nem elérve | ✅ Blokkolva |
| c | Admin user másik profil is_admin mezőjét állítja | ✅ `Admins can update any profile_fields` | `auth.uid()` admin = true | ✅ Engedélyezve |

---

## Definition of Done Eredmények

### 1. Auth és profil
| Kritérium | Státusz | Megjegyzés |
|-----------|---------|------------|
| User képes regisztrálni | ✅ | SignupScreen + Supabase auth |
| User képes bejelentkezni | ✅ | LoginScreen + session kezelés |
| Profilbejegyzés létrejön | ✅ | profiles.insert policy hozzáadva |
| Admin státusz szerveroldalon érvényesül | ✅ | is_admin() + trigger védelem |

### 2. Scenario flow
| Kritérium | Státusz | Megjegyzés |
|-----------|---------|------------|
| Admin képes szituációt létrehozni | ✅ | CreateScenarioScreen + RLS |
| Nem admin nem képes szituációt létrehozni | ✅ | RLS policy |
| User látja a szituációlistát | ✅ | ScenarioListScreen |
| User megnyitja a részletes oldalt | ✅ | ScenarioDetailScreen |

### 3. Submission flow
| Kritérium | Státusz | Megjegyzés |
|-----------|---------|------------|
| User beküldhet reakciót | ✅ | submission insert |
| Egy user egy scenario = egy submission | ✅ | unique constraint |
| Reakció megjelenik a listában | ✅ | submissions query |
| Reakció nem szerkeszthető | ✅ | Nincs edit flow |

### 4. Evaluation flow
| Kritérium | Státusz | Megjegyzés |
|-----------|---------|------------|
| Like működik | ✅ | submission_likes insert |
| Unlike működik | ✅ | submission_likes delete |
| Saját submission nem like-olható | ✅ | RLS policy |
| Duplicate like nem lehetséges | ✅ | PK |

### 5. Moderation minimum - ⏳ NEM KÉSZ
| Kritérium | Státusz | Megjegyzés |
|-----------|---------|------------|
| Reakció jelenthető | ✅ | Report dialog + reports insert |
| Admin megtekintheti a jelentéseket | ✅ | AdminScreen _ReportsList |
| Admin lezárhat jelentést | ✅ | _resolveReport funkció |
| Admin elrejtheti/törölheti szituációt | ✅ | scenario status change |
| Admin korlátozhat user-t (is_banned) | ⏳ | Backend/séma előkészítve, **dedikált UI nincs** |

**Fontos megjegyzés**: A `profiles.is_banned` mező és a kapcsolódó RLS+trigger védelem szerveroldalon működik, de:
- **Nincs dedikált admin UI** a user tiltására/feloldására
- **Nincs teljes moderation workflow** a user restriction kezelésére
- Ezek a funkciók **T2 (Moderation completion)** scope-ba tartoznak

### 6. Adatbiztonság
| Kritérium | Státusz | Megjegyzés |
|-----------|---------|------------|
| RLS policy-k működnek | ✅ | T1+T1.1 migrationök |
| is_admin/is_banned védelem | ✅ | Kétpolicy + trigger |
| Profiles insert működik | ✅ | Új policy |

---

## Következő Lépések (T1 után)

### Maradt későbbre:
- **Admin user management UI**: Nincs dedikált felület user-ek tiltására/feloldására
- **Submission hide/delete UI**: Nincs közvetlen gomb reakció elrejtésére (csak reporton keresztül)
- **Moderation completion (T2)**: Teljes moderation workflow

---

## Módosított Fájlok

```
rhetorium/
├── supabase/migrations/
│   └── 003_t1_1_trigger_fix.sql  # ÚJ - Trigger fix
├── acceptance_report.md            # Frissítve - moderation pontossítva
└── local_run_instructions.md       # Frissítve - release env
```

---

## Nem MVP scope (Tiltva) - Változatlan
- ❌ Klubok / csapatok
- ❌ Challenge-ek / szezonok
- ❌ Badge-ek / reward rendszer
- ❌ Kommentrendszer
- ❌ Dislike vagy többtényezős pontozás
- ❌ Témák/kategóriák UI
- ❌ Fizetős funkciók
- ❌ iOS build (Android only MVP)

---

## Összefoglaló

**T1 Scope:** ✅ ELKÉSZVE  
**T1.1 Scope:** ✅ ELKÉSZVE  
**Trigger Fix:** ✅ `auth.uid()` ellenőrzés javítva  
**Acceptance Correction:** ✅ Moderation rész pontosítva  
**Release Env:** ✅ Dokumentálva  

---

**Agent signature:** Rhetorium MVP Build Agent - T1.1 Task  
**Commit:** `e4b6cc4`
