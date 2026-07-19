import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/mobile_api_service.dart';
import '../services/storage_service.dart';

/// State management untuk auth & user session.
///
/// Lifecycle:
/// - appStart() → cek secure storage → if token: set token di ApiClient,
///   fetch /me untuk validasi → if valid: Authenticated, else: Unauthenticated.
/// - login(nik/kodeNama, password) → POST /login → cache token+guru → Authenticated.
/// - logout() → POST /logout (best-effort) → clear storage → Unauthenticated.
/// - 401 interceptor callback → auto logout.
class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    ApiClient.instance.setUnauthorizedHandler(_onUnauthorized);
  }

  AuthState _state = AuthState.initial();
  Guru? _guru;
  String? _errorMessage;

  AuthState get state => _state;
  Guru? get guru => _guru;
  String? get errorMessage => _errorMessage;

  /// Dipanggil sekali dari main.dart setelah runApp.
  Future<void> appStart() async {
    _state = AuthState.loading();
    notifyListeners();

    final token = await StorageService.instance.getToken();
    if (token == null) {
      _state = AuthState.unauthenticated();
      notifyListeners();
      return;
    }

    ApiClient.instance.setAuthToken(token);

    try {
      _guru = await MobileApiService.instance.getMe();
      _state = AuthState.authenticated();
    } catch (e) {
      if (kDebugMode) debugPrint('[Auth] appStart validate failed: $e');
      // Token invalid/expired → clear & unauth
      await StorageService.instance.clearAll();
      ApiClient.instance.setAuthToken(null);
      _state = AuthState.unauthenticated();
    }
    notifyListeners();
  }

  Future<bool> login({
    String? nik,
    String? kodeNama,
    required String password,
  }) async {
    _state = AuthState.loading();
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await MobileApiService.instance.login(
        nik: nik,
        kodeNama: kodeNama,
        password: password,
      );
      // Persist
      await StorageService.instance.setToken(res.token);
      await StorageService.instance.cacheGuru(
        id: res.guru.id,
        kodeNama: res.guru.kodeNama,
        nama: res.guru.nama,
      );
      ApiClient.instance.setAuthToken(res.token);
      _guru = res.guru;
      _state = AuthState.authenticated();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : 'Login gagal. Coba lagi.';
      _state = AuthState.unauthenticated();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _state = AuthState.loading();
    notifyListeners();

    // Best-effort: unregister FCM & call /logout
    try {
      // FCM unregister handled by PushNotificationService on logout action
      await MobileApiService.instance.logout();
    } catch (_) {
      // ignore
    }

    await StorageService.instance.clearAll();
    ApiClient.instance.setAuthToken(null);
    _guru = null;
    _state = AuthState.unauthenticated();
    notifyListeners();
  }

  void _onUnauthorized() {
    // 401 dari server — auto logout
    if (kDebugMode) debugPrint('[Auth] 401 → auto logout');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await logout();
    });
  }
}

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;

  const AuthState._({required this.isLoading, required this.isAuthenticated});

  factory AuthState.initial() => const AuthState._(isLoading: true, isAuthenticated: false);
  factory AuthState.loading() => const AuthState._(isLoading: true, isAuthenticated: false);
  factory AuthState.authenticated() => const AuthState._(isLoading: false, isAuthenticated: true);
  factory AuthState.unauthenticated() => const AuthState._(isLoading: false, isAuthenticated: false);
}
