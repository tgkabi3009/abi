// Basic smoke test — verifies app boots & Splash widget renders.
//
// Run with: `flutter test`
//
// Catatan: test ini TIDAK menjalankan network call (MobileApiService.ping
// di-trigger via postFrameCallback, tapi dio call akan fail di test env).
// Test hanya memverifikasi widget tree dasar ter-build tanpa exception.

import 'package:flutter/material.dart';
import 'package:flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:absensi_guru/app.dart';
import 'package:absensi_guru/providers/providers.dart';

void main() {
  testWidgets('App boots and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
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

    // Wait one frame.
    await tester.pump();

    // Verify splash UI elements are present.
    expect(find.text('Absensi Guru'), findsOneWidget);
    expect(find.text('MTs Fathin Al-Aziziyah'), findsOneWidget);
  });
}
