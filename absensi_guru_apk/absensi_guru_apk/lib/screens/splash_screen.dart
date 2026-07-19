import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../config/api_config.dart';
import '../config/theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/mobile_api_service.dart';
import '../services/push_notification_service.dart';
import 'login_screen.dart';
import 'main_shell.dart';

/// Splash screen — gate pertama setelah app launch.
///
/// Flow:
/// 1. GET /ping → cek server reachable, cek force-update, cek maintenance.
/// 2. Tunggu AuthProvider.appStart() selesai (token check).
/// 3. Route ke LoginScreen (unauth) atau MainShell (auth).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = 'Memuat...';
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    setState(() => _status = 'Menghubungkan ke server...');

    // === Step 1: Ping ===
    PingResponse ping;
    try {
      ping = await MobileApiService.instance.ping();
    } catch (e) {
      setState(() {
        _error = 'Tidak dapat terhubung ke server.\n\n'
            'Periksa koneksi internet Anda atau hubungi admin madrasah.\n\n'
            'Detail: ${e.toString()}';
        _status = '';
      });
      return;
    }

    // === Step 2: Maintenance check ===
    if (ping.maintenance) {
      setState(() {
        _error = 'Server sedang dalam pemeliharaan.\n\n${ping.maintenanceMessage}';
        _status = '';
      });
      return;
    }

    // === Step 3: Force-update check ===
    final pkg = await PackageInfo.fromPlatform();
    final appVersion = pkg.version;
    if (_compareVersions(appVersion, ping.minApkVersion) < 0) {
      setState(() {
        _error = 'Versi aplikasi ($appVersion) sudah usang.\n\n'
            'Versi minimum: ${ping.minApkVersion}\n'
            'Versi terbaru: ${ping.latestApkVersion}\n\n'
            'Silakan update aplikasi melalui Play Store atau admin madrasah.';
        _status = '';
      });
      return;
    }

    // === Step 4: Wait for auth check ===
    setState(() => _status = 'Memeriksa sesi...');

    // AuthProvider.appStart() di-trigger oleh app.dart builder.
    // Tunggu sampai state bukan loading.
    // Polling sederhana — bisa juga pakai selector.
    final auth = context.read<AuthProvider>();
    while (auth.state.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!mounted) return;

    if (auth.state.isAuthenticated) {
      // Init FCM (background, jangan block navigation).
      // Safe-fail: jika Firebase belum ter-config (google-services.json belum
      // di-set), panggilan akan throw — biarkan tertangkap di catchError.
      PushNotificationService.instance.init().catchError((e) {
        if (kDebugMode) debugPrint('[Push] init skipped: $e');
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  /// Compare semver: "1.2.3" vs "1.10.0" → -1, 0, 1.
  int _compareVersions(String a, String b) {
    final pa = a.split('.').map(int.tryParse).whereType<int>().toList();
    final pb = b.split('.').map(int.tryParse).whereType<int>().toList();
    for (var i = 0; i < 3; i++) {
      final va = i < pa.length ? pa[i] : 0;
      final vb = i < pb.length ? pb[i] : 0;
      if (va < vb) return -1;
      if (va > vb) return 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.brandLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.brand, AppTheme.brandDark],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.brand.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Absensi Guru',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.brandDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'MTs Fathin Al-Aziziyah',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.neutral,
                  ),
                ),
                const SizedBox(height: 40),
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.error.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, color: AppTheme.error, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _status = 'Menghubungkan ke server...';
                      });
                      _boot();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ] else ...[
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _status,
                    style: TextStyle(fontSize: 13, color: AppTheme.neutral),
                  ),
                ],
                const SizedBox(height: 60),
                Text(
                  'v${ApiConfig.kAppVersion}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.neutral.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
