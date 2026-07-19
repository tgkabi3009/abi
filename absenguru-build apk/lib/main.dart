import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/admin_api_service.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_home_screen.dart';

void main() {
  runApp(const AbsenGuruApp());
}

class AbsenGuruApp extends StatelessWidget {
  const AbsenGuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absen Guru',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _SplashGate(),
    );
  }
}

/// Cek token tersimpan saat app dibuka -> langsung ke Home kalau masih ada,
/// atau ke Login kalau belum pernah login / sudah logout.
class _SplashGate extends StatefulWidget {
  const _SplashGate();

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final guruToken = await ApiService.instance.loadToken();
    if (guruToken != null && guruToken.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      return;
    }

    final adminToken = await AdminApiService.instance.loadToken();
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => (adminToken != null && adminToken.isNotEmpty) ? const AdminHomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Icon(Icons.calendar_month_rounded, color: AppColors.gold, size: 64),
      ),
    );
  }
}
