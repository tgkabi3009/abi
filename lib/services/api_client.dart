import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

/// HTTP client wrapper berbasis dio dengan:
/// - Auto-attach Authorization header untuk semua request ke /api/mobile/*
/// - 401 interceptor → trigger global callback (Provider akan listen & logout)
/// - Timeout sesuai ApiConfig
/// - Pretty error logging di debug mode
///
/// Tidak menyimpan token — token dipegang oleh StorageService dan di-pass
/// via setAuthToken/clearAuthToken oleh AuthProvider.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.kBaseUrl,
        connectTimeout: const Duration(milliseconds: ApiConfig.kConnectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConfig.kReceiveTimeout),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null && options.path.startsWith(ApiConfig.kMobilePrefix)) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          handler.next(options);
        },
        onError: (e, handler) {
          if (kDebugMode) {
            debugPrint('[API ERROR] ${e.response?.statusCode} ${e.requestOptions.path}');
            debugPrint('  message: ${e.message}');
            if (e.response?.data != null) debugPrint('  body: ${e.response?.data}');
          }
          // 401 callback
          if (e.response?.statusCode == 401 && _onUnauthorized != null) {
            _onUnauthorized!();
          }
          handler.next(e);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();

  late final Dio _dio;
  String? _authToken;
  void Function()? _onUnauthorized;

  /// Set token (dipanggil AuthProvider saat login / app start).
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Register callback untuk handle 401 (AuthProvider akan set ini).
  void setUnauthorizedHandler(void Function() callback) {
    _onUnauthorized = callback;
  }

  /// Helper: GET.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) {
    return _dio.get<T>(path, queryParameters: query, options: options);
  }

  /// Helper: POST.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Options? options,
  }) {
    return _dio.post<T>(path, data: data, options: options);
  }

  /// Helper: DELETE.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Options? options,
  }) {
    return _dio.delete<T>(path, data: data, options: options);
  }

  /// Convenience: full mobile URL prefix.
  String mobile(String path) => '${ApiConfig.kMobilePrefix}$path';
}

/// Custom exception untuk parse error response (preferred shape {ok:false,error:...}
/// atau legacy shape {error:...}) ke pesan Indonesia yang siap ditampilkan.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;

  /// Build ApiException dari DioException.
  /// Coba extract `error` field dari body (legacy & preferred shape sama di sini).
  factory ApiException.fromDio(DioException e) {
    // Network error (no response)
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        null,
      );
    }
    if (e.type == DioExceptionType.cancel) {
      return const ApiException('Request dibatalkan.', null);
    }

    final response = e.response;
    if (response == null) {
      return const ApiException('Terjadi kesalahan jaringan tidak dikenal.', null);
    }

    final data = response.data;
    String msg = 'Request gagal (HTTP ${response.statusCode}).';
    if (data is Map) {
      // Preferred: { ok: false, error: "..." }
      // Legacy:   { error: "..." }
      msg = data['error'] as String? ?? msg;
    } else if (data is String && data.isNotEmpty) {
      msg = data;
    }
    return ApiException(msg, response.statusCode);
  }
}
