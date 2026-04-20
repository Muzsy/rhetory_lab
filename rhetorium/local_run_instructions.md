# Rhetorium MVP — Lokális Futtatási Útmutató

## Előfeltételek

### 1. Flutter SDK
```bash
# Telepítsd a Flutter SDK-t
git clone https://github.com/flutter/flutter.git -b stable --depth 1 ~/flutter
export PATH="$HOME/flutter/bin:$PATH"
flutter precache
flutter doctor
```

### 2. Supabase Projekt
- Hozz létre egy Supabase projektet a [supabase.com](https://supabase.com) címen
- Másold ki a `.env.example` tartalmát `.env.local` néven:
```bash
cp .env.example .env.local
```

### 3. Supabase Környezeti Változók
Töltsd ki a `.env.local` fájlt a Supabase dashboardról:
- `SUPABASE_URL` - A projekt URL-je
- `SUPABASE_ANON_KEY` - Az anonin kulcs

---

## Adatbázis Setup

### 1. Migration Futtatása
Futasd le a sémákat a Supabase SQL Editor-ban vagy CLI-vel:

**Fájlok:**
- `rhetorium/supabase/migrations/001_initial_schema.sql` - Alap séma
- `rhetorium/supabase/migrations/002_t1_auth_rls_fix.sql` - Auth és RLS javítások

### 2. Seed Data (Opcionális)
Futtasd a seed adatokat demo tartalomhoz:

**Fájl:** `rhetorium/supabase/seed/001_seed_data.sql`

### 3. Admin User Létrehozása
Az admin user manuálisan jön létre:

1. **Supabase Dashboard** → Authentication → Users → Create user
2. **Supabase Dashboard** → Table Editor → profiles → szerkeszd az új user `is_admin` mezőjét `true`-ra

---

## Alkalmazás Futtatása

### Android Eszközön (Javasolt)

```bash
cd rhetorium

# Futtasd az alkalmazást a .env.local-ból betöltött változókkal
flutter run --dart-define-from-file=../.env.local
```

### Android Emulátoron

```bash
cd rhetorium
flutter run --dart-define-from-file=../.env.local -d emulator-5554
```

### Weben (Debug)

```bash
cd rhetorium
flutter run --dart-define-from-file=../.env.local -d chrome
```

### Release Build (Android)

```bash
cd rhetorium
flutter build apk --release
```

---

## Projekt Struktúra

```
rhetorium/
├── lib/
│   ├── main.dart                    # App bootstrap
│   ├── env.dart                     # Environment config (--dart-define-from-file)
│   ├── app/
│   │   ├── app.dart                 # MaterialApp
│   │   └── router/
│   │       └── app_router.dart      # GoRouter config
│   ├── features/
│   │   ├── scenario/
│   │   │   ├── scenario_list_screen.dart
│   │   │   └── scenario_detail_screen.dart
│   │   └── admin/
│   │       ├── admin_screen.dart
│   │       └── create_scenario_screen.dart
│   └── shared/
│       └── core/
│           └── supabase_client.dart
├── supabase/
│   ├── migrations/
│   │   ├── 001_initial_schema.sql
│   │   └── 002_t1_auth_rls_fix.sql
│   └── seed/
│       └── 001_seed_data.sql
└── integration_test/
    └── auth_flow_test.dart
```

---

## Fontos: Környezeti Változók

Az alkalmazás **kötelezően** megköveteli a `.env.local` fájlt. Ha a változók nincsenek beállítva, az alkalmazás hibát dob indításkor.

A `.env.local` fájl **NEM** kerül a verziókezelésbe (.gitignore-ban van).
