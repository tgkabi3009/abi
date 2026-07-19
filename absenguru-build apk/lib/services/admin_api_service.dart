import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/admin.dart';
import '../models/admin_absensi.dart';
import 'api_service.dart' show ApiException;

const String kAdminPrefsTokenKey = 'admin_auth_token';
const String kAdminPrefsUserKey = 'admin_user_data';

class AdminApiService {
  AdminApiService._();
  static final AdminApiService instance = AdminApiService._();

  String? _token;

  // Base URL untuk API admin ada 1 level di atas /mobile, karena admin
  // pakai endpoint web biasa (/api/auth/*, /api/absensi*, /api/guru),
  // bukan /api/mobile/*.
  String get _baseUrl => kApiBaseUrl.replaceFirst('/api/mobile', '/api');

  Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(kAdminPrefsTokenKey);
    return _token;
  }

  Future<void> _saveSession(String token, Map<String, dynamic> userJson) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kAdminPrefsTokenKey, token);
    await prefs.setString(kAdminPrefsUserKey, jsonEncode(userJson));
  }

  Future<AdminUser?> loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kAdminPrefsUserKey);
    if (raw == null) return null;
    return AdminUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await http.post(Uri.parse('$_baseUrl/auth/logout'), headers: _headers).timeout(const Duration(seconds: 10));
    } catch (_) {
      // abaikan — token admin bersifat stateless (HMAC-signed), cukup hapus lokal
    }
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kAdminPrefsTokenKey);
    await prefs.remove(kAdminPrefsUserKey);
  }

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

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

  Future<AdminUser> login(String username, String password) async {
    late http.Response res;
    try {
      res = await http
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      throw ApiException('Tidak dapat terhubung ke server. Cek koneksi internet Anda.');
    }
    final body = _handle(res);
    final token = body['token'] as String;
    final userJson = body['user'] as Map<String, dynamic>;
    await _saveSession(token, userJson);
    return AdminUser.fromJson(userJson);
  }

  Future<List<GuruRingkas>> fetchGuruList() async {
    final res = await http.get(Uri.parse('$_baseUrl/guru'), headers: _headers).timeout(const Duration(seconds: 20));
    final body = _handle(res);
    final list = body['list'] as List<dynamic>;
    return list.map((e) => GuruRingkas.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// [tanggal] format "yyyy-MM-dd"
  Future<({String hari, List<AdminAbsensiRow> rows})> fetchAbsensiByDate(String tanggal) async {
    final res = await http
        .get(Uri.parse('$_baseUrl/absensi/by-date?tanggal=$tanggal'), headers: _headers)
        .timeout(const Duration(seconds: 20));
    final body = _handle(res);
    final list = body['list'] as List<dynamic>;
    return (
      hari: body['hari']?.toString() ?? '',
      rows: list.map((e) => AdminAbsensiRow.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// Simpan status absensi untuk 1 jadwal pada 1 tanggal.
  /// [statusGuru]: hadir | diganti | tidak_hadir
  Future<void> saveAbsensi({
    required String tanggal,
    required String jadwalId,
    required String statusGuru,
    String? subStatus,
    String? guruPenggantiId,
    String? keterangan,
  }) async {
    final res = await http
        .post(
          Uri.parse('$_baseUrl/absensi'),
          headers: _headers,
          body: jsonEncode({
            'tanggal': tanggal,
            'jadwalId': jadwalId,
            'statusGuru': statusGuru,
            if (subStatus != null) 'subStatus': subStatus,
            if (guruPenggantiId != null) 'guruPenggantiId': guruPenggantiId,
            if (keterangan != null) 'keterangan': keterangan,
          }),
        )
        .timeout(const Duration(seconds: 20));
    _handle(res);
  }

  /// Reset absensi ke "Belum" (hapus record).
  Future<void> deleteAbsensi({required String tanggal, required String jadwalId}) async {
    final res = await http
        .delete(Uri.parse('$_baseUrl/absensi?tanggal=$tanggal&jadwalId=$jadwalId'), headers: _headers)
        .timeout(const Duration(seconds: 20));
    _handle(res);
  }
}
