# Absen Guru — Aplikasi Android (Flutter)

Aplikasi portal guru: login pakai **NIK**, lihat jadwal mengajar, absensi
harian & rekap bulanan, slip gaji, dan profil.

Sudah terhubung ke server: `https://absenguru.abiserver.my.id/api/mobile`
(lihat `lib/constants.dart` kalau perlu ganti alamat server).

---

## Cara Dapat File .apk (untuk yang awam, tanpa install apapun)

### Langkah 1 — Buat akun GitHub (kalau belum punya)
Buka https://github.com/signup, ikuti langkahnya. Gratis.

### Langkah 2 — Buat repository baru
1. Setelah login, klik tombol **+** di kanan atas → **New repository**
2. Isi nama repo, misal `absenguru-apk`
3. Pilih **Private** (biar tidak publik) atau **Public** (bebas)
4. Klik **Create repository** (jangan centang opsi "Add README" dll, biarkan kosong)

### Langkah 3 — Upload kode ini ke repo
Di halaman repo yang baru dibuat, akan ada pilihan **"uploading an existing file"**
(link teks di tengah halaman). Klik itu.

- **Extract dulu** zip yang saya berikan ini di komputer Anda
- **Drag & drop seluruh isi folder** (bukan folder zip-nya, tapi isi di dalamnya —
  `lib/`, `pubspec.yaml`, `.github/`, dll) ke halaman upload GitHub
- Scroll ke bawah, klik **Commit changes**

### Langkah 4 — Tunggu APK ter-build otomatis
1. Klik tab **Actions** di bagian atas halaman repo
2. Akan ada proses berjalan bernama **"Build APK"** (otomatis jalan begitu Anda upload)
3. Tunggu sampai selesai (tanda centang hijau ✅), biasanya 5-10 menit
4. Kalau gagal (tanda silang merah ❌), klik untuk lihat detail errornya, dan
   kirimkan pesan errornya — saya bantu perbaiki

### Langkah 5 — Download APK
1. Masih di tab **Actions**, klik run yang sudah selesai (centang hijau)
2. Scroll ke bawah, ada bagian **Artifacts**
3. Klik **absenguru-apk** untuk download (berupa file .zip berisi .apk di dalamnya)
4. Extract, dapat file `app-release.apk`

### Langkah 6 — Install di HP Android
1. Kirim file `.apk` itu ke HP (lewat kabel USB, WhatsApp ke diri sendiri, Google Drive, dll)
2. Buka file-nya di HP, akan diminta izin "Install dari sumber tidak dikenal" — izinkan
   (ini normal untuk APK yang tidak dari Play Store)
3. Install seperti biasa

Setiap kali Anda update kode & upload ulang ke GitHub, APK baru akan otomatis
ter-build lagi — tinggal ulangi Langkah 4-6 untuk versi terbaru.

---

## Kredensial Login

Login pakai **NIK guru** (bukan username admin). Untuk data yang baru di-seed,
password default guru adalah `guru123` (bisa direset lewat Manajemen User di web admin).

## Build Manual (kalau sudah punya Flutter SDK terinstall)

```bash
flutter create --platforms=android --org com.absenguru --project-name absenguru .
flutter pub get
flutter build apk --release
```

File APK akan ada di `build/app/outputs/flutter-apk/app-release.apk`.
