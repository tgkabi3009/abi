// Alamat server backend (sudah diisi sesuai deployment Anda).
// Kalau suatu saat pindah server/domain, cukup ubah nilai ini.
const String kApiBaseUrl = 'https://absenguru.abiserver.my.id/api/mobile';

const String kPrefsTokenKey = 'auth_token';
const String kPrefsGuruKey = 'guru_data';

// Label tipe guru (disamakan dengan src/lib/constants.ts di backend)
const Map<String, String> kTipeGuruLabel = {
  'satminkal_sertifikasi': 'Satminkal + Sertifikasi',
  'satminkal_non_sertifikasi': 'Satminkal + Non-Sertifikasi',
  'non_satminkal_sertifikasi': 'Non-Satminkal + Sertifikasi',
  'non_satminkal_non_sertifikasi': 'Non-Satminkal + Non-Sertifikasi',
};
