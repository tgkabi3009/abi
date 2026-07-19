import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/models.dart';
import 'api_client.dart';

/// Service layer untuk semua endpoint /api/mobile/*.
/// Tiap method return model atau throw ApiException.
///
/// Tidak depend on Provider — pure service.
class MobileApiService {
  MobileApiService._internal();
  static final MobileApiService instance = MobileApiService._internal();

  // === AUTH ===

  /// POST /login
  /// Body: { nik OR kodeNama, password }.
  Future<AuthResponse> login({
    String? nik,
    String? kodeNama,
    required String password,
  }) async {
    final body = <String, dynamic>{'password': password};
    if (nik != null && nik.isNotEmpty) {
      body['nik'] = nik;
    } else if (kodeNama != null && kodeNama.isNotEmpty) {
      body['kodeNama'] = kodeNama;
    } else {
      throw const ApiException('NIK atau Kode Nama wajib diisi.', 400);
    }

    try {
      final res = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiClient.instance.mobile('/login'),
        data: body,
      );
      return AuthResponse.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /logout
  Future<void> logout() async {
    try {
      await ApiClient.instance.post<Map<String, dynamic>>(
        ApiClient.instance.mobile('/logout'),
      );
    } on DioException catch (e) {
      // Logout harus tetap sukses client-side meski server gagal.
      // Provider akan clear local token regardless.
      if (kDebugMode) debugPrint('[logout] server error: ${e.message}');
    }
  }

  /// GET /me
  Future<Guru> getMe() async {
    try {
      final res = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiClient.instance.mobile('/me'),
      );
      return Guru.fromJson(res.data!['guru'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /change-password
  Future<String> changePassword({
    required String passwordLama,
    required String passwordBaru,
  }) async {
    try {
      final res = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiClient.instance.mobile('/change-password'),
        data: {
          'passwordLama': passwordLama,
          'passwordBaru': passwordBaru,
        },
      );
      final ok = res.data!['ok'] as bool;
      if (!ok) {
        throw ApiException(res.data!['error'] as String? ?? 'Gagal mengubah password.', 400);
      }
      return (res.data!['data'] as Map<String, dynamic>)['message'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // === PING (PUBLIC) ===

  /// GET /ping
  Future<PingResponse> ping() async {
    try {
      final res = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiClient.instance.mobile('/ping'),
      );
      final ok = res.data!['ok'] as bool;
      if (!ok) {
        throw ApiException(res.data!['error'] as String? ?? 'Server maintenance.', 503);
      }
      return PingResponse.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // === DASHBOARD ===

  /// GET /dashboard
  Future<DashboardResponse> getDashboard() async {
    try {
      final res = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiClient.instance.mobile('/dashboard'),
      );
      return DashboardResponse.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // === JADWAL ===

  /// GET /jadwal?hari=
  /// Return map: { 'Senin': [JadwalItem, ...], 'Selasa': [...], ... }
  Future<Map<String, List<JadwalItem>>> getJadwal({String? hari}) async {
    try {
      final res = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiClient.instance.mobile('/jadwal'),
        query: hari != null ? {'hari': hari} : null,
      );
      final raw = res.data!['jadwal'] as Map<String, dynamic>;
      return raw.map((k, v) => MapEntry(
            k,
            (v as List).map((e) => JadwalItem.fromApi(e as Map<String, dynamic>)).toList(),
          ));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /jam-pelajaran
  Future<List<JamPelajaran>> getJamPelajaran() async {
    try {
      final res = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiClient.instance.mobile('/jam-pelajaran'),
      );
      final list = (res.data!['data'] as Map<String, dynamic>)['list'] as List;
      return list.map((e) => JamPelajaran.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // === ABSENSI ===

  /// GET /absensi?tanggal=
  Future<AbsensiHarianResponse> getAbsensiHarian({String? tanggal}) async {
    try {
      final res = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiClient.instance.mobile('/absensi'),
        query: tanggal != null ? {'tanggal': tanggal} : null,
      );
      return AbsensiHarianResponse.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /absensi-bulanan?bulan=
  Future<AbsensiBulananResponse> getAbsensiBulanan({String? bulan}) async {
    try {
      final res = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiClient.instance.mobile('/absensi-bulanan'),
        query: bulan != null ? {'bulan': bulan} : null,
      );
      return AbsensiBulananResponse.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // === HARI EFEKTIF ===

  /// GET /hari-efektif?bulan=
  Future<List<HariEfektif>> getHariEfektif({String? bulan}) async {
    try {
      final res = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiClient.instance.mobile('/hari-efektif'),
        query: bulan != null ? {'bulan': bulan} : null,
      );
      final list = res.data!['list'] as List;
      return list.map((e) => HariEfektif.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // === SLIP GAJI ===

  /// GET /periode-gaji  (list ringkas)
  Future<List<SlipRingkas>> getPeriodeGaji() async {
    try {
      final res = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiClient.instance.mobile('/periode-gaji'),
      );
      final ok = res.data!['ok'] as bool;
      if (!ok) throw ApiException(res.data!['error'] as String, 400);
      final list = (res.data!['data'] as Map<String, dynamic>)['list'] as List;
      return list.map((e) => SlipRingkas.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /gaji/[id]  (detail)
  Future<SlipDetail> getSlipDetail(String id) async {
    try {
      final res = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiClient.instance.mobile('/gaji/$id'),
      );
      return SlipDetail.fromJson(res.data!['slip'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // === NOTIFIKASI ===

  /// GET /notifikasi
  Future<List<Notifikasi>> getNotifikasi() async {
    try {
      final res = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiClient.instance.mobile('/notifikasi'),
      );
      final ok = res.data!['ok'] as bool;
      if (!ok) throw ApiException(res.data!['error'] as String, 400);
      final list = (res.data!['data'] as Map<String, dynamic>)['list'] as List;
      return list.map((e) => Notifikasi.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // === DEVICE TOKEN (FCM) ===

  /// POST /device-token
  Future<int> registerDeviceToken({required String token, String platform = 'android'}) async {
    try {
      final res = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiClient.instance.mobile('/device-token'),
        data: {'token': token, 'platform': platform},
      );
      final ok = res.data!['ok'] as bool;
      if (!ok) throw ApiException(res.data!['error'] as String, 400);
      final data = res.data!['data'] as Map<String, dynamic>;
      return (data['deviceCount'] as num).toInt();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// DELETE /device-token
  Future<void> unregisterDeviceToken(String token) async {
    try {
      await ApiClient.instance.delete<Map<String, dynamic>>(
        ApiClient.instance.mobile('/device-token'),
        data: {'token': token},
      );
    } on DioException catch (e) {
      // Idempotent — ignore error
      if (kDebugMode) debugPrint('[unregisterDeviceToken] ${e.message}');
    }
  }

  // === MADRASAH INFO ===

  /// GET /pengaturan  (basic)
  Future<MadrasahInfo> getPengaturan() async {
    try {
      final res = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiClient.instance.mobile('/pengaturan'),
      );
      return MadrasahInfo.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /profil-madrasah  (extended)
  Future<ProfilMadrasah> getProfilMadrasah() async {
    try {
      final res = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiClient.instance.mobile('/profil-madrasah'),
      );
      return ProfilMadrasah.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

// re-export for debugPrint
export 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
