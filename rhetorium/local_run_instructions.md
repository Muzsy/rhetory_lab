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
- `rhetorium/supabase/migrations/003_t1_1_trigger_fix.sql` - Trigger fix
- `rhetorium/supabase/migrations/004_t2_1_moderation_fix.sql` - Moderáció alapok
- `rhetorium/supabase/migrations/005_t2_1_rls_fix.sql` - RLS és admin visibility fix

### 2. Seed Data (Opcionális)
Futtasd a seed adatokat demo tartalomhoz:

**Fájl:** `rhetorium/supabase/seed.sql`

### 3. Admin User Létrehozása
Az admin user manuálisan jön létre:

1. **Supabase Dashboard** → Authentication → Users → Create user
2. **Supabase Dashboard** → Table Editor → profiles → szerkeszd az új user `is_admin` mezőjét `true`-ra

---

## Környezeti Változók Mechanizmusa

Az alkalmazás `String.fromEnvironment` alapú env kezelést használ.
A változókat a `--dart-define-from-file=.env.local` kapcsolóval kell átadni.

### Fontos
- Ha a változók nincsenek beállítva, az alkalmazás hibát dob indításkor.
- A `.env.local` fájl **NEM** kerül a verziókezelésbe (.gitignore-ban van).

---

## Alkalmazás Futtatása

### Android Eszközön (Debug)

```bash
cd rhetorium

# Futtasd az alkalmazást a .env.local-ból betöltött változókkal
flutter run --dart-define-from-file=../.env.local
```

### Android Emulátoron (Debug)

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

Release buildhez a változókat explicit módon kell átadni:

```bash
cd rhetorium

# Olvasd be a .env.local tartalmát és add át a build-nek
source ../.env.local
flutter build apk --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
```

**Alternatíva:** Használj scriptet vagy Makefile-t a buildhez.

---

## Projekt Struktúra (Feature-first / Moduláris)

```
rhetorium/
├── lib/
│   ├── main.dart                    # Belépési pont
│   ├── env.dart                     # Környezeti változók kezelése
│   ├── app/
│   │   ├── app.dart                 # MaterialApp alapok
│   │   ├── router/
│   │   │   ├── app_router.dart      # GoRouter definíciók
│   │   │   └── router_notifier.dart # Route Guard-ok (Auth & Admin)
│   │   └── ui/
│   │       └── main_shell.dart      # Navigációs váz (BottomNav)
│   ├── features/
│   │   ├── admin/                   # Adminisztrációs modul
│   │   │   ├── providers/           # Admin specifikus Riverpod állapot
│   │   │   ├── services/            # Moderációs és logolási szolgáltatások
│   │   │   └── ui/
│   │   │       ├── tabs/            # Moderációs al-lapok (reports, scenarios stb.)
│   │   │       ├── admin_screen.dart
│   │   │       └── create_scenario_screen.dart
│   │   ├── auth/                    # Hitelesítési modul
│   │   │   └── ui/                  # Login és Signup képernyők
│   │   ├── profile/                 # Profil modul
│   │   │   └── ui/                  # Profil képernyő és admin belépési pont
│   │   └── scenario/                # Szituációs modul
│   │       ├── providers/           # Szituáció specifikus állapot
│   │       └── ui/                  # Lista és részletes nézet
│   └── shared/                      # Közös szolgáltatások
│       └── core/
│           └── supabase_client.dart
├── supabase/
│   ├── migrations/                  # Adatbázis sémák (001-005)
│   └── seed.sql                     # Lokális demo adatok
└── integration_test/                # E2E / Flow tesztek
```

---

## Tesztelés

A projekt tartalmaz egység-, widget- és integrációs teszteket.

### Egység- és Widget tesztek
Ezek a tesztek lokálisan, eszköz nélkül futtathatók:

```bash
cd rhetorium
flutter test
```

**Lefedett területek:**
- `test/features/auth/`: Login és Signup képernyők renderelése
- `test/app/router/`: Route Guard logika (Auth és Admin redirect szabályok)

### Integrációs tesztek
Ezek a tesztek valódi eszközön vagy emulátoron futnak, és a Supabase-szel kommunikálnak:

```bash
cd rhetorium
# Futtatás alapértelmezett eszközön
flutter test integration_test/auth_flow_test.dart --dart-define-from-file=../.env.local

# Futtatás konkrét eszközön (pl. fizikai telefon)
flutter test integration_test/auth_flow_test.dart --dart-define-from-file=../.env.local -d <DEVICE_ID>
```

**Lefedett területek:**
- `integration_test/auth_flow_test.dart`: Teljes regisztrációs folyamat, navigáció ellenőrzése és kijelentkezés.

---

## Hibaelhárítás

### "SUPABASE_URL is not set" hiba
- Ellenőrizd, hogy a `.env.local` fájl létezik és tartalmazza a szükséges változókat
- Ellenőrizd, hogy a `--dart-define-from-file` kapcsoló helyesen mutat a fájlra

### Release build nem működik
- A release buildhez explicit `--dart-define` kapcsolókat kell használni
- A `--dart-define-from-file` debug módban működik, release buildnél nem

---

## További Információk

- Az env változók validálása az `Env.validate()` függvényben történik (lib/env.dart)
- Ha nincs .env.local, egyértelmű hibaüzenet jelenik meg
