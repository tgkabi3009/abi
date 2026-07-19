# Absensi Guru — Aplikasi Flutter (V.7 APK)

Aplikasi Android native untuk guru madrasah — integrasi penuh dengan backend
**Absensi Guru V.7** (Next.js + Prisma + SQLite).

## Fitur

Aplikasi mengonsumsi **18 endpoint** `/api/mobile/*` dari backend V.7:

| Tab | Endpoint | Fungsi |
|-----|----------|--------|
| Splash | `GET /ping` | Health check, force-update gate, maintenance check |
| Login | `POST /login` | Login dengan NIK atau Kode Nama |
| Beranda | `GET /dashboard` | Summary home screen (1 round trip) |
| Jadwal | `GET /jadwal` + `GET /jam-pelajaran` | Jadwal mengajar + rentang waktu |
| Absensi (Harian) | `GET /absensi?tanggal=` | Status absensi per tanggal |
| Absensi (Bulanan) | `GET /absensi-bulanan?bulan=` + `GET /hari-efektif` | Rekap bulanan + hari libur |
| Gaji | `GET /periode-gaji` + `GET /gaji/[id]` | List slip + detail breakdown |
| Notifikasi | `GET /notifikasi` | Notifikasi derived (slip baru, reminder) |
| Akun | `GET /me`, `POST /change-password`, `POST /logout` | Profil, ubah password, logout |
| Tentang | `GET /profil-madrasah` | Info madrasah lengkap (honor, jam, hari) |
| Push Notif | `POST /device-token`, `DELETE /device-token` | FCM register/unregister |

## Persyaratan

- **Flutter SDK** ≥ 3.19.0
- **Dart SDK** ≥ 3.3.0
- **Android SDK** dengan compileSdk 34, minSdk 23
- **Java JDK** 17
- **Android Studio** atau VS Code dengan Flutter extension
- Backend V.7 berjalan & dapat diakses dari device

## Setup & Build

### 1. Install dependencies

```bash
cd absensi_guru_apk
flutter pub get
```

### 2. Set Base URL backend

Edit `lib/config/api_config.dart`:

```dart
static const String kBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000',  // ganti untuk production
);
```

**Atau** lewat `--dart-define` saat build:

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://absensi.madrasah.sch.id
```

- **Emulator Android:** `http://10.0.2.2:3000` (10.0.2.2 = host loopback dari emulator)
- **Device fisik (dev):** `http://192.168.x.x:3000` (IP lokal server dev)
- **Production:** `https://absensi.madrasah.sch.id` (HTTPS wajib, jangan hardcode port)

### 3. (Opsional) Setup Firebase untuk Push Notifications

Aplikasi sudah ter-integrasi dengan `firebase_messaging` & `flutter_local_notifications`.
Untuk mengaktifkan push notification:

1. Buat project di [Firebase Console](https://console.firebase.google.com/).
2. Tambahkan aplikasi Android dengan package name `com.absensi.guru`.
3. Download `google-services.json` → letakkan di `android/app/google-services.json`.
4. Build ulang — FCM token otomatis di-register ke `/api/mobile/device-token` setelah login.

> Tanpa `google-services.json`, app masih bisa di-build & berjalan — fitur push notif
> saja yang tidak aktif (token tidak akan didapat dari FCM).

### 4. (Production) Generate keystore untuk signing APK release

```bash
keytool -genkey -v -keystore ~/absensi-guru.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias absensi-guru
```

Buat `android/key.properties` (jangan commit file ini!):

```properties
storePassword=*****
keyPassword=*****
keyAlias=absensi-guru
storeFile=/Users/anda/absensi-guru.jks
```

### 5. Generate app icon (opsional)

Taruh icon 1024x1024 PNG di `assets/icon/app_icon.png`, lalu:

```bash
dart run flutter_launcher_icons
```

### 6. Build APK

```bash
# Debug APK (cepat, untuk testing)
flutter build apk --debug

# Release APK (production, optimized)
flutter build apk --release \
  --dart-define=API_BASE_URL=https://absensi.madrasah.sch.id
```

Output APK ada di: `build/app/outputs/flutter-apk/app-release.apk`

### 7. Install ke device

```bash
# Via adb (USB debugging aktif)
adb install build/app/outputs/flutter-apk/app-release.apk

# Atau copy APK ke device & install manual
```

## Struktur Project

```
lib/
├── main.dart                    # Entry point + MultiProvider setup
├── app.dart                     # MaterialApp + theme + initial route
├── config/
│   ├── api_config.dart          # BASE_URL, timeout, version
│   └── theme.dart               # Material 3 theme (brand green)
├── models/
│   └── models.dart              # Semua data model (Guru, Jadwal, Absensi, dll)
├── services/
│   ├── api_client.dart          # dio + interceptors + 401 handler
│   ├── storage_service.dart     # flutter_secure_storage wrapper
│   ├── mobile_api_service.dart  # Semua 18 endpoint client
│   └── push_notification_service.dart  # FCM init & handler
├── providers/
│   ├── auth_provider.dart       # Auth state + login/logout
│   └── providers.dart           # Dashboard/Jadwal/Absensi/Gaji/Notif/Madrasah
├── screens/
│   ├── splash_screen.dart       # /ping + force-update + auth check
│   ├── login_screen.dart        # Login form
│   ├── main_shell.dart          # Bottom nav (5 tab)
│   ├── home_screen.dart         # Dashboard summary
│   ├── jadwal_screen.dart       # Jadwal mengajar + filter hari
│   ├── absensi_screen.dart      # Tab Harian + Tab Bulanan
│   ├── gaji_screen.dart         # List slip + detail
│   ├── notifikasi_screen.dart   # List notifikasi derived
│   ├── akun_screen.dart         # Profil + menu + logout
│   ├── ubah_password_screen.dart
│   └── tentang_screen.dart      # Profil madrasah lengkap
└── widgets/
    └── widgets.dart             # AppCard, StatusChip, LoadingIndicator,
                                 # EmptyState, ErrorState, SectionTitle
```

## Flow Aplikasi

1. **App launch** → `SplashScreen`:
   - `GET /ping` → cek server reachable + cek `maintenance` + cek `minApkVersion` (force-update).
   - Cek token di secure storage → `GET /me` untuk validasi.
   - Jika token valid → init FCM → route ke `MainShell`.
   - Jika tidak → route ke `LoginScreen`.

2. **Login** → `POST /login` dengan NIK atau Kode Nama.
   - Token & cached guru disimpan di Android Keystore.
   - FCM token otomatis di-register ke server (background).

3. **MainShell** (5 tab):
   - **Beranda**: dashboard summary dari `GET /dashboard` (1 round trip).
   - **Jadwal**: list jadwal per hari dengan rentang jam pelajaran.
   - **Absensi**: harian (date picker) + bulanan (month picker + hari libur).
   - **Gaji**: list slip → tap untuk detail breakdown.
   - **Akun**: profil, notifikasi, ubah password, tentang madrasah, logout.

4. **401 auto-logout**: interceptor di `ApiClient` men-trigger `AuthProvider.logout()`
   jika ada request yang dapat 401. Token dibersihkan, user di-route ke login.

## State Management

Menggunakan **Provider + ChangeNotifier** (sederhana, cukup untuk skala madrasah):
- `AuthProvider` — auth state, login/logout, 401 handler.
- `DashboardProvider`, `JadwalProvider`, `AbsensiProvider`, `GajiProvider`,
  `NotifikasiProvider`, `MadrasahProvider` — masing-masing layanan data.

## Testing

Test dasar (widget + unit) ada di `test/`. Jalankan:

```bash
flutter test
```

## Catatan Penting

- **Jangan hardcode port di production build.** Backend di-deploy di belakang
  reverse-proxy (Caddy/nginx) — port internal tidak terekspos. Gunakan HTTPS
  domain publik.
- **HTTPS wajib di production.** Android 9+ secara default menolak cleartext
  HTTP. `android:usesCleartextTraffic="true"` hanya untuk dev. Build production
  harus pakai HTTPS.
- **Token disimpan di Android Keystore** (via `flutter_secure_storage`) — tidak
  di SharedPreferences plain.
- **Force-update**: update `apk_min_version` di tabel Pengaturan backend untuk
  memaksa semua user update APK. Versi APK di-compare via semver.
- **Maintenance mode**: set `maintenance_mode=true` di Pengaturan untuk
  menampilkan layar maintenance & block login.
- **Tidak ada offline mode**: semua data real-time dari server. Cache hanya
  untuk token & cached guru (untuk splash routing).

## Troubleshooting

### "Tidak dapat terhubung ke server" di splash
- Cek `kBaseUrl` di `api_config.dart`.
- Jika pakai emulator, pastikan `10.0.2.2:3000` (bukan localhost).
- Jika pakai device fisik di dev, pastikan device & server di jaringan yang sama.
- Pastikan backend V.7 berjalan (`curl http://<server>/api/mobile/ping` harus
  return JSON).

### Push notification tidak masuk
- Pastikan `google-services.json` sudah di `android/app/`.
- Cek permission notifikasi di Settings → Apps → Absensi Guru.
- Cek log FCM via `adb logcat | grep FCM`.

### "Versi aplikasi sudah usang"
- Update `pubspec.yaml` `version: X.Y.Z+N` dan `api_config.dart kAppVersion`.
- Atau turunkan `apk_min_version` di tabel Pengaturan backend.

### Build error: minSdkVersion
- Pastikan `minSdk = 23` di `android/app/build.gradle.kts` (firebase_messaging
  15.x butuh API 23+).

## Lisensi

Internal — MTs Fathin Al-Aziziyah. Tidak untuk distribusi publik.

## Versi

- **APK**: 1.0.0
- **Backend minimum**: V.7.0
- **API endpoints**: 18 (lihat `API_CONNECTOR.md` di repo backend untuk detail)
