import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/providers.dart';
import 'screens/splash_screen.dart';

class AbsensiGuruApp extends StatelessWidget {
  const AbsensiGuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absensi Guru MTs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashScreen(),
      builder: (context, child) {
        // Trigger auth check on first build.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<AuthProvider>().appStart();
        });
        return child!;
      },
    );
  }
}
