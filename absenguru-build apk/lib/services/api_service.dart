import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/guru.dart';

/// Exception khusus untuk error yang berasal dari API
/// (supaya bisa ditampilkan pesannya langsung ke user).
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  String? _token;

  /// Ambil token dari penyimpanan lokal (dipanggil sekali saat app start).
  Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(kPrefsTokenKey);
    return _token;
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kPrefsTokenKey, token);
  }

  Future<void> _saveGuru(Map<String, dynamic> guruJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kPrefsGuruKey, jsonEncode(guruJson));
  }

  Future<Guru?> loadSavedGuru() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kPrefsGuruKey);
    if (raw == null) return null;
    return Guru.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> logout() async {
    // Beri tahu server supaya token lama di-invalidate (best-effort — kalau
    // gagal karena tidak ada koneksi, tetap lanjut hapus token lokal).
    try {
      await http.post(_uri('/logout'), headers: _headers).timeout(const Duration(seconds: 10));
    } catch (_) {
      // abaikan, tetap lanjut clear token lokal di bawah
    }
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kPrefsTokenKey);
    await prefs.remove(kPrefsGuruKey);
  }

  /// Ganti password guru yang sedang login. Server TIDAK revoke token lama,
  /// tapi tetap disarankan login ulang.
  Future<String> changePassword(String passwordLama, String passwordBaru) async {
    final res = await http
        .post(
          _uri('/change-password'),
          headers: _headers,
          body: jsonEncode({'passwordLama': passwordLama, 'passwordBaru': passwordBaru}),
        )
        .timeout(const Duration(seconds: 20));
    final data = _handleOk(res);
    return data['message']?.toString() ?? 'Password berhasil diubah';
  }

  /// Daftar notifikasi (turunan dari data yang ada, bukan tabel terpisah).
  Future<Map<String, dynamic>> fetchNotifikasi() async {
    final res = await http.get(_uri('/notifikasi'), headers: _headers).timeout(const Duration(seconds: 20));
    return _handleOk(res);
  }

  /// Profil madrasah lengkap (untuk halaman "Tentang Madrasah").
  Future<Map<String, dynamic>> fetchProfilMadrasah() async {
    final res = await http.get(_uri('/profil-madrasah'), headers: _headers).timeout(const Duration(seconds: 20));
    return _handle(res);
  }

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('$kApiBaseUrl$path').replace(queryParameters: query);
  }

  /// Handle response LEGACY (flat shape): lempar ApiException kalau status
  /// bukan 2xx, atau kalau body mengandung field "error".
  Map<String, dynamic> _handle(http.Response res) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Respons server tidak valid (${res.statusCode})', statusCode: res.statusCode);
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg = body['error']?.toString() ?? 'Terjadi kesalahan (${res.statusCode})';
      throw ApiException(msg, statusCode: res.statusCode);
    }
    return body;
  }

  /// Handle response BARU (envelope {ok, data} / {ok:false, error}),
  /// dipakai endpoint V.7 yang baru (logout, change-password, notifikasi, dst).
  Map<String, dynamic> _handleOk(http.Response res) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Respons server tidak valid (${res.statusCode})', statusCode: res.statusCode);
    }
    final ok = body['ok'] == true;
    if (!ok || res.statusCode < 200 || res.statusCode >= 300) {
      final msg = body['error']?.toString() ?? 'Terjadi kesalahan (${res.statusCode})';
      throw ApiException(msg, statusCode: res.statusCode);
    }
    return (body['data'] as Map<String, dynamic>?) ?? {};
  }

  // ---------------- AUTH ----------------

  Future<Guru> login(String nik, String password) async {
    late http.Response res;
    try {
      res = await http
          .post(
            _uri('/login'),
            headers: _headers,
            body: jsonEncode({'nik': nik, 'password': password}),
          )
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      throw ApiException('Tidak dapat terhubung ke server. Cek koneksi internet Anda.');
    }
    final body = _handle(res);
    final token = body['token'] as String;
    final guruJson = body['guru'] as Map<String, dynamic>;
    await _saveToken(token);
    await _saveGuru(guruJson);
    return Guru.fromJson(guruJson);
  }

  Future<Guru> fetchMe() async {
    final res = await http.get(_uri('/me'), headers: _headers).timeout(const Duration(seconds: 20));
    final body = _handle(res);
    final guruJson = body['guru'] as Map<String, dynamic>;
    await _saveGuru(guruJson);
    return Guru.fromJson(guruJson);
  }

  // ---------------- JADWAL ----------------

  /// Return: { guru, jadwal: { "Senin": [...], ... }, total }
  Future<Map<String, dynamic>> fetchJadwal({String? hari}) async {
    final res = await http
        .get(_uri('/jadwal', hari != null ? {'hari': hari} : null), headers: _headers)
        .timeout(const Duration(seconds: 20));
    return _handle(res);
  }

  // ---------------- ABSENSI ----------------

  Future<Map<String, dynamic>> fetchAbsensi({String? tanggal}) async {
    final res = await http
        .get(_uri('/absensi', tanggal != null ? {'tanggal': tanggal} : null), headers: _headers)
        .timeout(const Duration(seconds: 20));
    return _handle(res);
  }

  /// Rekap absensi sebulan penuh. [bulan] format "yyyy-MM", default bulan ini.
  Future<Map<String, dynamic>> fetchAbsensiBulanan({String? bulan}) async {
    final res = await http
        .get(_uri('/absensi-bulanan', bulan != null ? {'bulan': bulan} : null), headers: _headers)
        .timeout(const Duration(seconds: 20));
    return _handle(res);
  }

  // ---------------- GAJI ----------------

  Future<Map<String, dynamic>> fetchGajiList() async {
    final res = await http.get(_uri('/gaji'), headers: _headers).timeout(const Duration(seconds: 20));
    return _handle(res);
  }

  Future<Map<String, dynamic>> fetchGajiDetail(String id) async {
    final res = await http.get(_uri('/gaji/$id'), headers: _headers).timeout(const Duration(seconds: 20));
    return _handle(res);
  }

  // ---------------- PENGATURAN (info madrasah) ----------------

  Future<Map<String, dynamic>> fetchPengaturan() async {
    final res = await http.get(_uri('/pengaturan'), headers: _headers).timeout(const Duration(seconds: 20));
    return _handle(res);
  }
}
