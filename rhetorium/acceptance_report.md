# Rhetorium MVP — Acceptance Report

**Projekt:** Rhetorium MVP  
**Dátum:** 2026.04.20  
**Task:** T2.1 - Moderation blockers fix  
**Státusz:** ✅ TASK ELKÉSZVE

---

## T2.1 Task Eredmények

### 🔧 Javított Hibák

| # | Probléma | Megoldás | Státusz |
|---|----------|---------|---------|
| 1 | Admin nem látott minden usert | `Admins can view all profiles` RLS policy | ✅ |
| 2 | Admin nem látott hidden/removed submissiont | `View submissions based on role` RLS policy | ✅ |
| 3 | Report dialogból nem frissült a report státusza | `resolveReportId` paraméter + auto-resolve | ✅ |
| 4 | `unhide` nem volt az action_type check-ben | Migration 004 hozzáadva | ✅ |

---

## Migration 004 - T2.1 Fix

### Admin SELECT Policy-k
```sql
-- Profiles: admin láthatja az összes profilt
CREATE POLICY "Admins can view all profiles" ON public.profiles FOR SELECT
USING (exists (select 1 from public.profiles where id = auth.uid() and is_admin = true));

-- Submissions: admin látja az összes submissiont, user csak active-ot
CREATE POLICY "View submissions based on role" ON public.submissions FOR SELECT
USING (
  exists (select 1 from public.profiles where id = auth.uid() and is_admin = true)
  OR (status = 'active' AND exists (select 1 from public.scenarios where id = scenario_id and status = 'published'))
);
```

### Moderation Events Action Types
```sql
-- 'unhide' hozzáadva az engedélyezett action_type-okhoz
CHECK (action_type in ('hide', 'remove', 'unhide', 'archive', 'ban_user', 'unban_user', 'resolve_report', 'dismiss_report'))
```

---

## Moderation Events Teljes Lista

| Action Type | Leírás |
|-------------|--------|
| `hide` | Tartalom elrejtése |
| `remove` | Tartalom eltávolítása |
| `unhide` | Tartalom visszaállítása |
| `archive` | Szituáció archiválása |
| `ban_user` | User tiltása |
| `unban_user` | User feloldása |
| `resolve_report` | Jelentés elfogadva |
| `dismiss_report` | Jelentés elutasítva |

---

## Admin Moderation Flow

### Report → Moderation konzisztencia
Amikor admin a report dialogból moderál egy submissiont:
1. Submission státusza változik (hide/remove)
2. Report automatikusan `resolved` státuszra vált
3. `handled_by` és `handled_at` kitöltődik
4. Moderation event logolódik submission és report actionre is

---

## Definition of Done Eredmények

### 1. Auth és profil ✅
| Kritérium | Státusz | Megjegyzés |
|-----------|---------|------------|
| User képes regisztrálni | ✅ | SignupScreen + Supabase auth |
| User képes bejelentkezni | ✅ | LoginScreen + session kezelés |
| Profilbejegyzés létrejön | ✅ | profiles.insert policy |
| Admin státusz szerveroldalon érvényesül | ✅ | RLS + trigger |

### 2. Scenario flow ✅
| Kritérium | Státusz | Megjegyzés |
|-----------|---------|------------|
| Admin képes szituációt létrehozni | ✅ | CreateScenarioScreen |
| Nem admin nem képes szituációt létrehozni | ✅ | RLS policy |
| User látja a szituációlistát | ✅ | ScenarioListScreen |
| User megnyitja a részletes oldalt | ✅ | ScenarioDetailScreen |

### 3. Submission flow ✅
| Kritérium | Státusz | Megjegyzés |
|-----------|---------|------------|
| User beküldhet reakciót | ✅ | submission insert |
| Egy user egy scenario = egy submission | ✅ | unique constraint |
| Reakció megjelenik a listában | ✅ | active filter |
| Reakció nem szerkeszthető | ✅ | Nincs edit flow |

### 4. Evaluation flow ✅
| Kritérium | Státusz | Megjegyzés |
|-----------|---------|------------|
| Like működik | ✅ | submission_likes insert |
| Unlike működik | ✅ | submission_likes delete |
| Saját submission nem like-olható | ✅ | RLS policy |
| Duplicate like nem lehetséges | ✅ | PK |

### 5. Moderation minimum ✅
| Kritérium | Státusz | Megjegyzés |
|-----------|---------|------------|
| Reakció jelenthető | ✅ | Report dialog |
| Admin megtekintheti a jelentéseket | ✅ | Jelentések fül |
| Admin lezárhat jelentést | ✅ | resolve/dismiss gombok |
| Admin elrejtheti/törölheti reakciót | ✅ | Reakciók fül |
| Admin elrejtheti/archiválhatja szituációt | ✅ | Szituációk fül |
| Admin korlátozhat user-t | ✅ | Userek fül + ban/unban |
| Moderation events audit trail | ✅ | Minden akció logolódik |
| Admin lát hidden/removed submissiont | ✅ | T2.1 migration |
| Report → Moderation konzisztencia | ✅ | Auto-resolve report |

### 6. Adatbiztonság ✅
| Kritérium | Státusz | Megjegyzés |
|-----------|---------|------------|
| RLS policy-k működnek | ✅ | Teljes policy set |
| is_admin/is_banned védelem | ✅ | Kétpolicy + trigger |
| Banned user nem írhat | ✅ | RLS checks |
| Hidden/removed szűrés | ✅ | RLS + query filter |
| Admin teljes nézet | ✅ | T2.1 migration |

---

## Módosított Fájlok

```
rhetorium/
├── supabase/migrations/
│   └── 004_t2_1_moderation_fix.sql  # ÚJ - Admin visibility + action_type fix
├── lib/features/admin/admin_screen.dart  # Frissítve - report auto-resolve
└── acceptance_report.md  # Frissítve
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
- ❌ Appeal/fellebbezés
- ❌ AI moderáció
- ❌ Bulk moderation
- ❌ Audit export

---

## Összefoglaló

**T1 Scope:** ✅ ELKÉSZVE  
**T2 Scope:** ✅ ELKÉSZVE  
**T2.1 Scope:** ✅ ELKÉSZVE  

**Moderation Minimum Teljes:**
- ✅ Report beküldés
- ✅ Admin reports nézet
- ✅ Admin submission moderation (hide/remove/restore)
- ✅ Admin scenario moderation (hide/archive)
- ✅ Admin user restriction (ban/unban)
- ✅ Moderation events audit trail
- ✅ Hidden/removed szűrés normál user nézetben
- ✅ Admin teljes nézet (T2.1)
- ✅ Report → Moderation konzisztencia (T2.1)

---

**Agent signature:** Rhetorium MVP Build Agent - T2.1 Task  
**Commit:** (commitolás után frissül)
