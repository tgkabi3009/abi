import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'config/api_config.dart';
import 'providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init — required for FCM (push notifications).
  // Jika google-services.json belum di-set, init akan throw — catch & continue
  // (push notif akan nonaktif, app tetap jalan).
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('[Firebase] init failed (push notif disabled): $e');
  }

  // Override base URL via --dart-define=API_BASE_URL=https://absensi.madrasah.sch.id
  // saat build production release. Lihat ApiConfig.kBaseUrl.
  if (ApiConfig.kBaseUrl.isEmpty) {
    throw StateError('API_BASE_URL tidak boleh kosong. Set via --dart-define atau default di api_config.dart.');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<DashboardProvider>(create: (_) => DashboardProvider()),
        ChangeNotifierProvider<JadwalProvider>(create: (_) => JadwalProvider()),
        ChangeNotifierProvider<AbsensiProvider>(create: (_) => AbsensiProvider()),
        ChangeNotifierProvider<GajiProvider>(create: (_) => GajiProvider()),
        ChangeNotifierProvider<NotifikasiProvider>(create: (_) => NotifikasiProvider()),
        ChangeNotifierProvider<MadrasahProvider>(create: (_) => MadrasahProvider()),
      ],
      child: const AbsensiGuruApp(),
    ),
  );
}
