/// Konfigurasi global aplikasi.
///
/// Ubah `kBaseUrl` sesuai deployment server backend Anda.
/// - Production: domain publik madrasah (HTTPS).
/// - Dev/emulator: `http://10.0.2.2:3000` (Android emulator) atau
///   `http://192.168.x.x:3000` (device fisik di jaringan yang sama).
///
/// JANGAN hardcode port di production — backend di-deploy di belakang
/// reverse-proxy (Caddy/nginx), port internal tidak terekspos.
class ApiConfig {
  ApiConfig._();

  /// Base URL backend. Tanpa trailing slash.
  ///
  /// Contoh:
  /// - Production: `https://absensi.madrasah.sch.id`
  /// - Dev emulator: `http://10.0.2.2:3000`
  static const String kBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',  // ganti ke domain publik untuk production build
  );

  /// Prefix endpoint mobile.
  static const String kMobilePrefix = '/api/mobile';

  /// Versi APK saat ini (untuk cek force-update via /ping).
  /// Update sesuai pubspec.yaml `version: X.Y.Z+N`.
  static const String kAppVersion = '1.0.0';

  /// Timeout HTTP (ms).
  static const int kConnectTimeout = 10000;
  static const int kReceiveTimeout = 30000;

  /// Timezone server (untuk konversi waktu jika dibutuhkan).
  static const String kServerTimezone = 'Asia/Jakarta';
}
