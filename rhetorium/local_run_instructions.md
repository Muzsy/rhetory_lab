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
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY` (opcionális, admin műveletekhez)

---

## Adatbázis Setup

### 1. Migration Futtatása
Futasd le a sémát a Supabase SQL Editor-ban vagy CLI-vel:

**Fájl:** `supabase/migrations/001_initial_schema.sql`

```sql
-- Másold be a teljes SQL tartalmat a Supabase SQL Editorba és futtasd
```

### 2. Seed Data (Opcionális)
Futtasd a seed adatokat demo tartalomhoz:

**Fájl:** `supabase/seed/001_seed_data.sql`

### 3. Admin User Létrehozása
Az admin user manuálisan jön létre:

1. **Supabase Dashboard** → Authentication → Users → Create user
2. **Supabase Dashboard** → Table Editor → profiles → szerkeszd az új user `is_admin` mezőjét `true`-ra

---

## Alkalmazás Futtatása

### Android Emulátoron
```bash
cd rhetorium

# Ellenőrizd az emulátort
flutter devices

# Futtasd az alkalmazást
flutter run
```

### Weben (Debug)
```bash
cd rhetorium
flutter run -d chrome
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
│   ├── env.dart                     # Environment config
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
│   │   └── 001_initial_schema.sql  # Schema + RLS policies
│   └── seed/
│       └── 001_seed_data.sql        # Demo data
└── pubspec.yaml
```

---

## Tesztelési Útmutató

### 1. Regisztráció
1. Nyisd meg az appot
2. Kattints "Regisztrálj!"
3. Töltsd ki az adatokat
4. Ellenőrizd, hogy létrejön a profil

### 2. Szituáció Létrehozás (Admin)
1. Jelentkezz be az admin fiókkal
2. Navigálj az Admin felületre
3. Kattints "Új szituáció létrehozása"
4. Töltsd ki a címet és briefet
5. Küldd el és ellenőrizd a listában

### 3. Reakció Beküldés
1. Nyiss meg egy szituációt
2. Írj egy reakciót
3. Küldd el
4. Ellenőrizd, hogy megjelenik a listában

### 4. Like/Unlike
1. Kattints egy másik felhasználó reakciójára
2. Ellenőrizd, hogy a like count nő
3. Kattints újra (unlike)
4. Ellenőrizd, hogy a count csökken

### 5. Report
1. Kattints a report ikonra egy reakción
2. Válaszd ki az okot
3. Ellenőrizd, hogy megjelenik az Admin felületen

---

## Hibaelhárítás

### "No Supabase connection"
- Ellenőrizd a `.env.local` fájlt
- Ellenőrizd az internet kapcsolatot
- Próbáld újraindítani az alkalmazást

### "Admin funkció nem működik"
- Ellenőrizd, hogy `is_admin = true` a profilodban
- Ellenőrizd a Supabase RLS policies-t

### Build hiba
```bash
flutter clean
flutter pub get
flutter analyze
flutter build apk
```

---

## Supabase CLI (Opcionális)
```bash
# Telepítés
npm install -g supabase

# Bejelentkezés
supabase login

# Lokális linkelés
supabase link --project-ref <your-project-ref>

# Migration pull
supabase db pull

# Migration push
supabase db push
```
