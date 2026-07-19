import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage wrapper — single source of truth untuk token & cached data.
///
/// Token disimpan di Android Keystore (via flutter_secure_storage). Data
/// non-sensitif (pengaturan cache, last dashboard) disimpan di SharedPreferences
/// oleh masing-masing provider.
class StorageService {
  StorageService._internal();
  static final StorageService instance = StorageService._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Keys
  static const _kToken = 'auth_token';
  static const _kGuruId = 'guru_id';
  static const _kGuruKodeNama = 'guru_kode_nama';
  static const _kGuruNama = 'guru_nama';
  static const _kFcmToken = 'fcm_token';
  static const _kFcmRegistered = 'fcm_registered';

  // === Auth Token ===
  Future<String?> getToken() => _storage.read(key: _kToken);
  Future<void> setToken(String token) => _storage.write(key: _kToken, value: token);
  Future<void> clearToken() => _storage.delete(key: _kToken);

  // === Cached Guru (for splash screen routing) ===
  Future<Map<String, String>?> getCachedGuru() async {
    final id = await _storage.read(key: _kGuruId);
    if (id == null) return null;
    return {
      'id': id,
      'kodeNama': await _storage.read(key: _kGuruKodeNama) ?? '',
      'nama': await _storage.read(key: _kGuruNama) ?? '',
    };
  }

  Future<void> cacheGuru({required String id, required String kodeNama, required String nama}) async {
    await _storage.write(key: _kGuruId, value: id);
    await _storage.write(key: _kGuruKodeNama, value: kodeNama);
    await _storage.write(key: _kGuruNama, value: nama);
  }

  Future<void> clearCachedGuru() async {
    await _storage.delete(key: _kGuruId);
    await _storage.delete(key: _kGuruKodeNama);
    await _storage.delete(key: _kGuruNama);
  }

  // === FCM Token ===
  Future<String?> getFcmToken() => _storage.read(key: _kFcmToken);
  Future<void> setFcmToken(String token) => _storage.write(key: _kFcmToken, value: token);

  Future<bool> isFcmRegistered() async {
    final v = await _storage.read(key: _kFcmRegistered);
    return v == 'true';
  }

  Future<void> setFcmRegistered(bool registered) =>
      _storage.write(key: _kFcmRegistered, value: registered ? 'true' : 'false');

  /// Nuke everything — used saat full logout.
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
